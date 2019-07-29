function points = visualization(B,scale)
q = find(B);
[r, c, t] = ind2sub(size(B), q);
points = [c, r, scale*ones(size(r)), t];
end

