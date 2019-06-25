
function rfb_preprocessing(subj_code,phase_name)

rfb_convertBVData(subj_code,phase_name);
rfb_initialCleanup(subj_code,phase_name);
rfb_registerOnsets(subj_code,phase_name);