
function mrk = rfb_selectTrials(mrk,ind_sel,incell)
% Select a subset of trials from all existing trials. Best used in
% combination with tl_mrk_analyzeTrials in order to generate a conditional
% selection.
%
% Input:
%   mrk     - Marker structure as returned by tl_proc_loadData
%   ind_sel - Either a logical vector or a vector with indices that
%             indicates the selection
%   incell  - If true, returns mrk of single trials in a cell (default:
%             false)
% Output:
%   mrk     - Marker structure containing only markers of the selected
%             subset of trials
%

ind_all = rfb_getTrialMarkers(mrk);

if nargin==1
    ind_sel = 1:length(ind_all);
end

if islogical(ind_sel)
    ind_sel = find(ind_sel);
end

if nargin<3
    incell = false;
end

if incell
    mrk2 = cell(1,length(ind_sel));
    for ii = 1:length(ind_sel)
        mrk2{ii} = mrk_selectEvents(mrk,ind_all{ind_sel(ii)});
    end
    mrk = mrk2;
else
    mrk = mrk_selectEvents(mrk,[ind_all{ind_sel}]);
end