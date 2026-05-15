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

src1Img = (mixMat1 * srcSig.').'; % 音源1のソースイメージ（T×M行列）
src2Img = (mixMat2 * srcSig.').'; % 音源2のソースイメージ（T×M行列）

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

% sound(estSig(:, 1), fs); % 分離信号の再生

% SDR, SIRの計算
addpath("./bss_eval/"); % ファイルの中身の関数を使用できるようにする
refSig = [src1Img(:, refMic), src2Img(:, refMic)]; % ch1のソースイメージ
[inSdr, inSir] = bss_eval_sources(obsSig.', refSig.'); % 観測信号のsdrとsirを計算
[outSdr, outSir, outSar] = bss_eval_sources(estSig.', refSig.'); % スケール補正後の分離信号のsdrとsirとsarを計算
impSdr = outSdr - inSdr; % sdrの改善量を計算
impSir = outSir - inSir; % sirの改善量を計算

% sdr, sirの出力
% SDR、SIRの出力
disp("--- SDR improvement ---")
for s = 1:2 % 音源数分繰り返し
    fprintf("S%d: %.10f [dB]\n",s, impSdr(s)); % sdrを表示
end
disp("--- SIR improvement ---")
for s = 1:2 % 音源数分繰り返し
    fprintf("S%d: %.10f [dB]\n",s, impSir(s)); % sirを表示
end

% 音の出力
outputDir = "./output/"; % 出力先を指定
if ~exist(outputDir, 'dir') % 指定のフォルダがない場合作成
    mkdir(outputDir);
end

audiowrite(outputDir+"referenceSignal1.wav", refSig(:, 1), fs); % 音源1のソースイメージ
audiowrite(outputDir+"referenceSignal2.wav", refSig(:, 2), fs); % 音源2のソースイメージ
audiowrite(outputDir+"estimatedSignal1.wav", estSig(:, 1), fs); % 分離信号1
audiowrite(outputDir+"estimatedSignal2.wav", estSig(:, 2), fs); % 分離信号2
audiowrite(outputDir+"observedSignal.wav", obsSig(:, refMic), fs); % 観測信号