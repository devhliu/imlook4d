function outputImage=zhou( handles, matrix,outputFrameRange)
%
% function zhou
%
% (based on Patlak m-files)
%
% input:
%
%   handles             - handles to imlook4d variables.  handles.model is describing model.  
%   matrix              - matrix with data [x,y,z,frames]=[:,:,1,:]
%   outputFrameRange    - frames that function will output.  
%                         For models generating static images from a time-series, frame is ignored.
%
% output:
%   outputImage         -  2D image [:,:,1,1] 
%
%
% General information about model plug-in functions for imlook4d:
%   A model function should have ONE of the following capabilities:
%   - convert a time-series to another time-series [:,:,slice,:]=> [:,:,slice,:]
%   - convert a time-series to an image [:,:,slice,:]=> [:,:]
%   It is up to the definition of the model to return either of the above.  
%   (Imlook4d handles the display of both types of returned matrices)
%
%
% This function is an example of a function defined as:
%      input:   time-series at given slice [:,:,1,:]
%      output:  time-series (each frame is calculated)  [:,:,1,1]
% 
%
% A imlook4d plug-in model function follows the above described behavior,
% and the m-file is put into the FUNCTIONS folder.  A control function and
% GUI is also necessary.
%
% Using the plug-in function "test" as an example, the files of an imlook4d model-plugin is 
% /MODELS/test.m                    function manipulating image.
% /MODELS/test/test_control.m       Utility function used for setup of parameters
% /MODELS/test/test_control.fig     GUI for test_control
%
% Author: Jan Axelsson
% 2008-SEP-23

  
    %disp('logan called');

    % Perform calculations

    % This model takes a time series [:,:,slice,:] and generates a single image.


%       outputImage(:,:,1,1)=imlook4d_zhou(...
%             matrix, ...
%             handles.image.time, ...
%             handles.image.duration, ...
%             handles.model.Zhou.startFrame, ...
%             handles.model.Zhou.endFrame, ...
%             handles.model.Zhou.referenceData, ...
%             handles.model.Zhou.type );
    
   tic

        a = jjzhou( matrix, ...
            handles.image.time/60, ...
            handles.image.duration/60, ...
            handles.model.Zhou.referenceData, ...
            [ handles.model.Zhou.startFrame handles.model.Zhou.endFrame ] ...
            );
        
        if strcmp(handles.model.Zhou.type, 'BP')
            outputImage(:,:,1,1) = a.pars{1}; % BP
        end
         
        if strcmp(handles.model.Zhou.type, 'slope')
            outputImage(:,:,1,1) = a.pars{2}; % DVR
        end       
toc 

