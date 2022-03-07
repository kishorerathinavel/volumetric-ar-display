function ImageSeqNew = FovResize(location,v_factor,ImageSeq)

[m,n,num] = size(ImageSeq);
ImageSeqNew = ImageSeq;


for i=1:length(location)
    
    f = v_factor(location(i))/v_factor(location(1));
    I = imresize(ImageSeq(:,:,location(i)), f);
    [m_I,n_I] = size(I);
    
    
    m_start = floor((m_I - m)/2)+1;
    m_end = m_start + m - 1;
    n_start = floor((n_I - n)/2)+1;
    n_end = n_start + n - 1;
    
    
    T =graythresh(I);
    I = 255* im2bw(I,T);
    I_new = I(m_start:m_end,n_start:n_end);
    ImageSeqNew(:,:,location(i)) = I_new;
end