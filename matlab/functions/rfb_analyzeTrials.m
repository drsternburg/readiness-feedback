
function [mrk,trial] = rfb_analyzeTrials(subj_code,phase_name)

switch phase_name
    
    %%
    case 'Phase1'
        
        mrk = rfb_loadData(subj_code,phase_name);
        trial_mrk = rfb_getTrialMarkers(mrk);
        Nt = length(trial_mrk);
    
        valid = [];
        trial.t_ts2mo = [];
        trial.t_mo2pp = [];
        for ii = 1:Nt
            
            mrk_this = mrk_selectEvents(mrk,trial_mrk{ii});
            
            if any(strcmp(mrk_this.className,'movement onset'))
                valid = cat(1,valid,true);
                mrk_ = mrk_selectClasses(mrk_this,{'trial start','movement onset'});
                t_ts2mo = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
                trial.t_ts2mo = cat(1,trial.t_ts2mo,t_ts2mo);
                mrk_ = mrk_selectClasses(mrk_this,{'movement onset','pedal press'});
                t_mo2pp = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
                trial.t_mo2pp = cat(1,trial.t_mo2pp,t_mo2pp);
            else
                valid = cat(1,valid,false);
                trial.t_ts2mo = cat(1,trial.t_ts2mo,NaN);
                trial.t_mo2pp = cat(1,trial.t_mo2pp,NaN);
            end
            
        end
        mrk = mrk_selectEvents(mrk,[trial_mrk{:}]);
        
        trial.valid = logical(valid);
        trial.block_nr = ones(Nt,1);
        opt2 = rfb_getOptData(subj_code);
        trial.cout(trial.valid,1) = opt2.feedback.pyff_params(4).phase1_cout';
        
    otherwise
        %%
        L = rfb_getPyffLog(subj_code,phase_name);
        mrk = rfb_loadData(subj_code,phase_name);
        mrk = insert_online_markers(mrk,L);
        trial_mrk = rfb_getTrialMarkers(mrk);
        Nt = length(trial_mrk);
        
        ind_rem = [];
        trial.valid_off = [];
        trial.t_ts2mo_off = [];
        trial.t_mo2pp_off = [];
        trial.valid = [];
        trial.t_ts2mo = [];
        trial.t_mo2pp = [];
        ii = 1;
        while ii<=Nt
            
            mrk_this = mrk_selectEvents(mrk,trial_mrk{ii});
            
            if ~any(strcmp(mrk_this.className,'feedback'))
                ind_rem = cat(1,ind_rem,ii);
                ii = ii+1;
                continue
            end
            
            if any(strcmp(mrk_this.className,'movement onset'))
                trial.valid_off = cat(1,trial.valid_off,true);
                mrk_ = mrk_selectClasses(mrk_this,{'trial start','movement onset'});
                t_ts2mo_off = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
                trial.t_ts2mo_off = cat(1,trial.t_ts2mo_off,t_ts2mo_off);
                mrk_ = mrk_selectClasses(mrk_this,{'movement onset','pedal press'});
                t_mo2pp_off = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
                trial.t_mo2pp_off = cat(1,trial.t_mo2pp_off,t_mo2pp_off);
            else
                trial.valid_off = cat(1,trial.valid_off,false);
                trial.t_ts2mo_off = cat(1,trial.t_ts2mo_off,NaN);
                trial.t_mo2pp_off = cat(1,trial.t_mo2pp_off,NaN);
            end
            
             if any(strcmp(mrk_this.className,'mo online'))
                trial.valid = cat(1,trial.valid,true);
                mrk_ = mrk_selectClasses(mrk_this,{'trial start','mo online'});
                t_ts2mo = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
                trial.t_ts2mo = cat(1,trial.t_ts2mo,t_ts2mo);
                trial.t_mo2pp = cat(1,trial.t_mo2pp,L.t_mo2pp(ii));
            else
                trial.valid = cat(1,trial.valid,false);
                trial.t_ts2mo = cat(1,trial.t_ts2mo,NaN);
                trial.t_mo2pp = cat(1,trial.t_mo2pp,NaN);
            end
            
            ii = ii+1;
        end
        
        trial.valid_off = logical(trial.valid_off);
        trial.valid = logical(trial.valid);
        mrk = mrk_selectEvents(mrk,[trial_mrk{setdiff(1:Nt,ind_rem)}]);
                
        trial.block_nr = L.block_nr;
        trial.feedback = L.feedback;
        trial.cout = L.cout;
        trial.time = L.time;
        
end


%%
function mrk = insert_online_markers(mrk,L)
mrk_pp = mrk_selectClasses(mrk,'pedal press');
mrk_ts = mrk_selectClasses(mrk,'trial start');
Nt = length(mrk_pp.time);
t_mo_on = [];
for ii = 1:Nt
    if L.t_mo2pp(ii)<0 || (mrk_pp.time(ii) - L.t_mo2pp(ii))<mrk_ts.time(ii)
        % exclude
        % (1) negative velocities
        % (2) movement onset markers that would occur before trial start
        continue
    end
    t_mo_on = cat(2,t_mo_on,mrk_pp.time(ii) - L.t_mo2pp(ii));
end
mrk.time = cat(2,mrk.time,t_mo_on);
mrk.y = cat(1,mrk.y,zeros(1,size(mrk.y,2)));
mrk.y = cat(2,mrk.y,repmat([0 0 0 0 0 1]',1,Nt));
mrk.className{6} = 'mo online';
mrk = mrk_sortChronologically(mrk);





























