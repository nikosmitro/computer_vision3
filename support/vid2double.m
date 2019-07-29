function Id = vid2double(I)
    Id = zeros(size(I));
    for i=1:size(I,3)
        Id(:,:,i) = im2double(I(:,:,i));
    end
end