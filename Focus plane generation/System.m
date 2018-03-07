function F=System(x,f_t1,f_t2,n,f)

% f is x(1)
% l is x(2)
% o is x(3)

F(1)=(x(1)*x(3)+x(1)*x(2))*f_t1-x(1)*x(2)*x(3)-((x(1)-x(2)-x(3))*f_t1+x(2)*x(3)-x(1)*x(3))*n;
F(2)=(x(1)*x(3)+x(1)*x(2))*f_t2-x(1)*x(2)*x(3)-((x(1)-x(2)-x(3))*f_t2+x(2)*x(3)-x(1)*x(3))*f;
F(3)=x(1)-0.5;
