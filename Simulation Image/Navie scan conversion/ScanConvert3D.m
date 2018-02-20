function Image_sequence=ScanConvert3D(varargin)



[verts,faces,depthRange,NumofP,Isize,linewidth]=parseInputs(varargin{:});
[lines, numofL]=LineSegments(faces);

Image_sequence=zeros([Isize,NumofP]);

DepthPlane=linspace(depthRange(1),depthRange(2),NumofP);
DepthPlane=fliplr(DepthPlane);

Space=DepthPlane(1)-DepthPlane(2);
SpaceRange=[DepthPlane-Space/2;DepthPlane+Space/2];




for i=1:numofL
   [x,y,p1,p2,x_sign]=ConnectLines(verts(lines(i,:),:),linewidth);
   [x_dispatch,y_dispatch,plane_dispatch]=LineDispatch(x,y,SpaceRange,Space,p1,p2,x_sign);
   [x_final,y_final,plane_final]=SetValidRange(x_dispatch,y_dispatch,plane_dispatch,p1,p2,Isize,NumofP,x_sign);
   
   if ~isempty(x_final)
   [x_image,y_image]=SpaceTransfer([x_final',y_final'],Isize);
   
   indice=sub2ind(size(Image_sequence),round(y_image),round(x_image),plane_final');
   Image_sequence(indice)=1;
   end
   
end










%--------------------------------------------------------------------------
function [verts,faces,depthRange,NumofP,Isize,linewidth]=parseInputs(varargin)

parser = inputParser;
parser.addRequired('Vertices',@CheckVertices);
parser.addRequired('Faces',@CheckFaces);
parser.addParameter('DepthRange',[-40 40], @CheckDepthRange)
parser.addParameter('Isize',[768,1024],@checkIsize);
parser.addParameter('NumofP',280);
parser.addParameter('linewidth',1);

parser.parse(varargin{:});

verts=parser.Results.Vertices;
faces=parser.Results.Faces;
depthRange=parser.Results.DepthRange;
Isize=parser.Results.Isize;
NumofP=parser.Results.NumofP;
linewidth=parser.Results.linewidth;

%--------------------------------------------------------------------------
function tf=CheckVertices(Vertices)
validateattributes(Vertices,{'numeric'},{'ncols',3},mfilename,'Vertices');
tf=true;

%--------------------------------------------------------------------------
function tf=CheckFaces(Faces)
validateattributes(Faces,{'numeric'},{'integer','positive'},mfilename,'Faces');
tf=true;
   
%--------------------------------------------------------------------------
function tf=CheckDepthRange(DepthRange)   
validateattributes(DepthRange,{'numeric'},{'numel',2},mfilename,'DepthRange');
     
   if DepthRange(1)>=DepthRange(2)
      error(message('DepthRange:order'));
   end
     
tf=true;
      
%--------------------------------------------------------------------------
function tf=checkIsize(Isize)
validateattributes(Isize,{'numeric'},{'numel',2,'integer','positive'},mfilename,'Isize');
tf=true;

%--------------------------------------------------------------------------
function [lines,numofL]=LineSegments(faces)
[m,n]=size(faces);

lines_seg=[];

for i=1:n
    
    if i~=n
    lines_seg=[lines_seg;faces(:,i:i+1)];
    else
    lines_seg=[lines_seg;faces(:,[n,1])];   
    end
end
    
lines_seg=sort(lines_seg,2);
lines=unique(lines_seg,'rows');
numofL=size(lines,1);


%--------------------------------------------------------------------------

function [x,y]=SpaceTransfer(verts,Isize)

x=verts(:,1)+Isize(2)/2;
y=Isize(1)/2-verts(:,2);

%--------------------------------------------------------------------------

function [x,y,p1,p2,x_dominate]=ConnectLines(Points3D,linewidth)
[A,index]=sort(Points3D(:,3));
p1=Points3D(index(1),:);
p2=Points3D(index(2),:);

dx=p2(1)-p1(1);
dy=p2(2)-p1(2);

if abs(dx)>abs(dy)
    x_dominate=true;
    step_x=dx/abs(dx);
    
    x=p1(1):step_x:p2(1);
    y=linspace(p1(2),p2(2),numel(x)); 
    
    if linewidth~=1
    x=[x,x,x,x,x,x,x];
    y=[y,y+3,y+2,y+1,y-1,y-2,y-3];
    end
    
else
    x_dominate=false;
    step_y=dy/abs(dy);
    
    y=p1(2):step_y:p2(2);
    x=linspace(p1(1),p2(1),numel(y));
    
    if linewidth~=1
    y=[y,y,y,y,y,y,y];
    x=[x,x+3,x+2,x+1,x-1,x-2,x-3];
    end
end

%--------------------------------------------------------------------------
function [x_dispatch,y_dispatch,plane_dispatch]=LineDispatch(x,y,SpaceRange,Space,p1,p2,x_sign)
[intersect,PlaneNum]=FindPoint(p1,p2,SpaceRange);



    
k=p2-p1;
step_xyz=k/k(3)*Space;

if PlaneNum==0
    x_dispatch=[];
    y_dispatch=[];
    plane_dispatch=[];
end


x_dispatch=x;
y_dispatch=y;

if x_sign
    plane_dispatch=DisPatch(x,p1(1),p2(1),PlaneNum,step_xyz(1),intersect(1));
else
    plane_dispatch=DisPatch(y,p1(2),p2(2),PlaneNum,step_xyz(2),intersect(2));
end





%--------------------------------------------------------------------------
function [intersect,PlaneNum]=FindPoint(p1,p2,SpaceRange)

a1=p1(3)-SpaceRange;
index1=find(a1(1,:)>=0);
index2=find(a1(2,:)<0);

if isempty(index1)
    PlaneNum=index2(end)+1;
    intersect=CalculateIntersect(p1,p2,SpaceRange(1,end));
else if isempty(index2)
       PlaneNum=0;
       intersect=[];
    else 
        if index1(1)==index2(end)
            PlaneNum=index1(1);
        else
            error(message('index incorrect'));
        end
        
        intersect=CalculateIntersect(p1,p2,SpaceRange(2,PlaneNum));
    end
end
        
    
%--------------------------------------------------------------------------
function intersect=CalculateIntersect(p1,p2,z)

k=(z-p1(3))/(p2(3)-p1(3));
intersect=p1+k*(p2-p1);

%--------------------------------------------------------------------------

function plane_dispatch=DisPatch(x,p1,p2,PlaneNum,step_xyz,intersect)
 

plane_dispatch=zeros(size(x));

[a,b]=sort([p1,intersect]);
index=find(x>=a(1)&x<=a(2));
plane_dispatch(index)=PlaneNum;

end_x=intersect;



if p1<p2
    while end_x<=p2
        PlaneNum=PlaneNum-1;
        start=end_x;
        end_x=end_x+step_xyz;
        index=find(x>=start&x<end_x);
        plane_dispatch(index)=PlaneNum;
    end
else
    while end_x>=p2
        PlaneNum=PlaneNum-1;
        start=end_x;
        end_x=end_x+step_xyz;
        index=find(x<=start&x>end_x);
        plane_dispatch(index)=PlaneNum;
    end
        
end

%--------------------------------------------------------------------------

function [x_final,y_final,plane_final]=SetValidRange(x_dispatch,y_dispatch,plane_dispatch,p1,p2,Isize,NumofP,x_sign)

index=find(plane_dispatch>=1&plane_dispatch<=NumofP);
x_dispatch=x_dispatch(index);
y_dispatch=y_dispatch(index);
plane_dispatch=plane_dispatch(index);


x_n=-Isize(2)/2;
x_p=Isize(2)/2;
index=find(x_dispatch>=x_n & x_dispatch<=x_p);
x_dispatch=x_dispatch(index);
y_dispatch=y_dispatch(index);
plane_dispatch=plane_dispatch(index);

y_n=-Isize(1)/2;
y_p=Isize(1)/2;
index=find(y_dispatch>=y_n & y_dispatch<=y_p);
x_dispatch=x_dispatch(index);
y_dispatch=y_dispatch(index);
plane_dispatch=plane_dispatch(index);


if x_sign
    [a,b]=sort([p1(1),p2(1)]);
    index=find(x_dispatch>=a(1) & x_dispatch<=a(2));
else
    [a,b]=sort([p1(2),p2(2)]);
    index=find(y_dispatch>=a(1) & y_dispatch<a(2));
end

x_final=x_dispatch(index);
y_final=y_dispatch(index);
plane_final=plane_dispatch(index);


