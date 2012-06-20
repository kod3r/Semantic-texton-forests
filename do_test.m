function do_test(config_file)
%%%%%%%%%%%%%%%%%%%%
% Testing STF just for pixel level output
% 1. preprocess test data (make patches)
% 2. let it go down the tree, get class distribution P(C|X) and the
% bag of semantic texton histogram BOST, a non-normalized histogram
% that concatenates the occurrences of tree nodes across all trees
%
% May 30 '12 Angjoo Kanzawa
%%%%%%%%%%%%%%%%%%%%
DISPLAY = 1;
eval(config_file); % load settings

%% load the forest
load(PATH.forestFilled);

fid = fopen(PATH.testNames, 'r');
imageNames = textscan(fid, '%s');
imageNames = imageNames{1};
fclose(fid);
numTest = numel(imageNames);
wait = waitbar(0, 'testing');

for i = 1:numTest
    data = getPatches(imageNames{i}, DIR, [], BOX, []);   
    patches = [data.patch];
    % make it d by d by N by 3
    patches = reshape(patches, size(patches, 1), ...
                      size(patches, 1), numel(data), 3);        
    dist = zeros(numClass, numel(data), FOREST.numTree);
    for t = 1:FOREST.numTree            
        dist(:, :, t) = forest(t).classify(patches);
        % sfigure; bar(test(:, 550)); title(sprintf('dist of tree %d', t));
    end
    distAll = sum(dist, 3)./FOREST.numTree;
    % normalize
    distAll = bsxfun(@rdivide, distAll+(1e-4./numClass), sum(distAll)+1e-4);
    [~, pred] = max(distAll, [], 1);
    I = imread(fullfile(DIR.images, imageNames{i}));
    [r, c, ~] = size(I);
    pred = reshape(pred, r, c);
    predRGB = label2rgb(pred, LABELS./255);
    h=figure(1); imagesc(I), hold on;
    himage = imagesc(predRGB);
    set(himage, 'AlphaData', 0.4);
    print(h, fullfile(DIR.result, imageNames{i}))
    %    imwrite(fullfile(DIR.result, imageNames{i}), 'bmp');
    wait = waitbar(i/numTest, wait, sprintf(['done evaluating test ' ...
                        'image %d'], i));
end                                   
close(wait);



