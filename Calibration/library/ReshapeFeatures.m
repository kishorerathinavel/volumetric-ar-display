function points_return = ReshapeFeatures(varargin)
% Reshape the 2D features into a m by 2 array, the features are ordered
% starting from the leftmost column(in  image space), counting from the top
% to the bottom, then the second column... to the rightmost column.
% Input: 
%       points: a cell vector  each element contains the number of detected
%               centers and their locations
%       featureSize: a 2 element vector indicating the 
%                    dimension of the features, featureSize(1) is the
%                    number of the features in y direction, featureSize(2)
%                    is the number of features in x direction
%
% Output:
%        points_return: a cell vector  each element contains the number of 
%                       detected centers and their locations(ordered)



[points,featureSize,originalShape]=parseInputs(varargin{:});


TotalNum = featureSize(1)*featureSize(2);



num = length(points);



for j=1:num   
    
    xy_matrix = zeros([featureSize(1) featureSize(2) 2])-1;
    
    [indx,c_x] = kmeans(points{j}.Location(:,1),featureSize(2),'Replicates',5,'OnlinePhase','on');
    [c_x_sort,c_x_order] = sort(c_x);
    c_x_unorder(c_x_order)=1:featureSize(2);

    [indy,c_y] = kmeans(points{j}.Location(:,2),featureSize(1),'Replicates',5,'OnlinePhase','on');
    [c_y_sort,c_y_order] = sort(c_y);
     c_y_unorder(c_y_order) = 1:featureSize(1);

    for i =1:(points{j}.Count)
      xy_matrix(c_y_unorder(indy(i)),c_x_unorder(indx(i)),:) = points{j}.Location(i,:);
    end
    
    if originalShape ==1
    Locations(:,1) = reshape(xy_matrix(:,:,1),TotalNum,1);
    Locations(:,2) = reshape(xy_matrix(:,:,2),TotalNum,1);
    
    points_return{j}.Location = Locations;
    else
    points_return{j}.Location = xy_matrix;
    end

clear indx c_x c_x_sort c_x_order c_x_unorder indy c_y c_y_sort c_y_order c_y_unorder;
clear xy_matrix Locations;
    
    
    
end





%--------------------------------------------------------------------------
function [points,featureSize,originalShape]=parseInputs(varargin)

parser = inputParser;
parser.addRequired('Points',@CheckPoints);
parser.addRequired('featureSize',@checkFeature);
parser.addParameter('OriginalShape',1);

parser.parse(varargin{:});
points = parser.Results.Points;
featureSize = parser.Results.featureSize;
originalShape = parser.Results.OriginalShape;

%--------------------------------------------------------------------------
function valid = CheckPoints(Points)
validateattributes(Points,{'cell'},{'vector'},mfilename,'Points');
valid = true;

%--------------------------------------------------------------------------
function valid = checkFeature(FeatureNum)
validateattributes(FeatureNum,{'numeric'},{'vector','numel',2},mfilename,'FeatureNum');
valid = true;

