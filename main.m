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

% ソースイメージを求める(森末先輩のやり方)
mixMat1 = [0.8, 0;
          -0.7, 0];
mixMat2 = [0, -0.5;
           0, 0.9];

src1Img = (mixMat1 * srcSig.').'; % ソース1のソースイメージ（T×M行列）
src2Img = (mixMat2 * srcSig.').'; % ソース2のソースイメージ（T×M行列）

obsSig = src1Img + src2Img; % 観測信号を作成（T×M行列）
% obsSig = (mixMat * srcSig.').' 前までのやり方（T×M行列）

% 自然勾配法に基づくICAによるBSS
% 定数の定義
u = 0.01; % ステップサイズ
L = 1000; % 反復回数
nSrc = 2; % 音源数
nMic = 2; % マイクロホン数
refMic = 1; % レファレンス

% Set pseudorandom seed
rng(seed);
estSig = ICA(obsSig, u, L, nSrc, nMic, refMic); % ICAの実行（y:T×N行列)

sound(estSig(:, 1), fs); % 分離信号の再生