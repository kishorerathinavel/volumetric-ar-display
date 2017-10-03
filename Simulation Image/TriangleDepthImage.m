function Image_sequence=TriangleDepthImage(triangle,depthRange,Isize,NumofP)


Image_sequence=zeros([Isize,NumofP]);
t=linspace(depthRange(1),depthRange(2),NumofP);

triangle1=triangle(1:3,:);
triangle2=triangle(4:6,:);





for i=1:NumofP
    
    s1=triangle1(:,3)-t(i);
    s2=triangle2(:,3)-t(i);
    
    [p1,p2,p3]=SortEnds(s1);
    
    
    if ~isempty(p1)
        
        [x,y]=ComputeInterLine(p1,p2,p3,Isize,t(i),triangle1);
    
    
    
    indice=sub2ind(size(Image_sequence),y,x,i+zeros(1,numel(x)));
    Image_sequence(indice)=1;
    
    end
    
    
    [p1,p2,p3]=SortEnds(s2);
    
    if ~isempty(p1)
        
        [x,y]=ComputeInterLine(p1,p2,p3,Isize,t(i),triangle2);
    
    
    
    indice=sub2ind(size(Image_sequence),y,x,i+zeros(1,numel(x)));
    Image_sequence(indice)=1;
    
    end
end






function [x,y]=ComputeInterLine(p1,p2,p3,Isize,z,triangle)

     k1=(z-triangle(p1,3))/(triangle(p2,3)-triangle(p1,3));
     k2=(z-triangle(p1,3))/(triangle(p3,3)-triangle(p1,3));
     
     coord=[triangle(p1,1:2)+k1*(triangle(p2,1:2)-triangle(p1,1:2));...
                 triangle(p1,1:2)+k2*(triangle(p3,1:2)-triangle(p1,1:2))];
             
             coord(:,1)=coord(:,1)+Isize(2)/2;
             coord(:,2)=Isize(1)/2-coord(:,2);
             
             [a,fsort]=sort(coord(:,1));
             coord=coord(fsort,:);
             
             slope=(coord(2,2)-coord(1,2))/(coord(2,1)-coord(1,1));
             
             if slope<=1
             x=coord(1,1):1:coord(2,1);
             y=(x-coord(1,1))*slope+coord(1,2);
             
             else
             [a,fsort]=sort(coord(:,2));
             coord=coord(fsort,:);
             
             slope=(coord(2,1)-coord(1,1))/(coord(2,2)-coord(1,2));
             y=coord(1,2):1:coord(2,2);
             x=(y-coord(1,2))*slope+coord(1,1);
             end
             
             x=round(x);
             y=round(y);








function [p1,p2,p3]=SortEnds(s)

    n=numel(find(s>=0));
    
    switch n
        case 1
            p1=find(s>=0);
            index=find(s<0);
            p2=index(1);
            p3=index(2);
        case 2
            p1=find(s<0);
            index=find(s>=0);
            p2=index(1);
            p3=index(2);
        otherwise
            p1=[];
            p2=[];
            p3=[];
    end
 



        

