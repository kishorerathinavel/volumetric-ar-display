function [Image_sequence,Image_CutVol]=GenerateImgSeq2(varargin)

[RGBImg,DepthMap,NumofBP,colorbit,Isize,DepthBG]=parseInputs(varargin{:});


[RGBImg_re,DepthMap_re]=ResizeImg(RGBImg,DepthMap,Isize);

RGB_BR=Color2Binary(RGBImg_re,colorbit);
DepthMap_norm=DepthMapNormlization(DepthMap_re);
NumofCP=NumofBP-colorbit+1;

DepthList=GenDepthList(NumofBP,NumofCP,colorbit);
[Image_sequence,Image_CutVol]=GenImgSeq(RGBImg_re,DepthMap_norm,DepthList,NumofBP,NumofCP,colorbit,RGB_BR,Isize,DepthBG);

%--------------------------------------------------------------------------
function [RGBImg,DepthMap,NumofBP,colorbit,Isize,DepthBG]=parseInputs(varargin)
parser = inputParser;
parser.addRequired('RGBImg',@CheckRGBImg);
parser.addRequired('DepthMap',@CheckDepthMap);
parser.addParameter('NumofBP',280);
parser.addParameter('colorbit',24);
parser.addParameter('Isize',[768,1024],@CheckIsize);
parser.addParameter('DepthBG','white',@CheckDepthBG);


parser.parse(varargin{:});
RGBImg=parser.Results.RGBImg;
DepthMap=parser.Results.DepthMap;
NumofBP=parser.Results.NumofBP;
colorbit=parser.Results.colorbit;
Isize=parser.Results.Isize;
DepthBG=parser.Results.DepthBG;
%--------------------------------------------------------------------------
function tf=CheckRGBImg(RGBImg)
validateattributes(RGBImg,{'numeric'},{'3d'},mfilename,'RGBImg');
tf=true;

%--------------------------------------------------------------------------
function tf=CheckDepthMap(DepthMap)
validateattributes(DepthMap,{'numeric'},{'2d'},mfilename,'DepthMap');
tf=true;
      
%--------------------------------------------------------------------------
function tf=CheckIsize(Isize)
validateattributes(Isize,{'numeric'},{'numel',2,'integer','positive'},mfilename,'Isize');
tf=true;

%--------------------------------------------------------------------------
function tf=CheckDepthBG(DepthBG)
validateattributes(DepthBG,{'string'},{'nonempty'},mfilename,'DepthMap');

s1={DepthBG,DepthBG};
s2={'white','black'};
tf=sum(strcmp(s1,s2));


%--------------------------------------------------------------------------
function [RGBImg_out,DepthMap_out]=ResizeImg(RGBImg,DepthMap,Isize)

[m1,n1,q1]=size(RGBImg);
[m2,n2]=size(DepthMap);

if (m1~=m2)&&(n1~=n2)
    error(message('RGBImg and DepthMap not match'));
end

m=m1;
n=n1;

if (m~=Isize(1))||(n~=Isize(2))
    m_s=floor((m-Isize(1))/2)+1;
    n_s=floor((n-Isize(2))/2)+1;
    m_e=m_s+Isize(1)-1;
    n_e=n_s+Isize(2)-1;
    
    RGBImg_out=RGBImg(m_s:m_e,n_s:n_e,:);
    DepthMap_out=DepthMap(m_s:m_e,n_s:n_e);
else
   RGBImg_out=RGBImg;
   DepthMap_out=DepthMap;
end

%--------------------------------------------------------------------------
function RGB_BR=Color2Binary(RGBImg,colorbit)
RB=fliplr(double(de2bi(RGBImg(:,:,1),8)));
GB=fliplr(double(de2bi(RGBImg(:,:,2),8)));
BB=fliplr(double(de2bi(RGBImg(:,:,3),8)));
m=colorbit/3;
RGB_BR=[RB(:,1:m),GB(:,1:m),BB(:,1:m)];

%--------------------------------------------------------------------------
function DepthMap_norm=DepthMapNormlization(DepthMap)

max_D=max(max(DepthMap));

if max_D~=1
DepthMap_norm=double(DepthMap)/max_D;
else
DepthMap_norm=DepthMap;
end

%--------------------------------------------------------------------------
function DepthList=GenDepthList(NumofBP,NumofCP,colorbit)

DepthPlane=linspace(0,1,NumofBP);
DepthList=zeros([1,NumofCP]);

for i=1:colorbit
    DepthList=DepthList+DepthPlane(i:end-colorbit+i);
end
DepthList=DepthList/colorbit;


%--------------------------------------------------------------------------
function [Image_sequence,Image_CutVol]=GenImgSeq(RGBImg_re,DepthImg_norm,DepthList,NumofBP,NumofCP,colorbit,RGB_BR,Isize,DepthBG)

if strcmp(DepthBG,'white')
ValidIndex=find(DepthImg_norm<1);
else
ValidIndex=find(DepthImg_norm>0);
end


DepthSeparater=[0,(DepthList(1:end-1)+DepthList(2:end))/2,1];
Image_sequence=zeros([Isize NumofBP]);
Image_CutVol=zeros([Isize 3 NumofBP]);

for i=1:NumofCP
    index=find(DepthImg_norm>=DepthSeparater(i)&DepthImg_norm<DepthSeparater(i+1));
    index=intersect(index,ValidIndex);
    
    if~isempty(index)
        
        s=mod(i,colorbit);
            
            if s==0
                s=colorbit;
            end
        
        for j=1:numel(index)
            [a,b]=ind2sub(Isize, index(j));
            Image_sequence(a,b,i:(i+colorbit-1))=[RGB_BR(index(j),s:end),RGB_BR(index(j),1:s-1)];
            Image_CutVol(a,b,:,i)=RGBImg_re(a,b,:);
        end
          
    end
    
end