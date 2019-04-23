Image = zeros(1080, 1920,3);
%%
bunny = double(imread('trial_13_rgb.png'));
load('trial_13_DepthMap.mat');

index = find(repmat(DepthMap,1,1,3)>=3.99);
bunny(index)=0;

imshow(uint8(bunny),[]);

m_s = floor((1080 -768)/2);
n_s = floor((1920 -1024)/2);
m_e = m_s + 768 - 1;
n_e = n_s + 1024 - 1;
Image(m_s:m_e, n_s:n_e,:) = bunny;

imshow(uint8(Image),[]);

imwrite(uint8(Image), 'Test_Image.jpg');