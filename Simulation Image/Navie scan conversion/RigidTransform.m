function V= RigidTransform(verts,Rotate,T,order)

[A,I]=sort(order);
V=verts;

switch I(1)
    case 1
        V=Rotate_x(V,Rotate(1));
    case 2
        V=Rotate_y(V,Rotate(2));
    case 3
        V=Rotate_z(V,Rotate(3));
    case 4
        V=Transform(V,T);
end


switch I(2)
    case 1
        V=Rotate_x(V,Rotate(1));
    case 2
        V=Rotate_y(V,Rotate(2));
    case 3
        V=Rotate_z(V,Rotate(3));
    case 4
        V=Transform(V,T);
end

switch I(3)
    case 1
        V=Rotate_x(V,Rotate(1));
    case 2
        V=Rotate_y(V,Rotate(2));
    case 3
        V=Rotate_z(V,Rotate(3));
    case 4
        V=Transform(V,T);
end

switch I(4)
    case 1
        V=Rotate_x(V,Rotate(1));
    case 2
        V=Rotate_y(V,Rotate(2));
    case 3
        V=Rotate_z(V,Rotate(3));
    case 4
        V=Transform(V,T);
end

%--------------------------------------------------------------------------

function V=Rotate_x(verts,x)

V=verts;
V(:,2)=V(:,2)*cos(x)-V(:,3)*sin(x);
V(:,3)=V(:,2)*sin(x)+V(:,3)*cos(x);

function V=Rotate_y(verts,y)

V=verts;
V(:,3)=V(:,3)*cos(y)-V(:,1)*sin(y);
V(:,1)=V(:,3)*sin(y)+V(:,1)*cos(y);


function V=Rotate_z(verts,z)

V=verts;
V(:,1)=V(:,1)*cos(z)-V(:,2)*sin(z);
V(:,2)=V(:,1)*sin(z)+V(:,2)*cos(z);

function V=Transform(verts,T)

V=verts+repmat(T,size(verts,1),1);