
function [Acc_avg,Acc_max] = rfb_getAccelVars(mrk,trial,cnt,mo_class)

mrk = mrk_selectClasses(mrk,mo_class);
Nt = length(mrk.time);
Acc_avg = zeros(Nt,1);
Acc_max = zeros(Nt,1);
t_mo2pp = floor(trial.t_mo2pp/10)*10;
for ii = 1:Nt
    mrk2 = mrk_selectEvents(mrk,ii);
    epo = proc_segmentation(cnt,mrk2,[-100 t_mo2pp(ii)]);
    epo = proc_selectChannels(epo,'Acc*');
    epo = proc_baseline(epo,[-100 0]);
    epo = proc_selectIval(epo,[0 t_mo2pp(ii)]);
    Acc_avg(ii) = mean(mean(abs(epo.x)));
    Acc_max(ii) = max(max(abs(epo.x)));
end
