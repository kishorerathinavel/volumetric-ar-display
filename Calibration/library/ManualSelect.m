function points_to_return = ManualSelect(varargin)
% providing GUI for manually selecting previously detected centers
% Input: 
%       images: a cell vector  each element is a 2D array representing a
%                 gray image
%       points: a cell vector  each element contains the number of detected
%               centers and their locations
%       ROI:    

[images,points,ROI,featureNum]=parseInputs(varargin{:});


num = length(points);

TotalNum = featureNum(1)*featureNum(2);

for i=1:num
    
     NumofUndetected = TotalNum - points{i}.Count;
     
     if NumofUndetected>0
        manual_location = zeros(NumofUndetected,2);
    
     im = imcrop(images{i},ROI); 
    
     imshow(im,[]); hold on;
     imagetitle = sprintf('Image %d',i);
     title(imagetitle);
     plot(points{i}.Location(:,1)- ROI(1),points{i}.Location(:,2) - ROI(2),'color','g','marker','o','markersize',14,'linestyle','none');
     plot(points{i}.Location(:,1)- ROI(1),points{i}.Location(:,2) - ROI(2),'color','g','marker','+','markersize',18,'linestyle','none');
     
        
    
    for k = 1:NumofUndetected  
     [x,y] = ginput(1,'Color',[1,0,0]);
     % hold on;
     plot(x,y,'marker','o','color','r','markersize',10);
     plot(x,y,'marker','+','color','r','markersize',10);
     drawnow
     manual_location(k,:) = [x,y];     
    end
    
    
    manual_location(:,1) = manual_location(:,1) + ROI(1);
    manual_location(:,2) = manual_location(:,2) + ROI(2);
    
    points{i}.Location = [points{i}.Location;manual_location];
    points{i}.Count = points{i}.Count + NumofUndetected;
    end
end    


points_to_return = points;




%--------------------------------------------------------------------------
function [images,points,ROI,featureNum]=parseInputs(varargin)
parser = inputParser;
parser.addRequired('Images',@CheckImg);
parser.addRequired('Points',@CheckPoints);
parser.addParameter('ROI',[800,700,3800,2400]);
parser.addParameter('FeatureNum',[8, 10], @checkFeature);

parser.parse(varargin{:});
images = parser.Results.Images;
points = parser.Results.Points;
ROI = parser.Results.ROI;
featureNum = parser.Results.FeatureNum;


%--------------------------------------------------------------------------
function valid = CheckImg(Images)
validateattributes(Images,{'cell'},{'vector'},mfilename,'Images');

element = Images{1};
validateattributes(element,{'numeric'},{'3d'},mfilename,'Images');
valid=true;


%--------------------------------------------------------------------------
function valid = CheckPoints(Points)
validateattributes(Points,{'cell'},{'vector'},mfilename,'Points');
valid = true;

%--------------------------------------------------------------------------
function valid = checkFeature(FeatureNum)
validateattributes(FeatureNum,{'numeric'},{'vector','numel',2},mfilename,'FeatureNum');
valid = true;