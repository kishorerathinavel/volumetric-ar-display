function Ret = PreProcessing(varargin)
% Pre-preocessing of the images
% convert RGB images to gray and using morphological operations to remove
% noise
% Input:
%       images:   a cell vector  each element is a 3D array representing a
%                 RGB image
%       Pattern:  a Name-value pair, indicating the type of calibration
%                 images, supported values are 'dot', 'crosshair'
%       Disksize: a Name-value pair, setting the size of the structuring
%                 element in pixels for morphological operations
%
% Output:
%       images_processed: Pre-preocessing images, Same structure as input
%                         images
        

[images,pattern,size]=parseInputs(varargin{:});

num = length(images);
Ret = [];


if strcmp(pattern,'dot')
for i=1:num
    images_gray{i} = rgb2gray(images{i});
    images_gray{i} = imadjust(images_gray{i});
end

se = strel('disk',size);
for i=1:5
    images_erode{i} = imerode(images_gray{i},se);
    images_denoise{i} = imdilate(images_erode{i},se);
end

Ret = images_denoise;
end


%--------------------------------------------------------------------------
function [images,pattern,size]=parseInputs(varargin)

parser = inputParser;
parser.addRequired('Images',@CheckImg);
parser.addParameter('Pattern','dot');
parser.addParameter('Disksize',4);


parser.parse(varargin{:});
images = parser.Results.Images;
pattern = parser.Results.Pattern;
size = parser.Results.Disksize;
%--------------------------------------------------------------------------
function valid = CheckImg(Images)
validateattributes(Images,{'cell'},{'vector'},mfilename,'Images');

element = Images{1};
validateattributes(element,{'numeric'},{'3d'},mfilename,'Images');
valid=true;