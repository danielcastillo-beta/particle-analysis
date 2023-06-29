
%   Manager
%   try series of parameters for image processing
%   calculate the percentages of areas (h50T, h50F) in the processed images (threshold and filling holes)
%

function man_A

% chk threshold
thress = 100:5:130;
FFCs = 35;

% chk FFCs
% FFCs = 5:5:100;
% thress = 225;

for i = 1:length(thress)
    thresi = thress(i);
    
    for j = 1:length(FFCs)
        FFCi = FFCs(j);
        
        [h50T,h50F] = fun_A(thresi, FFCi);
        
        disp(['   thres|FFC: ' num2str(thresi) '|' num2str(FFCi) '   high50 = ' num2str(h50T/100) '|' num2str(h50F/100)])
                
    end
end

disp(' ')

end