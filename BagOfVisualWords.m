function BOVW = BagOfVisualWords(data, BRW)

centroids = 20;
[~, clusters] = kmeans(data, centroids);

for k = 1:9
    curr_data = BRW{k};
    for i = 1:size(curr_data,1)
        local = curr_data(i,:);
        distance(i,:) = LeastEucDist(local, clusters);
    end
    [~,mind_idx] = min(distance');
    hist = histc(mind_idx, 1:20);
    BOVW(k,:) = hist ./ norm(hist, 2);
end

end
