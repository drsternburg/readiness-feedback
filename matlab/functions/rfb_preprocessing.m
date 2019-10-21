
function rfb_preprocessing(subj_code)

rfb_convertBVData(subj_code,'Phase1');
rfb_convertBVData(subj_code,'Phase2');
rfb_initialCleanup(subj_code,'Phase2');
rfb_registerOnsets(subj_code,'Phase2',0);