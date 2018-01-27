function [blkimg_dec,ci] = decode_blk(blkcode,scanorder, n_max, n_min, trunN)

blksize2 = length(scanorder);
blksize = sqrt(blksize2);

if trunN==0
    blkimg_dec = zeros(blksize,blksize);
    ci=0;
    return;
end

%% The max bit plane in the block
ci = 1;
bc = blkcode(ci:ci+n_max-n_min);
bind = min(find(bc));

if length(bind)==0
    blkimg_dec = zeros(blksize,blksize);
    ci = ci + n_max - n_min + 1;
    return;
end

ci = ci + bind - 1;
n_max1 = n_max - bind + 1;

%% -----------   Initialization  -----------------

scanorder1 = (scanorder(:,2)-1)*blksize + scanorder(:,1);

%% construct binary tree
tlev = log(blksize2)/log(2);
tlen = 2*blksize2-1;      
blktree_dec = zeros(1,tlen,'int32');   

%% ------------------------------------------------------
Tk = 2^n_max1;
[blktree_dec,ci] = TravDep_dec(blktree_dec,1,blkcode,ci,Tk);

blkimg_dec = blktree_dec(end-blksize2+1:end)';

for n=n_max1-1:-1:n_min  
    
    Tk = int32(2^n);
    refined = 0;
    
    bi=2^tlev; ei=tlen;  tli=tlev;
    while bi>1
        Ind = bi:ei;
        
        di = find(abs(blktree_dec(Ind))>=2*Tk);
        dj0 = find(mod(Ind(di),2)==0);
        dj1 = find(mod(Ind(di),2)==1);
        Jnd = [Ind(di(dj0)) + 1, Ind(di(dj1)) - 1];
        Jnd(find(abs(blktree_dec(Jnd))>=2*Tk))=[];
        
        for j=Jnd
            [blktree_dec,ci] = TravDep_dec(blktree_dec,j,blkcode,ci,Tk);
        end
        
        if trunN == n*100 + tli
            ci = ci - 1;
            blkimg_dec = blktree_dec(end-blksize2+1:end)';
            return;
        end
        
        % ------------------------------------------------------------
        if tli==8
            blkimg_dec = blktree_dec(end-blksize2+1:end)';
            % magnitude refinement pass
            sigind = find(abs(blkimg_dec)>=2*Tk);
            if length(sigind)>0
                value = uint32(abs(blkimg_dec(sigind)));
                
                sb = int32(blkcode(ci:ci+length(sigind)-1));
                ci = ci+length(sigind);
                
                blkimg_dec(sigind) = blkimg_dec(sigind) + ((-1).^(sb + 1)) .* (2^(n-1)) .* sign(blkimg_dec(sigind));
                
                blktree_dec(end-blksize2+1:end) = blkimg_dec';
            end
            
            if trunN == n*100
                ci = ci - 1;
                return;
            end
        end
        
        tli=tli-1;
        ei = bi - 1;
        bi = 2^tli;
    end
    
end