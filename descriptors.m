function [HOG, HOF, HOGF] = descriptors(Video, Points, sigma)
tmax = size(Video,3);
y = Points(:,2);
x = Points(:,1);
np = size(Points,1);
for i = 1:np
    k = Points(i,4);
	s = size(Video(:,:,k));
    [dx(:,:,k), dy(:,:,k)] = lk(Video(:,:,k), Video(:,:,mod(k,tmax)+1), 8, 0.02, 0, 0, 4);
    [gx(:,:,k), gy(:,:,k)] = imgradientxy(Video(:,:,k));
    if (x(i) > 2*sigma && y(i) > 2*sigma && x(i) + 2*sigma <= size(gx, 2) && y(i) + 2*sigma <= size(gx, 1))
        sqdx = dx(y(i)-2*sigma:y(i)+2*sigma, x(i)-2*sigma:x(i)+2*sigma, k); 
        sqdy = dy(y(i)-2*sigma:y(i)+2*sigma, x(i)-2*sigma:x(i)+2*sigma, k);
        sqgx = gx(y(i)-2*sigma:y(i)+2*sigma, x(i)-2*sigma:x(i)+2*sigma, k);
        sqgy = gy(y(i)-2*sigma:y(i)+2*sigma, x(i)-2*sigma:x(i)+2*sigma, k);
        HOG(i, :) = OrientationHistogram(sqdx, sqdy, 3, [4, 4]);
        HOF(i, :) = OrientationHistogram(sqgx, sqgy, 3, [4, 4]);
        HOGF(i, :) = [HOG(i, :)  HOF(i, :)];
    end
end