%% Calibration pipeline
% Generate a lookup table for the display calibration
% Using linear-volume interpolation method
clear all;


%% Part 1
% preparing data needed for parameter estimation in calibration model
% This part involves loading images, detecting, organizing and saving 
% reference points

%% get the path where all data are stored
addpath('library');
data_folder_path =  get_data_folder_path();
%% extract point from the captured image

% variable indicating if using high resolution image
highres =false;

Imgnum = 10;

if ~highres
inputdir = sprintf('%s/Calibration/CalibratedCirclePattern_10/Capture',data_folder_path);
else
inputdir = sprintf('%s/Calibration/CalibratedCirclePattern_10/Capture/high_res',data_folder_path);
end

% read images
for i=1:Imgnum
    if highres
    filename = sprintf('%s/red/set%d_highres_red.JPG',inputdir,i);
    else
    filename = sprintf('%s/set%d.png',inputdir,i);
    end
    images{i} = imread(filename);
end

% pre-processing
if ~highres
images_processed = PreProcessing(images,'Pattern','dot','Disksize',4);
else
images_processed = PreProcessing(images,'Pattern','dot','Disksize',10);
end
%%
imshow(images_processed{1},[]);
ROI = getrect;
rectangle('Position',ROI,'EdgeColor','r');

for i = 1:Imgnum
ROI_Cell{i} = ROI;
end

points = featureDetect(images_processed,'ROI',ROI_Cell);

for i=1:Imgnum
figure
imshow(images_processed{i},[]); hold on;
title(sprintf('Image %d',i));
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');
end
%%

featureNum = [10,14];

% variable indicating if mannully marking undetected points
manual =true;

if manual
    points = ManualSelect(images_processed, points,'ROI',ROI,'FeatureNum',featureNum);
end

for i=1:Imgnum
figure
imshow(images_processed{i},[]); hold on;
title(sprintf('Image %d',i));
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');
end
%%
filename = sprintf('%s/Params/FocusDepth_sin.mat',data_folder_path);
save points_10 points

%% Part2
% Model parameters estimation 
% This part involves loading reference points, establishing model and
% estimating model parameters

%% load corresponding (xd,yd) data

% get the path where all data are stored
addpath('library');
data_folder_path =  get_data_folder_path();

filename = sprintf('%s/DataFiles/DepthLocation_10_14.mat',data_folder_path);
load(filename);

filename = sprintf('%s/DataFiles/XdYd_10_14.mat',data_folder_path);
load(filename);

filename = sprintf('%s/Params/FocusDepth_sin.mat',data_folder_path);
load(filename);

filename = sprintf('%s/DataFiles/points_10.mat',data_folder_path);
load(filename);

% flip the y coordinate of yd
% the captured image from display is upside down of the loaded parttern
Xdyd_flip = Xdyd;
Xdyd_flip(:,2) = 768 - Xdyd_flip(:,2) + 1;


%% Orgnize data points with correspondence.

% reshape the captured points
xy_data = ReshapeFeatures(points,[10,14],'OriginalShape',0);
% reshape the inported (xd,yd) data
xdyd_points{1}.Location = Xdyd_flip;
xdyd_points{1}.Count = 10*14;
xdyd_data = ReshapeFeatures(xdyd_points,[10,14],'OriginalShape',0);



%
X_coord = [];
Y_coord = [];
Z_coord = [];

XD_coord = [];
YD_coord = [];


for i=1:length(Location)
    
    
    x_tem = xy_data{i}.Location(:,:,1);
    y_tem = xy_data{i}.Location(:,:,2);
    
    X_coord = [X_coord; x_tem(:)];
    Y_coord = [Y_coord; y_tem(:)];
    Z_coord = [Z_coord; repmat(Location(i),10*14,1)];
    
    
    XD_coord = [XD_coord; reshape(xdyd_data{1}.Location(:,:,1),10*14,1)];
    YD_coord = [YD_coord; reshape(xdyd_data{1}.Location(:,:,2),10*14,1)];
end
ZD_coord = Z_coord;



%% establishing models
% z' = z;
% y' = f1(x,y,z)
% x' = f2(x,y,z)
% f1 and f2 are established as polynomial functions with respect to x,y,z
% f = sum(x.^i * y.^j * z.*k)  i,j,k belongs in N


m = length(X_coord);
% backward transform

% control the degree of the fitting function
PolyDegree = 3;


% variable controlling whether to add cubic term when PolyDegree = 2
% this comes from the fact that there is cubic terms in radial lens
% distortion correction formula
AddCubicTerm = true;

switch PolyDegree
    case 3
    % cubic
    A1 = [X_coord.^3, X_coord.^2, X_coord, ones([m,1])];
    A2 = [Y_coord.^3, Y_coord.^2, Y_coord, ones([m,1])];

    case 2
    %quadratic
    A1 = [X_coord.^2, X_coord, ones([m,1])];
    A2 = [Y_coord.^2, Y_coord, ones([m,1])];

    case 1
    %linear
    A1 = [X_coord, ones([m,1])];
    A2 = [Y_coord, ones([m,1])];
    
    otherwise
    %linear
    A1 = [X_coord, ones([m,1])];
    A2 = [Y_coord, ones([m,1])];
        
end


A3 = double([Z_coord.^3, Z_coord.^2, Z_coord, ones([m,1])]);

A4 = [];
A = [];

for i=1:size(A1,2)  
    %A4 = A1*A2
    A4 = [A4, A1(:,i).*A2];
end

for i=1:size(A3,2)
    %A = A3*A4;
    A = [A, A3(:,i).*A4];
end


if(AddCubicTerm)&&(PolyDegree == 2)
    A = [X_coord.^3, Y_coord.^3,A];
end

% standard normalization to A(otherwise, A is ill-conditioned)
% A_new = (A-M)*T
% where M = [m1 m2 ... mn        T = [t1 0 ... 0
%            m1 m2 ... mn             0 t2 ... 0
%            .                        .
%            .                        .
%            .                        .
%            m1 m2 ... mn]            0 0 ... tn]
% mi is the mean value of Ai, ti is the reciprocal of the standard devition
% of Ai, note that the last column is constant 1 which shouldn't be
% normalized(mn = 0, tn = 1)

M = repmat([mean(A(:,1:end-1)),0],m,1);
D = [std(A(:,1:end-1)),1];
T = diag(1./D);

A_new = (A-M)*T;

%% seperate data points to train set and test set
% planesIndex = 1:1:10;
% maxiter = 300;
% tol = [];
% [Coeff_x,flag_x,relres_x]= lsqr(A_new, XD_coord,tol, maxiter);
% [Coeff_y,flag_y,relres_y]= lsqr(A_new, YD_coord,tol, maxiter);

planesIndex = 1:1:10;

c = zeros([140,length(planesIndex)]);
for i=1:length(planesIndex)
    s = (planesIndex(i)-1)*140+1;
    e =  planesIndex(i)*140;
    c(:,i) = s:e;
end
pointsIndex = c(:);


%% Matlab built-in solver 

Coeff_x = A_new(pointsIndex,:)\XD_coord(pointsIndex,:);
Coeff_y = A_new(pointsIndex,:)\YD_coord(pointsIndex,:);

%% levenberg-Marquardt algorithm
fun_x = @(x)(A_new*x-XD_coord);
fun_y = @(x)(A_new*x-YD_coord);

% options = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective');
options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt');
options.FunctionTolerance = 1e-9;
options.StepTolerance = 1e-9;
x0 = zeros([64 1]);

[Coeff_x_refine,resnorm_x,residual_x,exitflag_x,output_x] = lsqnonlin(fun_x,Coeff_x,[],[],options);
[Coeff_y_refine,resnorm_y,residual_y,exitflag_y,output_y] = lsqnonlin(fun_y,Coeff_y,[],[],options);

% [Coeff_x_refine,resnorm_x,residual_x,exitflag_x,output_x] = lsqnonlin(fun_x,x0,[],[],options);
% [Coeff_y_refine,resnorm_y,residual_y,exitflag_y,output_y] = lsqnonlin(fun_y,x0,[],[],options);
%% 
[U,S,V] = svd(A_new);

