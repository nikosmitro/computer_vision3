function H = GaborFilter3(I,sigma,tau,max_samples)
% exo mal insi
ns = ceil(3*sigma)*2+1;
g = fspecial('gaussian',[ns 1], sigma);
q = reshape(g,[ns 1 1]);
M = imfilter(I,q,'conv','replicate');
q = reshape(g,[1 ns 1]);
M = imfilter(M,q,'conv','replicate');

omega = 4/tau;
ts = ceil(3*tau)*2+1;
t = linspace(-2*tau, 2*tau, ts);
hev(1,1,:) = -cos(2*pi.*t.*omega).*exp(-t.^2./(2.*tau.^2));
hod(1,1,:) = -sin(2*pi.*t.*omega).*exp(-t.^2./(2.*tau.^2));

H = imfilter(M,hev,'conv','replicate').^2 + imfilter(M,hod,'conv','replicate').^2;

B = ones(3, 3, 2);
Q = imdilate(H, B);
cond1 = (H == Q);
if(sum(cond1(:))<max_samples)
    H = cond1;
else
    R = H.*cond1;
    [Rs,~] = sort(R(:), 'descend');
    H = (R >= Rs(max_samples));
end
% qmax = max(Q,3);
% % qmax = repmat(qm,size(q,1),size(q,2),1);
% % size(qm)
% size(qmax)
% size(Q)
% 
% Qp = Q./qmax;
% l = Qp>=0;
% u = Qp<=1;
% cond2 = l.*u.*cond1;
%     
% sum(cond2(:))
% if (sum(cond2(:))<= max_samples)
%     H = cond1;
% else
%     q = find(cond1);
%     G = Q.*l.*u;
%     [~,idx] = sort(G(q),'descend');
%     H = zeros(size(H));
%     H(idx(1:400))=1;
% end

end