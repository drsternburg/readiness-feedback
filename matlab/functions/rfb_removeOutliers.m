
function trial = rfb_removeOutliers(trial)

v = trial.valid;

fprintf('Outlier trials removed')
if isfield(trial,'t_ts2mo_off')
    v1 = isoutlier(trial.t_mo2pp,2);
    v2 = trial.t_mo2pp<150;
    fprintf('\n  online movement onset: %d',sum(v1|v2))
else
    v1 = ~trial.valid;
    v2 = v1;
    %v2 = trial.t_mo2pp<250;
end
v3 = isoutlier(trial.t_ts2mo);
fprintf('\n  waiting time: %d',sum(v3))
v4 = isoutlier(trial.cout);
fprintf('\n  classifier output: %d\n',sum(v4))

trial.valid = logical(v & ~v1 & ~v2 & ~v3 & ~v4);

