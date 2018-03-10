function [RGBImg_Bit,RGBImg_re]= RGBbitExtract(varargin)

[RGBImg,colorbit,Isize]=parseInputs(varargin{:});

RGBImg_re=ResizeImg(RGBImg,Isize);


RB=fliplr(double(de2bi(RGBImg_re(:,:,1),8)));
GB=fliplr(double(de2bi(RGBImg_re(:,:,2),8)));
BB=fliplr(double(de2bi(RGBImg_re(:,:,3),8)));
m=colorbit/3;
RB_con=zeros(size(RB));
GB_con=zeros(size(GB));
BB_con=zeros(size(BB));
RB_con(:,1:m)=RB(:,1:m);
GB_con(:,1:m)=GB(:,1:m);
BB_con(:,1:m)=BB(:,1:m);

R_con=bi2de(fliplr(RB_con));
G_con=bi2de(fliplr(GB_con));
B_con=bi2de(fliplr(BB_con));

R=reshape(R_con,size(RGBImg_re,1),size(RGBImg_re,2));
G=reshape(G_con,size(RGBImg_re,1),size(RGBImg_re,2));
B=reshape(B_con,size(RGBImg_re,1),size(RGBImg_re,2));
RGBImg_Bit=uint8(cat(3,R,G,B));

%--------------------------------------------------------------------------
function [RGBImg,colorbit,Isize]=parseInputs(varargin)
parser = inputParser;
parser.addRequired('RGBImg',@CheckRGBImg);
parser.addParameter('colorbit',24);
parser.addParameter('Isize',[768,1024],@checkIsize);


parser.parse(varargin{:});
RGBImg=parser.Results.RGBImg;
colorbit=parser.Results.colorbit;
Isize=parser.Results.Isize;


%--------------------------------------------------------------------------
function tf=CheckRGBImg(RGBImg)
validateattributes(RGBImg,{'numeric'},{'3d'},mfilename,'RGBImg');
tf=true;

%--------------------------------------------------------------------------
function tf=checkIsize(Isize)
validateattributes(Isize,{'numeric'},{'numel',2,'integer','positive'},mfilename,'Isize');
tf=true;

%--------------------------------------------------------------------------
function RGBImg_out=ResizeImg(RGBImg,Isize)

[m,n,q]=size(RGBImg);




if (m~=Isize(1))||(n~=Isize(2))
    m_s=floor((m-Isize(1))/2)+1;
    n_s=floor((n-Isize(2))/2)+1;
    m_e=m_s+Isize(1)-1;
    n_e=n_s+Isize(2)-1;
    
    RGBImg_out=RGBImg(m_s:m_e,n_s:n_e,:);
else
    RGBImg_out=RGBImg;
end
