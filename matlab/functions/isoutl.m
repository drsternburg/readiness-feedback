
function ind = isoutl(x,direction)

mn = nanmean(x);
sd = nanstd(x);

switch direction
    case 'lo'
        ind = x<mn-sd*3;
    case 'hi'
        ind = x>mn+sd*3;
    case 'lohi'
        ind = (x<mn-sd*3|x>mn+sd*3);
end