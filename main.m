%% matlab code for BTOT(Binary Tree and Optimized Truncation)
% unoptimized, without head information, without entropy coding.
% 
% Reference:
% 
% Ke-Kun Huang, Hui Liu, Chuan-Xian Ren, Yu-Feng Yu and Zhao-Rong Lai. 
% Remote sensing image compression based on binary tree and optimized truncation.  
% Digital Signal Processing, vol. 64, pp. 96-106, 2017.
% http://dx.doi.org/10.1016/j.dsp.2017.02.008
% 
% Email: kkcocoon@163.com
% Homepage: http://www.scholat.com/huangkekun

clc;clear;
%% -----------   Input   ----------------
imname = 'SanDiego.bmp';
I_Orig = double(imread(imname));

[row, col] = size(I_Orig);
blksize = 64;  

%% -----------   Wavelet Decomposition   -------------
n_log = log2(row); 
level = floor(n_log);
I_Dec = wavecdf97(I_Orig, level);
    
n_min = 1;
brates = [0.0625, 0.125, 0.25, 0.5, 1];

%% -----------   Coding   ----------------
[out_code, blklen, n_max, n_min, out_S,out_R,out_N] = encode(I_Dec, blksize, n_min);    
%%
% 
% <<FILENAME.PNG>>
% 
% 
%   for x = 1:10
%       disp(x)
%   end
% 
%% -----------   Decoding   ----------------
disp([ 'aa_BTOT_' imname(1:end-4) '=[']);
for rate=brates
    I_DecR = decode(out_code, blklen, n_max, n_min, blksize, row, rate, out_S,out_R,out_N);
    
    I_Rec = wavecdf97(I_DecR, -level);
    MSE = sum(sum((I_Rec - I_Orig).^2))/(row*row);
    PSNR = 10*log10(255*255/MSE);
    disp([sprintf('%.4f',rate) ' ' sprintf('%.2f',PSNR)]);
end
disp('];');