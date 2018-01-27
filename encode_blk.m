function [blkcode,blkD,blkR,blkS,blkN,blkimg_rec] = encode_blk(blkimg, scanorder, n_max, n_min)

% Coding each block by BTCA.

% Traverse by level
% From bottom to the top of the tree, we find the brother of previous significant nodes to traverse.

mono=1;

blksize2 = length(blkimg);
blksize = sqrt(blksize2);

%% The max value in the block
ni = n_max:-1:n_min;
bc = max(abs(blkimg)) >= 2.^ni;
bind = min(find(bc));

if length(bind)==0
    blkcode = int8(bc');
    blkD = sum((blkimg).^2);
    blkR = length(bc);
    blkS = inf;
    blkN = 0;
    blkimg_rec = zeros(blksize2,1);
    return;
end

%% -----------   Initialization  -----------------

blkcode = 2*ones(2*blksize2,1,'int8');   % max compression ratio: 4:1
ci = 1;

n_max1 = ni(bind);
blkcode(ci:ci+bind-2) = bc(1:bind-1);
ci = ci + bind - 1;
blkimg_rec = zeros(blksize2,1);    % decoded image for calculating the distortion
scanorder1 = (scanorder(:,2)-1)*blksize + scanorder(:,1);


%% construct binary tree
tlev = log(blksize2)/log(2);
tlen = 2*blksize2-1;
blktree = zeros(1,tlen);
blktree(end-blksize2+1:end) = blkimg';

bi=2^tlev; ei=tlen;
for tli=tlev-1:-1:0
    pbi=bi; pei=ei;      % the node index of lower level
    bi=2^tli; ei=pbi-1;  % the node index of current level
    blktree(bi:ei) = max(abs([blktree(pbi:2:pei);blktree(pbi+1:2:pei)]));
end

leafb = int32((tlen+1)/2-1);

%% Initial the truncation points
preD = sum((blkimg).^2);
preR = 0;
preS = inf;
preN = inf;
bti = int32(1);

%% ------------------------------------------------------
% Before traversing the tree by levels,
% we should traverse the tree by depth with T0, so that there are
% previous significant nodes with smaller thresholds.
Tk = 2^n_max1;
[blkcodej,blkimg_rec]=TravDep_enc(blktree,1,Tk,tlev,blkimg_rec);
blkcode(ci:ci+length(blkcodej)-1) = blkcodej;
ci = ci+length(blkcodej);


%% record truncation point
theR = ci - 1;
theD = sum((blkimg_rec-blkimg).^2);

if theR-preR(bti)>0
    theS = (preD(bti)-theD)/(theR-preR(bti));
    while theS>preS(bti)
        bti  = bti - 1;
        theS = (preD(bti)-theD)/(theR-preR(bti));
    end
    bti = bti + 1;
    preD(bti) = theD;
    preR(bti) = theR;
    preS(bti) = theS;
    preN(bti) = n_max1*100 + 1;
end


for n=n_max1-1:-1:n_min  
    
    Tk = int32(2^n);
    refined = 0;
    
    % traverse by level
    bi=2^tlev; ei=tlen;  tli=tlev;
    while bi>1
        Ind = bi:ei;
        
        di = find(abs(blktree(Ind))>=2*Tk); % significant nodes
        dj0 = find(mod(Ind(di),2)==0); % significant nodes in the left sub-tree
        dj1 = find(mod(Ind(di),2)==1); %  significant nodes in the right sub-tree
        Jnd = [Ind(di(dj0)) + 1, Ind(di(dj1)) - 1]; % neighbors of significant nodes
        Jnd(find(abs(blktree(Jnd))>=2*Tk))=[];   % delete previous significant nodes
        
        for j=Jnd
            [blkcodej,blkimg_rec]=TravDep_enc(blktree,j,Tk,tlev,blkimg_rec);
            blkcode(ci:ci+length(blkcodej)-1) = blkcodej;
            ci = ci+length(blkcodej);
        end
        
        % record truncation point
        theR = ci - 1;
        if theR-preR(bti)>0
            theD = sum((blkimg_rec-blkimg).^2);
            theS = (preD(bti)-theD)/(theR-preR(bti));
            while theS>preS(bti) & mono~=0
                bti  = bti - 1;
                theS = (preD(bti)-theD)/(theR-preR(bti));
            end
            bti = bti + 1;
            preD(bti) = theD;
            preR(bti) = theR;
            preS(bti) = theS;
            preN(bti) = n*100 + tli;
        end
        
        % ------------------------------------------------------------
        if tli==8
            refined = 1;
            %  magnitude refinement pass
            sigind = find(abs(blkimg_rec)>=2*Tk);
            if length(sigind)>0
                value = floor(abs(blkimg(sigind)));
                sb = bitget(value,n+1);
                
                blkcode(ci:ci+length(sb)-1) = sb;
                ci = ci+length(sb);
                
                blkimg_rec(sigind) = blkimg_rec(sigind) + double((-1).^(sb + 1)) .* (2^(n-1)) .* sign(blkimg_rec(sigind));
            end
            
            theR = ci - 1;
            if theR-preR(bti)>0
                theD = sum((blkimg_rec-blkimg).^2);
                theS = (preD(bti)-theD)/(theR-preR(bti));
                while theS>preS(bti) & mono~=0
                    bti  = bti - 1;
                    theS = (preD(bti)-theD)/(theR-preR(bti));
                end
                bti = bti + 1;
                preD(bti) = theD;
                preR(bti) = theR;
                preS(bti) = theS;
                preN(bti) = n*100;
            end
        end
        % ------------------------------------------------------------
        
        tli=tli-1;
        ei = bi - 1;
        bi = 2^tli;
    end
    
    if refined==0
        refined = 1;
        % magnitude refinement pass
        sigind = find(abs(blkimg_rec)>=2*Tk);
        if length(sigind)>0
            value = floor(abs(blkimg(sigind)));
            sb = bitget(value,n+1);
            
            blkcode(ci:ci+length(sb)-1) = sb;
            ci = ci+length(sb);
            
            blkimg_rec(sigind) = blkimg_rec(sigind) + double((-1).^(sb + 1)) .* (2^(n-1)) .* sign(blkimg_rec(sigind));
        end
        
        theR = ci - 1;
        if theR-preR(bti)>0
            theD = sum((blkimg_rec-blkimg).^2);
            theS = (preD(bti)-theD)/(theR-preR(bti));
            while theS>preS(bti) & mono~=0
                bti  = bti - 1;
                theS = (preD(bti)-theD)/(theR-preR(bti));
            end
            bti = bti + 1;
            preD(bti) = theD;
            preR(bti) = theR;
            preS(bti) = theS;
            preN(bti) = n*100;
        end
    end
end

% ------------------------------------------------------------
blkD = preD';
blkR = preR';
blkS = preS';
blkN = preN';
blkD([1,bti+1:end]) = [];
blkR([1,bti+1:end]) = [];
blkS([1,bti+1:end]) = [];
blkN([1,bti+1:end]) = [];
blkcode(ci:end) = [];
