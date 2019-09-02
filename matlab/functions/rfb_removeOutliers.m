
function [mrk,trial] = rfb_removeOutliers(mrk,trial)

trial_mrk = rfb_getTrialMarkers(mrk);

v = trial.valid;

fprintf('Outlier trials removed')
if isfield(trial,'valid_off')
    v1 = isoutlier(trial.t_mo2pp,2);
    v2 = trial.t_mo2pp<150;
    fprintf('\n  online movement onset: %d',sum(v1|v2))
else
    v1 = ~trial.valid;
    v2 = v1;
end
v3 = isoutlier(trial.cout);
fprintf('\n  classifier output: %d\n',sum(v3))

trial.valid = logical(v & ~v1 & ~v2 & ~v3);
mrk = mrk_selectEvents(mrk,[trial_mrk{trial.valid}]);
