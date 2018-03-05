% MSBFirst
IntensityBin=[1 1 1 1 1 1 1 1;
              0 1 1 1 1 1 1 1;
              0 0 1 1 1 1 1 1;
              0 0 0 1 1 1 1 1;
              0 0 0 0 1 1 1 1;
              0 0 0 0 0 1 1 1;
              0 0 0 0 0 0 1 1;
              0 0 0 0 0 0 0 1];

Intensityhex=binaryVectorToHex(IntensityBin,'MSBFirst');

NumofBP=280;
colorbit=24;
m=floor(NumofBP/colorbit)+1;

Intensityhex_all=repmat(Intensityhex,3*m,1);
Intensityhex_all=Intensityhex_all(1:NumofBP);
Intensityhex_all=flipud(Intensityhex_all);



str1='static const char Intensity[]=';
fileID=fopen('Intensity.h','w');
fprintf(fileID,'%s',str1);
fprintf(fileID,'{');
fprintf(fileID,'0X%s,',Intensityhex_all{1:NumofBP});
fprintf(fileID,'};');

CLP_R=32;
CLP_G=31;
CLP_B=30;

% PIN select
PinSelect_R=repmat(CLP_R,1,8);
PinSelect_G=repmat(CLP_G,1,8);
PinSelect_B=repmat(CLP_B,1,8);

PinSelect=repmat([PinSelect_R,PinSelect_G,PinSelect_B],1,m);

str2='static const int PinSelect[]=';
fileID=fopen('PinSelect.h','w');
fprintf(fileID,'%s',str2);
fprintf(fileID,'{');
fprintf(fileID,'%d,',PinSelect(1:NumofBP));
fprintf(fileID,'};');