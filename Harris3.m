function P = Harris3(I, sigma, tau, k, theta_corn)
% tau : time scale 2
% sigma: space scale 4

L = fastGauss(I,sigma,tau);

% 1,3,1 Dx
% 3,1,1 Dy
% 1,1,3 Dt
PKD = [-1 0 1];
l = cell(3,1);
l{1} = imfilter(L,reshape(PKD,[1 3 1]),'conv','symmetric'); %Dx
l{2} = imfilter(L,reshape(PKD,[3 1 1]),'conv','symmetric'); %Dy
l{3} = imfilter(L,reshape(PKD,[1 1 3]),'conv','symmetric'); %Dt

D = cell(3);

for i=1:3
    for j=1:3
        D{i}{j} = l{i}.*l{j};
    end
end

M = cell(3);

for i=1:3
    for j=1:3
        M{i}{j} = fastGauss(D{i}{j},sigma,tau);
    end
end

detM = M{1}{1}.*(M{2}{2}.*M{3}{3} - M{2}{3}.*M{3}{2}) ...
     - M{1}{2}.*(M{2}{1}.*M{3}{3} - M{3}{1}.*M{2}{3}) ...
     + M{1}{3}.*(M{2}{1}.*M{3}{2} - M{2}{2}.*M{3}{1});
 
H = detM - k.*((M{1}{1}+M{2}{2}+M{3}{3}).^3);

ns = 3*ceil(sigma/2)+1;
[x,y,z] = ndgrid(-ns:ns);
se = strel(sqrt(x.^2 + y.^2 + z.^2) <= ns);
cond1 = (H == imdilate(H, se));
m = max(H(:));
cond2 = (H > theta_corn * m);
P = cond1 & cond2;

end