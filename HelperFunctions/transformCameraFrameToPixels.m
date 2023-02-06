function [px, py, z] = transformCameraFrameToPixels(pointWrtCam, intrinsics)
%     K = intrinsics.IntrinsicMatrix;
%     fx = K(1,1);
%     fy = K(2,2);
%     cx = K(3,1);
%     cy = K(3,2);
% 
%     k_1 = intrinsics.RadialDistortion(1);
%     k_2 = intrinsics.RadialDistortion(2);
%     k_3 = 0;%intrinsics.RadialDistortion(3);
%     disp(intrinsics.RadialDistortion)
%     p_1 = intrinsics.TangentialDistortion(1);
%     p_2 = intrinsics.TangentialDistortion(2);
% % 
%     x_prime = pointWrtCam(1) / pointWrtCam(3);
%     y_prime = pointWrtCam(2) / pointWrtCam(3);
%     r = sqrt(x_prime^2 + y_prime^2);
% % 
%     x = x_prime * (1 + k_1 * r^2 + k_2 * r^4 + k_3 * r^6) + 2 * p_1 * x_prime * y_prime + p_2 * (r^2 + 2 * x_prime^2);
%     y = y_prime * (1 + k_1 * r^2 + k_2 * r^4 + k_3 * r^6) + p_1 * (r^2 + 2 * y_prime^2) + 2 * p_2 * x_prime * y_prime;
% 
% %     px = round((fx * pointWrtCam(1)) / pointWrtCam(3) + cx);
% %     py = round((fy * pointWrtCam(2)) / pointWrtCam(3) + cy);
%     px = round(fx * x + cx);
%     py = round(fy * y + cy);
    imagePoint = worldToImage(intrinsics, eye(3,3), [0 0 0], pointWrtCam(1:3)', 'ApplyDistortion', true);
    px = imagePoint(1);
    py = imagePoint(2);
    z = pointWrtCam(3);
end