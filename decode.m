function [I_DecR,dlen] = decode(out_code, blklen, n_max, n_min, blksize, row, rate, out_S,out_R,out_N)

% -------------------------------------------------------------
% 
blkorder = get_blkorder(row,blksize);  % scanning order for the blocks
scanorder = get_blkorder(blksize,1);    % scanning order for the coefficietns in a block
scanorder1 = (scanorder(:,2)-1)*blksize + scanorder(:,1); % 1-D scanning order

nbit = n_max - n_min + 1;  % the number of bit planes
tc = double(10*nbit); % suppose there are at most 10 bit planes 
% -------------------------------------------------------------
% rate-distortion optimization after compression
maxbits = (row*row)*rate; % max bit rate
blkCount = int32((row/blksize)^2);  % the number of blocks

trunR = zeros(blkCount,1);
trunN = zeros(blkCount,1);
[ssort,sind] = sort(-out_S(:));
ssort = -ssort;
i=1;
while sum(trunR)<maxbits-5*blkCount % 5 bits for storing a truncation point 10 bit planes
    si = sind(i);
    if out_S(si)==0
        disp(['Too few data and can not reach the compression ratio: ' num2str(maxbits/(row*row))]);
        break;
    end
    bi = floor((si-1)/tc)+1; 
    trunR(bi) = out_R(si);
    trunN(bi) = out_N(si);
    i = i + 1;
end

%% -----------------------------------------
dlen = 0; 
ci=1;
I_DecR = zeros(row,row);
blkimg2 = zeros(blksize,blksize);
for bi=1:blkCount 
    
    blkcode = out_code(ci:ci+blklen(bi)-1);
    [blkimg_dec,blen] = decode_blk(blkcode,scanorder, n_max, n_min, trunN(bi));  

    dlen = dlen + blen;
    
    blkimg2(scanorder1) = blkimg_dec;
    I_DecR(blkorder(bi,1):blkorder(bi,1)+blksize-1,blkorder(bi,2):blkorder(bi,2)+blksize-1) = blkimg2; % 当前要处理的码块
    
    ci = ci + blklen(bi);
end

