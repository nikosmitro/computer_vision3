function [dx,dy] = lk(I1, I2, rho, epsilon, d_x0, d_y0, option)

I1 = I1./max(I1(:));
I2 = I2./max(I2(:));

ns = 5;
Gr = fspecial('gaussian', [ns ns], rho);

[x0,y0] = meshgrid(1:size(I1,2),1:size(I1,1));

dx = d_x0 .* ones(size(I1,1),size(I1,2));
dy = d_y0 .* ones(size(I1,1),size(I1,2));


%% Convergence boundaries
%1) Max Difference of Energies (Absolute)
q(1) = 0.08;

%2) Difference of Max Energies (Absolute)
q(2) = 0.001;


%3) Sum of absolute difference of energies.
q(3) = 1;
% 0.01* taxh megethous

%4) Max iterations
q(4) = 0;

% idxr = sub2ind(size(I1),x(:,1),x(:,2));
[Igrad_x, Igrad_y] =  imgradientxy(I1);

Ii = interp2(I1,x0+dx,y0+dy,'linear',0);
E = I2 - Ii;
Q = q(option)+1;

i=0;
while(Q > q(option))
    i = i+1;
    
    A1 = interp2(Igrad_x,x0+dx,y0+dy,'linear',0);
    A2 = interp2(Igrad_y,x0+dx,y0+dy,'linear',0);
    
    u11 = imfilter(A1.^2,Gr,'symmetric')+epsilon;
    u12 = imfilter(A1.*A2,Gr,'symmetric');
    u22 = imfilter(A2.^2,Gr,'symmetric')+epsilon;
    up1 = imfilter(A1.*E,Gr,'symmetric');
    up2 = imfilter(A2.*E,Gr,'symmetric');
    
    ud = u11.*u22 - u12.^2; %determinant
    
    ux = (u22.*up1 - up2.*u12)./ud;
    uy = (up2.*u11 - u12.*up1)./ud;
    
    dx = dx+ux;
    dy = dy+uy;
    
    Ii = interp2(I1,x0+dx,y0+dy,'linear',0);
    Ep = E;
    E = I2 - Ii;
    
    %%% Convergence criteria
    
    %% 1)
    switch option
        case 1
            tp = E-Ep;
            Q = max(abs(tp(:)));
        case 2
            Q = abs(max(abs(E(:)))-max(abs(Ep(:))));
        case 3
            tp = (E-Ep).^2;
            Q = sum(tp(:));
        case 4
            niter = 24;
            Q = niter-i;
    end 
end
%display(['Took ',num2str(i), ' rounds to converge']);

end