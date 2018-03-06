function Image_sequence=GenerateImgSeq(varargin)

[RGBImg,DepthImg,NumofBP,colorbit,Isize]=parseInputs(varargin{:});


[RGBImg_re,DepthImg_re]=ResizeImg(RGBImg,DepthImg,Isize);

RGB_BR=Color2Binary(RGBImg_re);
DepthImg_norm=DepthMapNormlization(DepthImg_re);
NumofCP=NumofBP-colorbit+1;

DepthList=GenDepthList(NumofCP);
Image_sequence=GenImgSeq(DepthImg_norm,DepthList,NumofBP,NumofCP,colorbit,RGB_BR,Isize);

%--------------------------------------------------------------------------
function [RGBImg,DepthImg,NumofBP,colorbit,Isize]=parseInputs(varargin)
parser = inputParser;
parser.addRequired('RGBImg',@CheckRGBImg);
parser.addRequired('DepthImg',@CheckDepthImg);
parser.addParameter('NumofBP',280);
parser.addParameter('colorbit',24);
parser.addParameter('Isize',[768,1024],@checkIsize);

parser.parse(varargin{:});
RGBImg=parser.Results.RGBImg;
DepthImg=parser.Results.DepthImg;
NumofBP=parser.Results.NumofBP;
colorbit=parser.Results.colorbit;
Isize=parser.Results.Isize;

%--------------------------------------------------------------------------
function tf=CheckRGBImg(RGBImg)
validateattributes(RGBImg,{'numeric'},{'3d'},mfilename,'RGBImg');
tf=true;

%--------------------------------------------------------------------------
function tf=CheckDepthImg(DepthImg)
validateattributes(DepthImg,{'numeric'},{'3d'},mfilename,'DepthImg');
tf=true;
      
%--------------------------------------------------------------------------
function tf=checkIsize(Isize)
validateattributes(Isize,{'numeric'},{'numel',2,'integer','positive'},mfilename,'Isize');
tf=true;

%--------------------------------------------------------------------------
function [RGBImg_out,DepthImg_out]=ResizeImg(RGBImg,DepthImg,Isize)

[m1,n1,q1]=size(RGBImg);
[m2,n2,q2]=size(DepthImg);

if (m1~=m2)&&(n1~=n2)
    error(message('RGBImg and DepthImg not match'));
end

m=m1;
n=n1;

if (m~=Isize(1))||(n~=Isize(2))
    m_s=floor((m-Isize(1))/2)+1;
    n_s=floor((n-Isize(2))/2)+1;
    m_e=m_s+Isize(1)-1;
    n_e=n_s+Isize(2)-1;
    
    RGBImg_out=RGBImg(m_s:m_e,n_s:n_e,:);
    DepthImg_out=DepthImg(m_s:m_e,n_s:n_e,:);   
end

%--------------------------------------------------------------------------
function RGB_BR=Color2Binary(RGBImg)
RB=double(de2bi(RGBImg(:,:,1),8));
GB=double(de2bi(RGBImg(:,:,2),8));
BB=double(de2bi(RGBImg(:,:,3),8));
RGB_BR=[RB,GB,BB];

%--------------------------------------------------------------------------
function DepthImg_norm=DepthMapNormlization(DepthImg)

DepthImg_norm=double(DepthImg(:,:,1))/255;

%--------------------------------------------------------------------------
function DepthList=GenDepthList(NumofCP)

DepthList=linspace(0,1,NumofCP);

%--------------------------------------------------------------------------
function Image_sequence=GenImgSeq(DepthImg_norm,DepthList,NumofBP,NumofCP,colorbit,RGB_BR,Isize)

ValidIndex=find(DepthImg_norm>0);
DepthSeparater=[0,DepthList(1:end-1)+DepthList(2:end),1];
Image_sequence=zeros([Isize NumofBP]);

for i=1:NumofCP
    index=find(DepthImg_norm>=DepthSeparater(i)&DepthImg_norm<DepthSeparater(i+1));
    index=intersect(index,ValidIndex);
    
    if~isempty(index)
        
        for j=1:numel(index)
            [a,b]=ind2sub(Isize, index(j));
            s=mod(i,colorbit);
            
            if s==0
                s=colorbit;
            end
            
            Image_sequence(a,b,i:(i+colorbit-1))=[RGB_BR(index(j),s:end),RGB_BR(index(j),1:s-1)];
        end
          
    end
    
end