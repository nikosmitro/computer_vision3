function M = fastGauss(I,sigma,tau)
ns = ceil(3*sigma)*2+1;
ts = ceil(3*tau)*2+1;

g = fspecial('gaussian',[ns 1], sigma);
q = reshape(g,[ns 1 1]);
M = imfilter(I,q,'conv','symmetric');

g = reshape(g,[1 ns 1]);
M = imfilter(M,g,'conv','symmetric');

g = fspecial('gaussian',[1 ts], tau);
g = reshape(g,[1 1 ts]);
M = imfilter(M,g,'conv','symmetric');

end