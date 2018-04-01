function custom_plot_save(xdata, ydata, filename)

figure('units','normalized','outerposition', [0 0 0.99 0.98], 'visible', 'on');
plot(xdata, ydata, '+', 'LineWidth', 2);
set(gcf, 'PaperPositionMode', 'auto');
set(gca, 'FontSize', 50);
print(filename, '-dsvg');
