function ImageSeqNew = custom_resize(factor, ImageSeq)

[m,n,b,num] = size(ImageSeq);
ImageSeqNew = zeros([m,n,b,num]);

for i=1:num
    I = imresize(ImageSeq(:,:,:,i), factor(i)); 
    I_new =zeros([m,n,b]);
    [m_I,n_I,b_I] = size(I);
    
    % remove registration error by only utilizing even number rows and
    % columns
    if mod(m_I,2) == 1
        m_I = m_I + 1;
    end
    
    if mod(n_I,2) == 1
        n_I = n_I + 1;
    end
    
    I = imresize(ImageSeq(:,:,:,i),[m_I, n_I]);
    
    m_start = floor((m - m_I)/2)+1;
    m_end = m_start + m_I - 1;
    n_start = floor((n - n_I)/2)+1;
    n_end = n_start + n_I - 1;
    
    I_new(m_start:m_end,n_start:n_end,:) = I;
    ImageSeqNew(:,:,:,i) = I_new;
end
end