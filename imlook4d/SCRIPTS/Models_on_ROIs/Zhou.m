StoreVariables;
Export;

model_name = 'Zhou';
ref_name = imlook4d_ROINames{imlook4d_ROI_number};

disp('Calculating time-activity curves ...');
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

ref = tacts(imlook4d_ROI_number,:); % Current ROI
tact = tacts;  % all ROIs


disp('Calculating model ...');
a = jjzhou( tact, imlook4d_time/60, imlook4d_duration/60, ref, imlook4d_frame); % Fit to end frame


% Display
modelWindow( ...
    a , ...
    imlook4d_ROINames(1:end-1), ...
    [model_name ' (Ref=' ref_name ',  First frame = '  num2str(imlook4d_frame) ')'] ...
    );

disp('Done!');

ClearVariables;