clear; close all; clc;

seed = 1;
inputDir = "./input/";
inputFiles = ["s1.wav", "s2.wav"];

% M:マイクロホン数,2 N:音源数,2 T:信号長,224001
mixMat = ... % 混合行列 （M×N行列)
    [0.8, -0.5;
    -0.7, 0.9];

for iData = 1:numel(inputFiles) % 1から2(inputFilesの大きさ)までをiDataに入れて繰り返す
    inputPath = inputDir + inputFiles(iData); % 信号までのパス
    [srcSig(:, iData), fs] = audioread(inputPath); % 信号源の取得（T×N行列）
end

% Set pseudorandom seed
rng(seed);
obsSig = (mixMat * srcSig.').'; % 観測信号を作成（T×M行列）

% 自然勾配法に基づくICAによるBSS
% 定数の定義
u = 0.01; % ステップサイズ
L = 1000; % 反復回数
nSrc = 2; % 音源数
nMic = 2; % マイクロホン数

estSig = ICA(obsSig, u, L, nSrc, nMic); % ICAの実行（y:T×N行列)

soundsc(estSig(:, 2), fs); % 分離信号の再生