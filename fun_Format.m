function [sfrate] = fun_Format(srate,len)
if ~exist('len') len=4; end

sfrate = '';
for ri=1:length(srate)
    rate = srate(ri);
    if rate>=100
        frate = sprintf('%.1f',rate);
    elseif rate>=10
        frate = sprintf('%.2f',rate);
    elseif rate>=1
        frate = sprintf('%.3f',rate);
    else
        frate = sprintf('%.4f',rate);
    end
    sfrate = [sfrate, frate,'  '];
end
if length(srate)>0
    sfrate = sfrate(1:end-2);
end