function DepthList=generate_depth_list(NumofBP,NumofCP,colorbit)

DepthPlane=linspace(0,1,NumofBP);
DepthList=zeros([1,NumofCP]);

for i=1:colorbit
    DepthList=DepthList+DepthPlane(i:end-colorbit+i);
end
DepthList=DepthList/colorbit;

