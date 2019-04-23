clear all ;
%%
I = uint8(zeros([768,1024,3]));



%pos =[0;1;2;3;4;5;6;7]*[68,50]+[150,80];
 pos =[300,500;
       360,480;
       420,460;
       480,440;
       540,420;
       600,400;
       650,390;
       700,380] + [-100,-200];
  
  
color = [2^6;2^5;2^7;2^4;2^0;2^3;2^1;2^2]*[1,1,1];

%color = [2^7;2^6;2^6;2^6;2^6;2^6;2^6;2^6]*[1,1,1];
Text =['A';'B';'C';'D';'E';'F';'G';'H'];
size = [110;95;84;79;75;65;53;45];

for i=1:8
I = insertText(I, pos(i,:), Text(i,:), 'FontSize', size(i,:), 'TextColor', color(i,:),'Boxopacity',0);
end


imshow(I,[]);
%%
Test = uint8(zeros([1080,1920,3]));

m = floor((1080-768)/2);
n = floor((1920-1024)/2);

Test(m:m+767,n:n+1023,:) = I;
imshow(Test,[]);
%%
imwrite(flipud(Test),'AlphaTest.png');