function varargout= bbci_acquire_lsl(varargin)
%BBCI_ACQUIRE_lsl - Online data acquisition from labstreaming layer (LSL)
%   This function acquires small blocks of signals including meta
%   information from the LSL. The LSL can hold streams from any common
%   devices that will be accessed by type: 'eeg' or 'marker'. For details
%   see https://code.google.com/p/labstreaminglayer/.
%
%Synopsis:
%  STATE= bbci_acquire_XYZ('init', <PARAM>)
%  [CNTX, MRKTIME, MRKDESC, STATE]= bbci_acquire_XYZ(STATE)
%  bbci_acquire_XYZ('close')
%  bbci_acquire_XYZ('close', STATE)
%
%Arguments:
%  PARAM - Optional arguments, specific to XYZ.
%
%Output:
%  STATE - Structure characterizing the incoming signals; fields:
%     'fs', 'clab', and intern stuff
%  CNTX - 'acquired' signals [Time x Channels]
%  The following variables hold the markers that have been 'acquired' within
%  the current block (if any).
%  MRKTIME - DOUBLE: [1 nMarkers] position [msec] within data block.
%      A marker occurrence within the first sample would give
%      MARTIME= 1/STATE.fs.
%  MRKDESC - CELL {1 nMarkers} descriptors like 'S 52'

% 11-2015 Jan Boelts
% --- --- --- ---

global BTB

% initialization of state structure and LSL streams
if isequal(varargin{1}, 'init'),
    
    % check whether lsl toolbox is on the path
    if ~isdir('liblsl-Matlab')
        error('LSL Toolbox is not on the path. add it via addpath(genpath(''path_to_LSL/liblsl-Matlab''))')
    end
    
    % use default electrode setting
    size_varargin = size(varargin)
    numOfAmp = size_varargin(2) - 2; % Minus 2 because the second one is the general one
    
    default_clab= ...
        {'AF5' 'AF3' 'AF1' 'AFz' 'AF2' 'AF4' 'AF6' ...
        'F5' 'F3', 'F1' 'Fz' 'F2' 'F4' 'F6' ...
        'FC7' 'FC5' 'FC3' 'FC1' 'FCz' 'FC2' 'FC4' 'FC6' 'FC8' ...
        'T7' 'C5' 'C3' 'C1' 'Cz' 'C2' 'C4' 'C6' 'T8' ...
        'CP7' 'CP5' 'CP3' 'CP1' 'CPz' 'CP2' 'CP4' 'CP6' 'CP8' ...
        'P7' 'P5' 'P3' 'P1' 'Pz' 'P2' 'P4' 'P6' 'P8' ...
        'PO5' 'PO3' 'PO1' 'POz' 'PO2' 'PO4' 'PO6' ...
        'O5' 'O3' 'O1' 'Oz' 'O2' 'O4' 'O6' ...
        };
    
     % set default parameters that may adapted from the stream later on
    props= {'fs'            100            '!DOUBLE[1]'
            'clab'          default_clab   'CELL{CHAR}'
            'blocksize'     10             '!DOUBLE[1]'
            'port'          'COM11'        '!CHAR'
            'timeout'       3              '!DOUBLE[1]'
            'filtHd'        []             'STRUCT'
            'verbose'       true           '!BOOL'
            'markerstreamname' 'DefaultStream' '!CHAR'
            'eeg_amp_num'   1              '!DOUBLE[1]'
            'chunk_size'    0              '!DOUBLE[1]'
            'post_processing_option' 0     '!DOUBLE[1]'
            };

    
    for i = drange(1:numOfAmp)
        proplist(i).props = horzcat(opt_proplistToStruct(varargin{i+1}{:}));
    end
 
    for i = drange(1:numOfAmp)
        if i == 1
           opts = opt_setDefaults(proplist(i).props, props, 1);
        else
           opts.state(i-1) = opt_setDefaults(proplist(i).props, props, 1);
        end
    end
    
    % set default filter coeffs
    if opts.filtHd,
        % Fs/4
        filt1.b= [0.85 0 0.85];
        filt1.a= [1 0 0.7];
        %Fs/2
        filt2.b= [0.8 0.8];
        filt2.a= [1 0.6];
        opts.filtHd= procutil_catFilters(filt1, filt2);
        opts.filtHd.PersistentMemory= true;
    end
    % set number of channels and corresponding values
    
    for i = drange(1:numOfAmp)
        if i == 1
            opts.nChans = length(opts.clab);
            opts.nBytesPerPacket = 2+3*opts.nChans+4;
        else
            opts.state(i-1).nChans = length(opts.state(i-1).clab);
            opts.state(i-1).nBytesPerPacket= 2+3*opts.state(i-1).nChans+4;
        end
    end
    
    %%%%%  resolve eeg stream from LSL %%%%%
    eeg = {};
    % load a lsl library
    lib = lsl_loadlib();
    % look for the stream several times
    for i=1:3
        % look for stream on the network
        eeg = lsl_resolve_byprop(lib,'type','EEG');
        if ~isempty(eeg)
            break
        end
        pause(0.1)
    end
    if isempty(eeg)
        error('No LSL EEG stream on the network')
    else
        % create a new inlet
        % save lsl structures to state structure
        for i = drange(2:numOfAmp)
            opts.state(i-1).inlet.x = lsl_inlet(eeg{opts.state(i-1).eeg_amp_num}, 'chunksize', opts.state(i-1).chunk_size);
            opts.state(i-1).inlet.x.set_postprocessing(opts.state(i-1).post_processing_option);
            [~, opts.state(i-1).starttime] = opts.state(i-1).inlet.x.pull_sample();
            eeg_info(i-1) = opts.state(i-1).inlet.x.info();
            
            opts.state(i-1).packetNo=[];
            opts.state(i-1).buffer= [];
            opts.state(i-1).lastx= zeros(1, opts.state(i-1).nChans);
            opts.state(i-1).scale= 1000000/2^24;
        end
        
        opts.running = 1;

    end
    
    % resolve marker stream, try several times
    mrks = {};
    
    for i = drange(2:numOfAmp)
        mrks(i-1) = lsl_resolve_byprop(lib, 'name', opts.state(i-1).markerstreamname, 1, 1);
        
        if isempty(mrks(i-1))        
            error('No LSL marker stream with name' + opts.state(i-1).markerstreamname + ' on the network, did set up the marker stream?')
        else
            temp = mrks(i-1);
            temp = temp{1};
            opts.state(i-1).inlet.mrk = lsl_inlet(temp, 'chunksize', opts.state(i-1).chunk_size);
            opts.state(i-1).inlet.mrk.set_postprocessing(opts.state(i-1).post_processing_option);
            opts.state(i-1).lastMrkDesc= 256;
        end
        
        if isempty(opts.state(i-1).filtHd)
            reset(opts.state(i-1).filtHd);
        end
    end
    

    output= {opts};
% close condition needs the 'state' structure.
elseif isequal(varargin{1}, 'close') && length(varargin)==1
    error('Please use ''close'' option with ''state'' variable as second argument: bbci_lsl_acquire(close, state)');
elseif isequal(varargin{1}, 'close') && isstruct(varargin{2}),
    % close inlets and libraries
    
%     TODO: I AM NOT SURE WHAT IS SUPPOSED TO HAPPEN HERE>>
    
    
    state(1) = varargin{2};
    state(1).inlet.x.delete(); 
    state(1).inlet.mrk.delete();
    
    state(2) = varargin{2};
    state(2).inlet.x.delete(); 
    state(2).inlet.mrk.delete();
    %state.lib.delete();
    output= {state};
    
elseif length(varargin)~=1
    error('Except for INIT/CLOSE case, only one input argument expected');
else % this is the running condition that receives and returns the samples
    if ~isstruct(varargin{1})
        error('First input argument must be ''init'', ''close'', or a struct');
    end
    opts = varargin{1};
    
    % get data sample from the inlet
    % set timeout to zero to prevent blocking if there is no marker in the
    % current sample.
    timeout = 0; % in seconds
    
    size_opts_state = size(opts.state);
    numOfAmp = size_opts_state(2);
    cntx = [];
    ts = [];
    for i = drange(1:numOfAmp)  
        
        [cntx(i), ts(i)] = opts.state(i).inlet.x.pull_chunk(); %returns numChannels x samples
        [mrkDesc(i), mrkTime(i)] = opts.state(i).inlet.mrk.pull_chunk(timeout);
        
%         VINCENT: I don't think this is needed.
%         mrkTime(i) = mrkTime(i)-opts.state(i).starttime;
%         opts.state(i).lastMrkDesc= mrkDesc(i);
        
        if isempty(cntx(i))
            opts.running = false;
            break;
        end
        
        cntx = vertcat(cntx, cntx(i));
        ts = vertcat(ts, ts(i));
    end

    opts.lastx= cntx;
%     Transpose the cntx matrix, so that it becomes samples X numChannels. 
    output = {cntx.', mrkTime, mrkDesc, opts};
end
varargout= output(1:nargout);
