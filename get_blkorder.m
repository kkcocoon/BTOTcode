function blkorder = get_blkorder(row,blksize)
% 
% Morton scanning order
% 

blkorder = int32([1,1]);
levsize = blksize;
while levsize < row
    hor = blkorder;
    vor = blkorder;
    dor = blkorder;
    
    hor(:,2) = hor(:,2) + levsize;
    vor(:,1) = vor(:,1) + levsize;
    dor(:,1) = dor(:,1) + levsize;
    dor(:,2) = dor(:,2) + levsize;
    
    blkorder = [blkorder; hor; vor; dor];
    levsize = levsize*2;
end