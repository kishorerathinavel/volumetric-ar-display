function custom_plot_save(xdata, ydata, filename, y_min_range, y_max_range, x_min_range, x_max_range)

figure('units','normalized','outerposition', [0 0 0.99 0.98], 'visible', 'on');
plot(xdata, ydata, '+', 'LineWidth', 2);
%ylim([y_min_range y_max_range]);
%xlim([x_min_range x_max_range]);
set(gcf, 'PaperPositionMode', 'auto');
set(gca, 'FontSize', 50);
print(filename, '-dsvg');
