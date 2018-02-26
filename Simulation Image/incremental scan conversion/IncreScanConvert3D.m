function Image_sequence = IncreScanConvert3D(varargin)


[faces,verts,depthRange,Isize,NumofP,radius]= parseInputs(varargin{:});

Image_sequence=zeros([Isize,NumofP]);
t=linspace(depthRange(1),depthRange(2),NumofP);




function [faces,verts,depthRange,Isize,NumofP,radius]=parseInputs(varargin)

parser = inputParser;
parser.addRequired('Vertices',@checkVertices);
parser.addRequired('Faces',@checkFaces);
parser.addRequired('depthRange',@checkDepthRange);
parser.addParameter('Isize',[768,1024],@checkIsize);
parser.addParameter('NumofP',100);
parser.addParameter('radius',3);

parser.parse(varargin{:});

faces=parser.Results.Faces;
verts=parser.Results.Vertices;
depthRange=parser.Results.depthRange;
Isize =parser.Results.Isize;
NumofP=parser.Results.NumofP;
radius=parser.Results.radius;


function tf=checkVertices(Vertices)
         validateattributes(Vertices,{'numeric'},{'ncols',3},mfilename,'Vertices');
         tf=true;

function tf=checkFaces(Faces)
         validateattributes(Faces,{'numeric'},{'integer','positive'},mfilename,'Faces');
         tf=true;

function tf=checkDepthRange(depthRange)
     validateattributes(depthRange,{'numeric'},{'numel',2},mfilename,'depthRange');
     
     if depthRange(1)>=depthRange(2)
         error(message('depthRange:order'));
     end
     
     tf=true;

function tf=checkIsize(Isize)
     validateattributes(Isize,{'numeric'},{'numel',2,'integer','positive'},mfilename,'Isize');
     tf=true;