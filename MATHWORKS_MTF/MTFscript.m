%{
 Slant Edge Script
 File: MTFscript.m
 Written by: Patrick Granton, 
 September 2, 2010 
 Contact e-mail, patrick.granton@maastro.nl
 
Tested using Matlab 7.7.0.471 (R2008b)
including the imaging toolbox on a mac using OSX 10.5.8
 
A Gaussian fitting tool has been used in this code. You can download this 
tool on the Matlab central website here: http://www.mathworks.com/matlabcentral/fileexchange/11733-gaussian-curve-fit
 
 
%%%%%%%%%%%%%%%%%%%%Notes on Script%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
General comments:
 
This code can be used to measure the pre-sampled MTF of an image, which is a 
quantity that describes the resolution of linear imaging system. The code
is based on measuring the pre-sample MTF using a precision machined 
edge that is aligned - with respect to the columns or rows of an image - 
at an angle between 1-5 degrees.  
 
To learn more about the pre-sampled MTF consult the references at the end
of this script.

When you run this script your image containing the edge with appear with the 
cropping tool. Crop your image to the region containing only the edge. 
Double-click your cropped area for the script to continue. 


Samei, Flynn, and Reimann (Ref.2 ) have a good description on how to 
fabricate the edge to measure the pre-sampled MTF. 
 
%%%%%%%%%%%%%%%%%%%%%Begin Script%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%}
%Identify and initialize all variables

clear all;

Focallength=34;

physicalObjectSize = 0.5*(350.0/2560.0)*16.96;
physicalObjectDist = 19;
cameraPixelsOccupiedByPhysicalObject = 1180;
angleSubtendedByPhysicalObject=2*rad2deg(atan(physicalObjectSize/physicalObjectDist));
px_size = angleSubtendedByPhysicalObject/cameraPixelsOccupiedByPhysicalObject;
% parameters used to calcute the pixels per degree of camera
% used to derive cycles/deg from cycles/mm or cycles/pixels.

isotropicpixelspacing = 0.0037; 
% isotropic detector pixel spacing in mm, (i.e. pixel pitch).  
% set this value to your detector
 
pixel_subdivision = 0.25; 
% keep between 0.03 - > 0.15  
% Samei, Flynn, and Reimann (Ref.2 )suggest that 0.1 subpixel bin spacing 
% provides a good trade-off between sampling uniformity and noise.
 
bin_pad = 0.0001;
% Bin_pad adds a small space so that all values are included the histogram 
% of edge spread distances.
 
span = 13;
% span is used to smooth the edge spread function 
% Samei, Flynn, and Reimann (Ref.2 ) use a forth weighted,
% Gaussian-weighted moving polynomial. 
 
edge_span = 13;
% Used to improve the location of the edge
 
boundplusminus = 20; 
% boundplusminus is a variable that is used to crop a small section of the
% edge in order to used to find the subpixel interpolated edge position.
 
 
boundplusminus_extra = 20;
% boundplusminus_extra incorperates addition pixel values near the edge to 
% include in the binned histogram. 
 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%LOAD IMAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

Button_Image_Import = questdlg('What type of image would you like to import ?',...
    'Image type?',...
    'Dicom','Tiff or Jpeg','Matlab file','Tiff or Jpeg');
 
switch Button_Image_Import,
    
    case 'Dicom',
 
     [image_file, path_name] = uigetfile('*.dcm','Please select the dicom image you wish to import');
 
     image = im2double(dicomread([path_name image_file]));
    
    case 'Tiff or Jpeg'  
 
    [image_file, path_name] = uigetfile({'*.tif; *.tiff; *.jpg; *.jpeg; *.png'},'Please select the jpeg or tiff image you wish to import');
    
    image = im2double(imread([path_name image_file]));
    if(size(image,3)==3)
        image = rgb2gray(image);
    end
    
 
    case 'Matlab file' 
 
    [image_file, path_name] = uigetfile('*.mat','Please select the Matlab file containing an image named "image"in you wish to load');
    
    matstruct = load([path_name image_file]);
       
    image = double(matstruct.image);
      
end % switch


% crop image to 50 % air and 50 % edge 
 
h = figure('Name','Please select a region contain 50% Air and 50% of the edge'); hold on
 
imshow(image,[]);
 
image = imcrop(h);
 
close(h);
 
%%
%{
 Threshold image using Otsu's threshold criterion on cropped image
 
 Then find the average of the two regions (i.e. air, Plexiglas)
 
 The difference between's Otsu's threshold and the mean threshold is small 
%}

level = graythresh(image);
 
threshold =  double(((max(max(image)) - min(min(image))))*level + min(min(image)));
 
BW1 = roicolor(image,threshold,max(max(image)));
 
BW2 = roicolor(image,min(min(image)),threshold);
 
Area1 = sum(image(BW1))/sum(sum(BW1));
 
Area2 = sum(image(BW2))/sum(sum(BW2));
 
threshold = (Area1 - Area2)/2 + Area2;  
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Detect edge and orientation
 
BW_edge = edge(double(image),'canny',level);
 
% Locate edge positions
 
[A_row_pos B_column_pos] = find(BW_edge==1);


[rowlength, columnlength] = size(image);
 
% Fit edge positions
 
P = polyfit(B_column_pos,(rowlength-A_row_pos),1);
 
% determine rough edge angle to determine orientation
 
Angle_radians = atan(P(1));
 
% show the determined edge

%edge_intensity=1;
%imshow(image + BW_edge*edge_intensity,[]);
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
% Determine the sub pixel edge in a particular direction. 
% 
 
 
if abs(Angle_radians) > pi/4 % i.e. edge is vertical
    
    % if the edge is vertical the image keeps the same orientation
    % else we transpose the image
    
    start_row = 1;
    end_row = rowlength;
    
else % the edge is horizontal and the image is transposed
    
    image = image';
    
    [rowlength, columnlength] = size(image);
  
    start_row = 1;
    end_row = rowlength;
end

    
for i =start_row:end_row
          
        %%%%%%%%%%%%%%%%%%%  USED FOR finding edge %%%%%%%%%%%%%%%%%
 
        ii = i - start_row +1;
        %ii=1;
        
        strip = image(i,:);
        
        % smooth edge to find approximate edge area
        
        window = ones(edge_span,1)/edge_span;
        
        strip_smoothed = convn(strip',window,'valid');
        
        app_edge = find(abs(diff(strip_smoothed))== max(abs(diff(strip_smoothed)))) + floor(edge_span/2);
        
        %  in case there are more than one maxima, take the first one
        
        bound_edge_left = app_edge(1) - boundplusminus;
        
        bound_edge_right = app_edge(1) + boundplusminus;
        
        strip_cropped = (image(i,bound_edge_left:bound_edge_right));
        
        temp_y = 1:length(strip_cropped);
        
        [strip_unique,strip_index]=unique(strip_cropped,'legacy');
        
        edge_position_temp = interp1(strip_unique,temp_y(strip_index),threshold,'pchip');  
        
        edge_position(ii) = edge_position_temp + bound_edge_left - 1;
        
        
        %%%%%%%%%%%%%%%%%%%  USED FOR HISOGRAM %%%%%%%%%%%%%%%%%%%%
        
        
        bound_edge_left_expand = app_edge(1) - boundplusminus_extra;   
        
        bound_edge_right_expand = app_edge(1) + boundplusminus_extra;   
 
        array_values_near_edge(ii,:) = (image(i,bound_edge_left_expand:bound_edge_right_expand)); 
 
        arraypositions(ii,:) = [bound_edge_left_expand:bound_edge_right_expand];
end
       
        
       
    
    
    %{
      
         Fit a curve to the edge of a polynomial degree 1 
         y = ax^2 + bx + c, x = (y-b)/m
    
      
         *some use a degree 2 polynomial fit though for lens aberrations in XRI. 
        Padgett and Kotre (Ref.1) suggest an iteration process could be used to
        optimize the angle of the edge but generally not necessary. 
      
      %}
      
        y = 1:length(edge_position);
        
        P = polyfit(edge_position,y,1); 
 
        m = P(1);
 
        b = P(2);
 
        xfit = ((y - b)/m);
        
        distance_from_edge = edge_position - xfit;
 
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% generate edge bins %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
          
   
        array_positions_by_edge = arraypositions - (xfit')*(ones(1,(1 + 2*boundplusminus_extra)));
       
        % size of matrix
        
        [m n] = size(array_positions_by_edge);
        
        array_values_by_edge = array_values_near_edge(1:(m*n)); 
        
        array_positions_by_edge = array_positions_by_edge(1:(m*n));
        array_positions_by_edge = array_positions_by_edge*sin(Angle_radians);
        
       
 
% Determine bin spacing 
 
topEdge = ((max(array_positions_by_edge))+ bin_pad + pixel_subdivision);
botEdge = ((min(array_positions_by_edge))- bin_pad);
binEdges = botEdge:pixel_subdivision:topEdge;
numBins = length(binEdges) - 1;
 
binPositions = binEdges(1:end-1) + 1/2*pixel_subdivision;
 
% Rebinning portion
 
[h,whichBin] = histc(array_positions_by_edge,binEdges);
 
for i = 1:numBins
    flagBinMembers = (whichBin == i);
    binMembers = array_values_by_edge(flagBinMembers);
    binMean(i) = mean(binMembers);
    
end
 

 
ESF = binMean(2:numBins - 1); % Eliminate first, second and last array position
 
xESF = binPositions(2:numBins - 1); % same as above comment
 
% fill in missing data
 
ESF_nonan = ESF(logical(1-isnan(ESF)));
 
xESF_nonan = xESF(logical(1-isnan(ESF)));
 
ESF = interp1(xESF_nonan,ESF_nonan,xESF,'pchip');


%{
lineImg=image(floor((start_row+end_row)/2),:);
lineAxis=(1:length(lineImg));
lineAxis=lineAxis-length(lineAxis/2);
[PLine,S,mu]=polyfit(lineAxis,lineImg,40);
lineImgFit=polyval(PLine,lineAxis,S,mu);

Hthresh=0.5382;
Lthresh=0.12;

% Hthresh=0.90*max(max(image));
% Lthresh=0.1*max(max(image));


lineImgFit(lineImgFit>Hthresh)=Hthresh;
lineImgFit(lineImgFit<Lthresh)=Lthresh;

LineImgGradient=[0,abs(diff(lineImgFit))];
LineImgGradient=LineImgGradient/sum(LineImgGradient);
e=find(LineImgGradient==max(LineImgGradient))-1;
lineFFT=abs(fft(LineImgGradient));
lineFFT=lineFFT(1:ceil(length(lineFFT)/2));

mtfval=lineFFT/max(lineFFT);

px_size=0.003612843576288;
maxCycPerDeg=1/2/px_size;
cpdAxis = linspace(0, maxCycPerDeg,length(mtfval));
%}


% smooth the edge spread function
window = ones(span,1)/span;
 
smoothed = convn(ESF,window','valid');



Hthresh=max(smoothed)*0.72;
Lthresh=min(smoothed)*1.6;

lineImg=smoothed;
lineImg(lineImg>Hthresh)=Hthresh;
lineImg(lineImg<Lthresh)=Lthresh;



[PLine,S,mu]=polyfit(xESF(round(span/2):round((length(xESF)-span/2))),lineImg,30);
lineImgFit=polyval(PLine,xESF(round(span/2):round((length(xESF)-span/2))),S,mu);
LineImgGradient=[0,abs(diff(lineImgFit))];
LineImgGradient=LineImgGradient/sum(LineImgGradient);

%{
lineImgFit=lineImg;
LineImgGradient=[0,abs(diff(lineImgFit))];
LineImgGradient=LineImgGradient/sum(LineImgGradient);
%}
 

 





%%

usingFormula=true;


subplot(2,2,1)
 
plot(xESF,ESF,xESF(round(span/2):round((length(xESF)-span/2))),smoothed); hold on;
plot(xESF(round(span/2):round((length(xESF)-span/2))),lineImgFit,'g--');
 
title('\fontname{Arial} The Edge Spread Function')
 
legend('Raw ESF','Smoothed ESF (Gaussian)')
 
xlabel('distance along the edge in pixels')
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
% Perform the MTF calculations
 
LSF_raw = diff(ESF);
 
LSF = -diff(smoothed);
 
 
Nans = isnan(LSF); % remove any Nans
 
LSF(Nans==1) = 0;
 
 
% Normalize the LSF
 
LSF = LSF/sum(LSF);
 
xLSF_fit = 1:length(LSF);
 
LSF_base_raw= LSF_raw/sum(LSF_raw);
 
LSF_raw = LSF_raw(span/2:1:(length(LSF_raw)-span/2));
 
LSF_raw = LSF_raw/sum(LSF_raw);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%Fit a Gaussian to the LSF fit%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
% acquire this function
% here:http://www.mathworks.com/matlabcentral/fileexchange/11733-gaussian-curve-fit
 

window = ones(7,1)/7;

LSF_filter=filter(window,1,LSF);

[sigma,mu,A] = mygaussfit(xESF(round(span/2):round((length(xESF)-span/2))),LineImgGradient,0.5); 
 
yLSF_fit = A*exp(-(xESF(round(span/2):round((length(xESF)-span/2)))-mu).^2/(2*sigma^2));

yLSF_fit=yLSF_fit/sum(yLSF_fit);
 
 
subplot(2,2,2)
 
plot(xESF(round(span/2):round((length(xESF)-span/2)-1)),LSF,xESF(round(span/2):round((length(xESF)-span/2))),yLSF_fit,xESF(1:(length(xESF)-1)),LSF_base_raw);hold on;
plot(xESF(round(span/2):round((length(xESF)-span/2))),LineImgGradient,'g--')
 
title('\fontname{Arial} The Line Spread Function of the Edge')
 
legend('Smoothed LSF','Fitted LSF (Gaussian)','Raw LSF')
 
xlabel('distance along the edge in pixels')
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
% Convert the spatial domain to frequency domain
  
N = length(LSF);
 
%generate the frequency axis
 

    
 %{
 
% Convert the spatial domain to frequency domain
  
%}
 
if usingFormula
Fs = 1/(2*isotropicpixelspacing*pixel_subdivision)*pi*focallength/180;% sampling rate in samples per mm
else
Fs = 1/(2*pixel_subdivision*px_size); 
end
   

    
freq = linspace(-Fs,Fs,2048);
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 %%%%Generate your MTF%%%%%
    
MTF= abs(fft(LSF,2048));  
 
MTF_fit = abs(fft(yLSF_fit,2048));
 
MTF_raw = abs(fft(LSF_raw,2048));

lineFFT=abs(fft(LineImgGradient,2048));

mtfval=lineFFT/max(lineFFT);

 
subplot(2,2,3)
 
plot(freq,fftshift(MTF),freq,fftshift(MTF_fit),freq,fftshift(MTF_raw));hold on;
plot(freq,fftshift(mtfval),'g--');
 
title('\fontname{Arial} The Modulation Transfer Function of the Edge')
 
legend('Smoothed MTF','Fitted LSF (Gaussian)','Raw MTF')
 
xlabel('frequency distribution')
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

 
freq = linspace(0,Fs,1024);
MTF=MTF(1:1024);
MTF_fit=MTF_fit(1:1024);
MTF_raw=MTF_raw(1:1024);
mtfval=mtfval(1:1024);

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
% Equivalent line pairs per mm @ 10% MTF
% 2.5 LPP is equivalent to 200 um, DU et al
% Other institutions use 50% 
 
    
YMTFfine = 0:0.01:1;
 
mtfpoint = find(MTF<0.05);
 
YMTF = interp1(MTF(1:mtfpoint(1)),freq(1:mtfpoint(1)),YMTFfine,'pchip');
 
mtfpoint = find(MTF<0.05);
 
YMTFit = interp1(MTF_fit(1:mtfpoint(1)),freq(1:mtfpoint(1)),YMTFfine,'pchip');
 
mtfpoint = find(MTF<0.05);
 
YMTraw = interp1(MTF_raw(1:mtfpoint(1)),freq(1:mtfpoint(1)),YMTFfine,'pchip');
 
 
LPP = YMTF(YMTFfine==0.5);
 
Resolution_smoothed= LPP % in mm 
 
LPP = YMTFit(YMTFfine==0.5);
 
Resolution_fit = LPP % in mm 
 
LPP = YMTraw(YMTFfine==0.5);
 
Resolution_raw = LPP % in mm 
 
 
 
 
subplot(2,2,4)
 
shortaxis = int16(length(freq)/16);
 
plot(freq(1:shortaxis),MTF(1:shortaxis),freq(1:shortaxis),MTF_fit(1:shortaxis),freq(1:shortaxis),MTF_raw(1:shortaxis)); hold on;
plot(freq(1:shortaxis),mtfval(1:shortaxis),'g--');
 
title('\fontname{Arial} The Modulation Transfer Function of the Edge (ZOOMED)')
 
legend(sprintf('Smoothed MTF Cutoff = %3.1f ',Resolution_smoothed), sprintf('Fitted LSF (Gaussian) MTF Cutoff = %3.1f ', Resolution_fit),sprintf('Raw MTF Cutoff = %3.1f ',Resolution_raw))
 
xlabel('The pre-sampled MTF in cycles per degree')
 
 
 
%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
References:
 
(1) Padgett and Kotre, 
    "Development and application of programs to measure modulation transfer
    function, noise power spectrum and detective quantum efficiency,"
    Radiation Protection Dosimetry, Vol. 117, No. 1-3, pp 283-287, (2005)
 
(2) Samei, Flynn, and Reimann,
    "Measuring the presampled MTF of digital radiographic systems"
    Medical Physics, Vol. 25, No.1, pp 102-113, (1998)
 
(3) Judy,
    "The line spread function and modulation transfer function of a computer
    tomographic scanner,"
    Medical Physics, Vol.3, No.4, pp 233-236, (1975)
 
(4) Fujitia et al. 
    " A simple Method for determining the modulation transfer function in 
    digital radiography,"
    IEEE transactions on medical imaging, Vol. 11, No.1, (1992)
 
(5) Du et al. 
    " A quality assurance phantom for the performance evaluation of
    volumetric micro-CT systems,"
    Physics Medicine Biology, Vol. 52, pp 7087-7108, (2007)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%}
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


