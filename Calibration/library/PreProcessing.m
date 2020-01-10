function Ret = PreProcessing(varargin)
% Pre-preocessing of the images
% convert RGB images to gray and using morphological operations to remove
% noise
% Input:
%       images:   a cell vector  each element is a either 3D array representing a
%                 RGB image or a 2D array representing a grayscale image
%       Pattern:  a Name-value pair, indicating the type of calibration
%                 images, supported values are 'dot', 'crosshair'
%       Disksize: a Name-value pair, setting the size of the structuring
%                 element in pixels for morphological operations
%
% Output:
%       images_processed: Pre-preocessing images, Same structure as input
%                         images
        

[images,pattern,Disksize]=parseInputs(varargin{:});

num = length(images);
Ret = [];


if strcmp(pattern,'dot')
    
 
if size(images{1},3) == 3
for i=1:num
    images_gray{i} = rgb2gray(images{i});
    images_gray{i} = imadjust(images_gray{i});
end

else
    images_gray = images;
end


se = strel('disk',Disksize);
for i=1:num
    images_erode{i} = imerode(images_gray{i},se);
    images_denoise{i} = imdilate(images_erode{i},se);
end

Ret = images_denoise;
end


%--------------------------------------------------------------------------
function [images,pattern,Disksize]=parseInputs(varargin)

parser = inputParser;
parser.addRequired('Images',@CheckImg);
parser.addParameter('Pattern','dot');
parser.addParameter('Disksize',4);


parser.parse(varargin{:});
images = parser.Results.Images;
pattern = parser.Results.Pattern;
Disksize = parser.Results.Disksize;
%--------------------------------------------------------------------------
function valid = CheckImg(Images)
validateattributes(Images,{'cell'},{'vector'},mfilename,'Images');
valid=true;