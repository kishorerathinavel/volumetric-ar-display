function points = featureDetect(varargin)

% Detect the center of features in the images
% return the location of centers and the number of centers detected in a
% struct.
% Input:
%       images: a cell vector  each element is a 2D array representing a
%                 gray image
%       ROI:    a Name-value pair, setting the Reigon of interest.
%
% Output: 
%       points: a cell vector  each element contains the number of detected
%               centers and their locations

[images,ROI]=parseInputs(varargin{:});

num = length(images);


for i = 1:num
    im = images{i};
    images_crop = imcrop(im,ROI);
    images_BW = imbinarize(images_crop,'global');
    stats = regionprops(images_BW,'centroid');
    centroids = cat(1,stats.Centroid);
    centroids  = centroids + repmat([ROI(1)-1,ROI(2)-1], length(centroids),1);
    points{i}.Location = centroids;
    points{i}.Count = length(centroids);
    
end




%--------------------------------------------------------------------------
function [images,ROI]=parseInputs(varargin)

parser = inputParser;
parser.addRequired('Images',@CheckImg);
parser.addParameter('ROI',[800,700,3800,2400]);


parser.parse(varargin{:});
images = parser.Results.Images;
ROI = parser.Results.ROI;

%--------------------------------------------------------------------------
function valid = CheckImg(Images)
validateattributes(Images,{'cell'},{'vector'},mfilename,'Images');

element = Images{1};
validateattributes(element,{'numeric'},{'3d'},mfilename,'Images');
valid=true;