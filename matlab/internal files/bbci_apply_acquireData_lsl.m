function [source, marker]= bbci_apply_acquireData_lsl(source, bbci_source, marker)
%BBCI_APPLY_ACQUIREDATA - Fetch data from acquisition hardware
%
%Synopsis:
%  SOURCE= bbci_apply_acquireData(SOURCE, BBCI_SOURCE);
%  [SOURCE, MARKER]= bbci_apply_acquireData(SOURCE, BBCI_SOURCE, MARKER);
%
%Arguments:
%  SOURCE - Structure of recently acquired signals and state information
%     about the acquisition setting; subfield of 'data' structure of
%     bbci_apply.
%  BBCI_SOURCE - Structure specifying the settings of acquiring signals
%     from a data source; subfield of 'bbci' structure of bbci_apply.
%  MARKER - Structure holding the recently received markers.
%     The length of the queue of stored markers is defined in
%     bbci.marker.queue_length and set in SOURCE by the function
%     bbci_apply_initData.
%
%Output:
%  SOURCE - Updated strcture of incoming signals 
%  MARKER - Updated marker structure
%
%For a description of the fields of all these structures, type
%'help bbci_apply_structures'.

% 02-2011 Benjamin Blankertz


source.x= [];
run= 1;
nMarkersPerBlock= 0;
while run
    [new_data, timestamps, mrkTime, mrkDesc, source.state] = ...
        bbci_acquire_lsl(source.state);
    nNewMarkers= length(mrkTime);
    if nNewMarkers>0
    % transfer relative marker positions (within new block)
    % to absolute marker positions relative to start
        mrkTime= mrkTime + source.time;
        if ~isempty(bbci_source.marker_mapping_fcn)
          [mrkDesc, idx]= bbci_source.marker_mapping_fcn(mrkDesc);
          mrkTime= mrkTime(idx);
          nNewMarkers= length(idx);
        end
    end
    % Since markers could get 'lost' in the marker_mapping_fcn, we need to
    % make the case distinction again here.
    if nNewMarkers>0
        marker.time= cat(2, marker.time(nNewMarkers+1:end), mrkTime);
        if isempty(marker.desc)
          % INIT case: We do the init here (and not in bbci_apply_initData),
          % since we can determine here the marker format (numeric or string).
            if iscell(mrkDesc)
                marker.desc= cell(1, length(marker.time));
            else
                marker.desc= NaN*ones(1, length(marker.time));
            end
        end
    end
    marker.desc= cat(2, marker.desc(nNewMarkers+1:end), mrkDesc);

     % This is only for logging:
    if ~isempty(source.log.fid) && bbci_source.log.markers
        for k= 1:length(mrkTime)
            timestr= sprintf(bbci_source.log.time_fmt, mrkTime(k)/1000);
            if iscell(mrkDesc)
                descstr= sprintf('M(''%s'')', mrkDesc{k});
            else
                descstr= sprintf('M(%d)', mrkDesc(k));
            end
            bbci_log_write(source.log.fid, '# Source: %s | %s', ...
                timestr, descstr);
        end
    end

    nMarkersPerBlock= nMarkersPerBlock + nNewMarkers;
    source.x= cat(1, source.x, new_data); 
    source.sample_no= source.sample_no + size(new_data,1);
    source.time= source.sample_no*1000/source.fs; % TODO: I think this is where I can use the timestamps
%     size(source.x,1)
    run= (size(source.x,1) < bbci_source.min_blocklength_sa);

%     pause(0.1); % TODO: I wonder if I need this, but basically I need a small window for pause to receive some data...

end

if ~isempty(source.log.fid) && bbci_source.log.data_packets && ...
      (size(source.x,1) > bbci_source.min_blocklength_sa),
  bbci_log_write(source.log.fid, ...
                 '# Source: block length %d samples.\n', size(source.x,1));
end

if strcmp(source.record.fcn, 'internal'),
  source.record= bbci_apply_recordSignals(source, marker, nMarkersPerBlock);
end
