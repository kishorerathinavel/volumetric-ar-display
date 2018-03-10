CalibrationImg=zeros([768,1024]);
Background=zeros([768,1024]);

height_unit=100;
width_unit=200;
h_num=3;
w_num=3;

height=height_unit*h_num;
width=width_unit*w_num;

m_s=(768-height)/2;
n_s=(1024-width)/2;

CalibrationImg(m_s:m_s+height_unit-1,n_s:n_s+width_unit-1)=1;
CalibrationImg(m_s+2*height_unit:m_s+3*height_unit-1,n_s:n_s+width_unit-1)=1;
CalibrationImg(m_s:m_s+height_unit-1,n_s+2*width_unit:n_s+3*width_unit-1)=1;
CalibrationImg(m_s+2*height_unit:m_s+3*height_unit-1,n_s+2*width_unit:n_s+3*width_unit-1)=1;
CalibrationImg(m_s+height_unit:m_s+2*height_unit-1,n_s+width_unit:n_s+2*width_unit-1)=1;

imshow(CalibrationImg,[]);
Space=20;
NumofBP=280;
Iter=NumofBP/Space;
load('FocusDepth.mat');
%%
for i=1:Iter
    str = sprintf('Calibration/Set_%03d',i);
    mkdir(str);
end

%%
s=1;
for i=1:Iter
    
    s_iter=s+(i-1)*Space;
    for j=1:NumofBP
        str=sprintf('Calibration/Set_%03d/Calibration_%03d.png',i,order(j));
        
        if j==s_iter
          imwrite(CalibrationImg,str);  
        else
          imwrite(Background,str);
        end
    end
end

%%
CalibrationImg=zeros([768,1024]);
Background=zeros([768,1024]);

CalibrationImg(1:40,1:end)=1;
CalibrationImg(end-39:end,1:end)=1;
CalibrationImg(1:end,1:40)=1;
CalibrationImg(1:end,end-39:end)=1;
imshow(CalibrationImg,[]);
%%
for i=1:NumofBP
    str=sprintf('Test_new/Test_%03d.png',order(i));
    
    if i==1
        imwrite(CalibrationImg,str);
    else
        imwrite(Background,str);
    end
end