StoreVariables
tic

aliveChecker = imlook4d_alive('spm'); % Print '.' while 'spm' in call stack (meaning that it is running). Stop-command: delete(aliveChecker)

if ~exist('atlasFileName')
    % Defaults
    atlasFileName = 'labels_Neuromorphometrics.nii'
    atlasLUT = 'labels_Neuromorphometrics.txt';
end
    
% atlasFileName = 'AAL2.nii';
% atlasLUT = 'AAL2.txt';
% 
% atlasFileName = 'labels_Neuromorphometrics.nii'
% atlasLUT = 'labels_Neuromorphometrics.txt';

%% Segment
disp('This will take a number of minutes!')
file = [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file];
[folder,name,ext] = fileparts(file);

Segment_CT_sav_deform_job; % Setup segmentation and match
matlabbatch{1}.spm.spatial.preproc.channel.vols = { file };
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 5; % Smoothing FWHM (about 5 for PET and SPECT, 0 for fMRI)

spm_jobman('run',matlabbatch);

%% Atlas to original space
fileInAtlasSpace = [ folder filesep 'iy_' name ext]; 
atlasFile = which( atlasFileName );

clear matlabbatch;
spm('defaults', 'PET');
Defortmation_AAL_job; % Setup deformation
matlabbatch{1}.spm.util.defs.comp{1}.def = { fileInAtlasSpace }; % Deformation file: MNI->Native
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = { atlasFile }; % Atlas in MNI
spm_jobman('run',matlabbatch);

%% Load native-space ROI
prefix = matlabbatch{1}.spm.util.defs.out{1}.pull.prefix; % As defined in matlabbatch
outRoiFile = [  folder filesep prefix atlasFileName ]
LoadROI( outRoiFile );
%% Load ROI-names
ROI_naming_from_file( atlasLUT)

%% Copy LUT to same folder as ROI-file
prefix = matlabbatch{1}.spm.util.defs.out{1}.pull.prefix; % = 'native_' from Defortmation_AAL_job;
newFile = [ prefix atlasLUT ];
copyfile( which(atlasLUT), [ folder filesep newFile ] );

%% Clear 
clear matlabbatch;
stop(aliveChecker);
delete(aliveChecker); 
toc
ClearVariables;