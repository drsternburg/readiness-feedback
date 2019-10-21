
function astr = pval2astr(pval)

if pval<.001
    astr = '***';
elseif pval<.01
    astr = '**';
elseif pval<.05
    astr = '*';
else
    astr = '';
end