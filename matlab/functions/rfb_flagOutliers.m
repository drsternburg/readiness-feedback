
function trial = rfb_flagOutliers(trial)

v = trial.valid;

if isfield(trial,'t_ts2mo_off') % Phase 2
    v1 = isoutlier(trial.t_mo2pp,2);
    v2 = trial.t_mo2pp<150;
    fprintf('%d trials with outlier online movement onsets flagged\n',sum(v1|v2))
else % Phase 1
    v1 = ~trial.valid;
    %v2 = v1;
    v2 = trial.t_mo2pp<150;
end

v3 = isoutlier(trial.t_ts2mo);
fprintf('%d trials with outlier waiting times flagged\n',sum(v3))

v4 = isoutlier(trial.cout);
fprintf('%d trials with outlier classifier outputs flagged\n',sum(v4))

trial.valid = logical(v & ~v1 & ~v2 & ~v3 & ~v4);

