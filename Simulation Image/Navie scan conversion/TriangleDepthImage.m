function [Image_sequence,colortype]=TriangleDepthImage(varargin)





[triangle1,triangle2,Colorvalue,depthRange,Isize,NumofP,radius,fused]= parseInputs(varargin{:});

Image_sequence=zeros([Isize,NumofP]);
t=linspace(depthRange(1),depthRange(2),NumofP);
diff=t(2)-t(1);

colorvalue1=Colorvalue(1:3);
colorvalue2=Colorvalue(4:6);

if size(Colorvalue,2)==1
    
    if all(Colorvalue==1)
        colortype='Binary';
    else
        colortype='GrayScale';
    end
    
else
    colortype='RGB';
end
    
    



for i=1:NumofP    
    s1=triangle1(:,3)-t(i);
    s2=triangle2(:,3)-t(i);
    
    [p1,sign]=SortEnds(s1);
    
    
    if ~isempty(p1)
        
        [x,y,point_color]=ComputeInterLine(p1(1),p1(2),p1(3),Isize,t(i),triangle1,colortype,colorvalue1);
    
        [m,n,color]=ComputewithR(x,y,point_color,radius,Isize);
        
    indice=sub2ind(size(Image_sequence),m,n,(NumofP-i+1)+zeros(numel(m),1));
    Image_sequence(indice)=color;
    
    end
    
    
    [p2,sign]=SortEnds(s2);
    
    if ~isempty(p2)
        
        [x,y,point_color]=ComputeInterLine(p2(1),p2(2),p2(3),Isize,t(i),triangle2,colortype,colorvalue2);
    
        [m,n,color]=ComputewithR(x,y,point_color,radius,Isize);
    
    indice=sub2ind(size(Image_sequence),m,n,(NumofP-i+1)+zeros(numel(m),1));
    Image_sequence(indice)=color;
    
    end
end



    
    
    


   
    
    











function [triangle1,triangle2,Colorvalue,depthRange,Isize,NumofP,radius,fused]=parseInputs(varargin)

parser = inputParser;
parser.addRequired('triangle',@checktriangle);
parser.addRequired('depthRange',@checkDepthRange);
parser.addOptional('Colorvalue',ones(6,1),@checkColor);
parser.addParameter('Isize',[768,1024],@checkIsize);
parser.addParameter('NumofP',100);
parser.addParameter('radius',3);
parser.addParameter('fused',true)

parser.parse(varargin{:});

triangle1=parser.Results.triangle(1:3,:);
triangle2=parser.Results.triangle(4:6,:);
Colorvalue=parser.Results.Colorvalue;
depthRange=parser.Results.depthRange;
Isize =parser.Results.Isize;
NumofP=parser.Results.NumofP;
radius=parser.Results.radius;
fused=parser.Results.fused;



function tf=checktriangle(triangle)
     validateattributes(triangle,{'numeric'},{'size',[6,3]},mfilename,'triangle');
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
     
function tf=checkColor(Colorvalue)
     validateattributes(Colorvalue,{'numeric'},{'nrows',6,'integer','positive'},mfilename,'Colorvalue');
     tf=true;
     
     
function [x,y,point_color]=ComputeInterLine(p1,p2,p3,Isize,z,triangle,colortype,colorvalue)

     k1=(z-triangle(p1,3))/(triangle(p2,3)-triangle(p1,3));
     k2=(z-triangle(p1,3))/(triangle(p3,3)-triangle(p1,3));
     
     coord=[triangle(p1,1:2)+k1*(triangle(p2,1:2)-triangle(p1,1:2));...
                 triangle(p1,1:2)+k2*(triangle(p3,1:2)-triangle(p1,1:2))];
             
             coord(:,1)=coord(:,1)+Isize(2)/2;
             coord(:,2)=Isize(1)/2-coord(:,2);
             x=round(coord(:,1));
             y=round(coord(:,2));
     
             
     if   ~strcmp(colortype,'Binary')
          point_color(1,:)=colorvalue(p1,:)+(colorvalue(p2,:)-colorvalue(p1,:))*k1;
          point_color(2,:)=colorvalue(p1,:)+(colorvalue(p3,:)-colorvalue(p1,:))*k2;
     else
          point_color=ones(2,1);
     end
     
             
             
             
function [m,n,color]=ComputewithR(x,y,point_color,radius,Isize)
 
         x1=x(1)-radius:x(1)+radius;
         y1=y(1)-radius:y(1)+radius;

         x1=x1(find(x1>0 & x1<=Isize(2)));
         y1=y1(find(y1>0 & y1<=Isize(1)));
         
         [n1,m1]=meshgrid(x1,y1);
         
         x2=x(2)-radius:x(2)+radius;
         y2=y(2)-radius:y(2)+radius;

         x2=x2(find(x2>0 & x2<=Isize(2)));
         y2=y2(find(y2>0 & y2<=Isize(1)));
         
         [n2,m2]=meshgrid(x2,y2);
         
         m=[m1(:); m2(:)];
         n=[n1(:); n2(:)];
         
         color=[repmat(point_color(1,:),numel(m1),1);repmat(point_color(2,:),numel(m2),1)];
         color(color>=256)=255;
         color=round(color);
    
         
 function [p,sign]=SortEnds(s)

    n=numel(find(s>=0));
    
    switch n
        case 1
            p(1)=find(s>=0);
            index=find(s<0);
            p(2)=index(1);
            p(3)=index(2);
            sign=1;
        case 2
            p(1)=find(s<0);
            index=find(s>=0);
            p(2)=index(1);
            p(3)=index(2);
            sign=2;
        otherwise
           p=[];
            sign=[];
    end  
    
    
function P=ComputeFused(triangle,t,diff)

    s1=triangle(:,3)-(t-diff/2);
    s2=triangle(:,3)-(t+diff/2);
    [p1,sign1]=SortEnds(s1);
    [p2,sign2]=SortEnds(s2);
    
    P.intersect=true;

    if ~isempty(p1)&&~isempty(p2)
  
        if sign1==sign2
            P.cat=1;
            P.verts=p1;
        else
            P.cat=2;
            index=[1,2,3];
            index(find(index==p1(1)|index==p2(1)))=[];
            P.verts=[p1(1);p2(1);index];
        end
        
    else if isempty(p1)&&isempty(p2)
            P.intersect=false;
            P.cat=[];
            P.verts=[];
            
        else if isempty(p1)&&~isempty(p2)
                
                if sign2==2
                    P.cat=3;
                    P.verts=p2;
                    P.near=true;
                else
                    P.cat=4;
                    P.verts=p2;
                    P.near=true;
                end
                
            else 
                
                if sign1==2
                    P.cat=4;
                    P.verts=p1;
                    P.near=false;
                else
                    P.cat=3;
                    P.verts=p1;
                    P.near=false;
                end
            end
                
                   
        end
        
    end
    
    
    
    

    
    
    
    

              

    
    

        
