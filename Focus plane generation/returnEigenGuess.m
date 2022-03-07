function LEDs=returnEigenGuess(img)
LEDs = [];

r_img = img(:,:,1); 
g_img = img(:,:,2);
b_img = img(:,:,3);

r_vec = reshape(r_img, 1, []);
g_vec = reshape(g_img, 1, []);
b_vec = reshape(b_img, 1, []);

p_vec = [r_vec', g_vec', b_vec'];

nz_p_vec = p_vec(any(p_vec,2),:);
mean_nz_p_vec = mean(nz_p_vec);
nz_p_vec = bsxfun(@minus, nz_p_vec, mean(nz_p_vec));

[coeff, score, latent] = pca(nz_p_vec);


if(isempty(coeff))
    coeff = [0;0;0];
    score = 0;
end

LEDs = coeff(:,1);
LEDs(LEDs < 0) = 0;
% LEDs = mean(p_vec);

