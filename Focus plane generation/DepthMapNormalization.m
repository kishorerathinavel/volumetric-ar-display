function DepthMap_norm=DepthMapNormlization(DepthMap)

max_D=max(max(DepthMap));

if max_D~=1
DepthMap_norm=double(DepthMap)/max_D;
else
DepthMap_norm=DepthMap;
end
