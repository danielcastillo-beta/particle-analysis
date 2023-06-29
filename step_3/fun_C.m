                                                                         %{
___________________________________________________________________________

 %% Analysis of aggregate coordinates

 .  Read coordinate data (AG_xy)
 .  Fill table of properties, i.e. number of vertices, area, max. radius
 .  Estimate particle sieve size (charLen) and rotation*
 .  Rewrite files
    
 *  Assumptions for estimation of charLen and rotation:
  - Aggregates are convex. Most of the times a reasonable approximation
    is obtained anyway.
  - (Corrected with poly centroid) Aggregate coordinates are more or
    less evenly distributed along their edges. This affects how
    similar/different is the centre of the coordinates to the actual
    centre of mass of the particle
___________________________________________________________________________

                                                                         %}
function fun_C

%
%   Parameters
%

smpName = 'A';
% smpName = 'B';

% smpName = 'C';
% smpName = 'D';
% smpName = 'E';
% smpName = 'F';
% smpName = 'H';

% visualization type and potential convex polygon warning (i.e. non-representative charLen)
visType = 0;
      ... 0, no visualization or convex alert whatsoever
      ... 1, visualization, stop at each polygon                            %
      ... 2, visualization, stop at potential convex polygons only          %  [1-3] plot & store potential convex polygons
      ... 3, visualization, non-stop                                        %

% appropriate file directory (out)
dirNames =                    {'1','2','3','4','5','6','7','8'};
[TF,index] = ismember(smpName,{'A','B','C','D','E','F','G','H'});
if TF
    dirName = dirNames{index};
else
    dirName = '0'; % default directory name
end

%%% Sieve series [mm]
%       #3� #5  #10 #18 #35  #60  #120   #230                               % QF experimental/simplified sieve series
%        |   |   |   |   |    |     |      |
svs = [ 5.6  4   2   1  0.5  0.25  0.125  0.063 0.04  0.02  0.01  0.005  0.0025  0.00125  0.0006  0.0003 ]; % sieve size [mm]

%%% Specimen coordinates [mm], closed

switch smpName
    case {'A'} % [mm]
        sx = [-2.89,-2.76,-2.59,-2.43,-2.43,-2.43,-2.28,-2.06,-2.01,-1.75,-1.67,-1.7,-1.46,-1.5,-1.77,-1.74,-1.63,-1.21,-1.11,-0.96,-0.79,-0.53,-0.22,0.1,0.53,0.79,0.96,1.32,1.54,1.93,2.11,2.41,2.85,3.13,3.44,3.74,4.04,4.38,4.84,5.19,5.52,5.49,5.22,4.91,4.84,4.78,4.82,4.5,4.35,4.18,3.82,3.77,3.63,3.5,3.39,2.98,2.18,1.54,1.13,0.46,0.34,-0.02,-0.09,-0.46,-0.83,-0.93,-1.16,-1.6,-1.69,-1.97,-2.41,-2.73,-2.8,-3.03,-3.09,-3.25,-3.41,-3.22,-3.25,-3.52,-3.91,-3.94,-4.29,-4.52,-4.86,-4.86,-5.26,-5.52,-5.5,-5.43,-5.12,-5.25,-5.01,-4.99,-4.82,-4.82,-4.62,-4.65,-4.64,-4.55,-4.42,-4.35,-4.01,-3.71,-3.44,-3.18,-2.89]; % [mm]
        sy = [-4.71,-4.57,-4.44,-4.31,-3.97,-3.78,-3.67,-3.39,-3.21,-3.26,-3.06,-2.83,-2.6,-2.32,-2.3,-2.07,-1.81,-1.8,-1.63,-1.64,-1.8,-1.91,-1.81,-1.84,-1.78,-1.84,-1.22,-1.17,-0.99,-0.97,-1.09,-0.99,-0.99,-0.87,-0.8,-0.98,-1,-0.88,-0.92,-0.8,-0.6,4.16,4.46,4.53,4.55,4.66,4.82,4.82,4.82,4.82,4.76,4.55,4.5,4.34,4.18,4.09,4.3,4.17,3.85,3.73,3.82,3.83,3.7,3.6,3.58,3.47,3.48,3.24,2.98,2.84,2.78,2.24,1.85,1.57,1.29,1.04,1.03,0.85,0.65,0.72,0.63,0.46,0.44,0.11,-0.29,-0.6,-1.08,-1.67,-1.92,-2.08,-2.05,-2.19,-2.86,-3.3,-3.28,-3.52,-3.9,-4.08,-4.64,-4.76,-4.74,-4.63,-4.63,-4.58,-4.66,-4.82,-4.71]; % [mm]

    case {'B'} % [mm]
        sx = [0.22,3.01,3.03,5.34,5.49,5.52,5.47,5.41,5.26,5.25,5.45,5.48,5.51,5.39,5.2,5.2,5.29,5.29,5.26,5.35,5.56,5.64,5.43,5.15,5.14,5.07,5.05,4.99,4.68,4.5,4.48,4.2,3.99,3.8,3.49,3.35,3.25,3.05,2.7,2.27,2.21,1.85,1.69,1.43,1.27,1.28,1.12,0.98,0.85,0.52,0.19,-0.14,-0.28,-0.61,-0.78,-0.81,-1.04,-1.08,-1.32,-1.52,-1.91,-2.12,-2.36,-2.54,-2.67,-2.66,-2.92,-3.22,-3.35,-4.04,-4.54,-4.63,-5.08,-5.53,-5.55,-5.2,-5.44,-5.56,-5.64,-4.97,-3.61,-2.95,-2.44,-2.29,-1.86,-1.87,-1.74,-1.64,-1.39,-1.18,-1,-0.52,-0.31,-0.33,-0.08,0.22]; % [mm]
        sy = [-3.55,-3.56,-4.46,-4.46,-4.27,-3.94,-3.63,-3.28,-3.03,-2.84,-2.66,-2.3,-1.79,-1.4,-1.22,-1.05,-0.94,-0.33,0.05,0.22,0.57,0.81,1.16,1.48,2.16,2.74,3.08,3.3,3.54,3.56,3.78,3.86,3.85,4,4.11,4.06,4.15,4.14,4.33,4.31,4.39,4.46,4.44,4.32,4.33,4.18,4.18,3.94,3.67,3.51,3.39,3.22,3.25,3.27,3.18,2.6,2.59,2.73,2.58,2.36,2.1,2.18,2.22,2.47,2.34,1.92,1.87,1.62,1.79,2.06,2.54,2.4,2.37,2.11,1.85,1.38,1.19,0.71,0.47,-0.2,-0.3,-0.65,-0.66,-0.61,-0.7,-0.93,-1.47,-1.81,-2.14,-2.15,-2.44,-2.67,-2.94,-3.2,-3.46,-3.55]; % [mm]

    case {'C','D','E','F','G','H'}
        sx = [-2.1,2.1,2.1,-2.1,-2.1]; % [mm]
        sy = [-1.4,-1.4,1.4,1.4,-1.4]; % [mm]

    otherwise
        sx = [-5,5,5,-5,-5]; % [mm]
        sy = [-5,-5,5,5,-5]; % [mm]
end

% folders
dirCrd = '[AG_xy]'; % coordinate files directory (in)

% additional
dirConvx = 'convxPolWarn'; % potential convex polygon directory (out)
progInt = 10; % progress interval, percentage
intFig = 1; % figure number for polygon plot
cMinMax = 1; % Y/N. when saving, center polygon coordinates around 0 according to max/min coords

% number of diameters (to estimate charLen). Needs to be even
nDiam = 30; % using higher than mg default, since coordinates are external

                                                                         %{
...........................................................................
                                                                         %}
tic

disp(' ')
disp(' � '); disp([' �   Specimen ' smpName ':']); disp(' � ');
disp(' ')

% _________________________________________________________________________
%   
%  1. Read polygon coordinates, build ags cell, count nAgs

disp('   Reading polygon coordinates... ') 

% read polygon coordinate file
xysAg_ext = load([dirCrd '/AG_xy ' smpName '.txt'], '-ascii');

% number of aggregates
%nAgs = max(xysAg_ext(:,1)); % crit A. First column of xysAg_ext contains numbered aggregates
nAgs = sum(isnan(xysAg_ext(:,1))); % crit B. NaN-based, aggregate numbering in col.1 not needed

% cell containing polygon coordinates
ags = cell(nAgs,1);

% to center coordinates
xMin = NaN;
xMax = NaN;
yMin = NaN;
yMax = NaN;

% polygon-wise. read and separate polygon coordinates
lnA = 1; % current nPol first line
lnB = 1; % next div line
for i = 1:nAgs
    
    if i < nAgs
        %lnB = find(xysAg_ext(:,1)==i+1,1)-1; % crit. A, nAgs numbered in first column
        lnB = lnA+find(isnan(xysAg_ext(lnA:end,1)),1)-1; % crit. B, NaN-based
    elseif i == nAgs
        lnB = size(xysAg_ext,1);
    end

    % read closed polygon, add to the cell
    x = xysAg_ext(lnA:lnB-1, 2);                       % the first column is index
    y = xysAg_ext(lnA:lnB-1, 3);
    ags{i} = [x y]; % closed
    
    % update line
    lnA = lnB+1;
    
    % update the range of area containing aggregates, to center coordinates
    xMin = min(xMin, min(x));
    xMax = max(xMax, max(x));
    yMin = min(yMin, min(y));
    yMax = max(yMax, max(y));
    
end
                                                                         %{
___________________________________________________________________________

 2. Table - Polygon info

    Columns:

    1. agID - 1:nAgs
    2. nVrt - number of vertices
    3. area - particle area [mm�]
    4. rMax - max. particle radius [mm]
    5. zero
    6. charLen - particle sieve size [mm]
    7. svRet   - sieve opening retaining the particle [mm]
    8. agRot   - aggregate rotation [rad]
                                                                         %}
disp('   Building table with polygon info... ')

tableAg = zeros(nAgs,8);

% -------------------------------------------------------------------------
% 2.1  Vertices, area, rMax (first/last coordinate)

% x-y centre coordinates of the polygons (not sorted)
cxyAgs = zeros(nAgs,2);

% polygon-wise
for i = 1:nAgs

    xy = ags{i}; % closed
    x = xy(:,1);
    y = xy(:,2);

    % 2. nVrt 
    nVrt = length(x)-1;                                                     % number of vertices = number of points - 1
    tableAg(i,2) = nVrt;                                                    % Table, Col. 2

    % 3. area (not yet sorted)
    tableAg(i,3) = polyarea(x,y);                                           % Table, Col. 3

    % 4. rMax + identify rMax index
    
    % centroid coordinates and update
   %cx = mean(x(1:end-1));
   %cy = mean(y(1:end-1));
    poly = polyshape(x,y);
    [cx,cy] = centroid(poly);
    cxyAgs(i,:) = [cx cy];
    
    % radii
    radii = zeros(nVrt,1);
    for j = 1:nVrt
        radii(j) = sqrt((x(j)-cx)^2+(y(j)-cy)^2);                           % the radius equals to the distance between point i to the centroid
    end
    [rMax,index] = max(radii);
    tableAg(i,4) = rMax;                                                    % Table, Col. 4
    
    % make rMax vertex first/last coordinate                                % reset the order of the points, by placing the current max-radius point til end to the upper part
    x = [x(index:end-1);x(1:index)]; % was closed. keeps closed
    y = [y(index:end-1);y(1:index)]; % was closed. keeps closed

    % update polygon in cell, now in this cell the aggregate points are in the order of decreasing radius
    ags{i} = [x,y];

end

% -------------------------------------------------------------------------
% 2.2  Sort table, cell (ags) and cxyAgs by area. Number aggregates

[~,index] = sort(tableAg(:,3),'descend'); % Col. 3, area
tableAg = tableAg(index,:);
ags = ags(index);
cxyAgs = cxyAgs(index,:);

tableAg(:,1) = (1:nAgs)';                                                   % Table, Col. 1, after sorting by area reset the aggregate ID

% -------------------------------------------------------------------------
% 2.3  Find rotation from horizontal, calculate charLen, svRet, agRot

nSvs = length(svs);                                                         % total number of sieves

% clarification
switch visType, case {1,2}
    disp('   To continue to the next polygon, click on the Figure and press any key.')
    disp('   To stop, click on the Command Window and press Ctrl+C'); disp(' ')
end

% polygon convex warning directory
switch visType, case {1,2,3}
    if ~exist(dirConvx,'dir'), mkdir(dirConvx); end
end

% polygon-wise
for i = 1:nAgs

    xy = ags{i}; % closed, 'rotated': angle unknown
    x = xy(:,1);
    y = xy(:,2);

    % rMax
    rMax = tableAg(i,4);

    % x-y centre coordinates of the polygons
   %cx = mean(x(1:end-1));
   %cy = mean(y(1:end-1));
    cx = cxyAgs(i,1);
    cy = cxyAgs(i,2);

    % move the aggregate centroid to the origin
    x = x-cx;
    y = y-cy;

    % plot rotated, centred polygon + rMax
    switch visType, case {1,2,3}
        figure(intFig); clf                                               %
        subplot(1,2,1); hold on                                           %
        plot(x,y, 'k')                                                    %
        plot([0,x(1)],[0,y(1)], 'color',[.75,.75,.75])                    % since aggregates have been sorted, the first one has max radius
        title(['nDiam = ' num2str(nDiam)])                                %
        xlabel('x [mm]'); ylabel('y [mm]')                                %
        axis equal                                                        %
    end

    %%% Calculate diameters by intersection with rotating line

    % table with directional angle info (theta, diameters)
    thetaDiams = zeros(nDiam,4);

    % horizontal line
    canon = sqrt(rMax^2+rMax^2);                                          % now put the max radius to the horizontal/x axis
    xd = [-1,1]*canon;
    yd = [0,0];

    % rotation matrix
    thetaRot = pi/nDiam;                                                  % 6 degrees
    R = [cos(thetaRot),-sin(thetaRot);sin(thetaRot),cos(thetaRot)];       % counter-clockwise

    % rotate the line and intersect the polygon to find diameters
    thetaj = 0;
    nIntMax = 0;
    for j = 1:nDiam

        % plot diameters
        switch visType, case {1,2,3}                                      %
            plot(xd,yd, ':','color',[.7 .7 .7])                           %
        end                                                               %

        % current theta
        thetaDiams(j,1) = thetaj;                                         % write the current theta into table

        % intersection segment and length METHOD 1
        if thetaj/pi == 0.5 % 90 degrees, vertical line
            xd = [0 0];
            % for good conditining. otherwise i.e. xd = [1.62630325872826e-19,-1.62630325872826e-19],
            % because we arrive here by rotating the line, and then polyxpoly does not work for some
        end
        [xint,yint] = polyxpoly(x',y',xd,yd);
        
        % % intersection segment and length METHOD 2 (takes longer...)
        % xy_pol = polyshape(x,y);        
        % [xySegIn,~] = intersect(xy_pol,[xd; yd]');
        % %[xySegIn,~] = intersect(xy_pol,polyshape(xd',yd'));
        % xint = xySegIn(:,1);
        % yint = xySegIn(:,2);
        
       %dj = sqrt((yint(2)-yint(1))^2+(xint(2)-xint(1))^2);                 % old, 'strict'
        dj = sqrt((max(yint)-min(yint))^2+(max(xint)-min(xint))^2);         % extended, 'relaxed'

        % diameter at current angle
        thetaDiams(j,2) = dj;

        % diameter at perpendicular angle
        if j > nDiam/2
            jPerp = j-nDiam/2;
        else
            jPerp = j+nDiam/2;
        end
        thetaDiams(jPerp,3) = dj;

        % update theta
        thetaj = thetaj + thetaRot;
        if thetaj > pi/2
            thetaj = thetaj-pi;
        end

        % line rotation
        line = R*[xd;yd];
        xd = line(1,:);
        yd =line(2,:);

        % number of intersections for potential non-convex warning
        nIntMax = max(nIntMax, size(xint,1));

    end

    %%% Rotate polygon to 'most horizontal' position.

    % criteria
   %[~,index] = min(thetaDiams(:,2)); % A. minimum diameter to vertical
   %[~,index] = max(thetaDiams(:,3)); % B. maximum diameter to horizontal
    thetaDiams(:,4) = thetaDiams(:,2)-0.1*thetaDiams(:,3);                       % vertical diameter minus 10% of the horizontal diameter, finding the horizontal place by searching for the angle where max difference is found of two orthogonal diameters
    [~,index] = min(thetaDiams(:,4)); % C. minimize weighted combination (cross)

    % 'optimum' angle
    thetaOptim = thetaDiams(index,1);

    % rotate counter-clockwise to align optimum angle vertically
    thetaAlign = pi/2-thetaOptim;
    if thetaAlign > pi/2
        thetaAlign = thetaAlign - pi;
    end

    R = [cos(thetaAlign),-sin(thetaAlign);sin(thetaAlign),cos(thetaAlign)]; % counter-clockwise
    xyRot = R*[x';y'];
    x = xyRot(1,:)';
    y = xyRot(2,:)';

    %%% Calculate the characteristic length and update table

    charLen = max(y)-min(y); % height of aggregate in 'most horizontal' position

    % 6. charLen
    tableAg(i,6) = charLen;                                                 % Table, col 6

    % 7. svRet
    if charLen < svs(end)
        svRetNo = 0;
        svRet = NaN;
    else
        svRetNo = find(charLen>=svs,1);
        svRet = svs(svRetNo);
    end
    tableAg(i,7) = svRet;                                                   % Table, col 7

    % 7. agRot
    agRot = -thetaAlign;
    tableAg(i,8) = agRot;                                                   % Table, col 8
    
    % display progress
    if mod(i,round(nAgs*progInt/100)) == 0 || i == nAgs                     % display the progress if the number of aggregate i reaches every 10% of the total number of aggregates 
       disp(['   | ' num2str(round(i/nAgs*100)) '%']);
    end

    switch visType, case {1,2,3}

        % plot diameters with optimum criterium (subplot 1)               %
        dmx = canon*cos(thetaOptim);                                      %
        dmy = canon*sin(thetaOptim);                                      %
        plot([-dmy,dmy],[dmx,-dmx], 'r') % horiz. diam. 'max'             %
        plot([-dmx,dmx],[-dmy,dmy], 'm--') % vertical diam. 'min'         %
        hold off                                                          %
                                                                          %
        % plot horizontal aggregate and charLen (subplot 2)               %
        subplot(1,2,2); hold on                                           %
        plot(x,y, 'k')                                                    %
        plot([0;0],[min(y);min(y)+charLen], 'b.:')                        %
                                                                          %
        % plot previous/retaining sieve, left/right                       %
        if svRetNo == 0                                                   %
            plot( [min(x) min(x)], [-svs(nSvs)/2 svs(nSvs)/2], 'ch-' )    % positive and negative half of the sieve size
        elseif svRetNo == 1                                               %
            plot( [max(x) max(x)], [-svRet/2 svRet/2], 'ch-' )            %
        else                                                              %
            plot( [min(x) min(x)], [-svs(svRetNo-1)/2 svs(svRetNo-1)/2], 'ch-' )
            plot( [max(x) max(x)], [-svRet/2, svRet/2], 'ch-' )           % within the aggregate diameter on x axis, show the sieve range on y axis (min diameter of the aggregate)
        end                                                               %
                                                                          %
        % labels                                                          %
        text(0,0,['\theta = ' num2str(tableAg(i,8)*180/pi) '�' ], 'VerticalAlignment','bottom' )
        text(0,0,['charLen = ' num2str(max(y)-min(y)) ' mm' ], 'VerticalAlignment','top' )
        title(['Polygon ' num2str(i) ' / ' num2str(nAgs)])                %
        xlabel('x [mm]'); ylabel('y [mm]')                                %
        axis equal                                                        %
        hold off                                                          %
                                                                          %
        % save potential convex polygon                                   %
        if nIntMax > 2                                                    % if the number of intersection points made by the rotated diameter and aggregate exceeds 2, the aggregate is possibly convex
            disp(['   Specimen ' smpName ' | Polygon ' num2str(i) ' may be non-convex. check charLen'])
            saveas(gcf,[dirConvx '/sp' smpName ' - pol' num2str(i) '.png'])
            switch visType, case 2, pause; end                            %
        end                                                               %
        switch visType, case 1, pause; end                                %
    end

end

% scale factor for inflation
sep = 0.01; % equal to minimum polygon separation in mg function [mm]
toAdd = sep/2; % mm to add radially

% polygon-wise, list where centroid is out of polygon
cxyOut = {};
areaOut = 0;
for i = 1:nAgs
    
    xy = ags{i}; % closed
    x = xy(:,1);
    y = xy(:,2);
    
    % centroid coordinates
    cx = cxyAgs(i,1);
    cy = cxyAgs(i,2);
    
    % scaled coordinates for inflation
    rMax = tableAg(i,4);
    fSep = 1+toAdd/rMax; % scale factor for separation
    xScl = (x-cx)*fSep+cx;
    yScl = (y-cy)*fSep+cy;
    
    cxyIn = inpolygon(cx,cy,xScl,yScl);
    if ~cxyIn
        cxyOut = [cxyOut, num2str(i)]; %#ok<AGROW>
        areaOut = areaOut + tableAg(i,3);
    end
    
end
if areaOut ~= 0
    cxyOutStr = join(cxyOut,','); % 1�1 cell array
    cxyOutStr = cxyOutStr{1}; % cell
end


% _________________________________________________________________________
% 
%  3. Save coordinates, table, center and specimen coordinates

disp(' '); disp('   Saving files... ')

% create specimen directory
if ~exist(dirName,'dir'), mkdir(dirName); end

% to center dynamically
lxAbs = xMax-xMin;
lyAbs = yMax-yMin;

%%% Polygon coordinate file (aggregates)

xysAg = NaN(sum(tableAg(:,2))+2*nAgs, 3); % NaN lines sep + closed polygons
for i = 1:nAgs

    xy = ags{i}; % closed
    x = xy(:,1);
    y = xy(:,2);

    switch cMinMax, case 1 % center dynamically
        x = x-xMin-lxAbs/2;
        y = y-yMin-lyAbs/2;
    end

    % row index numbers. nanRow + polygons are closed
    nVrt = tableAg(i,2);
    vrtA = sum(tableAg(1:i-1,2)) + 2*(i-1) + 1;
    vrtB = vrtA + nVrt;

    % add polygon to xysAg
    nAgVct = zeros(nVrt+1,1)+i;
    xysAg(vrtA:vrtB,:) = [nAgVct x y];

end

% save polygon coordinate list files
save([dirName '/AG_xy.txt'],'xysAg','-ascii');

%%% Centre coordinates

switch cMinMax, case 1
    cxyAgs(:,1) = cxyAgs(:,1) - xMin - lxAbs/2;
    cxyAgs(:,2) = cxyAgs(:,2) - yMin - lyAbs/2;
end

save([dirName '/AG_xyc.txt'],'cxyAgs','-ascii');

%%% Save specimen coordinates and table

xySp = [sx' sy'];
save([dirName '/sp_xy.txt'], 'xySp', '-ascii');
save([dirName '/AG_table.txt'],'tableAg','-ascii');

disp(' ')
disp(['   Specimen ' smpName ', processing time ' num2str(toc/60) ' minutes. ']);
disp(' ')

% xtra
disp(['   Specimen area: ' num2str(polyarea(sx,sy)) ' mm�'])
disp(['   agFrac = ' num2str(100*sum(tableAg(:,3))/polyarea(sx,sy)) '%'])
disp(['   Total vertices: ' num2str( sum(tableAg(:,2)) )])
disp(['   Smallest sieve size: ' num2str( min(tableAg(:,6)) ) ' mm'])
disp(' ')

if areaOut ~= 0
    disp([' * Centroid out of polygon, nAgs = ' cxyOutStr])
    fileID = fopen([dirName '/(' smpName '-' dirName '). nAgs centroid out of polygon.txt'],'wt');
    fprintf(fileID, cxyOutStr);
    fclose(fileID);
    disp(['   Extra area to remove (aggregates centroid out of polygon): ' num2str(areaOut) ' mm^2' ]);
    disp(' ')
end

% info file
save([dirName '/(' smpName '-' dirName '). nAgs=' num2str(nAgs) ', agFrac=' num2str(100*sum(tableAg(:,3))/polyarea(sx,sy)) '%, spAarea=' num2str(polyarea(sx,sy)) ' mm�, nVrts=' num2str( sum(tableAg(:,2)) ) ', smallest sieve size ' num2str( min(tableAg(:,6)) ) 'mm.txt'],'nAgs','-ascii');


end