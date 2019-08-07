
function [mrk,trial] = rfb_analyzeTrials(subj_code,phase_name)

mrk = rfb_loadData(subj_code,phase_name);
trial_mrk = rfb_getTrialMarkers(mrk);
Nt = length(trial_mrk);

switch phase_name
    
    case 'Phase1'
    %%    
        valid_mo_off = [];
        trial.t_ts2mo_off = [];
        trial.t_mo2pp_off = [];
        for ii = 1:Nt
            
            mrk_this = mrk_selectEvents(mrk,trial_mrk{ii});
            
            if any(strcmp(mrk_this.className,'movement onset'))
                valid_mo_off = cat(1,valid_mo_off,true);
                mrk_ = mrk_selectClasses(mrk_this,{'trial start','movement onset'});
                t_ts2mo_off = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
                trial.t_ts2mo_off = cat(1,trial.t_ts2mo_off,t_ts2mo_off);
                mrk_ = mrk_selectClasses(mrk_this,{'movement onset','pedal press'});
                t_mo2pp_off = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
                trial.t_mo2pp_off = cat(1,trial.t_mo2pp_off,t_mo2pp_off);
            else
                valid_mo_off = cat(1,valid_mo_off,false);
                trial.t_ts2mo_off = cat(1,trial.t_ts2mo_off,NaN);
                trial.t_mo2pp_off = cat(1,trial.t_mo2pp_off,NaN);
            end
            
        end
        mrk = mrk_selectEvents(mrk,[trial_mrk{:}]);
        
        trial.t_mo2pp_on = nan(Nt,1);
        trial.valid_mo = valid_mo_off;
        trial.block_nr = ones(Nt,1);
        trial.feedback = nan(Nt,1);
        trial.cout = nan(Nt,1);
            
    otherwise
    %%    
        ind_rem = [];
        valid_mo_off = [];
        trial.t_ts2mo_off = [];
        trial.t_mo2pp_off = [];
        ii = 1;
        while ii<=Nt
            
            mrk_this = mrk_selectEvents(mrk,trial_mrk{ii});
            
            if ~any(strcmp(mrk_this.className,'feedback'))
                ind_rem = cat(1,ind_rem,ii);
                ii = ii+1;
                continue
            end
            
            if any(strcmp(mrk_this.className,'movement onset'))
                valid_mo_off = cat(1,valid_mo_off,true);
                mrk_ = mrk_selectClasses(mrk_this,{'trial start','movement onset'});
                t_ts2mo_off = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
                trial.t_ts2mo_off = cat(1,trial.t_ts2mo_off,t_ts2mo_off);
                mrk_ = mrk_selectClasses(mrk_this,{'movement onset','pedal press'});
                t_mo2pp_off = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
                trial.t_mo2pp_off = cat(1,trial.t_mo2pp_off,t_mo2pp_off);
            else
                valid_mo_off = cat(1,valid_mo_off,false);
                trial.t_ts2mo_off = cat(1,trial.t_ts2mo_off,NaN);
                trial.t_mo2pp_off = cat(1,trial.t_mo2pp_off,NaN);
            end
            
            ii = ii+1;
        end
        mrk = mrk_selectEvents(mrk,[trial_mrk{setdiff(1:Nt,ind_rem)}]);
        
        L = rfb_getPyffLog(subj_code,phase_name);
        
        trial.t_mo2pp_on = L.t_mo2pp;
        mn = mean(trial.t_mo2pp_on);
        sd3 = std(trial.t_mo2pp_on)*3;
        valid_mo_on = ~(trial.t_mo2pp_on<mn-sd3|trial.t_mo2pp_on>mn+sd3);
        trial.valid_mo = valid_mo_off&valid_mo_on;
        
        trial.block_nr = L.block_nr;
        trial.feedback = L.feedback;
        trial.cout = L.cout;
        
end
































