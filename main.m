clear; close all; clc;

seed = 1;
inputDir = "./input/";
inputFiles = ["s1.wav", "s2.wav"];

% Set pseudorandom seed
rng(seed);

mixMat = ... % 混合行列
    [0.8, -0.5;
    -0.7, 0.9];

for iData = 1:numel(inputFiles) % 1から2(inputFilesの大きさ)までをiDataに入れて繰り返す
    inputPath = inputDir + inputFiles(iData); % 信号までのパス
    [src(:, iData), fs] = audioread(inputPath); % 信号源の取得
end

x = mixMat * src.'; % 観測信号を作成

% 自然勾配法に基づくICAによるBSS
u = 0.01; % ステップサイズ
L = 1000; % 反復回数

y = ICA(x, u, L); % ICAの実行

soundsc(y(2, :), fs); % 分離信号の再生