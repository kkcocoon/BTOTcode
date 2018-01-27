function [out_code, blklen, n_max, n_min, out_S,out_R,out_N] = encode(I_Dec, blksize, n_min)

%% -----------   Initialization  -----------------

out_code = int8([]);
row = size(I_Dec,1);
blkCount = int32((row/blksize)^2);  % the number of blocks
blkorder = get_blkorder(row,blksize);  % scanning order for the blocks
scanorder = get_blkorder(blksize,1);    % scanning order for the coefficietns in a block
scanorder1 = (scanorder(:,2)-1)*blksize + scanorder(:,1); % 1-D scanning order

n_max = floor(log2(double(abs(max(max(I_Dec)')))));  % Initial threshold T=2^n_max
nbit = n_max - n_min + 1; % the number of bit planes

% suppose there are at most 10 bit planes 
tc = double(10*nbit);
out_S = zeros(tc,blkCount); 
out_R = zeros(tc,blkCount); 
out_D = zeros(tc,blkCount); 
out_N = zeros(tc,blkCount); 
blklen = zeros(blkCount,1,'int32');

%% -----------   coding   ----------------
for bi=1:blkCount  
    blkimg2 = I_Dec(blkorder(bi,1):blkorder(bi,1)+blksize-1,blkorder(bi,2):blkorder(bi,2)+blksize-1); 
    blkimg = blkimg2(scanorder1);

    [blkcode,blkD,blkR,blkS,blkN,blkimg_rec] = encode_blk(blkimg, scanorder, n_max, n_min);
    
    out_code = [out_code; blkcode];
    out_D(1:length(blkD),bi) = blkD;
    out_R(1:length(blkR),bi) = blkR;
    out_S(1:length(blkS),bi) = blkS;
    out_N(1:length(blkN),bi) = blkN;

    blklen(bi) = length(blkcode);
end

