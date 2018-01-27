function [blkcodej,blkimg_rec] = TravDep_enc(blktree,j,Tk,tlev,blkimg_rec)

% traverse by depth-first, non-recursive by a stack

blkcodej = int8([]);   

jStack = zeros(32,10,'int32');  % stack
si = 1;
jStack(si) = j;

tlen = length(blktree);
leafb = (tlen+1)/2-1;

while si>0
    j = jStack(si); si = si-1;

    % If it has a significant parent and its brother has just been coded with insignificant.
    if j>1 & mod(j,2)==1 & abs(blktree(j-1))<Tk
        if (2*j<=tlen)
            si=si+1; jStack(si)=2*j+1;
            si=si+1; jStack(si)=2*j;
        else
            blkcodej = [blkcodej, int8((sign(blktree(j))~=1))];   
            blkimg_rec(j-leafb) = sign(blktree(j))*(Tk + Tk/2);      
        end

    % If it is significant with current threshold.
    elseif abs(blktree(j)) >= Tk
        
        blkcodej = [blkcodej, 1];
        
        if (2*j<=tlen) 
            si=si+1; jStack(si)=2*j+1;
            si=si+1; jStack(si)=2*j;
        else
            blkcodej = [blkcodej, int8((sign(blktree(j))~=1))]; 
            blkimg_rec(j-leafb) = sign(blktree(j))*(Tk + Tk/2);      
        end
    else
        blkcodej = [blkcodej, 0];
    end
end