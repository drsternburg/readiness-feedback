
function trial = rfb_getAccelVars(mrk,trial,cnt,mo_class)

mrk = rfb_selectTrials(mrk,trial.valid);
mrk = mrk_selectClasses(mrk,mo_class);
Nt = length(trial.valid);
trial.acc_avg = nan(Nt,1);
trial.acc_max = nan(Nt,1);
t_mo2pp = floor(trial.t_mo2pp(trial.valid)/10)*10;
ind = 1;
for ii = 1:Nt
    if not(trial.valid(ii))
        continue
    end
    mrk2 = mrk_selectEvents(mrk,ind);
    epo = proc_segmentation(cnt,mrk2,[-100 t_mo2pp(ind)]);
    epo = proc_selectChannels(epo,'Acc*');
    epo = proc_baseline(epo,[-100 0]);
    epo = proc_selectIval(epo,[0 t_mo2pp(ind)]);
    trial.acc_avg(ii) = mean(mean(abs(epo.x)));
    trial.acc_max(ii) = max(max(abs(epo.x)));
    ind = ind+1;
end
