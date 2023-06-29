                                                                         %{
___________________________________________________________________________

 %% Create binary/thresholded file from the original (raw) image.

 .  Read original
 .  Apply image processes as needed (adjustment, noise reduction...)
 .  Apply threshold and fill holes in binary image
 .  Calculate percentages of areas in binary image, save results and images
___________________________________________________________________________

                                                                         %}
function [h50T,h50F] = fun_A(thres, sigmaFFC)

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

ext = '.tif'; % format extension of sample images 

%%% Set threshold value (manual mode)

switch nargin, case 0 
    switch smpName
        case {'A'}
            thres = 114;
        case {'B'}
            thres = 111;
        case {'C','D','E','F','H'}
            thres = 146;
        case {'G'}
            thres = 125;
            sigmaFFC = 35; % FFC parameter, if applicable
        otherwise
            thres = -1; % default threshold will be used
    end
end

%%% Image processes/'filter' process, order as needed. Processes can be used more than once

imgIters = {'ori','adj','med','thr','fll'};

         ... ori (imread): reads original image. Must be first
         ... adj (imadjust): histogram adjustment, saturates bottom/top 1% of pixels, increasing contrast
         ... adjP (imadjust): maps intensity values between 0 and *peak* (cut-off histogram before maximum intensity)
         ... med (medfilt2): noise reduction via median filtering, output pixels contain median value in 3-by-3 neighborhood around the pixel
         ... FFC (imflatfield): flat field correction, corrects shades i.e. circular shades in corners
         ... hEq (histeq): histogram equalization, transforms a grayscale image so that output histogram has 64 bins and is approximately flat
         ... thr (imbinarize): binary image, all values above threshold replaced with 1s and all other values 0s.
         ... fll (imfill): fills holes in the grayscale image. A hole is an area of dark pixels surrounded by lighter pixels.


dirSmp = '[smp]'; % raw image files directory (in)

closeFigs = 0; % close figures after plotting (1 yes, 0 no)
dirHstTxt = 'hist txt'; % histogram-txt subdirectory (out)

% _________________________________________________________________________

%
%   Read original image and apply 'filter' processes in order
%

tic

% cell array of images, to store the original and filtered images
nIter = length(imgIters);
imgCell = cell(nIter,1);

% read and store original image
img_orig = imread([dirSmp '/' smpName ext]);
imgCell{1} = img_orig;

% use default threshold if needed, which is calculated by the Otsu method
if thres == -1
    thres = graythresh(img_orig)*255;
end

% apply image processes progressively as per imgIters
for i = 2:nIter
    
    % unprocessed image
    img_A = imgCell{i-1};
    
    % perform image process
    procLbl = imgIters{i};
    switch procLbl
        
        case {'adj'} % adjust histogram
            img_B = imadjust(img_A);
        
        case {'med'} % 2-D median filtering (noise reduction)
            img_B = medfilt2(img_A);            % [3 3] default window
           %img_B = medfilt2(img_A, [5 5]);     % [5 5] larger window
        
        case {'thr'} % threshold/binary image
            img_B = imbinarize(img_A,thres/255);
        
        case {'fll'} % fill holes
            img_B = imfill(img_A,'holes');      % 4-connect, default 
           %img_B = imfill(img_A,8,'holes');    % 8-connect
            
        
        case {'adjP'} % cut-off histogram at maximum intensity
            
            % find bin of maximum intensity (ignoring extremes at 0,255)
            [counts,binLocations] = imhist(img_A);
            [~,index] = max(counts(2:end-1));
            binPeak = binLocations(index);
            
            % cut-off histogram                        
            img_B = imadjust(img_A,[0 binPeak/255]); %  maps intensity values between 0 and *peak*
            
        case {'FFC'} % 2D image flat field correction
            img_B = imflatfield(img_A,sigmaFFC);
        
        case {'hEq'} % histogram equalization
            img_B = histeq(img_A);
    
    end
    
    % update name if applicable, to include also the applied filter parameter
    switch procLbl
        case {'FFC'}
            imgIters{i} = [procLbl num2str(sigmaFFC)];
        case {'thr','fll'}
            imgIters{i} = [procLbl num2str(thres)];
    end
    
    % store processed image
    imgCell{i} = img_B;
    
end

% from histograms of 2 bins, calculate higher 50% area of last two processed images, commonly 'thr' and 'fll'
[countsT,~] = imhist(imgCell{end-1},2);
[countsF,~] = imhist(imgCell{end},2);
h50T = countsT(2)/sum(countsT)*100;
h50F = countsF(2)/sum(countsF)*100;

%
%   Plot images and histograms, save
%

itersList = char(join(imgIters,' + ')); % for titles and folder/file names

% close figures (before)
switch closeFigs, case 1, close all; end

% figure 1, montage
fig = figure;
montage(imgCell);
title([smpName '. ' itersList]);

% manager mode | save montage in current folder and return
if nargin ~= 0
    saveas(fig,[smpName '. ' itersList ext])
    return
end

% create plot directory, histogram-txt subdirectory (out)
dirOut = [smpName '. ' itersList];
if ~exist(dirOut,'dir'), mkdir(dirOut); end
mkdir([dirOut '/' dirHstTxt]);

% save figure 1
saveas(fig,[dirOut '/' smpName '. ' itersList ext])

% plot processed images, histogram figures and save
for i = 1:nIter
    
    % iters names cut until i
    itersListCut = char(join(imgIters(:,1:i),' + '));
    
    % save current processed image
    img_i = imgCell{i};
    imwrite(img_i,[dirOut '/' smpName num2str(i) '. ' itersListCut ext])                        % 'ccitt' default compression for binary images 
   %imwrite(img_i,[dirOut '/' smpName num2str(i) '. ' itersListCut ext], 'Compression','none')  % suitable for opening in imageJ
    
    % plot/save histogram data of selected processed images
    procLbl3chr = imgIters{i}(1:3);
    switch procLbl3chr, case {'ori','adj','FFC','hEq','med'} % first three characters
        
        fig_i = figure;
        imhist(img_i);
       %axis tight;

        % figure info
        title([smpName num2str(i) '. ' itersListCut]);
        ylabel('Count [number of pixels in bin]');

        % save histogram plot
        saveas(fig_i,[dirOut '/h' smpName num2str(i) '. '  itersListCut ' hist' ext])
        
        % save histogram data as text in subdirectory
        [counts,binLocations] = imhist(img_i);
        bscs = [binLocations counts];
        save([dirOut '/' dirHstTxt '/' smpName num2str(i) '. '  itersListCut ' hist.txt'], 'bscs', '-ascii')

    end
    
    % save last image in current folder
    if i == nIter
        imwrite(img_i,[smpName ext])
    end
    
    % manager mode | save last image in current folder
    if nargin ~= 0 && i == nIter
        imwrite(img_i,[smpName num2str(i) '. ' char(join(imgIters(:,1:i),' + ')) ext])
    end
end

% save higher 50% area of last two processed images
save([dirOut '/' num2str(h50T) '%, ' num2str(h50F) '%.txt'], 'h50F', '-ascii')

% close figures (after)
switch closeFigs, case 1, close all; end

% display summary
switch nargin, case 0 
    disp(' '); disp([' § Sample ' smpName ':']); disp(' ')
    disp(['   Threshold set [default]: ' num2str(thres) ' [' num2str(graythresh(img_orig)*255) ']'])
    disp(['   high50: ' num2str(h50T) '% -> ' num2str(h50F) '%'])
    disp(['   ' smpName ', ' num2str(toc) ' seconds.'])
    disp(' ')
end

end