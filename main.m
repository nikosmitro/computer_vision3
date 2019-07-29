clc;
clear all;
close all;
addpath(genpath('support'));
vdir = 'Videos/';

%% Read Input
dst_boxing = {'person16_boxing_d4_uncomp','person21_boxing_d1_uncomp','person25_boxing_d4_uncomp'};
dst_running = {'person09_running_d1_uncomp','person15_running_d1_uncomp','person23_running_d3_uncomp'};
dst_walking = {'person07_walking_d2_uncomp','person14_walking_d2_uncomp','person20_walking_d3_uncomp'};
for i=1:3
    boxingV{i} = readVideo(['samples/boxing/',dst_boxing{i},'.avi'],Inf,false);
    boxingDV{i} = vid2double(boxingV{i});
    
    runningV{i} = readVideo(['samples/running/',dst_running{i},'.avi'],Inf,false);
    runningDV{i} = vid2double(runningV{i});

    walkingV{i} = readVideo(['samples/walking/',dst_walking{i},'.avi'],Inf,false);
    walkingDV{i} = vid2double(walkingV{i});
end


theta_corn = 0.003;
k = 0.001;
sigma = 3;
tau = 2;

samples = 400;

% switch verbose to false inorder to avoid exporting videos
verbose = false;
if(verbose)
    mkdir(vdir);
end

%% Get Features 1.1,1.2,1.3
for i=1:3
    % boxing
    Harris{1}{i} = Harris3(boxingDV{i}, sigma, tau, k,  theta_corn);
    HarrisPoints{1}{i} = visualization(Harris{1}{i},sigma);
    
    Gabor{1}{i} = GaborFilter3(boxingDV{i}, sigma, tau, samples);
    GaborPoints{1}{i} = visualization(Gabor{1}{i},sigma);
    
    % running
    Harris{2}{i} = Harris3(runningDV{i}, sigma, tau, k,  theta_corn);
    HarrisPoints{2}{i} = visualization(Harris{2}{i},sigma);
    
    Gabor{2}{i} = GaborFilter3(runningDV{i}, sigma, tau, samples);
    GaborPoints{2}{i} = visualization(Gabor{2}{i},sigma);
    
    % walking
    Harris{3}{i} = Harris3(walkingDV{i}, sigma, tau, k,  theta_corn);
    HarrisPoints{3}{i} = visualization(Harris{3}{i},sigma);
    
    Gabor{3}{i} = GaborFilter3(walkingDV{i}, sigma, tau, samples);
    GaborPoints{3}{i} = visualization(Gabor{3}{i},sigma);
    
    if(verbose)
        printDetection(boxingDV{i},HarrisPoints{1}{i},[vdir,'boxing',int2str(i),'_harris']);
        printDetection(boxingDV{i},GaborPoints{1}{i},[vdir,'boxing',int2str(i),'_gabor']);
        printDetection(runningDV{i},HarrisPoints{2}{i},[vdir,'running',int2str(i),'_harris']);
        printDetection(runningDV{i},GaborPoints{2}{i},[vdir,'running',int2str(i),'_gabor']);
        printDetection(walkingDV{i},HarrisPoints{3}{i},[vdir,'walking',int2str(i),'_harris']);
        printDetection(walkingDV{i},HarrisPoints{3}{i},[vdir,'walking',int2str(i),'_gabor']);
    end
end

%% Make Descriptors 2.1,2.2
for i=1:3

    % boxing
    [HOG_Harris{1}{i}, HOF_Harris{1}{i}] = descriptors(boxingDV{i}, HarrisPoints{1}{i}, sigma);

    [HOG_Gabor{1}{i}, HOF_Gabor{1}{i}] = descriptors(boxingDV{i}, GaborPoints{1}{i}, sigma);
    
    % running
    [HOG_Harris{2}{i}, HOF_Harris{2}{i}] = descriptors(runningDV{i}, HarrisPoints{2}{i}, sigma);

    [HOG_Gabor{2}{i}, HOF_Gabor{2}{i}] = descriptors(runningDV{i}, GaborPoints{2}{i}, sigma);
    
    % walking
    [HOG_Harris{3}{i}, HOF_Harris{3}{i}] = descriptors(walkingDV{i}, HarrisPoints{3}{i}, sigma);

    [HOG_Gabor{3}{i}, HOF_Gabor{3}{i}] = descriptors(walkingDV{i}, GaborPoints{3}{i}, sigma);
    
end

HOG_harris = [];
HOG_gabor = [];
HOF_harris = [];
HOF_gabor = [];
HOGF_harris = [];
HOGF_gabor = [];
for i=1:3
    for j=1:3
        HOG_harris = [HOG_harris ; HOG_Harris{i}{j}];
        HOG_harris_args{(i-1)*3+j} = HOG_Harris{i}{j};

        HOG_gabor = [HOG_gabor ; HOG_Gabor{i}{j}];
        HOG_gabor_args{(i-1)*3+j} = HOG_Gabor{i}{j};

        HOF_harris = [HOF_harris ; HOF_Harris{i}{j}];
        HOF_harris_args{(i-1)*3+j} = HOF_Harris{i}{j};

        HOF_gabor = [HOF_gabor ; HOF_Gabor{i}{j}];
        HOF_gabor_args{(i-1)*3+j} = HOF_Gabor{i}{j};

        HOGF_harris = [HOGF_harris ; [HOG_Harris{i}{j},  HOF_Harris{i}{j}]];
        HOGF_harris_args{(i-1)*3+j} = [HOG_Harris{i}{j},  HOF_Harris{i}{j}];
        
        HOGF_gabor = [HOGF_gabor ; [HOG_Gabor{i}{j},  HOF_Gabor{i}{j}]];
        HOGF_gabor_args{(i-1)*3+j} = [HOG_Gabor{i}{j},  HOF_Gabor{i}{j}];
    end
end

%% 2.3 Construct Bag of Visual Words
BOVW_HOG_harris = BagOfVisualWords(HOG_harris, HOG_harris_args);
BOVW_HOG_gabor = BagOfVisualWords(HOG_gabor, HOG_gabor_args);
BOVW_HOF_harris = BagOfVisualWords(HOF_harris, HOF_harris_args);
BOVW_HOF_gabor = BagOfVisualWords(HOF_gabor, HOF_gabor_args);
BOVW_HOGF_harris = BagOfVisualWords(HOGF_harris, HOGF_harris_args);
BOVW_HOGF_gabor = BagOfVisualWords(HOGF_gabor, HOGF_gabor_args);

%%3.1 Construction of the dendrograms with all possible combinations
%HOG_harris
link_HOG_harris = linkage(BOVW_HOG_harris, 'average', '@distChiSq');
figure(2);
dendrogram(link_HOG_harris);
title('HOG-Harris Dendrogram');

%HOG_gabor
link_HOG_gabor = linkage(BOVW_HOG_gabor, 'average', '@distChiSq');
figure(2);
dendrogram(link_HOG_gabor);
title('HOG-Gabor Dendrogram');

%HOF_harris
link_HOF_harris = linkage(BOVW_HOF_harris, 'average', '@distChiSq');
figure(3);
dendrogram(link_HOF_harris);
title('HOF-Harris Dendrogram');

%HOF_gabor
link_HOF_gabor = linkage(BOVW_HOF_gabor, 'average', '@distChiSq');
figure(4);
dendrogram(link_HOF_gabor);
title('HOF-Gabor Dendrogram');

%HOGF_harris
link_HOGF_harris = linkage(BOVW_HOGF_harris, 'average', '@distChiSq');
figure(5);
dendrogram(link_HOGF_harris);
title('HOGF-Harris Dendrogram');

%HOGF_gabor
link_HOGF_gabor = linkage(BOVW_HOGF_gabor, 'average', '@distChiSq');
figure(6);
dendrogram(link_HOGF_gabor);
title('HOGF-Gabor Dendrogram');

