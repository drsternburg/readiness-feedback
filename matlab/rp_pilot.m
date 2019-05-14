%% Ask for user input, a unique name/id
prompt = 'Please input a subject identifier? ';
subject_identifier = input(prompt);
unique_filename = datestr(now, 'dd-mm-yy HH:MM') + subject_identifier;

%% Calibration period
% Get 