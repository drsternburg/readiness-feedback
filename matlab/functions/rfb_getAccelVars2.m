
function trial = rfb_getAccelVars2(mrk,trial,cnt,mo_class)

cnt = proc_selectChannels(cnt,'Acc*');
mrk = rfb_selectTrials(mrk,trial.valid);
mrk = mrk_selectClasses(mrk,mo_class);

Nt = length(trial.valid);
trial.move_mean_a = nan(Nt,1);
trial.move_mean_v = nan(Nt,1);
trial.move_max_v = nan(Nt,1);
trial.move_r = nan(Nt,1);
t_mo2pp = floor(trial.t_mo2pp(trial.valid)/10)*10;

g = 9.80665;
f = @(x) sqrt(sum(x.^2,2));

ind = 1;
for ii = 1:Nt
    if not(trial.valid(ii))
        continue
    end
    mrk2 = mrk_selectEvents(mrk,ind);
    epo = proc_segmentation(cnt,mrk2,[-200 t_mo2pp(ind)]);
    epo = proc_baseline(epo,[-200 -100]);
    %epo = proc_selectIval(epo,[0 t_mo2pp(ind)]);
    a = epo.x/g*100; % cm/s^2
    t = epo.t*1/epo.fs; % s
    v = cumtrapz(t,a); % cm/s
    r = cumtrapz(t,v); % cm
    trial.move_mean_a(ii) = mean(f(a));
    trial.move_mean_v(ii) = mean(f(v));
    trial.move_max_v(ii) = max(f(v));
    trial.move_r(ii) = max(f(r));
    ind = ind+1;
end
