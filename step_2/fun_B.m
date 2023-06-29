                                                                         %{
___________________________________________________________________________

 %% Read boundaries from binary img, save x-y coordinate representation.

 .  Read binary image
 .  Trace BOUNDARIES, reduce, simplify
 .  Write x-y coordinate representation of boundaries (aggregates)
___________________________________________________________________________

                                                                         %}
function fun_B

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

% minimum polygon area threshold (specified as needed), equivalent circle
rMin = 0.00125/2; % [mm]
minArea = pi*rMin^2; % [mm^2]

% scale [px/mm]
switch smpName
    case {'A','B'}
        pxScl = 57.2; % [px/mm]
    case {'C','D','E','F','G','H'}
        pxScl = 371; % [px/mm]
    otherwise
        pxScl = 1; % [px/mm] arbitrary default, has to be specified for other images
end

% tolerance interpolation for edge reduction
%   tol = 0, no reduction
%   tol = 0.001, reference, default
%   tol = 1, total reduction
tol1 = 0.005;
tol2 = 0.015;
nVrts1 = 4;     % arbitary choice of low number of vertices
nVrts2 = 3000;  % arbitary choice of high number of vertices

ignoreHoles = 0; % (1 yes, 0 no)

dirSmp = '[bin]'; % binary image files directory (in)
progInt = 10; % [%] progress interval to be printed
                                                                         %{
___________________________________________________________________________

  1. Trace boundaries and scale to mm
                                                                         %}
tic

% read image
img_orig = imread([dirSmp '/' smpName '.tif']);

% trace boundaries
B = bwboundaries(img_orig,'noholes');               % 8-connect, default
%B = bwboundaries(img_orig,4,'noholes');            % 4-connect (more aggregates, more vertices)

% update boundaries convention and units
nBnds = length(B);
for i = 1:nBnds
    
    % x,y 'inverted', y negative
    yxB = B{i}; % [px]
    xB = yxB(:,2); % [px] 'corrected'
    yB = -yxB(:,1)+size(img_orig,1);                % [px] corrected so that y is positive
    
    % scale coordinates
    xB = xB/pxScl; % [mm]
    yB = yB/pxScl; % [mm]
    
    B{i} = [xB yB];
    
end
                                                                         %{
___________________________________________________________________________

  2. Reduce, simplify, and count/store separate particles

   > reduce density (tolerance)
   > simplify boundaries
   > count and manage regions of non-zero area boundaries, manage holes
                                                                         %}

% cell of aggregate coordinates
ags = cell(nBnds,1); % trimmed later
agsH = cell(0); % cell of aggregates with holes, currently it is empty

% number of aggregates and vertices (before count)
nAgs = 0;
nAgsH = 0;
nVrtsTot = 0;

% limits
xMin = NaN;
xMax = NaN;
yMin = NaN;
yMax = NaN;

% prepare plot
%close all
figure(1), clf;
hold on

% disable warnings (enabled at the end)
%warning('off','all')
warning('off','MATLAB:polyshape:boundary3Points');
warning('off','MATLAB:polyshape:repairedBySimplify');
% warning('off','MATLAB:polyshape:boolOperationFailed');

% parameters for tolerance interpolation, assuming a linear relation between tolerence and log(number of vertices)
mTol = (tol2 - tol1) / (log(nVrts2)-log(nVrts1));
bTol = tol1 - mTol * log(nVrts1);

% boundary-wise
for i = 1:nBnds
    
    xyB = B{i}; % [mm] closed
    xB = xyB(:,1);
    yB = xyB(:,2);
    
    % criterion of area and minimum vertices (closed polygon)
    if length(xB) > 3 && polyarea(xB,yB) > 1e-10
        
        % plot BEFORE reduction processes
        plot(xB,yB, 'k');
        
        % tolerance (interpolation) for reduction
        nVrtsi = length(xB) - 1;            % number of vertices = number of points -1
        redTol = mTol * log(nVrtsi) + bTol;
        
        % reduce: reduce the density of points in xy using Ramer-Douglas-Peucker line simplification algorithm
        %         removes points along straight lines, leaves points where the line curves
        xyR = reducepoly(xyB, redTol); % closed
        polR = polyshape(xyR);
        
        % list reduction in vertices
       %nVrtsi2 = length(xyR(:,1)) - 1;
       %disp([num2str(i) ' ' num2str(redTol) ' ' num2str(nVrtsi) ' ' num2str(nVrtsi2) ' ' ]);
       %if i == 5000, return, end
        
        % simplify: remove duplicate vertices and boundary intersections
        %           maintains boundary shape but may split polygon into regions
        %           removes boundaries with less than three points
        polS = simplify(polR,'KeepCollinearPoints',0);
        
        % count and manage regions (aggregates)
        polSregs = regions(polS);
        nReg = polS.NumRegions;

        % region-wise
        for j = 1:nReg

            % region (aggregate)
            regj = polSregs(j);
            
            % holes or no holes?
            nHoles = regj.NumHoles;
            
            if nHoles > 0 && ignoreHoles
                % region is replaced by first internal region, because polyshape defines the outermost boundary as the exterior bound of a solid region
                intRegs = regions(regj);
                regjXY = intRegs(1).Vertices; % 'open' 
                prevFirstNan = find(isnan(regjXY(:,1)),1)-1;    % the row index of the first NaN
                firstRegXY = regjXY(1:prevFirstNan,:);
                regj = polyshape(firstRegXY);
            end
            
            if nHoles == 0 || ignoreHoles
                
                % obtain x-y coordinates
                xyReg = regj.Vertices;        % open
                x = [xyReg(:,1); xyReg(1,1)]; % closed
                y = [xyReg(:,2); xyReg(1,2)]; % closed
                xy = [x y]; % closed
                
                % criterion of area and minimum vertices (closed polygon)
                if length(x) > 3 && polyarea(x,y) > minArea
                    
                    % count aggregate and update cell
                    nAgs = nAgs+1;
                    ags{nAgs} = xy;
                    
                    % update total number of vertices
                    nVrtsTot = nVrtsTot+length(x)-1;
                    
                    % update limits
                    xMin = min(xMin, min(x));
                    xMax = max(xMax, max(x));
                    yMin = min(yMin, min(y));
                    yMax = max(yMax, max(y));
                    
                    % plot AFTER reduction processes
                    plot(x,y, 'r')

                    % % plot 'live'
                    % if mod(i,50) == 0 || i == nAgs
                    %     title(['nAgs = ' num2str(nAgs)])
                    %     axis equal                
                    %     drawnow limitrate
                    % end
                    
                    % % ALERT
                    % polytest = polyshape(x,y);
                    % nRegInt = polytest.NumRegions;
                    % if nRegInt ~= 1
                    %     disp('alert')
                    % end
                
                end
                
            elseif nHoles > 0           % if there are holes and consider them, C or H shaped, 'open' vertices
                
                % obtain x-y coordinates and manage separately
                xyRegH = regj.Vertices; % 'open', but with NaN divisions
                xH = xyRegH(:,1); % 'open'
                yH = xyRegH(:,2); % 'open'

                % count aggregate and update cell (special)
                nAgsH = nAgsH+1;
                agsH{nAgsH} = xyRegH;

                % update total number of vertices
                nVrtsH = length(xyRegH(:,1))-sum(isnan(xyRegH(:,1)));
                nVrtsTot = nVrtsTot+nVrtsH;

                % update limits
                xMin = min(xMin, min(xH));
                xMax = max(xMax, max(xH));
                yMin = min(yMin, min(yH));
                yMax = max(yMax, max(yH));

                % plot (holes)
                plot(regj)

                % alert holes
                disp(' ')
                disp([' * ALERT, holes i=' num2str(i) ' (' num2str(nHoles) ' holes). Saved separately, correct manually']);
                disp(' ')
            
            end
        end
    end
    
    % display progress
    if mod(i,round(nBnds*progInt/100)) == 0 || i == nBnds
        disp(['   ' smpName ', ' num2str(round(i/nBnds*100)) '%']);
    end
    
end

% trim cell to actual number of aggregates
ags = ags(1:nAgs);
clear B

% maximum dimensions
lx = xMax-xMin;
ly = yMax-yMin;

                                                                         %{
___________________________________________________________________________

  3. Write aggregate coordinates and save figure
                                                                         %}

% output folder
dirOut = smpName;
if ~exist(dirOut,'dir'), mkdir(dirOut); end

% save aggregate coordinates following a conventional format
% numbered aggregates, NaN line after every aggregate including the last
xysAg = [];
divLine = [NaN NaN NaN];
for i = 1:nAgs
    xy = ags{i}; % closed
    zeroCol = zeros(length(xy),1);
    zeros_xy = [zeroCol+i xy];                                             % number of the aggregate and its coordinates
    xysAg = [xysAg; zeros_xy; divLine];                                    %#ok<AGROW>
end
save([dirOut '/AG_xy ' smpName '.txt'],'xysAg','-ascii');

if nAgsH > 0
    % save aggregates with holes
    xysAgH = [];
    for i = 1:nAgsH
        xyH = agsH{i}; % closed
        zeroCol = zeros(length(xyH),1);
        zeros_xy = [zeroCol+i xyH];
        xysAgH = [xysAgH; zeros_xy; divLine];                              %#ok<AGROW>
    end
    save([dirOut '/AG_xy ' smpName ' HOLES.txt'],'xysAgH','-ascii');
end

% save dummy info file
save([dirOut '/' smpName '. tol=' num2str(tol1) '-' num2str(tol2) ', nAgs=' num2str(nAgs) ', nVrts=' num2str(nVrtsTot) ' [lx=' num2str(lx) 'mm, ly=' num2str(ly) 'mm] .txt'],'nAgs','-ascii');


%
%   Save figure and finalize
%

% title, labels and proportions
title([smpName '. nAgs = ' num2str(nAgs) ', tol = ' num2str(tol1) '-' num2str(tol2) ', nVrts = ' num2str(nVrtsTot) ' [lx = ' num2str(lx) 'mm, ly = ' num2str(ly) 'mm]'])
xlabel('x [mm]'); ylabel('y [mm]')
axis equal tight
hold off
saveas(gcf,[dirOut '/' smpName '. tol=' num2str(tol1) '-' num2str(tol2) ', nAgs=' num2str(nAgs) ', nVrts=' num2str(nVrtsTot) ' [lx=' num2str(lx) 'mm, ly=' num2str(ly) 'mm].png']);

% enable warnings
%warning('on','all')
warning('on','MATLAB:polyshape:boundary3Points');
warning('on','MATLAB:polyshape:repairedBySimplify');
% warning('on','MATLAB:polyshape:boolOperationFailed');

% display summary
disp(' ')
disp(['   ' num2str(nAgs) '/' num2str(nBnds) ' (nonzero) aggregates/initial boundaries'])
disp(['   ' smpName ', ' num2str(toc) ' seconds.'])
disp(' ')

end