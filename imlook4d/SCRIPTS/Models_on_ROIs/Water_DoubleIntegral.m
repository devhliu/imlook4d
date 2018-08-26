StoreVariables;
Export;

model_name = 'Water Double Integral Method';
ref_name = imlook4d_ROINames{imlook4d_ROI_number};

disp('Calculating time-activity curves ...');
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

ref = tacts(imlook4d_ROI_number,:); % Current ROI
tact = tacts;  % all ROIs


disp('Calculating model ...');
a = jjwater_doubleintegralmethod( tact, imlook4d_time/60, imlook4d_duration/60, ref);

modelWindow( ...
    a , ...
    imlook4d_ROINames(1:end-1), ...
    [model_name ' (Ref=' ref_name ',  First frame = '  num2str(imlook4d_frame) ')'] ...
    );

disp('Done!');

ClearVariables;