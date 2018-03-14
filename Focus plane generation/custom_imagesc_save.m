function custom_imagesc_save(data, filename, ifwrite)

imwrite(uint8(255*data), filename);
return;


%figure('units','normalized','outerposition', [0 0 1 1], 'visible', 'off');
% figure('units','normalized','outerposition', [0 0 1 1]);
%figure('units','normalized','outerposition', [0 0 0.48 0.64]);
%figure();
tight = false;
%figure('units','normalized','outerposition', [0 0 0.48 0.64], 'visible', 'off');
figure('visible', 'off');
c = [];

imagesc(data); 
axis image;
% origPosition = get(gca,'Position');
% origAspectRatio = (origPosition(3) - origPosition(1))/(origPosition(4)-origPosition(2));

c = colorbar;

colormap(jet);


if(tight)
    ax = gca;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset; 
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
end


% newPosition = get(gca,'Position');
% newWidth = newPosition(3) - newPosition(1);
% newHeight = newWidth/origAspectRatio;
% modifiedPosition = [newPosition(1) newPosition(2) newPosition(3) newPosition(2)+newHeight];
% set(gca,'Position',modifiedPosition);
axis off;

% print(gcf, filename, '-dpng', '-fillpage')
set(gcf, 'PaperPositionMode', 'auto');
saveas(gcf, filename, 'png');

if(tight)
    str = sprintf('%s.png',filename);
    img = imread(str);
    gray = rgb2gray(img);
    gray(gray == 255) = 0;
    s1 = sum(gray,1);
    s2 = sum(gray,2);
    zeroCols = find(s1 == 0);
    zeroRows = find(s2 == 0);
    img(zeroRows,:,:) = [];
    img(:,zeroCols,:) = [];
    imwrite(img, str);
end


