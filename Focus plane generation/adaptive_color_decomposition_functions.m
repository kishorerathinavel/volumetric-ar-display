function Image_sequence=adaptive_color_decomposition_functions(varargin)

[RGBImg,DepthMap,NumofBP,colorbit,Isize,DepthBG]=parseInputs(varargin{:});

DepthMap_norm=DepthMapNormlization(DepthMap_re);
NumofCP=NumofBP-colorbit+1;

DepthList=GenDepthList(NumofBP,NumofCP,colorbit);
Image_sequence=GenImgSeq(DepthMap_norm,DepthList,NumofBP,NumofCP,colorbit,RGB_BR,Isize,DepthBG);

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
