function [Image_sequence,Image_CutVol]=GenerateImgSeq3(varargin)

[RGBImg,DepthMap,NumofBP,colorbit,Isize,Dlocation]=parseInputs(varargin{:});


[RGBImg_re,DepthMap_re]=ResizeImg(RGBImg,DepthMap,Isize);

RGB_BR=Color2Binary(RGBImg_re,colorbit);
%DepthMap_norm=DepthMapNormlization(DepthMap_re);
NumofCP=NumofBP-colorbit+1;

DepthList=GenDepthList(NumofBP,NumofCP,colorbit,Dlocation);
[Image_sequence,Image_CutVol]=GenImgSeq(RGBImg_re,DepthMap_re,DepthList,NumofBP,NumofCP,colorbit,RGB_BR,Isize,Dlocation);

%--------------------------------------------------------------------------
function [RGBImg,DepthMap,NumofBP,colorbit,Isize,Dlocation]=parseInputs(varargin)
parser = inputParser;
parser.addRequired('RGBImg',@CheckRGBImg);
parser.addRequired('DepthMap',@CheckDepthMap);
parser.addRequired('Dlocation',@CheckDlocation);
parser.addParameter('NumofBP',280);
parser.addParameter('colorbit',24);
parser.addParameter('Isize',[768,1024],@CheckIsize);

parser.parse(varargin{:});
RGBImg=parser.Results.RGBImg;
DepthMap=parser.Results.DepthMap;
Dlocation=parser.Results.Dlocation;
NumofBP=parser.Results.NumofBP;
colorbit=parser.Results.colorbit;
Isize=parser.Results.Isize;

%--------------------------------------------------------------------------
function tf=CheckDlocation(Dlocation)
validateattributes(Dlocation,{'numeric'},{'nondecreasing'},mfilename,'Dlocation');
tf=true;
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
function DepthList=GenDepthList(NumofBP,NumofCP,colorbit,Dlocation)


DepthList=zeros([1,NumofCP]);

for i=1:colorbit
    DepthList=DepthList+Dlocation(i:end-colorbit+i);
end
DepthList=DepthList/colorbit;


%--------------------------------------------------------------------------
function [Image_sequence,Image_CutVol]=GenImgSeq(RGBImg_re,DepthImg_re,DepthList,NumofBP,NumofCP,colorbit,RGB_BR,Isize,Dlocation)


ValidIndex=find(DepthImg_re<max(max(DepthImg_re)));



DepthSeparater=[Dlocation(1),(DepthList(1:end-1)+DepthList(2:end))/2,Dlocation(end)];
Image_sequence=zeros([Isize NumofBP]);
Image_CutVol=zeros([Isize 3 NumofBP]);

for i=1:NumofCP
    index=find(DepthImg_re>=DepthSeparater(i)&DepthImg_re<DepthSeparater(i+1));
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