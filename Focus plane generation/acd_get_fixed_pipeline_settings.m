function [descending, rgb] = acd_get_fixed_pipeline_settings()
    combinations = [[1,1]; [1,0]; [0,1]; [0,0]];
    combination_iter = 1;
    descending = combinations(combination_iter,1);
    rgb = combinations(combination_iter,2);
end
