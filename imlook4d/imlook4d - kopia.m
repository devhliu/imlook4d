% =========================================================================
% 
% imlook4d DOCUMENTATION 
%
% =========================================================================
    %
    % Author:   Jan Axelsson
    %
    % Purpose:  Used for display and ROI-analysis of 4D images.
    %
    % EXAMPLE USE
    % --------------------------------------------------------------------
    % OPEN FILE DIALOG
    %   imlook4d   
    %   h=imlook4d dialog
    %
    % OPEN A MATRIX
    %   imlook4d(matrix)
    %   imlook4d(matrix, time_vector, duration_vector)  % time points and duration
    %
    % OPEN A m4 OBJECT
    %   imlook4d(m4)
    %
    % OPEN FILES 
    %   DICOM: Open all files in same directory as selected file
    %   imlook4d(path_to_one_file_in_directory) 
    %
    %   ECAT, SHR, Analyze, Interfile, ITK, binary single files: 
    %   imlook4d(path_to_file) 
    %
    
    %   <a href="matlab:help sin">Advanced help</a>

    %
    % -------------------------------------------------------------------
    %
    % Advanced documentation
    %
    % --------------------------------------------------------------------


    %
    % WORK WITH IMLOOK4D INSTANCE IN MATLAB - THE REALLY SIMPLE WAY
    % -------------------------------------------------------------
    %
    %   Use WORKSPACE/EXPORT menu in imlook4d to place variables in workspace
    %   Use WORKSPACE/IMPORT menu in imlook4d to read back variables from workspace
    %
    % WORK WITH IMLOOK4D INSTANCE IN MATLAB - THE SIMPLE WAY (an example)
    % -------------------------------------------------------------------
    %
    %   1) imlook4d/Workspace/Export menu to make active window handles in
    %   workspace:
    %       imlook4d_current_handle     handle to imlook4d
    %                                   equivalent to hObject in this program,
    %                                   equivalent to h in example below
    %       imlook4d_current_handles    equivalent to handles in this code (This is what you work with)
    %
    %   2) Modify handles.image.CachedImage from matlab workspace
    %       imlook4d_current_handles.image.CachedImage=1000;
    %
    %   3) Save changed parameter to current Imlook4d instance
    %       guidata(imlook4d_current_handle,imlook4d_current_handles)
    %
    %
    % EXAMPLE: COMMUNICATE BETWEEN MATLAB AND IMLOOK4D
    % ------------------------------------------------
    %
    % START
    %   h=imlook4d(Data);
    %   handles = guidata(h);
    %
    % READ FROM MATLAB
    %   localROI=handles.image.ROI;        % Reads ROI into separate variable localROI
    %   handles.image.Cdata;               % Way to manipulate CData
    %
    % WRITE TO IMLOOK4D OBJECT 
    %   handles.image.Cdata(:)=10*handles.image.Cdata(:);  % Multiply by 10
    %   guidata(h,handles);                                % Save handles
    %
    % CALL FUNCTION WITHIN IMLOOK4D INSTANCE
    %   set(h,'Name', [file]);                                      % Set file name
    %   handles = guidata(h);   
    %   set(handles.FlipAndRotateRadioButton,'Value',1);            % Set radiobutton
    %   imlook4d('FlipAndRotateRadioButton_Callback', h,{},handles);% Call function
    %
% -------------------------------------------------------------------
%
% SCRIPT documentation
%
% -------------------------------------------------------------------
    % -------
    % Scripts are saved in imlook4d/SCRIPTS folder (no spaces or odd characters), 
    % and are automatically visible in SCRIPTS menu. 
    %
    % The imlook4d_current_handles variable in workspace is updated when selecting SCRIPTS menu.
    % Scripts can get access to the internal variables directly using the
    % variable imlook4d_current_handles.image.XXX.
    %
    % If a script modifies one of these variables, it can be stored by 
    % guidata(imlook4d_current_handle,imlook4d_current_handles)
    % 
    % The Export/Import menu functions can be called from a script, giving
    % access to the most common variables:
    %   imlook4d_Cdata              % 4D matrix
    %   imlook4d_ROI                % 3D ROI matrix
    %   imlook4d_ROINames           % cells with ROI names
    %   imlook4d_current_handle     % handle to current imlook4d instance ("hObject" internally)
    %   imlook4d_current_handles    % handles (equivalent to "handles" internally)
    %   imlook4d_duration           % 1D matrix of frame durations
    %   imlook4d_frame              % 1D matrix of frame time, as defined in input 
    %   imlook4d_slice              % currently selected slice (only exported)
    %   imlook4d_time               % currently selected frame (only exported)
    %
    % the commandline calls for export/import are:
    % Export:  imlook4d('exportToWorkspace_Callback',imlook4d_current_handle,{},imlook4d_current_handles);
    % Import:  imlook4d('importFromWorkspace_Callback',imlook4d_current_handle,{},imlook4d_current_handles);
    %
% -------------------------------------------------------------------
%handles.record.enabled = false;
% Code documentation
%
% -------------------------------------------------------------------
    %
    % The program is built on callbacks, from the GUI.  
    % GUI state is read when needed, thus not storing any variables that are avialable in GUI.
    %
    % The following data is available from the handles:
    %
    % STORAGE:
    % --------
    % handles.image.time          vector of frame times (exists only when time data exists)
    % handles.image.duration      vector of frame duration (exists only when duration data exists)
    % handles.image.Cdata         4D matrix of image data [x, y, slice,frame]
    % handles.image.ROI           3D matrix of ROI data [x, y, slice]
    %                             where the pixel value equals the ROI number (thus, only one ROI possible in each pixel)
    % handles.image.CachedImage   cached image, not flipped or rotated.  Flips and rotate are done at display only.
    %                             (updated with PCA-filter, change of frame
    %                             or slice, radio button pressed, etc)
    % handles.image.eigenValues   vector of normalized eigenvalues for the current slice.
    % handles.image.zoomFactorFormula  a formula string, used to calculate zoom factor (default value 1)
    % handles.image.plane         view plane.  One of: Axial, Sagital,  Coronal
    % handles.image.history       a description of how an image is derived. 
    %                             For instance, an image is opened (no history), 
    %                             and a SUV is created (history="SUV-").
    %                             The image is then filtered with a
    %                             gaussian filter (history="gaussian-SUV-").
    %                       
    %
    % handles.GUILayout           stores original positions of GUI-widgets (used for resizing)
    %
    %
    %       ECAT specific storage
    %       ---------------------
    %       handles.image.mainHeader              % Stores binary header  
    %       handles.image.subHeader               % Stores binary header
    %       handles.image.ECATDirStruct           % Stores binary internal file structure
    %
    %       DICOM specific storage                % MATLAB DICOM read
    %       ---------------------
    %       handles.image.DICOMHeader
    %
    %       Dirty-DICOM specific storage                % Binary read of DICOM files
    %       ----------------------------
    %       handles.image.dirtyDICOMHeader              % Stores binary header   
    %       handles.image.dirtyDICOMFileNames           % Stores file names for original input files
    %       handles.image.dirtyDICOMPixelSizeString     % Stores dialog answers in case we want to save modified results
    %       handles.image.dirtyDICOMSlicesString        % Stores dialog answers in case we want to save modified results
    %       handles.image.dirtyDICOMMachineFormat       % Stores dialog answers in case we want to save modified results
    %      
    %
    % FUNCTIONS (the not so obvious):
    % ----------
    % The graphics is built in two levels, one for the image, and one
    % for the ROIs.  The following functions perform the work in image
    % display and ROI drawing.
    %
    % function updateImage: A cached image is processed and store (handles.image.CachedImage)
    %                       whenever a callback that change the display of the current image
    %                       is performed.  This function calls updateROIs.
    %
    % function updateROIs:  This display of the ROI and the cached image is performed in this function.
    %
    % function drawROI:     ROI drawing.  This function calls updateROIs, and draws on the cached image.  
    %                       The following utility functions are used to allow
    %                       drawing ROIs while dragging the mouse: wbd, wbm, wbu
    % 
    %
    %
    % CALLBACKS:    (that are not self-explained) 
    % ---------
    % wbd:                  when Mouse down in GUI
    % 



    
% ========================================================================
% 
% INITIALIZATION 
%
% ========================================================================
% --------
% imlook4d
% --------
%
% Author:   Jan Axelsson
%
% Purpose:  Used for display and ROI-analysis of 4D images.
%
%  INSTRUCTIONS  
%
%
%  Input arguments:  Data       4D (or 3D) matrix
%                    time       vector of frame time (4D matrix)
%                    duration   vector of frame duration (4D matrix)
%
%                    NO input arguments launches a file dialog
%
%  Example:          imlook4d
%                    h=imlook4d
%                    imlook4d( matrix, time)
%                    imlook4d( matrix, time, durations)
%
%

% IMLOOK4D M-openmenu for imlook4d.fig
% Based on imlook3d by Omer Demirkay
% Modified to allow 4D (dynamic) PET data, Jan Axelsson

%      IMLOOK4D, by itself, creates a new IMLOOK4D or raises the existing
%      singleton*.
%
%      H = IMLOOK4D returns the handle to a new IMLOOK4D or the handle to
%      the existing singleton*.
%
%      IMLOOK4D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMLOOK4D.M with the given input
%      arguments.
%
%      IMLOOK4D('Property','Value',...) creates a new IMLOOK4D or raises
%      the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before imlook4d_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to imlook4d_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imlook4d

% --------------------------------------------------------------------
% STARTUP
% --------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
function varargout = imlook4d(varargin)


    gui_Singleton = 0;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @imlook4d_OpeningFcn, ...
                       'gui_OutputFcn',  @imlook4d_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
   
    % Handle calling imlook4d with a function name
    % Example:  imlook4d('LoadRoiPushbutton_Callback', imlook4d_current_handles.LoadROI,{} ,imlook4d_current_handles, filePath)
    % Want to handle differently if:
    % 1) Function name - use str2func
    % 2) File path - avoid doing anything
    try            
            if nargin && ischar(varargin{1}) 
                % New code, because str2func will get changed behaviour in
                % future matlab versions.
               [pathstr,name,ext] = fileparts(varargin{1});  % 
               if ~exist(pathstr,'dir') % Not file path (thus function name)
                    gui_State.gui_Callback = str2func(varargin{1});
               end
            end
    catch
        % If not a valid function name - for instance when calling imlook4d('C:\mytest.dcm');
    end

    if isempty(varargin)
        %disp('No image to display');
        %disp('USAGE: imlook4d(img) or imlook4d( matrix, time) or imlook4d( matrix, time, durations)');
        

        %varargin{1}=zeros(128,128,5,5); Dummy array to make imlook4d open without arguments
        
         % THIS ROW COMMENTED ALLOWS IMLOOK4D TO RUN WITH NO INPUT, AND WITHOUT FILE
        % DIALOG       
        %return
    end

    if nargout
         [varargout{1:nargout}] = gui_mainfcn(gui_State,varargin{:});        

    else
        gui_mainfcn(gui_State, varargin{:});
    end
% End initialization code - DO NOT EDIT
  
% Executes just before imlook4d is made visible
function imlook4d_OpeningFcn(hObject, eventdata, handles, varargin)
            % This function has no output args, see OutputFcn.
            % hObject    handle to figure
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            % varargin   command line arguments to imlook4d (see VARARGIN)
            %
            
            % Set recording to off
            handles.record.enabled = false;
            
            % Set data cursor function
              dcm = datacursormode(hObject);
              set(dcm,'UpdateFcn',@dataCursorUpdateFunction)
            
            % Set screen resolution for MATLAB (make GUI look similar for
            % different resolutions)
            %set(0,'ScreenPixelsPerInch',96)
            

            %
            % Clear hidden image (I don't know how this got to be a default
            % image, but lets simple clear it).
            %
                hc=get(handles.axes1,'Children');
                delete(hc(1));

            %
            % Check if file path, instead of matrix, then read file
            %         
                if nargin()==4 
                    if iscellstr(varargin)
                        disp('File path as input argument');
                        OpenFile_Callback(hObject, eventdata, handles, varargin{1});  % Open new file dialog, puts into new imlook4d instance
                        delete(hObject);  % Remove current imlook4d (the one called with empty arguments)
                        return
                    end
                end


            % Choose default command line output for imlook4d if isempty(varargin{:})
               if isempty(varargin)
                     % If imlook4d is called with no arguments,
                     %     h=imlook4d
                     % an instance of imlook4d is created, and the execution will enter here.
                     %
                     % The idea is to delete this instance, and open a new imlook4d from a file.
                     % This will be done in the following steps:
                     % - an open dialog is displayed (which will create a new imlook4d instance)
                     % - the current instance within this if statement (hObject) is killed
                     %
                     % The handle to the imlook4d instance created by OpenFile_Callback 
                     % is found by function gcf, (see imlook4d_OutputFcn)

                    button = questdlg('Open file or from PACS?','Select file source','File','PACS','File');
                    
                    guidata(hObject,handles); % Store 
                    if strcmp(button,'File')
                        % hObject is normally called back from menu item
                        OpenFile_Callback(hObject, eventdata, handles);  % Open new file dialog, puts into new imlook4d instance
                    end
                    
                    
                    % BUILD A PACS LIST - this is a duplicate of what
                    % happens below for the "Network Hosts" submenues.
                    if strcmp(button,'PACS')
                        
                         [pathstr1,name,ext] = fileparts(which('imlook4d'));
                         temp=listDirectory([pathstr1 filesep 'PACS']);

                         % Build list of PACS:es
                             counter=1;
                             for i=1:length(temp)
                                [pathstr,name,ext] = fileparts(temp{i});
                                if strcmp(ext,'.m')
                                    nameWithSpaces{i}= regexprep(name,'_', ' ');  % Replace '_' with ' '
                                    fileName{counter}=[name ext];
                                    counter=counter+1;
                                end
                             end  
                         
                         % Select PACS from list if more than one PACS,
                         % otherwise use the single PACS
                             if exist('fileName','var')  
                                 selected=1;  % Default value

                                 % Select PACS from list
                                 if length(fileName)>1
                                     [selected,v] = listdlg('PromptString','Select PACS:',...
                                              'SelectionMode','single',...
                                              'ListString',nameWithSpaces);
                                 end

                                  ok=getFromPacs(fileName{selected}); % Open from PACS
                             else
                                 errordlg({'NO PACS DEFINED', 'Define a PACS, or open from file'});
                             end

                    end                    
                    
                    delete(hObject);  % Remove current imlook4d (the one called with empty arguments)
                    return
                 end

            % This alternative should allow for multiple input arguments
            % without giving an error
                if isempty(varargin{1})
                   return;
                end





            %
            % Setup display 
            %
                handles.output = hObject;
                Std.Interruptible = 'off';
                Std.BusyAction = 'queue';
                Ax = Std;
                Ax.Units = 'Pixels';
               % Ax.YDir = 'reverse';
                Ax.XLim = [.5 128.5];
                Ax.YLim = [.5 128.5];
                Ax.CLimMode = 'auto';
                Ax.XTick = [];
                Ax.YTick = [];
                set(handles.axes1,Ax);
               % set(handles.foreground,Ax);
               % set(handles.roiLayer,Ax); 

                % Set axis to auto-fit 
                axis(handles.axes1, 'auto')
               % axis(handles.foreground, 'auto')
              %  axis(handles.roiLayer, 'auto')

                % Defaults for image axes
                Img = Std;
                Img.CData = [];
                Img.Xdata = [];
                Img.Ydata = [];
                Img.CDataMapping = 'scaled';
                %Img.Erasemode = 'none';
                handles.image= Img;

           %
           % Setup saved parameters
           %

                %inpargs = varargin{:};
                inpargs = varargin{1};    % Matrix


                %INPUT time and duration (this is the only way to get them into
                %imlook4d, as input arguments
                if nargin()>=5
                    handles.image.time=varargin{2};
                    %disp('Second argument (time) detected');
                end
                if nargin()>=6
                    handles.image.duration=varargin{3};
                    %disp('Third argument (duration) detected');

                    % Calculating frame mid-time (assuming frame start-time)
                    %handles.image.time=handles.image.time+handles.image.duration/2;
                end

                
%                 %%%% Anders code for m4 %%%%%
%                 if (isa(inpargs,'Matrix4D'))
%                   m4 = inpargs;
%                   inpargs = single(m4.matrix);
%                   handles.image.time = m4.getVolumeTimeStamp('mean');
%                   handles.image.fileType = 'Matrix4D';
%                   handles.image.pixelSizeX = m4.voxelSize(1);
%                   handles.image.pixelSizeY = m4.voxelSize(2);
%                   handles.image.sliceSpacing = m4.voxelSize(3);
%                   handles.image.modality = m4.imagingInfo.Modality;
%                     
%                 end
%                 %%%%% End Anders code for m4 %%%%
                
                
                [r,c,z,frames]=size(inpargs);
                %inpargs=flipdim(inpargs,2);             % flip y axis
                handles.image.Cdata=inpargs;            % put 4D matrix into handles.image.Cdata

                % ECAT file storage 
                %handles.image.mainHeader=1;
                %handles.image.subHeader=1;
                %handles.image.ECATDirStruct=1;

                handles.image.StoredFrameSliderValue=0; % Used to store the frame when jumping from image to PC-image.  Zero means no frame stored

                handles.image.zoomFactorFormula='1';   % String used to calculate zoom factor



            %
            % Setup image, colorbar and ROI 
            %

                %handles.image.ROI=zeros(size(inpargs),'int8'); % Matrix for ROIs
                handles.image.ROI=zeros(size(inpargs,1),size(inpargs,2),size(inpargs,3),'uint8'); % 3D Matrix for ROIs
                
                handles.image.VisibleROIs=uint8([]);   % Allow 255 ROIs, make them all visible
                handles.image.LockedROIs=uint8([]);    % Allow 255 ROIs
                handles.imSize = [r,c,z];
                cimg = handles.image.Cdata(:,:,1,1);    % put current image (slice 1, frame 1) into cimg 
                %cimg=orientImage(cimg);                 % correct orientation on first image to display

                % Create image object and set the properties
                handles.ImgObject = image(Img,'Parent',handles.axes1);
                handles.ImgObject2 = image(Img,'Parent',handles.axes1);
                handles.ImgObject3 = imagesc(Img,'Parent',handles.axes1);
% Warning: The EraseMode property is no longer supported and will error in a future release. Use the
% ANIMATEDLINE function for animating lines and points instead of EraseMode 'none'. Removing instances
% of EraseMode set to 'normal', 'xor', and 'background' has minimal impact. 
                

                handles.image.CachedImage=cimg;      % create cached image
                %handles.ImgObject = imagesc(Img,'Parent',handles.axes1);


                % cimg = imscale(cimg,[],[]);
                set(handles.ImgObject,'Cdata',cimg);
                set(handles.SliceNumEdit,'String',1);

                htable = feval('jet');
                set(handles.figure1,'Colormap',htable); 
                set(handles.ImgObject,'Cdata',cimg);
                set(handles.ImgObject,'Xdata',[0 r]+0.5);
                set(handles.ImgObject,'Ydata',[0 c]+0.5);
                
                % ROI layer
                set(handles.ImgObject3,'Cdata', zeros(size(cimg)));  
                set(handles.ImgObject3,'Xdata',[0 r]+0.5);
                set(handles.ImgObject3,'Ydata',[0 c]+0.5);

                % Set the properties of the axes
                set(handles.axes1,'XLim',[0 r]+0.5);
                set(handles.axes1,'YLim',[0 c]+0.5);
                set(handles.axes1,'XLim',[-0.5 r+0.5]);
                set(handles.axes1,'YLim',[-0.5 c+0.5]);
                % Set the slider's value and step size

                % Colorbar

               % colormap jet
               handles.ColorBar=colorbar('peer',handles.axes1, 'FontSize', 9);
               
               set(handles.ColorBar, 'HitTest', 'off'); % No contextual menu
               
               %handles.ColorBar=colorbar(handles.axes1,'eastoutside' ); % Funkar ej i Matlab 2013 o tidigare
            %   drawnow % force redraw, otherwise axis becomes misplaced in Matlab 2014b

            %
            % Setup GUI sliders
            %

                %initiateSliderRanges(handles);
                adjustSliderRanges(handles)
                  drawnow % force redraw, otherwise axis becomes misplaced in Matlab 2014b
  
                

                % Set the string of the edit box
                %set(handles.SliceNumEdit,'String','1')
                % Set the string of the edit box
                %set(handles.FrameNumEdit,'String','1')

            %
            % Make SCRIPT MENUS (from files in imlook4d SCRIPTS directory)
            %
            %    (Scripts are m-files saved in SCRIPTS subdirectories)
            %
            %   SCRIPTS menu            scriptsMenuHandle -                      
            %       ITEM menu               scriptsMenuSubHandle -
            %           script-file.m           scriptsMenuSubItemHandle
            
                  % Main menu item
                 handles.scriptsMenuHandle = uimenu(handles.figure1,'Label','SCRIPTS');
                 set(handles.scriptsMenuHandle, 'Callback', 'imlook4d(''ScriptsMenu_Callback'',gcbo,[],guidata(gcbo))');          
            
                 [pathstr1,name,ext] = fileparts(which('imlook4d'));
                 %temp=ls([pathstr1 filesep 'SCRIPTS']);            % Read files in SCRIPTS directory
                 %temp = cellstr(temp(3:end,:));             % Make cell array of all except '.' and '..' 
                 
                 [files dirs]=listDirectory([pathstr1 filesep 'SCRIPTS']);

                 % Submenues (Folder names, skip if starting with '.')
                 for i=1:length(dirs)
                    if ~strcmp(dirs{i}(1),'.') % Skip if directory starts with '.'
                        
                        nameWithSpaces= regexprep(dirs{i},'_', ' ');  % Replace '_' with ' '
                        handles.scriptsMenuSubHandle = uimenu(handles.scriptsMenuHandle,'Label',nameWithSpaces);  % Make submenu (don't add callback - let SCRIPT menu do callback)
                        %set(handles.scriptsMenuHandle, 'Callback', 'imlook4d(''ScriptsMenu_Callback'',gcbo,[],guidata(gcbo))');  % Same callback for all scripts
                        
                        % Submenu scripts (Look inside folders, and make submenu items (script names)  )
                         [files2 dirs2]=listDirectory([pathstr1 filesep 'SCRIPTS' filesep dirs{i}]);
                         addpath([pathstr1 filesep 'SCRIPTS' filesep dirs{i}]);      % Add folder to path (in case you made a new one) 
                         
                         for j=1:length(files2)
                            
                            [pathstr,name,ext] = fileparts(files2{j});
                            if strcmp(ext,'.m')
                                nameWithSpaces= regexprep(name,'_', ' ');  % Replace '_' with ' '
                                
                                %handles.scriptsMenuSubItemHandle(j) = uimenu(handles.scriptsMenuSubHandle,'Label',nameWithSpaces, 'Callback', ['eval(''' name ''') ']); 
                                
                                % EXAMPLE how to callback two functions
                                %handles.scriptsMenuSubItemHandle(j) = uimenu(handles.scriptsMenuSubHandle,'Label',nameWithSpaces, 'Callback', ['disp(''HEJ'');' 'eval(''' name ''') ']); 
                                %disp(['eval(''' name ''') ']);

                                % Advanced callback to allow help files for
                                % scripts
                                handles.scriptsMenuSubItemHandle(j) = ...
                                    uimenu(handles.scriptsMenuSubHandle,'Label',nameWithSpaces, 'Callback', [ ...
                                    'if imlook4d(''DisplayHelp'',gcbo,[],guidata(gcbo));return;end;' ...
                                    'eval(''' name ''') ' ...
                                    ]); 

                            end
                         end

                    end
                 end


                 
            %
            % Make MODELS menu (from files in imlook4d MODELS directory)
            %
            %   (Models are m-file functions saved in MODELS directory)
                 [pathstr1,name,ext] = fileparts(which('imlook4d'));
                 %temp=ls([pathstr1 filesep 'MODELS']);             % Read files in SCRIPTS directory
                 %temp = cellstr(temp(3:end,:));             % Make cell array of all except '.' and '..' 

                 % Main menu item
                 handles.image.modelsMenuHandle = uimenu(handles.figure1,'Label','MODELS');
                 set(handles.image.modelsMenuHandle, 'Callback', 'imlook4d(''ModelsMenu_Callback'',gcbo,[],guidata(gcbo))');
                 %disp('imlook4d: MODELS menu commands');

                 %temp=ls([pathstr1 filesep 'MODELS']);
                 
                 temp=listDirectory([pathstr1 filesep 'MODELS']);

                 % Submenu items
                 for i=1:length(temp)
                     [pathstr,name,ext] = fileparts(temp{i});
                    nameWithSpaces= regexprep(name,'_', ' ');  % Replace '_' with ' '

                    if strcmp(ext,'.m')
                        % Setup submenu callback (for instance test_control)
                        handles.image.modelsSubMenuHandle(1) = uimenu(handles.image.modelsMenuHandle,'Label',nameWithSpaces, 'Callback', [name '_control(gcbo)']);
                      
                        %disp([name '_control(guidata(gcbo))']);% Display paths to scripts

                        % Setup image generation function (for instance @test)
                        handles.model.functionHandle=[];
                    end
                 end

            %
            % Make COLOR menu (from files in imlook4d COLORMAPS directory)
            %
                 [pathstr1,name,ext] = fileparts(which('imlook4d'));
%                  temp=ls([pathstr1 filesep 'COLORMAPS']);          % Read files in SCRIPTS directory
%                  temp=([pathstr1 filesep 'COLORMAPS']);
%                  temp = cellstr(temp(3:end,:));             % Make cell array of all except '.' and '..' 
                 
                 temp=listDirectory([pathstr1 filesep 'COLORMAPS']);

                 % Submenu items
                 for i=1:length(temp)
                    [pathstr,name,ext] = fileparts(temp{i});
                    nameWithSpaces= regexprep(name,'_', ' ');  % Replace '_' with ' '

                    if strcmp(ext,'.m')
                        % Setup submenu callback 
                        % WAS callbackString=['imlook4d(''Color_Callback'',gcf,[],guidata(gcf),''' name ''')'];
%                         callbackString=['@(hObject,eventdata)imlook4d(''Color_Callback'',hObject,eventdata,guidata(hObject), ''' name ''' )'];
%                         callbackString=['@(hObject,eventdata)imlook4d(''Color_Callback'',gcf,{},guidata(gcf), ''' name ''' )'];
%                         
                        callbackString=['imlook4d(''Color_Callback'',gcf,[],guidata(gcf), ''' name ''' )'];
                       callbackString=['imlook4d(''Color_Callback'',gcbo,[],guidata(gcbo), ''' name ''' )'];

                        %disp(['name=' name '   ColorCallback=' callbackString]);% Display paths
                        handles.image.colorSubMenuHandle(i) = uimenu(handles.Cmaps, 'Label',nameWithSpaces, 'Callback', callbackString);
                    end
                 end  
            %
            % Make WINDOW LEVEL menu (from files in imlook4d WINDOW_LEVELS directory)
            %
                 [pathstr1,name,ext] = fileparts(which('imlook4d'));
%                  temp=ls([pathstr1 filesep 'WINDOW_LEVELS']);      % Read files in WINDOW_LEVELS directory
%                  temp=([pathstr1 filesep 'WINDOW_LEVELS']);
%                  temp = cellstr(temp(3:end,:));             % Make cell array of all except '.' and '..' 
 
                 temp=listDirectory([pathstr1 filesep 'WINDOW_LEVELS']);

                 % Submenu items
                 for i=1:length(temp)
                    [pathstr,name,ext] = fileparts(temp{i});
                    nameWithSpaces= regexprep(name,'_', ' ');  % Replace '_' with ' '

                    if strcmp(ext,'.m')
                        % Setup submenu callback 
                        callbackString=[name '(gcbo,[],guidata(gcbo))'];  % Callback using ui object
                        callbackString=[callbackString ';' 'imlook4d(''updateImage'',gcf,[],guidata(gcf) )'];

                        
                        %disp(['name=' name '   WINDOW_LEVELS Callback=' callbackString]);% Display paths
                        handles.image.WindowLevelsSubMenuHandle(i) = uimenu(handles.WindowLevelsMenu, 'Label',nameWithSpaces, 'Callback', callbackString);     
                    end
                 end  
                 
            %
            % Make NETWORK HOSTS menu (from files in imlook4d PACS directory)
            %
                 [pathstr1,name,ext] = fileparts(which('imlook4d'));
%                  temp=ls([pathstr1 filesep 'WINDOW_LEVELS']);      % Read files in WINDOW_LEVELS directory
%                  temp=([pathstr1 filesep 'WINDOW_LEVELS']);
%                  temp = cellstr(temp(3:end,:));             % Make cell array of all except '.' and '..' 
                 
                 temp=listDirectory([pathstr1 filesep 'PACS']);

                 % Submenu items
                 counter=0;
                 for i=1:length(temp)
                    [pathstr,name,ext] = fileparts(temp{i});
                    nameWithSpaces= regexprep(name,'_', ' ');  % Replace '_' with ' '

                    if strcmp(ext,'.m')
                        counter=counter+1;
                        % Setup submenu callback 
                        callbackString=['imlook4d(''NetworkHostsSubMenu_Callback'',gcbo,[],guidata(gcbo))'];
                        
                        %disp(['name=' name '   WINDOW_LEVELS Callback=' callbackString]);% Display paths
                        handles.image.NetworkHostsSubMenuHandle(counter) = uimenu(handles.NetworkHostsMenu, 'Label',nameWithSpaces, 'Callback', callbackString, 'UserData', [name '.m']);     
                    end
                 end     

                 
                 % Select first item, if not empty
                 try
                        % Select the first item
                        %NetworkHostsSubMenu_Callback( handles.image.NetworkHostsSubMenuHandle(1),[], guidata(handles.image.NetworkHostsSubMenuHandle(1) ) );
                        pacsDataFileName=get(handles.image.NetworkHostsSubMenuHandle(1),'UserData');
                        
                        handles.image.PACS.HostFile=pacsDataFileName;   % WHY IS THIS LOST after OpeningFunction is done?
                        set(handles.image.NetworkHostsSubMenuHandle(1),'Checked','on')
                 catch
                        % Gray out PACS menues if no PACS enabled 
                        set(handles.OpenFromPACS,'Enable','off')
                        set(handles.NetworkHostsMenu,'Enable','off')
                 end

                                
            %
            % Make HELP menu (let it display at far right)
            %
                 set(handles.HelpMenu,'Position',8);
                 disp('HELP menu')

                 
            %
            % Make Windows menu (let it display to the left of HelpMenu)
            %
                set(handles.windows,'Position',7);
                disp('Windows menu')




            %
            % Gray out menues requiring special toolboxes
            %             
                % Profile
                if ( strfind('C:\Program Files\MATLAB\R2008b\toolbox\matlab\codetools\profile.m', 'profile.m')>0)
                else
                    set(handles.imProfile', 'Enable', 'off');
                end;       

            %
            % Store GUI layout information (use when resizing window)
            %

                units='Pixels';

                % Set Font sizes
                SMALL = 7;
                MEDIUM = 8;
                FONTNAME = 'Arial';
                % Loop all GUI objects including figure1, axes1 
                 guiNames=fieldnames(handles);
                for i=1:size(guiNames,1)
                    h=eval(['handles.' guiNames{i}]);
                    try % Some things in handles struct do not have Units property
                        %set(h,'Units',units);
                        
                        set(h,'FontName',FONTNAME)
                        
                        % For all except edit boxes
                        if ~strcmp( 'edit', get(h,'Style'))
                            set(h,'FontSize',MEDIUM)
                        end
                    catch
                    end
                end
                
                set(handles.infoText1,'FontSize',SMALL)

               guiHandles=findobj(hObject,'-property','Units');
               for i=1:size(guiHandles,1)
                    try % Some things in handles struct do not have Units property
                        set(guiHandles(i),'Units',units);
                    catch
                    end
               end



                %disp('setting GUILayout');

               % set(handles.axes1,'Units','Normalized');


                % Figure and image
                handles.GUILayout.figure1=get(handles.figure1, 'Position');
                handles.GUILayout.axes1=get(handles.axes1, 'Position');

                % Panels
                handles.GUILayout.uipanel1=get(handles.uipanel1, 'Position');
                handles.GUILayout.uipanel2=get(handles.uipanel2, 'Position');
                handles.GUILayout.uipanel5=get(handles.uipanel5, 'Position');
                handles.GUILayout.uipanel6=get(handles.uipanel6, 'Position');
                handles.GUILayout.uipanel7=get(handles.uipanel7, 'Position');
                %handles.GUILayout.ColorBar=get(handles.ColorBar, 'Position');


                set(handles.ColorBar,'Units','normalized');  % Correct above loop (otherwise interactive colorbar does not work)

                                


                
                
                % Controls (GUILayout2 should not move in y direction)
    %             handles.GUILayout2.frame1=get(handles.frame1, 'Position');
    %             handles.GUILayout2.frame3=get(handles.frame3, 'Position');           
    %             handles.GUILayout2.FrameText=get(handles.FrameText, 'Position');  
    %             handles.GUILayout2.SliceText=get(handles.SliceText, 'Position');           
    %             handles.GUILayout2.FrameNumSlider=get(handles.FrameNumSlider, 'Position');   
    %             handles.GUILayout2.SliceNumSlider=get(handles.SliceNumSlider, 'Position'); 
    %             handles.GUILayout2.FrameNumEdit=get(handles.FrameNumEdit, 'Position');  
    %             handles.GUILayout2.SliceNumEdit=get(handles.SliceNumEdit, 'Position');  
    %             handles.GUILayout2.frameTimeText=get(handles.frameTimeText, 'Position');  
    %             handles.GUILayout2.frameTimeMinutesText=get(handles.frameTimeMinutesText, 'Position');  
    %             handles.GUILayout2.text17=get(handles.text17, 'Position');                          
%                 set(handles.versionText,'Units','normalized');  % Correct above loop (otherwise interactive colorbar does not work)
%                  handles.GUILayout2.versionText=get(handles.versionText, 'Position'); 

    

            %
            % Set continous auto-update on sliders (when moving slider with mouse)
            %
                hs = handles.SliceNumSlider;
                hListener = addlistener(hs,'Value','PostSet',...
                    @(hObject,eventdata)imlook4d('updateImage',gcf,eventdata,guidata(gcf)) ...
                    );
                
                
                hs = handles.FrameNumSlider;
                hListener = addlistener(hs,'Value','PostSet',...
                    @(hObject,eventdata)imlook4d('updateImage',gcf,eventdata,guidata(gcf)) ...
                    );
                
                
                hs = handles.PC_high_slider;
                hListener = addlistener(hs,'Value','PostSet',...
                    @(hObject,eventdata)imlook4d('updateImage',gcf,eventdata,guidata(gcf)) ...
                    );
                
            %
            % Set same background color on all widgets
            %
               figureBackgroundColor=get(hObject,'Color');    
               guiHandles=findobj(hObject, '-not', 'uimenu', '-not', 'Style', 'edit', '-not', 'Style', 'popupmenu');
               for i=1:size(guiHandles,1)
                   try  
                           % set(guiHandles(i),'BackgroundColor',  figureBackgroundColor); 
                   catch
                   end
               end 

               
            %
            % Set version number (from About.txt file)
            %


                version=getImlook4dVersion();
                set(handles.versionText, 'String', ['imlook4d (' version ') /Jan Axelsson'  ]);
 

                

            %
            % Generate brush
            %
                %BrushSize_Callback(hObject, eventdata, handles);

            %
            % Finalize
            %
            
                % Set sliders
                adjustSliderRanges(handles);
%                 get(handles.PC_high_slider)
%                 get(handles.PC_high_edit)
            
                set(handles.axes1, 'visible', 'off');  % hide 

                set(hObject, 'Name','Name');   
                set(hObject,'Tag', 'imlook4d');
                
                 % Store view type
                handles.image.plane='Axial';
               
                % Store history
                handles.image.history='';
                
                % Store currently selected radio button
                handles.imageRadioButtonGroupActiveButton = handles.ImageRadioButton;
                

                % Update handles structure
                guidata(hObject, handles);

                clear varargin;
                figure1_ResizeFcn(hObject, eventdata, handles)
                imlook4d_set_defaults(hObject, eventdata, handles);
                
%                             
%                             
%             % Adjust colorbar position
%            % handles.ColorBar = findobj(gcf,'Tag','Colorbar');
% 
%            initpos = get(handles.ColorBar,'Position')
%             initfontsize = get(handles.ColorBar,'FontSize');
% 
%             dY=0.08;
%             dY=20;
% 
%             set(handles.ColorBar, 'Position', ...
%                 [ initpos(1) ...
%                  initpos(2)+dY ...
%                   initpos(3) ...
%                   initpos(4)-2*dY ], ...
%                'FontSize',initfontsize*1, ...
%                'Location', 'EastOutside')


% Output to command line                    
function varargout = imlook4d_OutputFcn(hObject, eventdata, handles)
        % --- Outputs from this function are returned to the command line.
        % varargout  cell array for returning output args (see VARARGOUT);
        % hObject    handle to figure
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)

        % Get default command line output from handles structure
        try
            varargout{1} = handles.output;

            
        catch
             % gcf will be the handle to imlook4d 
             % as created in OpenFile_Callback
             % (which was called from imlook4d_OpeningFcn)
             varargout{1}=gcf;
        end

       
% --------------------------------------------------------------------
% GUI CREATION, this is where a GUI is defined
% --------------------------------------------------------------------
  
    % Depreciated (phased out)
    function initiateSliderRanges(handles)
       warndlg('initiateSliderRanges is depreciated.  Contact Jan');
       % This function initiates the slider ranges
       % when a new imlook4d instance is opened
       [r,c,z,frames]=size(handles.image.Cdata);
     
        % one or multiple slides
        if z == 1
            % Make slice slider and edit invisible
            %disp('Single slice')
            set(handles.SliceNumSlider,'visible','off','Value', 1);
            set(handles.SliceNumEdit,'visible','off');
            set(handles.SliceText,'visible','off');
        else
            %disp('Multiple slices')
            %if ( get(handles.SliceNumSlider,'Value')>z)
                set(handles.SliceNumSlider,'visible','on','Min',1,'Max',z,...
                    'Value',round(z/2),...
                    'SliderStep',[1.0/double(z-1) 1.0/double(z-1)]);
                
                set(handles.SliceNumEdit,'String',num2str(round(z/2)) );
            %end
            
            %set(handles.SliceNumEdit,'visible','on');
            %set(handles.SliceText,'visible','on');
        end

        % one or multiple frames
        if frames == 1
            % Make frame slider and edit invisible
            %disp('Single frame')
            set(handles.FrameNumSlider,'visible','off','Value',1);
            set(handles.FrameNumEdit,'visible','off');
        else
            %disp('Multiple frames')
            set(handles.FrameNumSlider,'visible','on','Min',1,'Max',frames,...
                'Value',1,...
                'SliderStep',[1.0/double(frames-1) 1.0/double(frames-1)]);
            
            set(handles.PC_low_slider,'Min',1,'Max',frames,...
                'Value',1,...
                'SliderStep',[1.0/double(frames-1) 1.0/double(frames-1)]);
            
            set(handles.FrameNumEdit,'visible','on');
            set(handles.FrameText,'visible','on');
            
            
            % Hardcoded initial value for noise cutoff
            set(handles.PC_high_slider,'Min',1,'Max',frames,'Value',...
                frames,'SliderStep',[1.0/double(frames-1) 1.0/double(frames-1)]);
        end
        
        set(handles.PC_high_edit,'visible','on','String',num2str(frames));
        
        set(handles.PC_high_edit,'visible','on','String',frames);    
    function SliceNumSlider_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to SliceNumSlider (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns
        % called

        % Hint: slider controls usually have a light gray background, change
        %       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
        usewhitebg = 1;
        if usewhitebg
            set(hObject,'BackgroundColor',[.9 .9 .9]);
        else
            set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor')); %#ok<UNRCH>
        end
    function SliceNumEdit_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to SliceNumEdit (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called
        % Hint: edit controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        if ispc
            set(hObject,'BackgroundColor','white');
        else
            set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
        end
    function FrameNumSlider_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to FrameNumSlider (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: slider controls usually have a light gray background.
        if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor',[.9 .9 .9]);
        end
    function FrameNumEdit_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to FrameNumEdit (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: edit controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        if ispc
            set(hObject,'BackgroundColor','white');
        else
            set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
        end
    function PC_high_edit_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to PC_high_edit (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: edit controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end     
    function PC_low_slider_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to PC_low_slider (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: slider controls usually have a light gray background.
        if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor',[.9 .9 .9]);
        end
    function PC_high_slider_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to PC_high_slider (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: slider controls usually have a light gray background.
        if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor',[.9 .9 .9]);
        end
    function PC_low_edit_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to PC_low_edit (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: edit controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
    function ROINumberMenu_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to ROINumberMenu (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: popupmenu controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
        set(hObject,'String', {'Add ROI'});
    function FirstFrame_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to PC_low_edit (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: edit controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end   
    function imlook4d_set_colorscale_from_modality(hObject, eventdata, handles)
               %
               % Set Colorscale according to modality
               %
               disp('Entered imlook4d_set_colorscale_from_modality');
                    try  
                          
                        switch handles.image.modality
                            case 'PT'
                                Color(hObject, eventdata, handles, 'Sokolof')
                                handles.ColormapName = 'Sokolof';
                            case 'CT'
                                Color(hObject, eventdata, handles, 'Gray')
                                handles.ColormapName = 'Gray';
                            case 'MR'
                                Color(hObject, eventdata, handles, 'Gray')
                                handles.ColormapName = 'Gray';
                            otherwise
                                Color(hObject, eventdata, handles, 'Gray')
                                handles.ColormapName = 'Gray';
                        end %switch
                        
                    catch
                         Color(hObject, eventdata, handles, 'Sokolof')
                         handles.ColormapName = 'Sokolof';
                    end  
                    
                    guidata(handles.figure1, handles);
                    
    function imlook4d_set_defaults(hObject, eventdata, handles)
            resizePushButton_ClickedCallback(hObject, eventdata, handles);                      % Resize up one step
            try
                if size(handles.image.Cdata,1)<257
                    interpolate2_Callback( handles.interpolate2, [], guidata( handles.interpolate2));   % Sets default to interpolate x2 if less than 257 pixels
                end
            catch
            end
            imlook4d_set_colorscale_from_modality(hObject, eventdata, handles);                               % Sets colorscale according to modality (if known)
       
            % Brush size
            BrushSize_Callback(hObject, eventdata, handles)    


           


% ========================================================================
% 
% GUI CALLBACKS, this is where a GUI event goes into the code
%
% ========================================================================
    function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: delete(hObject) closes the figure
    delete(hObject);
    function figure1_ResizeFcn(hObject, eventdata, handles, dyIn)
    % Performs resizing of the imlook4d window in either of the following
    % ways:
    % Case 1: The resize is performed by mouse, and the
    % figure1OriginalPosVector is retrieved.
    % Case 2: The resize is performed by program, because smaller than original size was selected by mouse
    %
    % The strategy is to resize with kept proportions on axes1 (the image),
    % AND keeping the top left corner stationary until leaving screen.
    % - Number of pixels resized in y-direction (dy) is used to calculate resize in x-direction (dx), (keeping proportions of axes1)
    % - The number of pixels resized in figure1 is equal to number of pixels resized in axes1.
    % - If resized to smaller than original size, resize to original size
    % - GUI widgets are moved to correct position
    % - axes1 is resized
    % - figure1 is resized
    try
        SetColorBarUpdateState(handles.axes1, 'on'); 
    catch
    end
        %drawnow;
        %disp(['New size=(' num2str(get(handles.figure1, 'Position') ) ')']);
        
        %
        % Initialize
        %
            try
                set(handles.ColorBar,'Units','Pixels');              % Make colorbar possible to move correct distance
            catch
            end
        
            figure1OriginalPosVector=handles.GUILayout.figure1;  % Stored at start of imlook4d
            axes1OriginalPosVector=handles.GUILayout.axes1;      % Stored at start of imlook4d
            originalProportions=axes1OriginalPosVector(4)/axes1OriginalPosVector(3);  % Original proportions of axes1, height/width

            figure1CurrentPosVector=get(handles.figure1,'Position');    % Current size of figure1 
            
            % New position of figure window (guess same as current)
            figure1PosVector(1)=figure1CurrentPosVector(1);  
            figure1PosVector(2)=figure1CurrentPosVector(2);
            % figure1PosVector(3), figure1PosVector(4) is set below
      
        %   
        % Calculate change in size relative original
        %
            % Case 1: Mouse-resizing:  Calculate change in size relative % original
                dx1=figure1CurrentPosVector(3)-figure1OriginalPosVector(3);  % changed width  of figure1 relative original size
                dy1=figure1CurrentPosVector(4)-figure1OriginalPosVector(4);  % changed height of figure1 relative original size

                % Calculate new dx that keeps proportions of axes1
                % NOTE: dx, dy is also the size difference for axes1
                % Change width to keep proportions:
                %   [ dy+axes1OriginalPosVector(4) ]/ [ dx+axes1OriginalPosVector(3) ]=originalProportions
                
                dx=( dy1+axes1OriginalPosVector(4) ) /originalProportions  - axes1OriginalPosVector(3);
                
                dy=dy1;
                
                % Bail out if too small of a change 
                % (otherwise GUI will shake from small movement)
                if ( abs( dx - dx1 ) <1 )
                    return
                end

            % Case 2: Resize to original size, if window smaller than original
                if (dy1<0)
                    % The y-position is smaller than in reality, because I don't allow shrinking below original size
                    % Therefore, make sure new position is same as before resize
                    figure1PosVector(2)=figure1PosVector(2)+dy;  
                    dx=0;% Set width to original size
                    dy=0;% Set height to original size
                end
%                 
%             % Case 3: x changed more than y.  Resize by calculating new dy
%                 if (dy1/dx1 < originalProportions)
%                     dx=dx1; % Set width to that of x
%                     dy=(dx1+axes1OriginalPosVector(3))*originalProportions;   % Calculate new y
%                 end
%                 
%             % Case 4: Resize to original size, if window smaller than original
%                 if (dy1/dx1 > originalProportions)
%                     dx=( dy1+axes1OriginalPosVector(4) ) /originalProportions  - axes1OriginalPosVector(3);
%                     dy=dy1;
%                 end
                
         %
         % Move GUI widgets according to resize of figure1
         %
               % FieldNames for GUILayout
               try
                    guiNames=fieldnames(handles.GUILayout);
               catch
                   disp('imlook4d/figure1_ResizeFcn:  ERROR getting field names');
                   return
               end
           
             guiPositions=struct2cell(handles.GUILayout);  % gui positions stored at start of imlook4d instance
             % Loop all GUI objects except first two (figure1, axes1)       
                for i=3:size(guiPositions,1)
                    xPos=guiPositions{i}(1)+dx;
                    yPos=guiPositions{i}(2)+dy;
                    width=guiPositions{i}(3);
                    height=guiPositions{i}(4);

                    h=eval(['handles.' guiNames{i}]);
                    set(h,'Position',[xPos yPos width height]);
                end         
                   
      
         %
         % Resize axes1
         %         
              axes1PosVector(1)=axes1OriginalPosVector(1);
              axes1PosVector(2)=axes1OriginalPosVector(2);
              axes1PosVector(3)=handles.GUILayout.axes1(3)+dx;
              axes1PosVector(4)=handles.GUILayout.axes1(4)+dy;
              set(handles.axes1,'Position',axes1PosVector);            
              
         %
         % Resize figure1
         %            
               figure1PosVector(3)=handles.GUILayout.figure1(3)+dx;
               figure1PosVector(4)=handles.GUILayout.figure1(4)+dy;
               set(handles.figure1,'Position',figure1PosVector);
                   
         %
         % Clean up
         %
              set(handles.ColorBar,'Units','normalized');  % Make colorbar interactive shift work again    
    function ColorBar_Callback(hObject, eventdata, handles)       
        %oldVal= round(get(hObject,'Value'));
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 %set(hObject,'Value',oldVal);
                 %return 
             end
       
    % --------------------------------------------------------------------
    % KEY PRESSED
    % --------------------------------------------------------------------             
    % This callback is used to stop ctrl-c from interrupting the Copy_Image_Callback:
    function figure1_KeyReleasedFunction(hObject, eventdata, handles) 
        key=eventdata.Key;
        
        
        direction = 0;
        switch key
            case 'uparrow'
                direction = 1;
            case 'downarrow'
                direction = -1;
            otherwise 
        end

        scrollSlices(hObject, eventdata, handles, direction)
        
    % --------------------------------------------------------------------
    % SCROLL WHEEL (change slice / frame)
    % --------------------------------------------------------------------
    function figure1_ScrollWheelFcn(hObject, eventdata, handles)
        direction=-eventdata.VerticalScrollCount
        scrollSlices(hObject, eventdata, handles, direction);
        function scrollSlices(hObject, eventdata, handles, direction)

        % Initialize
            numberOfSlices=size(handles.image.Cdata,3);
            numberOfFrames=size(handles.image.Cdata,4);
            currentSlice = get(handles.SliceNumSlider,'Value');
            currentFrame = get(handles.FrameNumSlider,'Value');

            newSlice=round(currentSlice+direction);
            newFrame=round(currentFrame+direction);
            %newSlice=currentSlice+direction
        
        % Slice
            if (newSlice>numberOfSlices)
                newSlice=numberOfSlices;
            end

            if (newSlice<1)
                newSlice=1;
            end    
        
        % Frame
            if (newFrame>numberOfFrames)
                newFrame=numberOfFrames;
            end

            if (newFrame<1)
                newFrame=1;
            end    
               
        % Set Slice slider and edit box
            if ( strcmp( get(handles.figure1, 'currentmodifier'),'control') | strcmp( get(handles.figure1, 'currentmodifier'),'shift'))
                set(handles.FrameNumEdit,'String',num2str(newFrame));
                set(handles.FrameNumSlider,'Value',newFrame);     
                updateImage(hObject, eventdata, handles);
            else
                %%set(handles.SliceNumEdit,'String',num2str(newSlice));
                %%set(handles.SliceNumSlider,'Value',newSlice);
                setSlice( handles, newSlice , handles.figure1);
            end

    % --------------------------------------------------------------------
    % TOOLBAR BUTTONS
    % --------------------------------------------------------------------
    function resizePushButton_ClickedCallback(hObject, eventdata, handles)
        % Performs resizing of the imlook4d when resize button is pressed
        %
        % The strategy is to resize with kept proportions on axes1 (the image),
        % AND keeping the top left corner stationary until leaving screen.
        % - Number of pixels resized in y-direction (dy) is used to calculate resize in x-direction (dx), (keeping proportions of axes1)
        % - The number of pixels resized in figure1 is equal to number of pixels resized in axes1.
        % - If resized to smaller than original size, resize to original size
        % - GUI widgets are moved to correct position
        % - axes1 is resized
        % - figure1 is resized
        %
        % The lowerLeftY corner is calculated
        
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 %set(hObject,'State', 'off')
                 return 
             end

             
             
             
        %
        % Initialize
        %
            set(handles.ColorBar,'Units','Pixels');              % Make colorbar possible to move correct distance
        
            ySizeIncrease=100;                                          % Increase in pixels relative current figure (y-direction)
            figure1OriginalPosVector=handles.GUILayout.figure1;         % Stored at start of imlook4d
            figure1CurrentPosVector=get(handles.figure1,'Position');    % Current size of figure1

            axes1OriginalPosVector=handles.GUILayout.axes1;             % Stored at start of imlook4d
            originalProportions=axes1OriginalPosVector(4)/axes1OriginalPosVector(3);  % Original proportions of axes1, height/width
 
            screenSize=get(0,'ScreenSize');                             % Vector.  Index 3 is x, 4 is y
            
            topLeftY=figure1CurrentPosVector(4)+figure1CurrentPosVector(2); % Y position of top left corner

        
       %
       % New size and position
       %

            % Increase:  Calculate new height (increase size until full, then jump to smallest size)
                % dy is size increase relative original imlook4d window size
                if (figure1CurrentPosVector(4)>(screenSize(4)-100) )
                    % Full size now, jump to original size
                    dy=0;
                else % Not full size now, increase one step
                    dy=(figure1CurrentPosVector(4)-figure1OriginalPosVector(4) ); % Current height relative original
                    dy=dy+ySizeIncrease;                                          % New height relative original
                end

            % Decrease (CTRL button pressed): Calculate new width 
                if strcmp( get(handles.figure1, 'currentmodifier'),'control') | (strcmp( get(handles.figure1, 'currentmodifier'),'shift')) 
                    dy=(figure1CurrentPosVector(4)-figure1OriginalPosVector(4) ); % Current height relative original
                    dy=dy-ySizeIncrease;                                          % New height relative original
                end

                %disp(['New size=(' num2str(get(handles.figure1, 'Position') ) ')']);


            % If window smaller than original, set to original
                if (dy<0)
                    dy=0;% Set height to original size
                end

            % Calculate dx, keeping proportions:
            %   [ dy+axes1OriginalPosVector(4) ]/ [ dx+axes1OriginalPosVector(3) ]=originalProportions
                dx=( dy+axes1OriginalPosVector(4) ) /originalProportions  - axes1OriginalPosVector(3);
    
                
         %
         % Move GUI widgets according to resize of figure1
         %
            
               % FieldNames for GUILayout
               try
                    guiNames=fieldnames(handles.GUILayout);
               catch
                   disp('imlook4d/figure1_ResizeFcn:  ERROR getting field names');
                   return
               end
           
             guiPositions=struct2cell(handles.GUILayout);  % gui positions stored at start of imlook4d instance
             % Loop all GUI objects except first two (figure1, axes1)       
                for i=3:size(guiPositions,1)
                    xPos=guiPositions{i}(1)+dx;
                    yPos=guiPositions{i}(2)+dy;
                    width=guiPositions{i}(3);
                    height=guiPositions{i}(4);

                    h=eval(['handles.' guiNames{i}]);
                    set(h,'Position',[xPos yPos width height]);
                end         
                
         %
         % Resize axes1
         %         
              axes1PosVector(1)=axes1OriginalPosVector(1);
              axes1PosVector(2)=axes1OriginalPosVector(2);
              axes1PosVector(3)=handles.GUILayout.axes1(3)+dx;
              axes1PosVector(4)=handles.GUILayout.axes1(4)+dy;
              set(handles.axes1,'Position',axes1PosVector);                 
         %
         % Resize figure1
         %  
              realHeight=dy+figure1OriginalPosVector(4);  % real window height=dy+[original height]
              figure1PosVector(1)=figure1CurrentPosVector(1);  
              figure1PosVector(2)=topLeftY-realHeight; 
              figure1PosVector(3)=handles.GUILayout.figure1(3)+dx;
              figure1PosVector(4)=handles.GUILayout.figure1(4)+dy;
              set(handles.figure1,'Position',figure1PosVector);
              movegui(hObject, 'onscreen')
              
         %
         % Clean up
         %
              set(handles.ColorBar,'Units','normalized');  % Make colorbar interactive shift work again
    function ZoomIntoggletool_ClickedCallback(hObject, eventdata, handles)           
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(hObject,'State', 'off')
                 return 
             end

    function ZoomOuttoggletool_ClickedCallback(hObject, eventdata, handles)
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(hObject,'State', 'off')
                 return 
             end
    function Pantoggletool_ClickedCallback(hObject, eventdata, handles)
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(hObject,'State', 'off')
                 return 
             end
    function DataCursortoggletool_ClickedCallback(hObject, eventdata, handles)
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(hObject,'State', 'off')
                 return 
             end          
             
   function DataCursortoggletool_ReleasedCallback(hObject, eventdata, handles)
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(hObject,'State', 'off')
                 return 
             end            
             a=findall(gcf,'Type','hggroup');
             delete(a);         111
     
    function helpToggleTool_OnCallback(hObject, eventdata, handles)
        % Make text boxes and other things that can't be callbacked inactive
        set(handles.BrushSize,'Enable', 'inactive');
        set(handles.FrameNumEdit,'Enable', 'inactive');
        set(handles.SliceNumEdit,'Enable', 'inactive');
        set(handles.PC_low_edit,'Enable', 'inactive');
        set(handles.PC_high_edit,'Enable', 'inactive');
        set(handles.ROINumberMenu,'Enable', 'inactive');
        set(handles.orientationMenu,'Enable', 'inactive');
        set(handles.PC_low_slider,'Enable', 'inactive');
        set(handles.FirstFrame,'Enable', 'inactive');
        set(handles.ColorBar, 'ButtonDownFcn', @(hObject,eventdata)imlook4d('ColorBar_Callback',hObject,eventdata,guidata(hObject)) ); 
    function helpToggleTool_OffCallback(hObject, eventdata, handles)
        % Set textboxes etc on, to allow normal work when help button is not activated
        set(handles.BrushSize,'Enable', 'on');
        set(handles.FrameNumEdit,'Enable', 'on');
        set(handles.SliceNumEdit,'Enable', 'on');
        set(handles.PC_low_edit,'Enable', 'on');
        set(handles.PC_high_edit,'Enable', 'on');
        set(handles.ROINumberMenu,'Enable', 'on');
        set(handles.orientationMenu,'Enable', 'on');
        set(handles.PC_low_slider,'Enable', 'on');
        set(handles.FirstFrame,'Enable', 'on');
        set(handles.ColorBar, 'ButtonDownFcn', '@resetCurrentAxes');
      
        % Close web browser
        try
            handles.webbrowser.close();
        catch
        end
        
    function yokeOffButton_ClickedCallback(hObject, eventdata, handles)
             % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(hObject,'State', 'off')
                 return 
             end
             imlook4d_instances=findobj('Tag','imlook4d');
             buttonsSameNameAsPressed=findobj('Tag',get(hObject, 'Tag'));
             this_imlook4d_instance=get(get(hObject,'Parent'),'Parent');
            
             disp('-------------------------------------');
             %disp([ 'This imlook4d=' num2str(this_imlook4d_instance) '   ' get(hObject, 'Tag') ' ' 'OFF' ]);
             
             % Clear all references TO this imlook4d-instance
              imlook4d_instances=findobj('Tag','imlook4d');
              for i=1:length(imlook4d_instances)
                  yokes=getappdata(imlook4d_instances(i),'yokes');
                  yokes=yokes(yokes~=this_imlook4d_instance);  % Remove this_imlook4d_instance
                  setappdata(imlook4d_instances(i),'yokes',yokes);
              end  
              
              % Clear all references IN this imlook4d-instance
              rmappdata(this_imlook4d_instance,'currentYoke');  
              setappdata(this_imlook4d_instance,'yokes',[]);      
    function yokeOnButton_ClickedCallback(hObject, eventdata, handles)
            % appdata:  
            %  currentYoke  handle to button
            %  yokes       imlook4d-handles, where same yoke button pressed
            % Add this imlook4d-handle to all with same button pressed
            
             % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(hObject,'State', 'off')
                 return 
             end
            
             %imlook4d_instances=findobj('Tag','imlook4d');
             buttonsSameNameAsPressed=findobj('Tag',get(hObject, 'Tag'));
             this_imlook4d_instance=get(get(hObject,'Parent'),'Parent');
            
             disp('-------------------------------------');
             %disp([ 'This imlook4d=' num2str(this_imlook4d_instance) '   ' get(hObject, 'Tag') ' ' 'ON' ]);
 
           % Toggle previously pressed button
           if ( getappdata(this_imlook4d_instance,'currentYoke') ~= hObject)
              set( getappdata(this_imlook4d_instance,'currentYoke'), 'State', 'off'); % Callback yokeOffButton_ClickedCallback
           end
           
           % Add this imlook4d-handle to all with same button pressed
              sameYoke=findobj('-regexp','Tag',get(hObject, 'Tag'),'State','on');  % Buttons with same yoke
              disp(['Found ' num2str(length(sameYoke)) ' pressed buttons with tag=' get(hObject, 'Tag')]);
              yokes=[];
              % Build array of all imlook4d-instances with same button pressed as this
              for i=1:length(sameYoke)
                  imlook4d_instances(i)=get(get(sameYoke(i),'Parent'),'Parent');   % imlook4d instances with same yoke
                  yokes=[yokes imlook4d_instances(i)];
              end  
              % Set appdata for all imlook4d-instances
              for i=1:length(sameYoke)
                  setappdata(imlook4d_instances(i),'yokes',yokes);
              end
              
%            % Remove this button from this imlook4d-instance
%                  yokes=getappdata(this_imlook4d_instance,'yokes');
%                  yokes=yokes(yokes~=this_imlook4d_instance);  % Remove this_imlook4d_instance
%                  setappdata(this_imlook4d_instance,'yokes',yokes);


          setappdata(this_imlook4d_instance,'currentYoke',hObject);
          yoke_inspection(this_imlook4d_instance, get(hObject, 'Tag') );      
    	function yoke_inspection(this_imlook4d_instance, yokeString )
          % Display stored yokes for all imlook4ds
             imlook4d_instances=getappdata(this_imlook4d_instance,'yokes');
             imlook4d_instances=findobj('Tag','imlook4d');

             for i=1:length(imlook4d_instances)
                 yokes=getappdata(imlook4d_instances(i),'yokes');
                 currentYoke=get( getappdata(imlook4d_instances(i),'currentYoke'), 'Tag');
                 %disp([ num2str(imlook4d_instances(i)) '(' currentYoke ')   ' '   yokes=' num2str(yokes(:)')]);
             end
    function recordOnButton_ClickedCallback(hObject, eventdata, handles)            
             % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(hObject,'State', 'off')
                 return 
             end
             EOL = sprintf('\n');
                    
             handles.record.enabled = true;
             
             buttons  = findobj('Tag','record_toolbar_button');
             
             % Find editor used in other imlook4ds
             for i=1:length(buttons)
                 h = getParentFigure(buttons(i));  
                 hHandles = guidata(h);
                 try
                     if isfield(hHandles.record, 'editor')
                         handles.record.editor = hHandles.record.editor;
                     end
                 catch
                 end
             end
             
            
             % Set editor
             newEditor = false;
             try
                 % Try to use existing editor -- with dummy command
                handles.record.editor.getLength();
             catch
                % Editor not open -- make a new one
                a = com.mathworks.mde.editor.MatlabEditorApplication.getInstance();
                handles.record.editor = a.newEditor( ['% Script recording started at : ' datestr(now) EOL ]);
                handles.record.editor.setCaretPosition(handles.record.editor.getLength());  % Go to end of line
                newEditor = true;
             end
             

             
             % Temporarily store callback
             tempCallback = get(hObject, 'OnCallback'); 
             
            
             % Set all record buttons 
           %  buttons  = findobj('Tag','record_toolbar_button');
             for i=1:length(buttons)
                 % Inibit callbacks
                 set(buttons(i),'OnCallback', [])

                 % Copy record struct (editor, enabled, )
                % imlook4d_handle = get( get( get(buttons(i),'Parent') ,'Parent'));  % Get imlook4d instance for i:th button
                % imlook4d_handles.record = handles.record;   % Copy the record struct
                 
                 % Set state
                 set(buttons(i),'State', 'on')
                 
                 % Copy and store handles.record to other figures
                 h = getParentFigure(buttons(i));
                 hHandles = guidata(h);
                 hHandles.record = handles.record; % Copy 
                 guidata(h, hHandles);
                 
                 hHandles.record.editor
                 % Reset callback functions
                 set(buttons(i),'OnCallback', tempCallback)
             end
             
             % Move to top
             if newEditor
                set(handles.figure1, 'Visible', 'off');  
                set(handles.figure1, 'Visible', 'on'); 
             end
                         
             guidata(handles.figure1, handles);
                function fig = getParentFigure(fig)
                    % if the object is a figure or figure descendent, return the
                    % figure. Otherwise return [].
                    while ~isempty(fig) && ~strcmp('figure', get(fig,'type'))
                        fig = get(fig,'parent');
                    end
    function recordOffButton_ClickedCallback(hObject, eventdata, handles)            
             % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(hObject,'State', 'off')
                 return 
             end
             handles.record.enabled = false;
             guidata(handles.figure1, handles);
             
                         
             % Set all record buttons 
             buttons  = findobj('Tag','record_toolbar_button');
             for i=1:length(buttons)
                 set(buttons(i),'State', 'off')
   
                 % Copy record struct                               
                 h = getParentFigure(buttons(i));
                 hHandles = guidata(h);
                 hHandles.record = handles.record;   % Copy the record struct
             end
             guidata(handles.figure1, handles);
       
   function cdPushButton_ClickedCallback(hObject, eventdata, handles)            
             % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 %set(hObject,'State', 'off')
                 return 
             end
             disp('Pressed cdPushButton');
             
             try
                disp([ 'File type = '  handles.image.fileType] ); 
             catch
             end

             try
                disp([ 'Changing Matlab workspace directory to  "' handles.image.folder '"' ]); 
                cd( handles.image.folder )
             catch
                disp([ 'Failed changing Matlab workspace directory to  "' handles.image.folder '"' ]); 

             end
             
             

    % --------------------------------------------------------------------
    % SLIDERS
    % --------------------------------------------------------------------
    function FrameNumSlider_Callback(hObject, eventdata, handles)        
        oldVal= round(get(hObject,'Value'));
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(hObject,'Value',oldVal);
                 return 
             end
        NewVal= round(get(hObject,'Value'));
        set(handles.FrameNumEdit,'String',num2str(NewVal));
        updateImage(hObject, eventdata, handles);
    function SliceNumSlider_Callback(hObject, eventdata, handles) 
             % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        setSlice( handles,round(get(hObject,'Value')) , handles.figure1)
        function setSlice(handles, slice, this_imlook4d_instance)
            % This function is called from all callbacks changing slice
            % When yokes (coupled imlook4d-instances):
            %   function setSlicesInYokes is called
            highestSlice= size(handles.image.Cdata,3);
            newSlice=round(slice);
            if ( newSlice>=1 && newSlice<=highestSlice )
                set(handles.SliceNumEdit,'String',num2str(newSlice));
                set(handles.SliceNumSlider,'Value',newSlice);
                updateImage(this_imlook4d_instance, {}, handles);  %  handles as called to this function, ignoring that handles have been saved in updateImage (thus loosing from updateImage CachedImage)
                setSlicesInYokes(slice, this_imlook4d_instance);
                %setSlicesInYokes(slice, gcf);
                %setSlicesInYokes(slice, hObject.figure1);
            end
        function setSlicesInYokes(slice, this_imlook4d_instance)
            % This function is called from setSlice
            % It iterates through and updates all coupled images
            yokes=getappdata( this_imlook4d_instance, 'yokes');
            for i=1:length(yokes) 
                handles=guidata(yokes(i));
                if this_imlook4d_instance~=yokes(i)
                    set(handles.SliceNumEdit,'String', num2str(slice));
                    set(handles.SliceNumSlider,'Value',slice);
                    imlook4d('updateImage', handles.figure1,{}, handles)
                end

            end
            
    function PC_low_slider_Callback(hObject, eventdata, handles)
        oldVal= round(get(hObject,'Value'));
        
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(handles.PC_low_slider,'Value',oldVal);
                 return 
             end
         
        highPC=round(get(handles.PC_high_slider,'Value'));
        NewVal= round(get(hObject,'Value'));
        if (NewVal>highPC) % Move high slider with low slider
            set(handles.PC_high_slider,'Value',NewVal);
            set(handles.PC_high_edit,'String',num2str(NewVal));
        end
        

        set(handles.PC_low_edit,'String',num2str(NewVal));
        updateImage(hObject, eventdata, handles)                
    function PC_high_slider_Callback(hObject, eventdata, handles)
        oldVal= round(get(hObject,'Value'));
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 set(handles.PC_high_slider,'Value',oldVal);
                 return 
             end
         
        lowPC=round(get(handles.PC_low_slider,'Value')); 
        NewVal= round(get(hObject,'Value'));
        if (NewVal<lowPC) % Move low slider with high slider
            set(handles.PC_low_slider,'Value',NewVal);
            set(handles.PC_low_edit,'String',num2str(NewVal));
        end
        

        set(handles.PC_high_edit,'String',num2str(NewVal));
        updateImage(hObject, eventdata, handles)                   
        
    % --------------------------------------------------------------------
    % TEXTBOXES
    % --------------------------------------------------------------------
    function FrameNumEdit_Callback(hObject, eventdata, handles)
        % Hints: get(hObject,'String') returns contents of FrameNumEdit as text
        %        str2double(get(hObject,'String')) returns contents of FrameNumEdit as a double

        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        
        % Do work     
            frames= size(handles.image.Cdata,4);
            strg = get(hObject,'String');

            if str2num(strg)>=1 && str2num(strg)<=frames
                set(handles.FrameNumSlider,'Value',str2num(strg));
                updateImage(hObject, eventdata, handles)
            end
    function SliceNumEdit_Callback(hObject, eventdata, handles)
        %disp(['SliceNumEdit_Callback ' num2str(handles.figure1)  ]);
        % Display HELP and get out of callback
         if DisplayHelp(hObject, eventdata, handles) 
             return 
         end
        setSlice( handles,str2num(get(hObject,'String')) , handles.figure1)
    function PC_low_edit_Callback(hObject, eventdata, handles)
        
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        
        % Do work  
        frames= size(handles.image.Cdata,4);
        strg = get(hObject,'String');
        if str2num(strg)>=1 && str2num(strg)<=frames
            set(handles.PC_low_slider,'Value',str2num(strg));
            updateImage(hObject, eventdata, handles)
        end 
    function PC_high_edit_Callback(hObject, eventdata, handles)
        
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        
        % Do work  
        frames= size(handles.image.Cdata,4);
        strg = get(hObject,'String');
        if str2num(strg)>=1 && str2num(strg)<=frames
            set(handles.PC_high_slider,'Value',str2num(strg));
            updateImage(hObject, eventdata, handles)
        end
    function FirstFrameInPCAFilter_Callback(hObject, eventdata, handles)
        
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
             
        disp('FirstFrameInPCAFilter_Callback called');
        
        % Do work  
        z= size(handles.image.Cdata,4);
        strg = get(hObject,'String');
        if str2num(strg)>=1 && str2num(strg)<=z
            set(handles.FirstFrame,'String',strg);
            updateImage(hObject, eventdata, handles)
        end
        
    function BrushSize_Callback(hObject, eventdata, handles)         
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 %set(hObject,'State', 'off')
                 return 
             end
             
             r=round( str2num( get(handles.BrushSize,'String') ) );
             %handles.image.brush=circleROI(zeros(2*r+1,2*r+1),1,r+1,r+1,r);
             handles.image.brush=circleROI(zeros(2*r,2*r),1,r,r,r);
             guidata(hObject,handles);% Save handles
             
    function text7_ButtonDownFcn(hObject, eventdata, handles)      
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 %set(hObject,'State', 'off')
                 return 
             end
             
     
    % --------------------------------------------------------------------
    % CHECKBOXES & RADIOBUTTONS
    % --------------------------------------------------------------------
    function hideROIcheckbox_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        updateImage(hObject, eventdata, handles);        
    function ContourCheckBox_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        updateImage(hObject, eventdata, handles);
        updateROIs(handles);      
            
    function ImageRadioButton_Callback(hObject, eventdata, handles)   
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
             
        % Store this radiobutton as current
        handles.imageRadioButtonGroupActiveButton = hObject;
        guidata(handles.figure1, handles);
             
        numberOfFrames=size(handles.image.Cdata,4);    
             
        % Change text on PC slider to Frame
        set(handles.FrameText,'String', 'Frame');
        
        % Make PCA-filter sliders and edit boxes visible
        if (numberOfFrames>1)
            %set(handles.PC_low_slider,'Visible', 'on');
            set(handles.PC_high_slider,'Visible', 'on');
            %set(handles.PC_low_edit,'Visible', 'on');
            set(handles.PC_high_edit,'Visible', 'on');
            set(handles.FirstFrame,'Visible', 'on');
        end
        
        % Retrieve Frame slider value and invert settings, as stored when displaying PC images
        if(handles.image.StoredFrameSliderValue>0)
            frame=handles.image.StoredFrameSliderValue;
            set(handles.FrameNumEdit,'String',num2str(frame))
            set(handles.FrameNumSlider,'Value',frame)
            handles.image.StoredFrameSliderValue=0;             % Zero means that no frame number is stored
        
        
            set(handles.invertRadiobutton,'Value', handles.image.StoredInvert);  % Store value on Invert radio button
            set(handles.PCAutoInvert,'Value', handles.image.StoredAutoInvert);   % Store value on Auto check box

            set(handles.PC_low_edit,'visible','off');  
            set(handles.PC_low_slider,'visible','off');
        end

        
  
        % Update image
        updateImage(hObject, eventdata, handles);  
    function PCImageRadioButton_Callback(hObject, eventdata, handles)        
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
             
        % Store this radiobutton as current
        handles.imageRadioButtonGroupActiveButton = hObject;
        guidata(handles.figure1, handles);
        
        % Change text on Frame slider to PC
        set(handles.FrameText,'String', 'PC');
        
        % Make PCA-filter sliders and edit boxes invisible
        set(handles.PC_low_slider,'Visible', 'off');
        set(handles.PC_high_slider,'Visible', 'off');
        set(handles.PC_low_edit,'Visible', 'off');
        set(handles.PC_high_edit,'Visible', 'off');
        
        % Store Frame slider values, and Invert settings
        frame=round(get(handles.FrameNumSlider,'Value'));
        handles.image.StoredFrameSliderValue=frame;         % Store value on Frame slider
        handles.image.StoredInvert=get(handles.invertRadiobutton,'Value');  % Store value on Invert radio button
        handles.image.StoredAutoInvert=get(handles.PCAutoInvert,'Value');   % Store value on Auto check box
        
        NewVal=1;
        set(handles.FrameNumEdit,'String',num2str(NewVal));
        set(handles.FrameNumSlider,'Value',NewVal);
        set(handles.PCAutoInvert,'Value', 1);  % Turn Auto-invert checkbox on
  
        %guidata(hObject,handles);% Save handles
        
        % Update image      
        updateImage(hObject, eventdata, handles);
    function ResidualRadioButton_Callback(hObject, eventdata, handles)        
        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end    
             
        % Store this radiobutton as current
        handles.imageRadioButtonGroupActiveButton = hObject; 
        guidata(handles.figure1, handles);
             
        ImageRadioButton_Callback(hObject, eventdata, handles);
    function restoreImageRadioButtonGroup(handles)
        set(handles.ImageRadioButton,'Value',0)
        set(handles.PCImageRadioButton,'Value',0)
        set(handles.ResidualRadiobutton,'Value',0)
        set(handles.imageRadioButtonGroupActiveButton,'Value',1)
        
        
        
        
    function removeNegativesRadioButton_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        %disp(eventdata);
        updateImage(hObject, eventdata, handles);   
    function invertRadiobutton_Callback(hObject, eventdata, handles)
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        updateImage(hObject, eventdata, handles);
    function autoColorScaleRadioButton_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        
        updateImage(hObject, eventdata, handles);
    function PCAutoInvert_Callback(hObject, eventdata, handles)
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        updateImage(hObject, eventdata, handles);

    function FlipAndRotateRadioButton_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
       if DisplayHelp(hObject, eventdata, handles)
           return
       end
%        
%        try
%            XLim0 = get(handles.axes1,'XLim');
%            YLim0 = get(handles.axes1,'YLim');
%            set(handles.axes1,'XLim', YLim0 );
%            set(handles.axes1,'YLim', XLim0 );
%            
%            
%            if get(handles.FlipAndRotateRadioButton,'Value')              
%                mmX=handles.image.pixelSizeX; % X pixel size (mm)
%                mmY=handles.image.pixelSizeY; % Y pixel size (mm)
%                
%                set(handles.axes1,'DataAspectRatio', [ 1  mmY/mmX  1]);
%            else
%                mmX=handles.image.pixelSizeX; % X pixel size (mm)
%                mmY=handles.image.pixelSizeY; % Y pixel size (mm)
%                set(handles.axes1,'DataAspectRatio', [ mmY/mmX  1  1]);
%            end
%            
%        catch
%            mmX=1;
%            mmY=1;
%            set(handles.axes1,'DataAspectRatio', [  mmY mmX  1]);
%            disp('imlook4d/updateROI:  Error calculating DataAspectRatio');
%        end
           guidata(handles.figure1,handles);  
         updateImage(hObject, eventdata, handles);
    function SwapHeadFeetRadioButton_Callback(hObject, eventdata, handles)
  
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        
        % This function changes raw data and ROIs
        % by flipping the 3d dimension
        
        % Set Slice slider and edit box
        numberOfSlices=size(handles.image.Cdata,3);
        numberOfFrames=size(handles.image.Cdata,4);
        currentSlice = get(handles.SliceNumSlider,'Value');
        newSlice=round( numberOfSlices-currentSlice+1 );
        
        set(handles.SliceNumEdit,'String',num2str(newSlice));
        set(handles.SliceNumSlider,'Value',newSlice);
        
        % Flipping
        handles.image.ROI=flipdim(handles.image.ROI,3);
        handles.image.Cdata=flipdim(handles.image.Cdata,3);
        
        
       % NEW _ FLIP THE REST
        % Flip cell arrays for each frame   - Example size cell 1x1269
       % for i=1:numberOfSlices
       % index=slice+numberOfSlices*(frame-1);
       
        for j=1:numberOfFrames
                
            for i=1:numberOfSlices/2
                try % Catch exception if not DICOM
                    % Index translated from frame and slice
                    oldIndex= i+ numberOfSlices*(j-1) ;  
                    newIndex= (1+ numberOfSlices-i ) + numberOfSlices*(j-1);

                    % Move dirtyDICOMFileNames
                    temp=handles.image.dirtyDICOMFileNames{1,newIndex};
                    handles.image.dirtyDICOMFileNames{1,newIndex}= handles.image.dirtyDICOMFileNames{1,oldIndex};
                    handles.image.dirtyDICOMFileNames{1,oldIndex}= temp;

                    % Move dirtyDICOMHeader
                    temp=handles.image.dirtyDICOMHeader{1,newIndex};
                    handles.image.dirtyDICOMHeader{1,newIndex}= handles.image.dirtyDICOMHeader{1,oldIndex};
                    handles.image.dirtyDICOMHeader{1,oldIndex}= temp;

                    % Move dirtyDICOMIndecesToScaleFactor
                    temp=handles.image.dirtyDICOMIndecesToScaleFactor{1,newIndex};
                    handles.image.dirtyDICOMIndecesToScaleFactor{1,newIndex}= handles.image.dirtyDICOMIndecesToScaleFactor{1,oldIndex};
                    handles.image.dirtyDICOMIndecesToScaleFactor{1,oldIndex}= temp;
                catch
                end
            end
        end
        
        
        % Flip - Example size (47,27)
        try
            handles.image.time2D=flipdim(handles.image.time2D,1);
            handles.image.duration2D=flipdim(handles.image.duration2D,1);
        catch
        end
        
        % END NEW FLIP THE REST
      
        
        guidata(hObject,handles);% Save handles
        
        updateImage(hObject, eventdata, handles);

    function EraserRadioButton_Callback(hObject, eventdata, handles)
         % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 disp('RETURN');
                 return 
             end

    % --------------------------------------------------------------------
    % BUTTONS
    % --------------------------------------------------------------------
    function TACT_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
             
        %TACT(hObject, eventdata, handles);
        newTACT(hObject, eventdata, handles); 
    function clearROI_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
             
         ROINumber=get(handles.ROINumberMenu,'Value');
        if ( handles.image.LockedROIs(ROINumber) )                  
            return 
        end

         handles.image.ROI(handles.image.ROI==ROINumber) = 0;

         guidata(hObject,handles);% Save handles

         updateImage(hObject, eventdata, handles); 
         updateROIs(handles);
   
    % --------------------------------------------------------------------
    % SELECTIONS
    % --------------------------------------------------------------------
    function ROINumberMenu_Callback(hObject, eventdata, handles, name)
       % This function asks for a ROI name, and creates an empty ROI.
       % If input parameter name is given, this will be the ROI name, and no dialog will be displayed.  
       try
           %get(handles.figure1,'SelectionType')

           % Display HELP and get out of callback
                 % Special case, needs to reset the value, otherwise the dropdown
                 % menu will not be drawn.
                 ROINumber=get(hObject,'Value');
                 if DisplayHelp(hObject, eventdata, handles) 
                     set(hObject,'Value', ROINumber)
                     return 
                 end

            % Hints: contents = get(hObject,'String') returns ROINumberMenu contents as cell array
            %        contents{get(hObject,'Value')} returns selected item from ROINumberMenu     
            contents = get(hObject,'String'); % Cell array   
            ROINumber=get(hObject,'Value');

            %IF Add ROI
            if strcmp( contents{get(hObject,'Value')},'Add ROI' )
                n=size(contents,1);

                % Default ROI names only
                %contents={ contents{1:(n-1)}, ['ROI ' num2str(n)],contents{n}};
                %set(hObject,'String', contents);

                if nargin==3
                % Dialog option
                    prompt={'Enter ROI name:'};
                    name='Input ROI name';
                    numlines=1;
                    defaultanswer={['ROI ' num2str(n)]};
                    answer=inputdlg(prompt,name,numlines,defaultanswer);
                    name=answer{1};
                end
                if nargin==4
                    % 
                end           

                contents={ contents{1:(n-1)}, name, contents{n}}; % Put "Add ROI" last

                set(hObject,'String', contents);
                handles.image.VisibleROIs=[ handles.image.VisibleROIs 1];
                handles.image.LockedROIs=[ handles.image.LockedROIs 0];

            else
            % ELSE an existing ROI - we will now display the slice of that ROI   

                % Find first slice of ROI
                numberOfSlices=size(handles.image.Cdata,3);

                currentSlice= str2num(get(handles.SliceNumEdit,'String' ));

                %ROISlice=handles.image.ROI(:,:,1,1);
                ROISlice=handles.image.ROI(:,:,currentSlice);


                % If current slice not in ROI, start looking in first slice
                % (otherwise look in current slice)
                if (size(ROISlice(ROISlice==ROINumber),1)  ==0 )
                    i=0; % Will be updated by 1 in while loop
                else
                    i=currentSlice;
                end

                %if (size(ROISlice(ROISlice==ROINumber),1)  ==0 )
                    % Loop until first slice with a ROI
                    try
                        while (i<=numberOfSlices)&&(  size(ROISlice(ROISlice==ROINumber),1)  ==0  )
                            i=i+1;
                            %ROISlice=handles.image.ROI(:,:,i,1);
                            ROISlice=handles.image.ROI(:,:,i);
                        end
                        disp(['Found ROI ' num2str(ROINumber) ' in slice=' num2str(i)]);

                        % Set SliceNumber in GUI

                        setSlice(handles, i, handles.figure1);

                        updateImage(handles, eventdata, handles);
                        %updateROIs(handles);
                    catch
                        % No ROI found, catch error because i>numberOfSlices in while
                        % loop
                        %disp(['imlook4d/ROINumberMenu_Callback ERROR: No ROI with number ' num2str(ROINumber) 'found in any slice']);
                    end

                %end
            end
        
            guidata(handles.figure1,handles);% Save handles 
            updateROIs(handles);
       catch
           disp('Exception in ROINumberMenu_Callback');
       end
    function ROI_Show_Callback(hObject, eventdata, handles, name)
        if DisplayHelp(hObject, eventdata, handles)
            return
        end
        ROINumberMenu=get(handles.ROINumberMenu);
        contents = ROINumberMenu.String; % Cell array 
        
        ROINumber=ROINumberMenu.Value;
        contents{ROINumber} = regexprep(contents{ROINumber}, '\(hidden\) ', ''); % Remove (hidden) prefix
        set(handles.ROINumberMenu,'String', contents);
        
        handles.image.VisibleROIs(ROINumber)=ROINumber;
        disp(handles.image.VisibleROIs);
        guidata(hObject,handles);% Save handles
        updateROIs(handles);
    function ROI_ShowAll_Callback(hObject, eventdata, handles, name) 
        if DisplayHelp(hObject, eventdata, handles)
            return
        end
        ROINumberMenu=get(handles.ROINumberMenu);
        contents = ROINumberMenu.String; % Cell array 
        %handles.image.VisibleROIs=[1:size(ROINumberMenu.String,1)-1];  % Set all ROIs to visible
        handles.image.VisibleROIs(1:size(ROINumberMenu.String,1)-1)=1;       
        ROINumber=ROINumberMenu.Value;
        contents = regexprep(contents, '\(hidden\) ', ''); % Remove (hidden) prefix
        set(handles.ROINumberMenu,'String', contents);
        
        disp(handles.image.VisibleROIs);
        guidata(hObject,handles);% Save handles
    function ROI_Hide_Callback(hObject, eventdata, handles, name)
        if DisplayHelp(hObject, eventdata, handles)
            return
        end
        ROINumberMenu=get(handles.ROINumberMenu);
        contents = ROINumberMenu.String; % Cell array 
        ROINumber=ROINumberMenu.Value;
        
        handles.image.VisibleROIs(ROINumber)=0;
        contents{ROINumber}=['(hidden) ' contents{ROINumber}];   % Set (hidden) prefix
        set(handles.ROINumberMenu,'String', contents)
        
        disp(handles.image.VisibleROIs);
        guidata(hObject,handles);% Save handles
        updateROIs(handles);   
    function ROI_Hide_All_Callback(hObject, eventdata, handles, name) 
        if DisplayHelp(hObject, eventdata, handles)
            return
        end
        ROINumberMenu=get(handles.ROINumberMenu);
        contents = ROINumberMenu.String; % Cell array 

        handles.image.VisibleROIs(1:size(ROINumberMenu.String,1)-1)=0;       

        for i=1:(size(ROINumberMenu.String,1)-1)
            if ~strcmp(  contents{i}(1:1), '(' )  % If not starting with "("
                contents{i}=['(hidden) ' contents{i}];   % Set (hidden) prefix
            end
        end 
    
        set(handles.ROINumberMenu,'String', contents)
        
        disp(handles.image.VisibleROIs);
        guidata(hObject,handles);% Save handles
        updateROIs(handles);   
    function ROI_Rename_Callback(hObject, eventdata, handles, name)
        if DisplayHelp(hObject, eventdata, handles)
            return
        end
            ROINumberMenu=get(handles.ROINumberMenu);
            contents = ROINumberMenu.String; % Cell array 
            ROINumber=ROINumberMenu.Value;

            % Default ROI names only
            %contents={ contents{1:(n-1)}, ['ROI ' num2str(n)],contents{n}};
            %set(hObject,'String', contents);

            % Dialog option
                prompt={'Enter ROI name:'};
                name='Input ROI name';
                numlines=1;
                defaultanswer={contents{ROINumber}};
                answer=inputdlg(prompt,name,numlines,defaultanswer);
                name=answer{1};
               
            contents{ROINumber}=name;
            set(handles.ROINumberMenu,'String', contents);
            updateROIs(handles);
    function ROI_Lock_Callback(hObject, eventdata, handles, name)
        if DisplayHelp(hObject, eventdata, handles)
            return
        end
        ROINumberMenu=get(handles.ROINumberMenu);
        contents = ROINumberMenu.String; % Cell array 
        ROINumber=ROINumberMenu.Value;
        
        handles.image.LockedROIs(ROINumber)=1;
        contents{ROINumber}=['(locked) ' contents{ROINumber}];   % Set (locked) prefix
        set(handles.ROINumberMenu,'String', contents)
        
        disp(handles.image.LockedROIs);
        guidata(hObject,handles);% Save handles
        updateROIs(handles);   
    function ROI_UnLock_Callback(hObject, eventdata, handles, name)
        if DisplayHelp(hObject, eventdata, handles)
            return
        end
        ROINumberMenu=get(handles.ROINumberMenu);
        contents = ROINumberMenu.String; % Cell array
        ROINumber=ROINumberMenu.Value;
        
        handles.image.LockedROIs(ROINumber)=0;
        contents = regexprep(contents, '\(locked\) ', ''); % Remove (hidden) prefix
        set(handles.ROINumberMenu,'String', contents)
        
        disp(handles.image.LockedROIs);
        guidata(hObject,handles);% Save handles
        updateROIs(handles);
    function ROI_Remove_Callback(hObject, eventdata, handles, name)
        if DisplayHelp(hObject, eventdata, handles)
            return
        end
        
        ROINumberMenu=get(handles.ROINumberMenu);
        contents = ROINumberMenu.String; % Cell array
        ROINumber=ROINumberMenu.Value;
        
        % Remove if not locked
        if ( handles.image.LockedROIs(ROINumber) == 1 )
            disp('LOCKED ROI - not allowed to remove');
        else
            
            % Delete ROI pixels, and Shift down ROIs in ROI-matrix
            handles.image.ROI( handles.image.ROI == ROINumber ) = 0; % Delete ROI pixels
            handles.image.ROI( handles.image.ROI > ROINumber ) = handles.image.ROI( handles.image.ROI > ROINumber ) -1;
            
            % Shift down ROI names
            contents = {contents{1:ROINumber-1} , contents{ROINumber+1:end}};
            
            % Shift down Visible and Locks
            handles.image.VisibleROIs=[ handles.image.VisibleROIs(1:ROINumber-1) handles.image.VisibleROIs(ROINumber+1:end)   ];
            handles.image.LockedROIs=[ handles.image.LockedROIs(1:ROINumber-1) handles.image.LockedROIs(ROINumber+1:end)   ];
            
            set(handles.ROINumberMenu,'String', contents)          
            
            % Selected ROI
            if ( ROINumber >= length( contents ) ) % Selected ROI pointing to Add ROI, or outside
                set(handles.ROINumberMenu,'Value', length( contents ) - 1 );
            end
            
            disp(handles.image.LockedROIs);
            guidata(hObject,handles);% Save handles
            updateROIs(handles);
        end
    function ROI_Remove_All_Callback(hObject, eventdata, handles, name)
        if DisplayHelp(hObject, eventdata, handles)
            return
        end
        ROINumberMenu=get(handles.ROINumberMenu);
        contents= ROINumberMenu.String; % Cell array 
        
        % Remove if not locked
        if ( sum( handles.image.LockedROIs) > 0 )
            disp('ONE OR MORE LOCKED ROIs - not allowed to remove');
        else
            
            contents = {contents{end}}; % Remove all but 'Add ROI'
            set(handles.ROINumberMenu,'String', contents)
            handles.image.ROI(:) = 0;
            
            guidata(hObject,handles);% Save handles
            updateROIs(handles);
        end
        
    function orientationMenu_Callback(hObject, eventdata, handles, name)
        
        orientationNumber=get(hObject,'Value');
        if DisplayHelp(hObject, eventdata, handles)
            set(hObject,'Value', orientationNumber); % Reset value to when clicked
            return
        end
  
        handles = setOrientation(handles, orientationNumber);
        guidata(handles.figure1, handles);       
      function handles = setOrientation(handles, newNumericOrientation)

        % Numerical constants
            AXIAL=1;
            CORONAL=2;
            SAGITAL=3;
        
        % Recipy for coordinate permutation and back-permutation
            PERMUTE={[1 2 3 4], [1 3 2 4],  [2 3 1 4] };
            BACKPERMUTE={[1 2 3 4], [1 3 2 4],  [3 1 2 4] };  
        
        %
        % Rotate back to Axial (by applying inverted transformation as was in image)
        %
            % Get current orientation
            try 
                CurrentOrientation = handles.image.plane; 
            catch
                CurrentOrientation = 'Axial';
            end
            
            % Rotate back from current image orientation to axial
            switch CurrentOrientation
                case 'Axial'
                    [handles, newOrientation] = rotateOrientation( handles, BACKPERMUTE, AXIAL);
                case 'Coronal'
                    [handles, newOrientation] = rotateOrientation( handles, BACKPERMUTE, CORONAL);
                case 'Sagital'
                    [handles, newOrientation] = rotateOrientation( handles, BACKPERMUTE, SAGITAL);
                otherwise 
            end

        %
        % Rotate and flip to selected
        %
            disp(['2) newNumericOrientation = ' num2str(newNumericOrientation)]);
            [handles, newOrientation] = rotateOrientation( handles, PERMUTE, newNumericOrientation);

            % Set new orientation
            handles.image.plane = newOrientation;
        
        % Finish   
             % Set scale in new X and Y direction
                set(handles.axes1, 'XLim', [1 size( handles.image.Cdata,1)])
                set(handles.axes1, 'YLim', [1 size( handles.image.Cdata,2)]) 
             % Set sliders
                adjustSliderRanges(handles);
             % Update image   
                updateROIs(handles);
                updateImage(handles.figure1, [], handles);
                figure1_ResizeFcn(handles.figure1, [], handles, 0)  
         function [handles, newOrientation] = rotateOrientation( handles, PERMUTE, numericOrientation)
                AXIAL=1;
                CORONAL=2;
                SAGITAL=3;       
                
                X=1; Y=2; Z=3;
                
                PERMUTE{numericOrientation}

                
              % Get current pixel dimensions
                try                
                    voxelSize(1)=handles.image.pixelSizeX;
                    voxelSize(2)=handles.image.pixelSizeY;
                    voxelSize(3)=handles.image.sliceSpacing;
                catch
                    disp('ERROR - pixelsizes undefined, setting them to 1');
                    voxelSize(1)=1;
                    voxelSize(2)=1;
                    voxelSize(3)=1;
                end
                
            % Guess returned orientation, which is what should be returned    
            newOrientation = 'Axial';

            % Axial
            if ( numericOrientation == AXIAL )   
                newOrientation = 'Axial';
                V = PERMUTE{AXIAL};
                newVoxelSize = [ voxelSize( V(X) ), voxelSize( V(Y) ) , voxelSize( V(Z) ) ];
            end 


            % Coronal
            if ( numericOrientation == CORONAL )  
                % Reorient data and ROI
                handles.image.Cdata=permute(handles.image.Cdata, PERMUTE{CORONAL});  % Image
                handles.image.ROI=permute(handles.image.ROI, PERMUTE{CORONAL});      % ROI
                newOrientation = 'Coronal';
                V = PERMUTE{CORONAL};
                newVoxelSize = [ voxelSize( V(X) ), voxelSize( V(Y) ) , voxelSize( V(Z) ) ];
            end


            % Sagital
            if ( numericOrientation == SAGITAL ) 
                % Reorient data and ROI    
                handles.image.Cdata=permute(handles.image.Cdata, PERMUTE{SAGITAL});  % Image
                handles.image.ROI=permute(handles.image.ROI,  PERMUTE{SAGITAL});      % ROI       
                newOrientation = 'Sagital'; 
                V = PERMUTE{SAGITAL};
                newVoxelSize = [ voxelSize( V(X) ), voxelSize( V(Y) ) , voxelSize( V(Z) ) ];
            end 
            
            % Pixelsizes
                handles.image.pixelSizeX = newVoxelSize(X);
                handles.image.pixelSizeY = newVoxelSize(Y);
                handles.image.sliceSpacing = newVoxelSize(Z);
        
            % Test
            disp(['rotateOrientation       size(ROI)=' num2str(size(handles.image.ROI)) ]);
            disp(['rotateOrientation  SliceNumSlider=' num2str(get(handles.SliceNumSlider,'Max')) ]);
      function handles = resetOrientation(handles)
%             disp(['resetOrientation  size(ROI)=' num2str(size(handles.image.ROI)) ]);
%             disp(['resetOrientation  size(Cdata)=' num2str(size(handles.image.Cdata)) ]);
            
%             % Go back to original orientation
%             set(handles.orientationMenu,'Value',1);
%             orientationMenu_Callback(handles.orientationMenu, [], handles)
%             % Get modified handles
             %handles = guidata(handles.figure1);
            
            set(handles.orientationMenu,'Value',1);
            handles = setOrientation(handles, 1)            
            %handles = guidata(handles.figure1); % Set modified handles  
        
            % Test
            disp(['resetOrientation        size(ROI)=' num2str(size(handles.image.ROI)) ]);
            disp(['resetOrientation   SliceNumSlider=' num2str(get(handles.SliceNumSlider,'Max')) ]);

        
    % --------------------------------------------------------------------
    % ROI drawing functions
    % --------------------------------------------------------------------
    function wbd(h, evd, handles)
         % executes when the mouse button is down 
         % (guide couples this to the mouse button via property:  figure/WindowButtonDownFcn )
         %get(gca,'currentpoint')
         % Display HELP and get out of callback
             if DisplayHelp(h, evd, handles) 
                 return 
             end
          
         activeROI=get(handles.ROINumberMenu,'Value');
         
         % Get out if trying to draw ROI when "Add ROI" is chosen
         if strcmp(  get(handles.ROINumberMenu,'String'), 'Add ROI')
             return
         end

         % Get out if trying to draw ROI when "hidden"   
         if (handles.image.VisibleROIs(activeROI)==0)
             return
         end

         % get the values and store them in the figure's appdata
         props.WindowButtonMotionFcn = get(h,'WindowButtonMotionFcn');
         props.WindowButtonUpFcn = get(h,'WindowButtonUpFcn');
         setappdata(h,'TestGuiCallbacks',props);

         % set the new values for the WindowButtonMotionFcn and
         % WindowButtonUpFcn
         %set(h,'WindowButtonMotionFcn',{@wbm})
         %set(h,'WindowButtonUpFcn',{@wbu})
         set(h,'WindowButtonMotionFcn','imlook4d(''wbm'',gcbo,[],guidata(gcbo))');
         set(h,'WindowButtonUpFcn','imlook4d(''wbu'',gcbo,[],guidata(gcbo))');    
         
          % Record last mouse position for drawROI track interpolation
         coordinates=get(gca,'currentpoint') + 1;
         x=round(coordinates(1,1) );
         y=round(coordinates(1,2) ); 
         handles.image.lastMousePosition = [x y];
         guidata(handles.figure1,handles);
         
         drawROI(h, evd, handles)         
    function wbm(h, evd, handles)
         % executes while the mouse moves and mouse button is pressed
        % tic;
         drawROI(h, evd, handles);        
    function wbm2(h, evd, handles)
    function wbu(h, evd, handles)
         % executes when the mouse button is released
         % get the properties and restore them         
         %props = getappdata(h,'TestGuiCallbacks');
         %set(h,props);        
         %set(h,'WindowButtonMotionFcn','');
         set(h,'WindowButtonMotionFcn','imlook4d(''wbm2'',gcbo,[],guidata(gcbo))');
    function drawROI(hObject, eventdata, handles)
        
                activeROI=get(handles.ROINumberMenu,'Value');
                if ( handles.image.LockedROIs(activeROI) )                  
                    return 
                end
                
                % Get 4D coordinates

                x_old = handles.image.lastMousePosition(1);
                y_old = handles.image.lastMousePosition(2);
                
                coordinates=get(gca,'currentpoint')+1;

                x=round(coordinates(1,1) );
                y=round(coordinates(1,2) );  
                x_new = x;
                y_new = y;
                handles.image.lastMousePosition = [x_new y_new];
                
                slice=round(get(handles.SliceNumSlider,'Value'));
                frame=round(get(handles.FrameNumSlider,'Value'));                    

                % Exchange x and y if image in original orientation (not FlipAndRotate)
                if ~get(handles.FlipAndRotateRadioButton,'Value')
                    xSize=size(handles.image.ROI,2);
                    ySize=size(handles.image.ROI,1);
                    XLim=get(gca,'YLim');
                    YLim=get(gca,'XLim');
                    temp=x_new;   x_new=y_new; y_new=temp;
                    temp=x_old;  x_old=y_old; y_old=temp;
                else
                    xSize=size(handles.image.ROI,2);
                    ySize=size(handles.image.ROI,1);
                    XLim=get(gca,'XLim');
                    YLim=get(gca,'YLim');               
                end
                
                

                % Draw ROI
                r0=round( str2num(get(handles.BrushSize,'String')) );
                r2=r0^2;
                %center=r+1;


                % Hints: contents = get(hObject,'String') returns ROINumberMenu contents as cell array
                %contents{get(handles.ROINumberMenu,'String')} 
                activeROI=get(handles.ROINumberMenu,'Value');

                    % Cache the slice
                    %roiImage = handles.image.ROI( :, :, slice); % Cache ROI for this slice

                    
                    % step along line
                    dX = ( x_new - x_old );
                    dY = ( y_new - y_old );
                    r = sqrt( dX^2 + dY^2 ); % length
                    brushSteps = r / r0;  % Number of brush radii
                    rStep = 0.5 / brushSteps; % Steps
                    
                    indeces=find(handles.image.brush>0);  % Use only non-zero brush values

                    for ir = 0:rStep:1
                        % Equal steps along diagonal
                        ix = round( x_old + 1 + ir * dX);
                        iy = round( y_old + 1 + ir * dY);
                        
                        % Bounding box
                        rx=size(handles.image.brush,1);
                        ry=size(handles.image.brush,2);

                        % New ROI center position
                        ixx=ix-round(rx/2)+mod(rx,2);
                        iyy=iy-round(ry/2)+mod(ry,2);

                        % Draw in 
                        if (ixx>XLim(1))&&(ixx<=XLim(2)-rx+1)&&(iyy>YLim(1))&&(iyy<=YLim(2)-ry+1)  
                            subMatrix= handles.image.ROI( ixx:(ixx+rx-1),(iyy):(iyy+ry-1), slice);  % Same matrix size as brush
                            

                            if get(handles.ROIEraserRadiobutton,'Value')   
                                subMatrix(indeces)=0;
                            else
                                subMatrix(indeces)=activeROI;  % Draw over any pixels in brush
                            end
                            
                            handles.image.ROI( (ixx):(ixx+rx-1),(iyy):(iyy+ry-1), slice) = subMatrix;
                        end
                    end
                    



                    % Trim ROI matrix to fit image size 
                    xsize=size(handles.image.Cdata,1);
                    ysize=size(handles.image.Cdata,2);
                   %handles.image.ROI=handles.image.ROI(1:xsize,1:ysize,:); % Trim ROI matrix (because indeces higher than image size may have enlarged ROI matrix)

                %
                % Update image
                %
 
                   updateROIs(handles);

                    % Save changes to handles
                   guidata(hObject,handles);% Save handles
         function drawCursorInYokes(axesPoint, this_imlook4d_instance)
              yokes=getappdata( this_imlook4d_instance, 'yokes');
            for i=1:length(yokes) 
                handles=guidata(yokes(i));
                tempData=handles.image.CachedImage; % Read cached image
                    disp('drawCursorInYokes - Read CachedImage');

                %if this_imlook4d_instance~=yokes(i)
                    handles=guidata(yokes(i));     % The i:th other imlook4d-instance
                    
                    x=round(axesPoint(1,1))/128;
                    y=round(axesPoint(1,2))/128;
                    w=0.1;
                    h=0.1;
                    annotation('rectangle',[x y w h]) 
 
               %end
            end                    
         function drawCursorInYokes2(axesPoint, this_imlook4d_instance)
            marker=zeros(11,11);
            marker(1:11,6)=1;
            marker(6,1:11)=1;
            
            
            yokes=getappdata( this_imlook4d_instance, 'yokes');
            for i=1:length(yokes) 
                handles=guidata(yokes(i));
                tempData=handles.image.CachedImage;  % Read cached image
                    disp('drawCursorInYokes2 - Read CachedImage');

                %if this_imlook4d_instance~=yokes(i)
                    handles=guidata(yokes(i));     % The i:th other imlook4d-instance
                    
                                        % Draw ROI (if inside image)
                    x=round(axesPoint(1,1));
                    y=round(axesPoint(1,2));
                    
                    rx=size(marker,1);
                    ry=size(marker,2);
                    
                    ix=x-round(rx/2)+mod(rx,2);
                    iy=y-round(ry/2)+mod(ry,2);
                    
                    xSize=size(tempData,1);
                    ySize=size(tempData,2);
                    
                    
                    if (ix>0)&&(ix<=xSize-rx)&&(iy>0)&&(iy<=ySize-ry)  
                        subMatrix= tempData( (ix):(ix+rx-1),(iy):(iy+ry-1) );  % Same matrix size as brush
                        indeces=find(marker>0);  % Use only non-zero brush values
                        subMatrix(indeces)=10000;  % Draw over any pixels in brush
                        tempData( (ix):(ix+rx-1),(iy):(iy+ry-1))=subMatrix; 
                    end
                    
                    tempData=reshape(tempData, [size(tempData,2), size(tempData,1), size(tempData,3)] );
                    tempData=orientImage(tempData);       
                    set(handles.ImgObject,'Cdata',tempData);  
 
               %end
            end           
            
% --------------------------------------------------------------------
%
% MENUES
%
% --------------------------------------------------------------------
    
    % --------------------------------------------------------------------
    % FILE 
    % --------------------------------------------------------------------   

    % Open File                  
        function OpenFile_Callback(hObject, eventdata, handles, varargin)
            %
            % Option 1: varargin contains no filePath -> file dialog
            % Option 2: varargin contains filePath (char array 1*N) -> opens file

             % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end

            % General method to automatically open correct image type
            dispLine;

            try % Catch if error or "Cancel" from GUI

                if isempty(varargin)
                    try
                    % Select file
                        [file,path] = uigetfile( ...
                            {'*',  'All Files'; ...
                           '*.dcm',  'DICOM files (*.dcm)'; ...
                            '*.v','ECAT Files (*.v)'; ...
                            '*.img;*.hdr','Analyze Files (*.img, *.hdr)'; ...
                            '*.nii,*.img;*.hdr','Nifti Files (*.nii, *.img, *.hdr)'; ...
                           '*.mhd;*.mha',  'ITK files (*.mhd, *.mha)'; ...
                           '*.mgh;*.mgz',  'Freesurfer files (*.mgh, *.mgz)'; ...
                           '*.ima*','SHR files (*.ima)'; ...
                           '*.mat','State files (*.mat)';...
                           '*.mat','m4 object (*.mat)'} ...
                           ,'Select one file to open');
                           
                        fullPath=[path file];
                        cd(path);
                    catch
                       %Canceled ?
                       return
                    end
                else
                    fullPath=varargin{1};
                    [path,name,ext] = fileparts(fullPath);
                    path=[path filesep];
                    file=[name ext];
                    cd(path);
                end
                    disp(['file=' file]);
                    disp(['path=' path]);
                %   
                % Determine file type
                %
                    FILETYPE='UNKNOWN';
                    [pathstr,name,ext] = fileparts(file);

                    % Test if ECAT, MATLAB, SHR, ITK (mhd, mha)
                        try
                            if strcmp(ext,'.v') FILETYPE='ECAT'; end
                            if strcmp(ext,'.mhd') FILETYPE='ITK'; end
                            if strcmp(ext,'.mha') FILETYPE='ITK'; end
                            if strcmp(ext,'.mgh') FILETYPE='MGH'; end
                            if strcmp(ext,'.mgz') FILETYPE='MGH'; end
                            if strcmp(ext,'.mat') FILETYPE='MATLAB'; end
                            if strcmp(ext,'.ima') FILETYPE='SHR'; end
                            if strcmp(ext,'.img') FILETYPE='ANALYZE'; end % Assume Analyze format (modify below if Nifti)
                            if strcmp(ext,'.hdr') FILETYPE='ANALYZE'; end % Assume Analyze format (modify below if Nifti)
                            if strcmp(ext,'.nii') FILETYPE='NIFTI'; end 
                            if size(ext,2)>3 % Dynamic SHR
                                if strcmp(ext(1:4),'.ima') FILETYPE='SHR'; end
                            end
                        catch
                        end;


                    % Test if ANALYZE or NIFTI
                        if( strcmp(FILETYPE,'ANALYZE') ||strcmp(FILETYPE,'NIFTI') )
                            fid = fopen(file, 'r');
                            tempHeader= fread(fid, 348,'char');                     % Binary header in memory 
                            fclose(fid);
                            
                            %"n+1" means that the image data is stored in the same file as the header information (.nii)
                            if strcmp(char(tempHeader(345:347))', 'n+1')  FILETYPE='NIFTY_ONEFILE';end
                            
                            %"ni1" means that the image data is stored in the ".img" file corresponding to the header file (starting at file offset 0).
                            if strcmp(char(tempHeader(345:347))', 'ni1')  FILETYPE='NIFTY_TWOFILES';end
                            
                            % Assume Single-file NIFTI if did not match NIFTY_ONEFILE or NIFTY_TWOFILES
                            if( strcmp(FILETYPE,'NIFTI'))  LocalOpenNifti(hObject, eventdata, handles, file,path,FILETYPE );end 

                        end
                        
                    % Test if INTERFILE
                        if( strcmp(FILETYPE,'UNKNOWN'))
                            text =  fileread(file);
                            if findstr(text(1:200),'INTERFILE')  % In beginning
                                FILETYPE='INTERFILE';
                            end
                        end

                    % Test if DICOMDIR
                        if( strcmp(FILETYPE,'UNKNOWN'))
                            if strcmp(name, 'DICOMDIR')  FILETYPE='DICOMDIR';end
                        end

                    % Test if DICOM
                        if( strcmp(FILETYPE,'UNKNOWN'))
                            dummy1=1;dummy3='l'; % Assume a stupidly small image
                            [Data, headers, fileNames]=Dirty_Read_DICOM(path, dummy1,dummy3, file); % selected file
                            if strcmp(char(headers{1}(129:132))', 'DICM')  FILETYPE='DICOM';end
                        end

                    % Test if HERMES (taken from CD cache)
                        if( strcmp(FILETYPE,'UNKNOWN'))
                            dummy1=1;dummy3='l'; % Assume a stupidly small image
                            [Data, headers, fileNames]=Dirty_Read_DICOM(path, dummy1,dummy3, file); % selected file
                            if strcmp(char(headers{1}(129:132))', '1000')  
                                FILETYPE='DICOM';
                                disp([ 'Probably a Hermes DICOM-like image, trying to open it.  Bytes that should read DICM=' char(headers{1}(129:132))' ]);
                            end
                        end
                        
                    % Open if M4
                    if( strcmp(FILETYPE,'MATLAB'))
                        try
                            m4=load( [path filesep file] ); % Load file
                            fn = fieldnames(m4);
                            m4_field = fn{1};  % Assume just m4 objects in this struct
                            a = getfield(m4,m4_field);
                            if isa(a,'Matrix4D')
                                FILETYPE='Matrix4D';  % Modify -- because M4 object
                                
                                % Open real part
                                handle=imlook4d( single( real( a.matrix) ));
                                handles = guidata(handle);
                                handles.image.fileType = 'Matrix4D';
                                try handles.image.pixelSizeX = a.voxelSize(1); catch end
                                try handles.image.pixelSizeY = a.voxelSize(2); catch end
                                try handles.image.sliceSpacing = a.voxelSize(3); catch end
                                try handles.image.modality = a.imagingInfo.Modality; catch end
                                try handles.image.time = a.timeStamp(1,:); catch end
                                
                                set(handle,'Name', file); 
                                guidata(handle, handles);
                                
                                % Open imaginary part
                                if ~isreal(a.matrix)
                                    % Modify name of Real                                   
                                    set(handle,'Name', ['REAL ' ' ' get(handles.figure1,'Name') ]); 
                                    guidata(handle, handles);
  
                                    handle=imlook4d( single( imag( a.matrix) ) );
                                    handles = guidata(handle);
                                    handles.image.fileType = 'Matrix4D';
                                    try handles.image.pixelSizeX = a.voxelSize(1); catch end
                                    try handles.image.pixelSizeY = a.voxelSize(2); catch end
                                    try handles.image.sliceSpacing = a.voxelSize(3); catch end
                                    try handles.image.modality = a.imagingInfo.Modality; catch end
                                    try handles.image.time = a.timeStamp(1,:); catch end
                                    
                                                                        
                                    set(handle,'Name', ['IMAGINARY ' ' ' file ]); 

                                    guidata(handle, handles);
                                end
                            end
                        catch
                        end
                    end

                         
                    % If UNKNOWN, guess binary format
                        if( strcmp(FILETYPE,'UNKNOWN'))
                            FILETYPE='BINARY';
                         end   

                        %disp(['OpenFile_Callback:  Filetype=' FILETYPE]);
                        disp(['Filetype=' FILETYPE]);
                %
                % Call function to open correct file format
                %
                    if( strcmp(FILETYPE,'ECAT'))    LocalOpenECAT(hObject, eventdata, handles, file,path);end
                    if( strcmp(FILETYPE,'MATLAB'))  LocalOpenMat(hObject, eventdata, handles, file,path);end
                    if( strcmp(FILETYPE,'SHR'))     LocalOpenSHR(hObject, eventdata, handles, file,path);end
                    if( strcmp(FILETYPE,'DICOM'))   LocalOpenDirtyDICOM3(hObject, eventdata, handles, file,path);end
                    if( strcmp(FILETYPE,'DICOMDIR')) LocalOpenDICOMDIR(hObject, eventdata, handles, file,path);end
                    if( strcmp(FILETYPE,'BINARY'))  LocalOpenBinary(hObject, eventdata, handles, file,path,'BINARY');end                    
                    if( strcmp(FILETYPE,'ITK'))     LocalOpenBinary(hObject, eventdata, handles, file,path,'ITK' );end                   
                    if( strcmp(FILETYPE,'MGH'))     LocalOpenMGH(hObject, eventdata, handles, file,path );end
                    if( strcmp(FILETYPE,'INTERFILE'))  LocalOpenBinary(hObject, eventdata, handles, file,path,'INTERFILE' );end
                 
% Own analyze and nifty reader                    
%                     if( strcmp(FILETYPE,'ANALYZE'))  LocalOpenBinary(hObject, eventdata, handles, file,path,'ANALYZE' );end
%                     if( strcmp(FILETYPE,'NIFTY'))  LocalOpenBinary(hObject, eventdata, handles, file,path,'ANALYZE' );end  % NIFTY treated as Analyze
%                     if( strcmp(FILETYPE,'NIFTY_ONEFILE'))  LocalOpenBinary(hObject, eventdata, handles, file,path,'NIFTY_ONEFILE' );end  % Single-file NIFTY is special

% Jonny Seans Analyze and Nifty reader
                    if( strcmp(FILETYPE,'ANALYZE'))  LocalOpenNifti(hObject, eventdata, handles, file,path,FILETYPE);end         % ANALYZE
                    if( strcmp(FILETYPE,'NIFTY_TWOFILES'))  LocalOpenNifti(hObject, eventdata, handles, file,path,FILETYPE);end  % NIFTY behaving as Analyze (img+hdr files)
                    if( strcmp(FILETYPE,'NIFTY_ONEFILE'))  LocalOpenNifti(hObject, eventdata, handles, file,path,FILETYPE );end  % Single-file NIFTY
                    
                    
                    if( strcmp(FILETYPE,'UNKNOWN')) end

               %Remember path
                    cd(path);
                    handles.image.folder = path;
                    
                    newHandle = gcf;
                    newHandles = guidata(newHandle);
                    newHandles.image.folder = path;
                    guidata(newHandle,newHandles);


            catch % Error 
                
                try
                    disp(['Fallback to BINARY - because ' FILETYPE ' failed']);
                    LocalOpenBinary(hObject, eventdata, handles, file,path,'BINARY'); 
                catch % Fallback to binary ( for instance when .img is not an Analyze file)
                     disp('ERROR:  imlook4d/OpenFile_Callback');
                     disp(lasterr)
                    %MExeption.last
                    %errordlg({'Error opening file','', [file],'',['(' path  file ')']},'Error opening file')
                end
            end
            
             % Set colorscale
                    imlook4d_set_colorscale_from_modality(gcf, {}, guidata(gcf));
            function LocalOpenMGH(hObject, eventdata, handles, file,path)  
                % Test if Freesurfer files exist
                    if strcmp('', which('MRIread'))
                        warndlg({'MGH not read because Freesurfer Matlab files not in path.',...
                            'Add these files to path, or',...
                            'download Freesurfer Matlab files'});
                        displayMessageRow([''   ]);
                        return;
                    end;       
                
                % Read files
                    fullPath=[path file];                
                    disp([ 'Opening MGH/MGZ from path=' fullPath ]);
                    mri = MRIread(fullPath,0);    

                % Operate on the new imlook4d instance
                    h=imlook4d(mri.vol);
                    [pathstr, name, ext] = fileparts(fullPath);
                    set(h,'Name', [name]);
                    newhandles = guidata(h);

                % Save information of file format in new imlook4d        
                    newhandles.image.fileType='MGH';
                    newhandles.image.modality='';  % Assume PET
                    newhandles.image.mri=mri;  % Save MGH data structure
                    
                % Set pixel dimensions
                    newhandles.image.pixelSizeX=mri.xsize;
                    newhandles.image.pixelSizeY=mri.ysize;
                    newhandles.image.sliceSpacing=mri.zsize;    
                    newhandles.image.unit='';  % Unit not in header, but needed in some scripts                   
                    
                    % Save guidata
                    guidata(h, newhandles); 

                % Set colorscale
                    imlook4d_set_colorscale_from_modality(h, eventdata, newhandles);
            function LocalOpenSHR(hObject, eventdata, handles, file,path)
                    pixelx=256;
                    pixely=256;

                    fullPath=[path file];
                    disp([ 'Opening SHR path=' path ]);

                    % Read data
                    [Data, time, duration]=SHR_readMultipleFiles(  fullPath ,  pixelx,  pixely);


                    % Operate on the new imlook4d instance
                        h=imlook4d(Data, time, duration);
                        [pathstr, name, ext] = fileparts(fullPath);
                        set(h,'Name', [name]);
                        newhandles = guidata(h);

                        % Turn off menues that do not apply to SHR data               
                        set(newhandles.SaveFile,'Enable','off');

                    % Save information of file format in new imlook4d        
                        newhandles.image.fileType='SHR';
                        newhandles.image.modality='PT';  % Assume PET
                        
                        % Save guidata
                        guidata(h, newhandles); 
                        
                                            
                    % Set colorscale
                        imlook4d_set_colorscale_from_modality(h, eventdata, newhandles);

                    %Remember path
                        cd(path);  
            function LocalOpenNifti(hObject, eventdata, handles, file,path, fileType)
                fullPath=[path file];
                [path,name,ext] = fileparts(fullPath);
                
                disp([ 'Opening Analyze/Nifti from path=' fullPath ]);
                
                % Load Analyze/Nifti
                %
                % load_nii transforms image to radiological RAS
                % coordinate system, and outputs the nii structure.
                %--------------------------------------------------
                %  nii structure:
                %	hdr -		struct with NIFTI header fields.
                %	filetype -	Analyze format .hdr/.img (0);
                %			NIFTI .hdr/.img (1);
                %			NIFTI .nii (2)
                %	fileprefix - 	NIFTI filename without extension.
                %	machine - 	machine string variable.
                %	img - 		3D (or 4D) matrix of NIFTI data.
                %	original -	the original header before any affine transform.
                    try
                        nii = load_nii(fullPath);
                        openingMode='load_nii';
                    catch
                        %  Load NIFTI or ANALYZE dataset, but not applying any appropriate affine
                        %  geometric transform or voxel intensity scaling.
                        %warndlg({'WARNING - load_nii failed.',  'Trying load_untouch_nii.',  'The data will not go through geometrical transforms'}); 
                        nii = load_untouch_nii(fullPath)
                        openingMode='load_untouch_nii';                        
                    end
                    
                    
                
                % Get times from sif file - if exists (Turku data has that)
                    try 
                        fullPath=[path filesep name '.sif'];  % hdr file (img file was opened) 
                        fid=fopen(fullPath);

                        C = textscan(fid, '%f %f %f %f', 'headerLines', 1);
                        time=C{1}';
                        duration= (C{2}-C{1})';                           
                        [ 'time' 'duration'];
                        [time duration];

                        fclose(fid);
                    catch
                        % Sif file does not exist
                    end
                    
              % New imlook4d 
                    %nii.img = flipdim( nii.img, 2);
                    nii.img(isnan(nii.img))=0;
                    if exist('time')&&exist('duration')
                        h=imlook4d(single(nii.img),time, duration);
                    else
                         h=imlook4d(single(nii.img));
                    end
                    
                    set(h,'Name', [file]);
                    newhandles = guidata(h);
                    
              % Display message
                    if strcmp(openingMode,'load_untouch_nii')
                        displayMessageRow({'WARNING - load_nii failed.  Trying load_untouch_nii.',  'The data did not go through geometrical transforms'})
                    end
               
              % Set Y-direction
                    newhandles.axes1.YDir = 'normal';  
                  %set(newhandles.axes1, 'YDir', 'reverse');   

                    
               % Enable menues
                    set(newhandles.SaveFile,'Enable','on');
                    
               % Save nii struct (except images)
                    nii = rmfield(nii, 'img');
                    newhandles.image.nii=nii;
                    

               % Set pixel dimensions
                    newhandles.image.fileType=fileType;
                    newhandles.image.pixelSizeX=nii.hdr.dime.pixdim(2);
                    newhandles.image.pixelSizeY=nii.hdr.dime.pixdim(3);
                    newhandles.image.sliceSpacing=nii.hdr.dime.pixdim(4);    
                    newhandles.image.unit='';  % Unit not in header, but needed in some scripts
                    
                    newhandles.image.openingMode=openingMode;
 
                % Set radio button and call callback function
%                     set(newhandles.SwapHeadFeetRadioButton,'Value',1);
%                     imlook4d('SwapHeadFeetRadioButton_Callback', h,{},newhandles);
                        
               % Save guidata
                    guidata(h, newhandles);                
            function LocalOpenBinary(hObject, eventdata, handles, file,path, fileType)
                % Used for opening different types of binary files
                % 1) Pure binary
                % 2) Interfile, where the header is parsed to fill in the defaultanswers
                % 3) Analyze
                % 4) ITK formats (MHD, MHA)
                
                % TODO : phase out Analyze from this code
                
                scaleFactor=1;
                offset=0;
             

                fullPath=[path file];

                %
                % Input pixels and slices
                %
                    prompt={'xPixels',...
                            'yPixels',...
                            'Slices (formula such as 1269/47 is allowed)',...
                            'Frames (formula allowed)',...
                            'Byte order - b or l (little L)',...
                            'Format int16, float32, short, ... (see MATLAB fread documentation)'};
                    title='Input data dimensions';
                    numlines=1;
                    %defaultanswer={'128','47','b'};
                    
                    % IF BINARY
                    if strcmp(fileType,'BINARY')
                        defaultanswer={'128','128', '47','1','l','int16'};
                    end
                    
                    % IF INTERFILE
                    if strcmp(fileType,'INTERFILE')
                        [defaultanswer fullPath]=interfileHeaderInformation( fullPath);
                        try
                            frameDuration=str2num( interfileHeader( filePath, 'image duration (sec)')  );  % Not used yet
                        catch
                        end
                    end
                    
                    %
                    % IF MHD, MHA (ITK format)
                    %
                    if strcmp(fileType,'ITK')

                        % Pixel dimensions
                        pixelString=mhdHeader( fullPath, 'ElementSpacing');    % in x y z
                        [dX, remain] = strtok(pixelString,' ');    % dX
                        [dY, dZ] = strtok(remain,' ');              % dY dZ
                        dX=str2num(dX);
                        dY=str2num(dY);
                        dZ=str2num(dZ);
                        
                        % Populate dialog that comes below, and retrieve
                        % path to binary file
                        [defaultanswer fullPath]=mhdHeaderInformation( fullPath);                            
                    end
                    
                    %
                    % IF ANALYZE
                    %
                    if strcmp(fileType,'ANALYZE') || strcmp(fileType,'NIFTY_ONEFILE')
                        [path,name,ext] = fileparts(fullPath);
                        
                        % Read header
                        if strcmp(fileType,'ANALYZE') && strcmp(ext, '.hdr')
                            fid=fopen(fullPath);
                        end
                        if strcmp(fileType,'ANALYZE') && strcmp(ext, '.img')
                           fullPath=[path filesep name '.hdr'];  % hdr file (img file was opened) 
                           fid=fopen(fullPath);
                        end
                        if strcmp(fileType,'NIFTY_ONEFILE')
                            fid=fopen(fullPath);
                        end
                        
                        headerFile=fullPath;  % Remember header file path

                        % Probe little or big-endian
                        headerSize=fread(fid,[1],'int32'); % Header size (348 if not extended mode)
                        if headerSize>5000
                            machineFormat='b';
                            disp('Big endian');
                        else
                            machineFormat='l';
                            disp('Little endian');
                        end
                        
                        % Read rest of header
                        fread(fid,[10],'char');
                        fread(fid,[18],'char');
                        fread(fid,[1],'int32',0,machineFormat); % 16384 -- This could be better test if little-endian
                        fread(fid,[1],'int16',0,machineFormat);
                        fread(fid,[1],'char');  % r - if not extended mode
                        fread(fid,[1],'char'); 
                        
                        pixels=fread(fid,[8],'int16',0,machineFormat);   % Voxels per dimension, pixels(1) is number of dimensions
                        disp(['Pixels=' num2str(pixels(2:pixels(1)+1)')]);
                        
                        disp(['Voxel Units=' fread(fid,[4],'char')']);  % Units
                        disp(['Cal Units=' fread(fid,[8],'char')']);  % Units
                        fread(fid,[1],'int16',0,machineFormat); % 
                        
                        DT_xxx=fread(fid,[1],'int16',0,machineFormat);
                        disp(['DT_xxx=' num2str(DT_xxx) ' (1=binary, 2= 8bits/voxel, 4=16bits/voxel, 8=32bits/voxel)']); 
                        
                        disp(['Bits per pixel=' fread(fid,[1],'int16',0,machineFormat)]);

                        fread(fid,[1],'int16',0,machineFormat); % unused
                        
                        fread(fid,[1],'float',0,machineFormat); % 
                        dX=fread(fid,[1],'float',0,machineFormat); % Voxel width
                        dY=fread(fid,[1],'float',0,machineFormat); % Voxel height
                        dZ=fread(fid,[1],'float',0,machineFormat); % Voxel thickness
                        fread(fid,[1],'float',0,machineFormat); % undoc
                        fread(fid,[1],'float',0,machineFormat); % undoc
                        fread(fid,[1],'float',0,machineFormat); % undoc
                        fread(fid,[1],'float',0,machineFormat); % undoc   
                        
                        disp(['Pixel dimensions= (' num2str(dX) ',' num2str(dY) ',' num2str(dZ) ')' ]);
                        
                        vox_offset=fread(fid,[1],'float',0,machineFormat); % vox offset 
                        disp(['vox offset='  num2str(vox_offset) ]);  % vox offset 
                        
                        scaleFactor=fread(fid,[1],'float',0,machineFormat);
                        offset=fread(fid,[1],'float',0,machineFormat);
                        disp(['SPM Scale factor=' num2str(scaleFactor) ]); % SPM Scale factor
                        disp(['SPM offset=' num2str(offset) ]);  % SPM offset
                        fread(fid,[1],'float',0,machineFormat); %                    

                        fread(fid,[1],'float',0,machineFormat); % Max calibration value
                        fread(fid,[1],'float',0,machineFormat); % Min calibration value
                        fread(fid,[1],'float',0,machineFormat); % compressed
                        fread(fid,[1],'float',0,machineFormat); % verified
                        fread(fid,[1],'int32',0,machineFormat); % max pixel value for entire database
                        fread(fid,[1],'int32',0,machineFormat); % min pixel value for entire database
                        fread(fid,[2],'int32',0,machineFormat); % TEST
                        
                        disp(['hist=' fread(fid,[80],'char=>char',0,machineFormat)']); % hist
                        fread(fid,[1],'int32',0,machineFormat); % TEST
                        disp(['aux file=' fread(fid,[24],'char=>char',0,machineFormat)']); % aux file
                        
                        fread(fid,[1],'char',0,machineFormat); % slice orientation
                        fread(fid,[5],'int16',0,machineFormat); % originator
                        
                        % SKIP rest of file
                        
                        fclose(fid);
                        
                        valueType='int16';
                        if DT_xxx==2
                            valueType='uint8';
                         end
                        
                        if DT_xxx==4
                            valueType='int16';
                        end
                         
                        if DT_xxx==8
                            valueType='int32';
                        end                       
                          
                        if DT_xxx==16
                            valueType='float';
                        end
                          
                        if DT_xxx==32
                            valueType='complex';
                        end 
                        
                        if DT_xxx==64
                            valueType='double';
                        end

                        
                        
                        % Populate dialog that comes below, and retrieve
                        % path to binary file
                        
                        defaultanswer={num2str(pixels(2)),num2str(pixels(3)), num2str(pixels(4)),num2str(pixels(5)),machineFormat,valueType};
                        
                        
                        if strcmp(fileType,'NIFTY_ONEFILE')
                            % Use same fullPath
                        else
                            fullPath=[path filesep name '.img'];   % img file  
                        end

                    end
                    
                    answer=inputdlg(prompt,title,numlines,defaultanswer);

                    XPIXELS=str2num(answer{1});
                    YPIXELS=str2num(answer{2});

                    FORMAT=answer{6};
                    MACHINEFORMAT=answer{5};
                    
                    SLICES=eval(answer{3});
                    FRAMES=eval(answer{4}); 

                %
                % READ MATRIX
                %
                    %fid=fopen(fullPath,'r','b');
                    fid=fopen(fullPath,'r',answer{5});
                    disp([ 'Opening binary file=' fullPath ]);
                    
                    if strcmp(fileType,'NIFTY_ONEFILE')
                            % Skip to voxoffset
                    end
                    

                    Data=zeros(XPIXELS,YPIXELS,SLICES,FRAMES);    % Create empty matrix

                    for j=1:FRAMES
                        for i=1:SLICES  
                           Data(:,:,i,j)=fread(fid,[XPIXELS YPIXELS],FORMAT,0,MACHINEFORMAT);
                        end;
                    end;

                    fclose(fid);


                    disp(['Matrix size=' num2str(size(Data))]);
                    disp('DONE opening binary file ');
                    
                    % Scaling
                    Data=scaleFactor*Data+offset;
                        
                        
                %
                % Get times from sif file - if exists (Turku data has that)
                % 


                    try 
                        fullPath=[path filesep name '.sif'];  % hdr file (img file was opened) 
                        fid=fopen(fullPath);

                        C = textscan(fid, '%f %f %f %f', 'headerLines', 1);
                        time=C{1}';
                        duration= (C{2}-C{1})';                           
                        [ 'time' 'duration'];
                        [time duration];

                        fclose(fid);
                    catch
                        % Sif file does not exist
                    end



                %
                % Operate on the new imlook4d instance
                %
                    if exist('time')&&exist('duration')
                        h=imlook4d(single(Data),time, duration);
                    else
                         h=imlook4d(single(Data));
                    end

                    set(h,'Name', [file]);
                    newhandles = guidata(h);

                    % Save information of file format in new imlook4d        
                    try
                        newhandles.image.fileType=fileType;
                    catch
                        newhandles.image.fileType='BINARY';
                    end

                   % Turn off menues that do not apply to binary data               
                   set(newhandles.SaveFile,'Enable','off');

                   % Set fake dimensions
                        newhandles.image.pixelSizeX=1;
                        newhandles.image.pixelSizeY=1;
                        newhandles.image.sliceSpacing=1;
                   
                   % 
                   % ITK
                   %
                    if strcmp(fileType,'ITK')
                        try
                            % Set radio button and call callback function
                                set(newhandles.FlipAndRotateRadioButton,'Value',0);
                                imlook4d('FlipAndRotateRadioButton_Callback', h,{},newhandles);
                            % Set pixel dimensions
                                newhandles.image.pixelSizeX=dX;
                                newhandles.image.pixelSizeY=dY;
                                newhandles.image.sliceSpacing=dZ;        
                        catch
                            disp('ERROR:  mhdHeader.m  : Could not find matrix size'); 
                        end  
                    end

                    % 
                    % ANALYZE
                    %
                    if strcmp(fileType,'ANALYZE')
                        try
                            % Enable menues
                                set(newhandles.SaveFile,'Enable','on');
                            
                            % Set radio button and call callback function
                                %set(newhandles.FlipAndRotateRadioButton,'Value',0);
                                %imlook4d('FlipAndRotateRadioButton_Callback', h,{},newhandles);
                            
                            % Store header file path
                                newhandles.image.headerFile=headerFile;
                                newhandles.image.valueType=valueType;
                                newhandles.image.machineformat=MACHINEFORMAT;
                                 FILETYPE=handles.image.fileType;
                                 
                             % Set pixel dimensions
                                newhandles.image.pixelSizeX=dX;
                                newhandles.image.pixelSizeY=dY;
                                newhandles.image.sliceSpacing=dZ;    
                        catch
                            disp('ERROR:  mhdHeader.m  : Could not find matrix size'); 
                        end  
                    end
                    
                    % Save guidata
                    guidata(h, newhandles);
            function LocalOpenMat(hObject, eventdata, handles, file,path)

                    fullPath=[path file];

                    disp([ 'Opening matlab matrix file=' fullPath ]);
                    load(fullPath);
                    whos
                    
                    % If m4-object

                    %if (isa(inpargs,'Matrix4D'))
                    try
                        if isobject('m4Map')
                          imlook4d(m4Map);
                          return
                        end 
                    catch end
                    
                    % If m4 mat-file (non-object)
                    if exist('m4ADCDataw')
                        [pathstr, variableName, ext] = fileparts(fullPath);  % name will be same as variable
                        
                       numberOfm4s=eval(['size(' variableName ',2)']);
                        for i=1:numberOfm4s
                            m4=eval( [variableName '{' num2str(i) '}']);  % The m4-object
                            h=imlook4d(real(m4.matrix()) );
                            set(h,'name', [ variableName '(' num2str(i) ') (' m4.name() ')']);
                            
                            % Show also imaginary data
                            if not( isreal(m4.matrix()) )
                                h=imlook4d(real(m4.matrix()) );
                                set(h,'name', [ '[Imag]' variableName '(' num2str(i) ') (' m4.name() ')']);
                            end
                            
                        end
                        
                        return
                        
                    end
                    

        
                    disp(['Matrix size=' num2str(size(Data))]);
                    disp('DONE opening matlab matrix file ');

                    % Try using time information
                    % If missing, obtain time information:
                    %   try ECAT 
                    %   try DICOM 
                    %   fallback on only Data matrix

                    try
                        disp('Try imlook4d with time information');
                        h=imlook4d(Data, time, duration); 
                    catch  % IF PROBLEM with missing time/duration, try to obtain them:
                        disp('Time information did not exist, try to obtain this from possible header information');

                        try
                            disp('DICOM header did not work');
                            [time, duration]=timeFromDICOMInput(header);
                            h=imlook4d(Data, time, duration);
                        catch
                            try 
                                disp('Try ECAT header');
                                [time, duration]=timeFromECATInput(subHeader);
                                h=imlook4d(Data, time, duration);

                            catch
                                disp('ECAT header did not work');
                                h=imlook4d(Data);
                            end
                            %h=imlook4d(Data);
                        end
                    end   

                    %h=imlook4d(Data);
                    set(h,'Name', [file]);
                    newhandles = guidata(h);
                    
                    % Pixel dimensions
                    try
                         [newhandles.image.pixelSizeX newhandles.image.pixelSizeY newhandles.image.sliceSpacing]=pixel_dims;
                    catch

                        disp('imlook4d/OpenMat_Callback:ERROR - Failded Importing pixel_dims');
                    end
                    

                    % Store ECAT headers
                    try        
                        disp('Importing ECAT headers');
                        %newhandles = guidata(h);
                        % Store header and subheader
                        newhandles.image.subHeader=subHeader;
                        newhandles.image.mainHeader=mainHeader;
                        newhandles.image.ECATDirStruct=dirstruct;
                        disp('Sizes subHeader mainHeader dirstruct');
                        size(subHeader)
                        size(mainHeader)
                        size(dirstruct)
                    catch

                        disp('imlook4d/OpenMat_Callback:ERROR - Failded Importing ECAT headers');
                    end

                    % Store DICOM headers
                    try        
                        disp('Importing DICOM headers');
                        %newhandles = guidata(h);
                        % Store DICOM header
                        newhandles.image.DICOMHeader=DICOMHeader;
                    catch

                        disp('imlook4d/OpenMat_Callback:ERROR - Failded Importing DICOM headers');
                    end

                    % Store isotope half time
                    %
                    try
                        disp('Importing isotope halflife');
                        %newhandles = guidata(h);
                        newhandles.image.halflife=halflife;
                    catch
                        disp('imlook4d/OpenMat_Callback:ERROR  Failed Importing isotope halflife');
                    end           

                    % Store file type
                    %
                    try
                        disp('Importing fileType');
                        newhandles.image.fileType=fileType;
                    catch
                        disp('imlook4d/OpenMat_Callback:ERROR  Failed importing fileType');
                    end       
                    
                    
                    % Store pixel dimensions
                    %
                    try
                        disp('Importing pixel dimensions');
                        newhandles.image.pixelSizeX=pixel_dims(1);
                        newhandles.image.pixelSizeY=pixel_dims(2);
                        newhandles.image.sliceSpacing=pixel_dims(3);
                            
                    catch
                        disp('imlook4d/OpenMat_Callback:ERROR  Failed importing pixel_dims');
                    end


                    cd(path);  %Remember path


                    % Save guidata
                    guidata(h, newhandles);

                    updateImage(h, eventdata, newhandles);
            function LocalOpenECAT(hObject, eventdata, handles, file,path)

                    %
                    % Open file and create new imlook4d instance
                    %
                        %[file,path] = uigetfile('*.v','ECAT Open file name');
                        fullPath=[path file];

                        disp([ 'Opening ECAT file=' fullPath ]);
                        [Data, mainHeader, subHeader, dirstruct]=ReadECAT(fullPath, @DummyGeneral);    

                        unit=char(nonzeros(mainHeader(466:466+31)'))';
                        disp(['UNIT="' unit '"']);

                        disp(['Matrix size=' num2str(size(Data))]);
                        disp('DONE opening ECAT file ');
                        
                     % Get pixel size information   
                        
                        pixelSizeX=10*ECAT_readHeaderReal(subHeader(:,1), 34);        % PixelSize in mm, from ECAT X_PIXEL_SIZE
                        pixelSizeY=10*ECAT_readHeaderReal(subHeader(:,1), 38);       % PixelSize in mm, from ECAT Y_PIXEL_SIZE
                        sliceSpacing=10*ECAT_readHeaderReal(subHeader(:,1), 42);     % PixelSize in mm, from ECAT Z_PIXEL_SIZE
                        
                        
                     %
                     % Get time information
                     %
                        try
                            [time, duration]=timeFromECATInput(subHeader);
                            %h=imlook4d(Data, time, duration);
                        catch
                            %h=imlook4d(Data);
                            disp('NO TIME INFO FOUND');
                        end
                    %    
                    % Sort on time (Very rare: some dynamic ECAT files can be scrambled in time)
                    %
                        if exist('time') % Sort if time exist
                            % Build index with columns:  [ time,  original_index ]
                            last=size(subHeader,2);  % Used when iterating files
                            for i=1:last
                                indexlist(i,1)=time(i); 
                                indexlist(i,2)=i;                       
                            end
                            
                            % Sort on time
                            disp('sorting ');
                            sortedIndexList=sortrows(indexlist,[1]);  % Sort on time
                                          
                            % Sort according to index list
                            disp('sorting data');
                            for i=1:last            
                                imageNumber=sortedIndexList(i,2);           % original image number for i:th image
                                sortedData(:,:,:,i)=Data(:,:,:,imageNumber);  
                                
                                sortedSubHeaders(:,i)=subHeader(:,imageNumber);
                                sortedTime(i)=time(imageNumber);
                                sortedDuration(i)=duration(imageNumber);
                            end 
                        end % if time exist
                        
                    % Swap head and feet
                    %sortedData=flipdim(sortedData,3);   
                        
                        
                     %   
                     % New imlook4d instance
                     %
                        try
                            %[time, duration]=timeFromECATInput(subHeader);
                            %h=imlook4d(Data, time, duration);
                            h=imlook4d(sortedData, sortedTime, sortedDuration);
                        catch
                            h=imlook4d(Data);
                            %disp('NO TIME INFO FOUND');
                        end
                        
                    %
                    % Operate on the new imlook4d instance
                    %
                        set(h,'Name', [file]);
                        newhandles = guidata(h);

                        % Save header and subheader
                        %newhandles.image.subHeader=subHeader;
                        newhandles.image.subHeader=sortedSubHeaders;
                        newhandles.image.mainHeader=mainHeader;
                        newhandles.image.ECATDirStruct=dirstruct;
                        newhandles.image.halflife=ECAT_readHeaderReal(mainHeader, 74);
                        disp(['Halflife=' num2str(newhandles.image.halflife)]);
                        newhandles.image.pixelSizeX=pixelSizeX;
                        newhandles.image.pixelSizeY=pixelSizeY;
                        newhandles.image.sliceSpacing=sliceSpacing;
                        newhandles.image.unit=unit;
                        newhandles.image.modality='PT';  % Assume PET

                        % Set radio button and call callback function
                        set(newhandles.FlipAndRotateRadioButton,'Value',1);
                        imlook4d('FlipAndRotateRadioButton_Callback', h,{},newhandles);
                        
                        %Remember path
                            cd(path);   
                        
                        % Set colorscale
                            %imlook4d_set_colorscale_from_modality(h, eventdata, newhandles);
                            handleToColorMenu=findobj(newhandles.EditMenu, 'Label', 'Color');  % Menu Color
                            imlook4d_set_colorscale_from_modality( handleToColorMenu , eventdata, newhandles);     % Sets color according to modality 

                        % Save information of file format in new imlook4d        
                        newhandles.image.fileType='ECAT';


                        % Save guidata
                        guidata(h, newhandles);
            function h=LocalOpenDirtyDICOM3(hObject, eventdata, handles, file,directoryPath)
                % This function is a new version which relies on new external
                % functions
                    selectedFile=file;


                %
                % Select files
                %
                    prompt={'Filter (for instance PT* )'};
                    title='Input File filter';
                    numlines=1;
                    [pathstr,name,ext] = fileparts(file);
        
                    % Give a pattern
                    defaultanswer={['*']};answer=defaultanswer;

                    %answer=inputdlg(prompt,title,numlines,defaultanswer); % Dialog for input of pattern
                  
                    fileFilter=answer{1};

                    % Create list of file names
                    fileNames=dir([directoryPath fileFilter]);

                %
                % Open scaled image
                %
                    try
                        [outputMatrix, outputStruct]=JanOpenScaledDICOM(directoryPath, fileNames, selectedFile);
                    catch
                        disp('imlook4d ERROR: Failed opening images (when calling JanOpenScaledDICOM) ');
                        disp(lasterr)
                        
                        return
                    end
                    %numberOfSlices=str2num(outputStruct.dirtyDICOMSlicesString);

                %
                % Display list of tags
                %
                    %headers=outputStruct.dirtyDICOMHeader;
                    mode=outputStruct.dirtyDICOMMode;

                    dummy1=1;dummy3='l'; [Data, headers, dummy]=Dirty_Read_DICOM(directoryPath, dummy1,dummy3, file); % selected file

                    % Initial tags
                    disp('INFORMATION FROM DICOM FILE=');
                    disp([ '   ' directoryPath name ext] );
                    
                    % Display tags
                    displayDicomListOfTags( headers, mode);

                %  
                % Sort
                %
                    try
                        [outputMatrix, outputStruct]=dirtyDICOMsort( outputMatrix, outputStruct);  
                    catch
                        disp('imlook4d ERROR: Failed sorting images');
                    end
                    
                    sliceLocations=outputStruct.dirtyDICOMsortedIndexList(:,3);

                    
                %
                % Find the different series, and select which one to open
                %
                    [b, m, n]=unique(outputStruct.dirtyDICOMsortedIndexList(:,6),'first');  % m is index to row
                    
                    % If more than one series - redo opening with selected scan 
                    % Exception, File/Open and Merge
                    
                    multipleSeries=(size(m,1)>1)
                    try
                        openAndMergeMode=strcmp(get(hObject,'Label'),'Open and merge');
                    catch
                        openAndMergeMode=0;
                    end
                        
                    
                    if (multipleSeries & ~openAndMergeMode)
                    %if size(m,1)>1
                        
                        % Populate listdlg selection box
                        for i=1:size(m,1)
                            TAB='   ';
                            
                            try
                                patientName=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, m(i),'0010', '0010',mode);
                            catch
                                patientName.string='';
                            end
                            
                            try
                                patientID=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, m(i),'0010', '0020',mode);
                            catch
                                patientID.string='';
                            end
                            try
                                studyDesc=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, m(i),'0008', '1030',mode);
                            catch
                                studyDesc.string='';
                            end
                            
                            try
                                seriesDesc=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, m(i),'0008', '103E',mode);
                            catch
                                seriesDesc.string='';
                            end
                            
                            
                           % Default colors
                           str{i}=[patientName.string TAB '(' patientID.string ')' TAB studyDesc.string TAB '---' TAB seriesDesc.string];
                            
                           % Colored text in listdlg
                           strColor{i}=[ '<HTML><FONT color="blue">' patientName.string TAB '</FONT>' ...
                                    '<HTML><FONT color="gray">' '(' patientID.string ')' TAB '</FONT>' ...
                                    '<HTML><FONT color="blue">' studyDesc.string TAB '</FONT>' ...
                                    '<HTML><FONT color="gray">' TAB seriesDesc.string '</FONT>' ...
                                    '</HTML>' ];
                           
                        end


                        % Select
                        try
                            % Colored text in listdlg 
                            [selected,v] = listdlg('PromptString','Select scan to open:',...
                                  'SelectionMode','single',...
                                  'ListSize', [800 400], ...
                                  'ListString',strColor);
                        catch
                            % Default black and white text
                             [selected,v] = listdlg('PromptString','Select scan to open:',...
                                  'SelectionMode','single',...
                                  'ListSize', [800 400], ...
                                  'ListString',str);                           
                        end
                          
                        % Make file list from selected series
                        counter=0;
                        for i=1:size(outputStruct.dirtyDICOMsortedIndexList,1)
                            if outputStruct.dirtyDICOMsortedIndexList(i,6)==b(selected)
                                counter=counter+1;
                                [pathstr, name, ext] = fileparts(outputStruct.dirtyDICOMFileNames{ i });
                                newFileNames(counter,1).name=[name ext];
                                
                                temp=dir(newFileNames(counter,1).name);
                                newFileNames(counter,1).bytes=temp.bytes;
                            end
                        end
                        
                        selectedFile=newFileNames(1,1).name;



                        % Open selected series
                        try
                            [outputMatrix, outputStruct]=JanOpenScaledDICOM(directoryPath, newFileNames, selectedFile);
                        catch
                            disp('imlook4d ERROR: Failed opening images');
                        end
                        
                        % Sort selected series
                        try
                            [outputMatrix, outputStruct]=dirtyDICOMsort( outputMatrix, outputStruct);  
                        catch
                            disp('imlook4d ERROR: Failed sorting images');
                        end
                        
                    end % End selection if more than one series


                %
                % Display information about the tags used in sorting
                %
                    sortedIndexList=outputStruct.dirtyDICOMsortedIndexList;
                    disp(' ');
                    disp('   Sorting parameters (sort order from left to right)');  

%                     disp( [sprintf( '   %-10s %-20s %-23s %-20s %-20s\n', '    ', '2)Frame ref time','Original image index','3)Slice location','1)Acquisition time' ) ...
%                         sprintf( '   %-10s %-20s %-23s %-20s %-20s\n', '    ', '(0054,1300)','(File input order)','(0020,1041)','(0008,0032)' ) ...
%                         sprintf('   %-10s %-20d %-23d %-20.3f %-20f\n' , 'min:', min(sortedIndexList) )  ...
%                         sprintf('   %-10s %-20d %-23d %-20.3f %-20f\n' , 'max:', max(sortedIndexList) )]...
%                     )


                    tempMin=min(sortedIndexList);
                    tempMax=max(sortedIndexList);
                    myFormat=       '   %-10s %-25f  %-10d %-17.3f %-15d %-10.0f %-20d\n';
                    try
                    disp( [sprintf( '   %-10s %-25s %-10s %-17s %-15s %-10s %-20s\n', ...
                                            '    ', 'Series Instance UID', 'Acq date','Slice location', 'Frame ref time',  'Acq time','Original image index' ) ...
                        sprintf( myFormat , 'min:' ,    tempMin(6),tempMin(5),tempMin(3),tempMin(1),tempMin(4),tempMin(2) )  ...
                        sprintf( myFormat , 'max:' ,    tempMax(6),tempMax(5),tempMax(3),tempMax(1),tempMax(4),tempMax(2) )  ...
                        sprintf('   %-10s\n','  ') ...
                        sprintf( myFormat , '1st row:' , sortedIndexList(1,6),  sortedIndexList(1,5), sortedIndexList(1,3), sortedIndexList(1,1),   sortedIndexList(1,4), sortedIndexList(1,2) )...
                        sprintf( myFormat , '2nd row:' , sortedIndexList(2,6),  sortedIndexList(2,5), sortedIndexList(2,3), sortedIndexList(2,1),   sortedIndexList(2,4), sortedIndexList(2,2) )...
                        sprintf('   %-10s\n',' ... ') ...
                        sprintf( myFormat , 'end row:' , sortedIndexList(end,6),  sortedIndexList(end,5), sortedIndexList(end,3), sortedIndexList(end,1),   sortedIndexList(end,4), sortedIndexList(end,2) ) ]...
                    )
                    catch
                    end
                    
                    
                    myFormat=       '   %-10s %-25.0f  %-10d %-10d %-17.3f %-15d %-12.0u %10.0f %-20d\n';
                    try
                        disp(' ');
                        disp( sprintf( '   %-10s %-25s %-10s %-10s %-17s %-15s %-12s %-10s %-20s\n', ...
                                                '    ', 'Series Instance UID', 'Acq date','Trig Time' , 'Slice location', 'Frame ref time',  'Acq time','Instance No', 'Original image index' ) );
                        disp(  sprintf( myFormat , 'min:' ,    tempMin(6),tempMin(5),tempMin(7),tempMin(3),tempMin(1),tempMin(4),tempMin(8),tempMin(2) )  );
                        disp(  sprintf( myFormat , 'max:' ,    tempMax(6),tempMax(5),tempMax(7),tempMax(3),tempMax(1),tempMax(4),tempMax(8),tempMax(2) )  );
                        disp(  sprintf('   %-10s\n','  ')  );
                        for i=1:size(sortedIndexList,1)
                           %disp( sprintf( myFormat , ['row=' num2str(i)] , sortedIndexList(i,6),  sortedIndexList(i,5),sortedIndexList(i,7), sortedIndexList(i,3), sortedIndexList(i,1),   sortedIndexList(i,4),sortedIndexList(i,8), sortedIndexList(i,2) ) )
                        end
        
                        disp( sprintf( myFormat , 'end row:' , sortedIndexList(end,6),  sortedIndexList(end,5),sortedIndexList(end,7), sortedIndexList(end,3), sortedIndexList(end,1),   sortedIndexList(end,4),sortedIndexList(end,8), sortedIndexList(end,2) ) )
                    catch
                    end                    
                    


                %
                % Get time, duration, and halflife
                %
                    try
                        [outputStruct]=dirtyDICOMTimeAndDuration( outputStruct);
                    catch
                        disp('imlook4d ERROR: Failed reading time and duration');
                    end

                    % If "File/Open and merge" is selected, the time is calculated
                    % from Acquisition time, relative first slice.
                    try
                        %if strcmp(get(hObject,'Label'),'Open and merge')
                        if openAndMergeMode

                            [outputStruct]=dirtyDICOMTimeFromAcqTime(outputStruct);
                        end
                    catch
                    end

                %
                % Calculate number of slices and number of frames
                %
                    % Get number of patient positions (column 3) that equals first patient position
                    % => number of frames /gates/ phases
                    numberOfFrames=sum( sortedIndexList(:,3)==sortedIndexList(1,3)); % Number of frames

                    % Get number of slices from total number of images, and number
                    % of frames
                    numberOfSlices=size(sortedIndexList,1) / numberOfFrames;
                    if mod( size(sortedIndexList,1), numberOfFrames )
                       h=errordlg({'Number of slices and number of images do not match',...
                           ['Number of images i=' num2str( size(sortedIndexList,1) )], ...
                           ['Number of frames f=' num2str(numberOfFrames) '  at position=' num2str( sortedIndexList(1,3) )]...
                           ['giving number of slices i/f=' num2str( numberOfSlices ) '  (which should be an integer)'], ...
                           [''], ...
                           ['Make sure that only files acquired at same positions are opened'], ...
                           });
                       uiwait(h);
                    end
                    
                %    
                % Special - multiple images in same file
                %
                    % if a single DICOM file had multiple images, then above method does not work.  
                    % Use that the filename is the same for all images, to determine that this is the case.
                    % Correct above and put images in slices.
                    if sum(strcmp(outputStruct.dirtyDICOMFileNames(:),outputStruct.dirtyDICOMFileNames(1)))>1
                        numberOfImages=size(outputStruct.dirtyDICOMFileNames(:),1);
                        numberOfSlices=numberOfImages;
                        numberOfFrames=1;
                        
                        % NM (0054,0033) Number of frames in Phase
                         try 
                             numberOfFramesInPhase=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, 1,'0054', '0033',mode); 
                             numberOfFrames=numberOfFramesInPhase.bytes(1)+256*numberOfFramesInPhase.bytes(2);
                             numberOfSlices=numberOfImages/numberOfFrames;
                         catch
                             numberOfFrames=1; 
                             numberOfSlices=numberOfImages;
                         end
                         
                         % assume NM, calculate slice locations
                         
                         startLocation=sliceLocations(1);
                         try
                            out=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, 1, '0018', '0088',mode);  %Spacing Between Slices (can be negative number)
                            sliceStep=str2num(out.string);
                         catch
                            sliceStep=outputStruct.sliceSpacing;  % This is not a negative number
                         end
                         
                         for i=1:numberOfSlices
                             sliceLocations(i)=startLocation+(i-1)*sliceStep;
                         end
                       
                        
                        
                    end
                    
                %
                % Fix DICOM y-axis
                %
                    outputMatrix=imlook4d_fliplr(outputMatrix);  % Flip row vector (which is the y direction of the matrix)

                %                
                % New imlook4d 
                %             
                    try
                        h=imlook4d(single(reshape(outputMatrix,size(outputMatrix,1),size(outputMatrix,2),numberOfSlices,[]) ),outputStruct.time, outputStruct.duration);
                    catch
                        h=imlook4d(single(reshape(outputMatrix,size(outputMatrix,1),size(outputMatrix,2),numberOfSlices,[]) ));
                    end

                    set(h,'Name', ['[' outputStruct.modality '] ' outputStruct.title]); % Window title
                    newhandles = guidata(h);

                    % Save header and subheader
                    newhandles.image.dirtyDICOMHeader=outputStruct.dirtyDICOMHeader;
                    newhandles.image.dirtyDICOMFileNames=outputStruct.dirtyDICOMFileNames;
                    newhandles.image.dirtyDICOMPixelSizeString=outputStruct.dirtyDICOMPixelSizeString;
                    newhandles.image.dirtyDICOMSlicesString=outputStruct.dirtyDICOMSlicesString;
                    newhandles.image.dirtyDICOMMachineFormat=outputStruct.dirtyDICOMMachineFormat;
                    newhandles.image.dirtyDICOMIndecesToScaleFactor=outputStruct.dirtyDICOMIndecesToScaleFactor;
                    newhandles.image.dirtyDICOMMode=outputStruct.dirtyDICOMMode;   % Explicit or implicit 2 or 0
                    newhandles.image.fileType='DICOM';
                    newhandles.image.pixelSizeX=outputStruct.pixelSizeX;
                    newhandles.image.pixelSizeY=outputStruct.pixelSizeY;
                    newhandles.image.sliceSpacing=outputStruct.sliceSpacing;
                    newhandles.image.imagePosition=outputStruct.imagePosition;
                    newhandles.image.modality=outputStruct.modality;
                    
                    newhandles.image.sliceLocations=sliceLocations;
                    newhandles.image.DICOMsortedIndexList=outputStruct.dirtyDICOMsortedIndexList;
                    
                    try
                        unit=dirtyDICOMHeaderData(headers, 1, '0054', '1001' ,mode); % Unit
                        newhandles.image.unit=unit.string;
                    catch
                    end
                    
                    try
                        newhandles.image.time2D=outputStruct.time2D;
                        newhandles.image.duration2D=outputStruct.duration2D;
                    catch
                    end
                    
                    try
                        newhandles.image.halflife=outputStruct.halflife;
                    catch
                    end;
                    
                    % Save guidata
                    guidata(h, newhandles);  
                    
                    % Set Colorscale and modality
                    %imlook4d_set_colorscale_from_modality(h, eventdata, newhandles);
                    
                    % Not sure why this works - since hObject is handle to
                    % FILE/OPEN uimenu on the imlook4d instance that opened
                    % this file.
                 
                    %imlook4d_set_colorscale_from_modality( get( findobj(hObject, 'Label', 'Gray') ), eventdata, newhandles);
                    
                    handleToColorMenu=findobj(newhandles.EditMenu, 'Label', 'Color');  % Menu Color
                    imlook4d_set_colorscale_from_modality( handleToColorMenu , eventdata, newhandles);     % Sets color according to modality 


                    updateImage(h, eventdata, newhandles);
                function displayDicomListOfTags( headers, mode)

                    % MACHINE INFO
                    disp('MACHINE INFO');
                    displayDicomTag(headers, 1, 'Modality', '0008', '0060', mode);
                    displayDicomTag(headers, 1, 'Manufacturer', '0008', '0070', mode);
                    displayDicomTag(headers, 1, 'Model', '0008', '1090', mode);

                    % OPENING 
                    disp('OPENING');
                    displayDicomTag(headers, 1, '*Transfer Syntax UID', '0002', '0010', mode);
                    displayDicomTag(headers, 1, ' Number of slices', '0054', '0081', mode);
                    displayDicomTag(headers, 1, ' Number of images in acq', '0020', '1002', mode);
                    displayDicomTag(headers, 1, '*Number of pixels', '0028', '0010', mode);
                    displayDicomTag(headers, 1, ' Study time', '0008', '0031', mode);
                    displayDicomTag(headers, 1, '*Rescale Slope', '0028', '1053', mode);
                    displayDicomTag(headers, 1, '*Rescale Intercept', '0028', '1052', mode);
                    displayDicomTag(headers, 1, ' Rescale Type', '0028', '1054', mode);
                    displayDicomTag(headers, 1, ' Unit', '0054', '1001', mode);
                    % SORTING
                    disp('SORTING');
                    displayDicomTag(headers, 1, '*Frame reference time', '0054', '1300', mode);
                    displayDicomTag(headers, 1, '*Slice location', '0020', '1041', mode);
                    displayDicomTag(headers, 1, ' Patient position', '0020', '0032', mode);
                    displayDicomTag(headers, 1, '*Acquisition time', '0008', '0032', mode);
                    displayDicomTag(headers, 1, ' Temporal Position Identifer', '0020', '0100', mode);
                    displayDicomTag(headers, 1, ' Image Number', '0020', '0013', mode);
                    % Get time, duration, and halflife
                    disp('TIME & DURATION');
                    displayDicomTag(headers, 1, 'Frame duration', '0018', '1242', mode);
                    displayDicomTag(headers, 1, 'Radioactive half life', '0018', '1075', mode); 
                function displayDicomTag( headers, number, name, group, element, mode)
                           % This function displays OK if tag is found, otherwise BAD
                           % String representation of tag is displayed (the first
                           % characters)
                           %
                           % INPUT
                           % - headers  cell array of binary headers
                           % - number   which element in headers to display
                           % - name     a string to display
                           % - group    hexadecimal string, 4 characters, giving the tag group
                           % - element  hexadecimal string, 4 characters, giving the tag element
                           % - mode     0 or 2
                           %
                            NAMELENGTH=35;   % Length of name string to display
                            STRINGLENGTH=35; % Length of output string
                            name=[name '                                                        '];                  % fill with spaces

                            try
                                temp=dirtyDICOMHeaderData(headers, number, group, element,mode);
                                outputString=[temp.string '                                                        '];   % fill with spaces
                                disp([ '   [ OK ]' '  (' group ',' element ')   ' name(1:NAMELENGTH) '=' outputString(1:STRINGLENGTH) ]);
                            catch
                                disp([ '   [    ]' '  (' group ',' element ')   ' name(1:NAMELENGTH) '=' 'not defined' ]);
                            end
                            
            function OpenFromPacs_Callback(hObject, eventdata, handles)
                
                % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end
                getFromPacs(handles.image.PACS.HostFile);
                return
            function NetworkHostsMenu_Callback(hObject, eventdata, handles)
                                 
                % Display HELP and get out of callback
                 %if DisplayHelp(hObject, eventdata, handles) 
                     %return 
                 %end
                
                return       
                function NetworkHostsSubMenu_Callback(hObject, eventdata, handles)
                    % Display HELP and get out of callback
                     if DisplayHelp(hObject, eventdata, handles) 
                         return 
                     end
                    
                    % Get file name 
                     disp(['Selected Network Hosts submenu item' get(hObject,'Label')] );
                     pacsDataFileName=get(hObject,'UserData');
                     
                    % Save PACS file to use
                    handles.image.PACS.HostFile=pacsDataFileName;
                    
                     
                    % Checkmarks
                       hPACSMenuObjects=get( get(hObject,'Parent'), 'Children');  % All other
                       for i=1:size(hPACSMenuObjects)
                           set(hPACSMenuObjects(i),'Checked','off')
                       end
                       set(hObject,'Checked','on')
                       
                       
                       guidata(hObject,handles);


                    return  

   % Save File                
        function SaveFile_Callback(hObject, eventdata, handles)
             % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end
                 
            % Make axial     
            handles = resetOrientation(handles);

            FILETYPE=handles.image.fileType;    % Obtain original file type
            oldPath=pwd();                      % Store path (which in some cases is destroyed in writing files)

            % Generate 4D image according to slice and frame defined in GUI
                
                displayMessageRow(['Calculating data to save'   ]);
                tempData=generateImage(handles, 1:size(handles.image.Cdata,3) ,  1:size(handles.image.Cdata,4)); % All slices, all frames
            %
            % Call function to open correct file format
            %
                displayMessageRow(['Writing data'   ]);
                %if( strcmp(FILETYPE,'ECAT'))    SaveECAT_Callback(hObject, eventdata, handles);end
                
                if( strcmp(FILETYPE,'MGH'))    LocalSaveMGH(handles, tempData);end
                if( strcmp(FILETYPE,'ECAT'))    LocalSaveECAT(handles, tempData);end
                if( strcmp(FILETYPE,'MATLAB'))  SaveMat_Callback(hObject, eventdata, handles);end
                if( strcmp(FILETYPE,'SHR'))     warndlg('Saving SHR is not supported');end
                if( strcmp(FILETYPE,'DICOM'))   LocalSaveDICOM(handles, tempData);end
                %if( strcmp(FILETYPE,'ANALYZE'))   LocalSaveAnalyze(handles, tempData);end
                if( strcmp(FILETYPE,'ANALYZE'))  LocalSaveNifti(handles, tempData);end         % ANALYZE
                if( strcmp(FILETYPE,'NIFTY_TWOFILES'))  LocalSaveNifti(handles, tempData);end  % NIFTY behaving as Analyze (img+hdr files)
                if( strcmp(FILETYPE,'NIFTY_ONEFILE'))  LocalSaveNifti(handles, tempData);end  % Single-file NIFTY
                if( strcmp(FILETYPE,'Matrix4D')) localSaveM4(handles, tempData); end  % M4 Umeå format
                
                if( strcmp(FILETYPE,'BINARY'))  warndlg('Saving Binary is not supported');end
                if( strcmp(FILETYPE,'UNKNOWN')) end    


                cd(oldPath);    % Restore path
                try
                    displayMessageRow(['DONE writing file'   ]);
                catch
                    % Fails if gcf not an imlook4d (for instance, after error dialog)
                end
            function LocalSaveM4(handles, file,path)                 
                                        suggestedFileName=get(handles.figure1, 'Name');
                        cleanedFileName=regexprep(suggestedFileName, '[*"/[]:;|=\\]', '_');  % Avoid characters that are not accepted in Windows file names
                        [path,name,ext] = fileparts([cleanedFileName]);


                            [file,path] = uiputfile(['*.hdr'] ,'Save as .hdr AND .img file', name);             
            function LocalSaveMGH(handles, file,path)  
                    % Test if Freesurfer files exist
                        if strcmp('', which('MRIwrite'))
                            displayMessageRow([' ']);
                            warndlg({'MGH OR MGZ not read because Freesurfer Matlab files not in path.',...
                                'Add these files to path, or',...
                                'download Freesurfer Matlab files'});
                            return;
                        end;       

                    % Prepare file path
                    suggestedFileName=get(handles.figure1, 'Name');
                    cleanedFileName=regexprep(suggestedFileName, '[*"/[]:;|=\\]', '_');  % Avoid characters that are not accepted in Windows file names
                    [path,name,ext] = fileparts([cleanedFileName]);


                    [file,path] = uiputfile({'*.mgh'; '*.mgz'; '*.nii'} ,'Save as .mgh, .mgz  ( Freesurfer) or .nii (nifti)', name);
                    %[file,path] = uiputfile({'*.mgh'} ,'Save as .mgh  ( Freesurfer)', name);
                    fullPath=[path file]; 
                    disp([ 'Saving MGH/MGZ from path=' fullPath ]);
                    [path,name,ext] = fileparts([fullPath]); 
                    mri=handles.image.mri;  % recall saved mri struct
                    mri.vol=handles.image.Cdata;

                    % Set pixel dimensions
                        mri.xsize=handles.image.pixelSizeX;
                        mri.ysize=handles.image.pixelSizeY;
                        mri.zsize=handles.image.sliceSpacing;    
                        mri.volsize=size(handles.image.Cdata);
                        mri.nframes=size(handles.image.Cdata,4);

                    % Save data



    %                     outfile = ['JAN' ts{1} '.nii'];       % Make name for nii file (also gives instruction to create nifti)
    %                     MRIwrite(temp, outfile, 'float'); % Save nifti (because file extension .nii)




                        %MRIwrite(mri,fullPath ,'int');
                        disp(['Writing to:' fullPath]);
                        MRIwrite(mri,fullPath ,'float');  % Writes mgh (but will call it mgz if that is selected from uiputdlg)
                        % Make mgz, if that was selected
                        if strcmp( '.mgz', ext)
                           gzip( fullPath);
                           movefile( [fullPath '.gz'], fullPath);
                        end
            function LocalSaveNifti(handles, tempData)

                    % New file name
                        suggestedFileName=get(handles.figure1, 'Name');
                        cleanedFileName=regexprep(suggestedFileName, '[*"/[]:;|=\\]', '_');  % Avoid characters that are not accepted in Windows file names
                        [path,name,ext] = fileparts([cleanedFileName]);


                        if strcmp(handles.image.fileType,'ANALYZE') || strcmp(handles.image.fileType,'NIFTY_TWOFILES')
                            [file,path] = uiputfile(['*.hdr'] ,'Save as .hdr AND .img file', name);
                        end
                        if strcmp(handles.image.fileType,'NIFTY_ONEFILE')
                            [file,path] = uiputfile(['*.nii'] ,'Save as .nii file', name);
                        end

                        if file==0 
                            error('imlook4d/LocalSaveNifti:ERROR') 
                        end   

                        destination=[path file];


                    % Setup struct
                        nii=handles.image.nii;
                        nii.img=tempData;
                        nii.hdr.dime.dim= nii.hdr.dime.dim;
                        nii.hdr.dime.dim(2)=size(tempData,1);
                        nii.hdr.dime.dim(3)=size(tempData,2);
                        nii.hdr.dime.dim(4)=size(tempData,3);
                        nii.hdr.dime.dim(5)=size(tempData,4);

                        % Make 3D if required
                        if (nii.hdr.dime.dim(5)==1) nii.hdr.dime.dim(1)=3;end

                        % Set output format to float
                        nii.hdr.dime.datatype=16;
                        nii.hdr.dime.bitpix=32;
                        % Set output format signed short
                        %nii.hdr.dime.datatype=4;
                        %nii.hdr.dime.bitpix=16;

                        if strcmp(handles.image.openingMode,'load_nii')
                            save_nii(nii, destination);
                        end

                        if strcmp(handles.image.openingMode,'load_untouch_nii')
                            save_untouch_nii(nii, destination);
                        end                    
            function LocalSaveAnalyze(handles, matrix)

                    % New file name
                        suggestedFileName=get(handles.figure1, 'Name');
                        cleanedFileName=regexprep(suggestedFileName, '[*"/[]:;|=\\]', '_');  % Avoid characters that are not accepted in Windows file names
                        [path,name,ext] = fileparts([cleanedFileName]);

                        [file,path] = uiputfile(['*.hdr'] ,'Save as .hdr AND .img file ( unmodified header and matrix)', name);

                        if file==0 
                            error('imlook4d/LocalSaveAnalyze:ERROR') 
                        end

                   % Copy header file from original
                        destination=[path file];
                        copyfile(handles.image.headerFile, destination,'f')
                        disp(['Copying Analyze header file='  destination ]);
                        displayMessageRow(['Copying Analyze header file='  destination ]);
                        fclose('all');

                   % Manipulate copied file header
                        machineFormat=handles.image.machineformat;
                        fileattrib( destination, '+w')
                        fid1 = fopen(destination, 'r+');

                        % Number format
                        fseek(fid1, 70, 'bof');
                        fwrite(fid1, 16 ,'int16',0, machineFormat); % 16=Float 

                        % Write matrix size
                        fseek(fid1, 42, 'bof');
                        dimensions=[ size(matrix,1) size(matrix,2) size(matrix,3) size(matrix,4)]
                        fwrite(fid1, dimensions,'int16',0, machineFormat); 

                        fclose(fid1);

                   % Save image file (assuming zero offset to data in file)
                        [path,name,ext] = fileparts([path file]);
                        destination=[path filesep name '.img'];
                        disp(['Writing Analyze image file='  destination ]);

                        displayMessageRow(['Writing Analyze image file='  destination ]);

                        % Write transposed image matrices (because opened that way)
                        fid=fopen(destination,'w');     
                        for i=1:size(matrix,3)*size(matrix,4)
                            %fwrite(fid,matrix(:,:,i), handles.image.valueType);
                            fwrite(fid,matrix(:,:,i), 'float');
                        end
                        fclose(fid);
                        disp('DONE writing ANALYZE file');
                        displayMessageRow(['DONE writing ANALYZE file'   ]);    
            function LocalSaveECAT(handles, Data)
                 % Save Data and header as .v file
                 %
                 % The headers and ECATDirStruct are updated according to
                 % - values in handles.image.time
                 % - values in handles.image.duration
                 % - number of frames (i.e. size(Data,4)  )
                 %                 

                 numberOfFrames=size(Data,4);
                 disp(['Number of frames=' num2str(numberOfFrames) ]);


                 % Modify ECAT main header from dialog
                 mainHeader=handles.image.mainHeader;
                 %mainHeader=modifyECATHeader(mainHeader);  % I don't think this is useful   

                 %
                 % Make static if matrix has fewer dimensions than before (after models, such as Patlak)
                 %
                      if (numberOfFrames==1)
                            disp('STATIC image');
                            byte=328;length=2;handles.image.mainHeader(byte+1:byte+length)=[0 3]; % Set static mode
                            byte=354;length=2;handles.image.mainHeader(byte+1:byte+length)=[0 1]; % Set 1 frame
                            handles.image.ECATDirStruct(9:end)=0; % Make directory structure reflect one frame
                            handles.image.ECATDirStruct=handles.image.ECATDirStruct(:,1);  % Make directory structure length what is needed for less than 31 frames
                      else
                           disp('DYNAMIC image');
                           byte=354;length=2;handles.image.mainHeader(byte+1:byte+length)=[0 numberOfFrames]; % Set number of frames
                      end

                 %----------------------------------  
                 %
                 % Modify directory structure to reflect number of frames
                 %

                    % Base it on old directory structure, by copying directory structure frame by frame.
                        newPETDirStruct=zeros( size(handles.image.ECATDirStruct(:,:) ));    % Make all directory structures zero

                        newPETDirStruct(1,1)=31-numberOfFrames;                             % First directory structure
                        newPETDirStruct(2:4,1)=handles.image.ECATDirStruct(2:4,1);          % First directory structure


                    % Make zero for frames that are not existing
                        PETDirStructNumber=1;  % Number of Directory Structures
                        positionCounter=1;
                        for i=1:numberOfFrames
                            positionCounter=positionCounter+4;  % Move to next position in structure

                            if (i==31*1+1)||(i==31*2+1)||(i==31*3+1)
                                % If end of directory structure,
                                % Move to next directory structure
                                PETDirStructNumber=PETDirStructNumber+1;
                                positionCounter=1;
                                positionCounter=positionCounter+4; 
                            end  

                            % Update directory structure for current frame
                            newPETDirStruct(positionCounter:positionCounter+3,PETDirStructNumber)=...
                                handles.image.ECATDirStruct(positionCounter:positionCounter+3,PETDirStructNumber);
                        end


                    % Fix last record to point to first record
                        % newPETDirStruct(1,PETDirStructNumber) % I don't know the function of this, but it works
                        newPETDirStruct(2,PETDirStructNumber)=2;  % Point to first record of first directory structure
                        %newPETDirStruct(3,PETDirStructNumber)  % Points to previous directory structure.  This is unaffected
                        newPETDirStruct(4,PETDirStructNumber)=numberOfFrames-(PETDirStructNumber-1)*31;  % Number of frames in last directory structure

                        handles.image.ECATDirStruct=newPETDirStruct;  % Copy new directory structure to old directory structure


                 %----------------------------------    
                 %
                 % ECAT subheaders - Update times and duration in 
                 %         
                        for i=1:numberOfFrames

                           % Start time of frame
                                hexValue=uint32_to_hex(1000*handles.image.time(i) );    % ms-Time in hexadecimal notation
                                byte=50;length=1;
                                handles.image.subHeader(byte+1:byte+length, i)              =hex_to_uint8( hexValue(1:2) ); % Write each byte
                                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)  =hex_to_uint8( hexValue(3:4) );
                                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)  =hex_to_uint8( hexValue(5:6) );
                                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)  =hex_to_uint8( hexValue(7:8) );
                                %disp(['Time=' num2str(1000*handles.image.time(i) )    '    hexvalue=' hexValue '    Header value=' num2str( ECAT_readHeaderInt4(handles.image.subHeader(:,i), 50)  ) 'ms']);

                           % Duration of frame
                                hexValue=uint32_to_hex(1000*handles.image.duration(i) );    % ms-Duration in hexadecimal notation
                                byte=46;length=1;
                                handles.image.subHeader(byte+1:byte+length, i)              =hex_to_uint8( hexValue(1:2) ); % Write each byte
                                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)  =hex_to_uint8( hexValue(3:4) );
                                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)  =hex_to_uint8( hexValue(5:6) );
                                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)  =hex_to_uint8( hexValue(7:8) );

                                %disp([num2str(i) '   SCRIPTS/SumFrames ECAT header Frame start time=' num2str( ECAT_readHeaderInt4(handles.image.subHeader(:,i), 50)  ) 'ms']);
                                %disp([num2str(i) '   SCRIPTS/SumFrames ECAT header Frame duration=' num2str( ECAT_readHeaderInt4(handles.image.subHeader(:,i), 46)  ) 'ms']);
                                %disp(' ');
                        end

                 %----------------------------------    
                 %
                 % Save ECAT file   
                 %

                    %[file,path] = uiputfile(['filename' '.v'] ,'Save as .v file ( matrix and header)');
                    suggestedFileName=get(handles.figure1, 'Name');
                    cleanedFileName=regexprep(suggestedFileName, '[*"/[]:;|=\\]', '_');  % Avoid characters that are not accepted in Windows file names

                    [file,path] = uiputfile(['*.v'] ,'Save as .v file ( matrix and header)', cleanedFileName);

                    if file==0 
                        error('imlook4d/SaveECAT_Callback:ERROR') 
                    end


                    fullPath=[path file];
                    disp(['Writing ECAT-file='  path file ]);  
                    
                    % Swap head and feet
                    Data=flipdim(Data,3);


                    % Save ECAT
                    unit=handles.image.unit;
                    disp(['UNIT="' unit '"']);
                    %unit='test';

                        disp('Writing dynamic ECAT - filtered images');
                            WriteECAT( fullPath, ...
                                Data,...
                                mainHeader, ...
                                handles.image.subHeader, ...
                                handles.image.ECATDirStruct, ...
                                unit)...
                                ;    


                    disp('Finished writing ECAT file');
            function mainHeader=modifyECATHeader(mainHeader)   


             % Modify ECAT main header


                prompt={'Patient ID: (16 chars)',...
                        'Patient name: (32 chars)',...
                        'Study Type: (12 chars)',...
                        'Study Description (32 chars):',...
                        'User Process Code (10 chars):'};
                title='ECAT main header scan info';
                numlines=1;
                defaultanswer={char( mainHeader(166+1:166+16))',...
                        char( mainHeader(182+1:182+32))',...
                        char( mainHeader(154+1:154+12))',...
                        char( mainHeader(296+1:296+32))',...
                        char( mainHeader(434+1:434+10))'};
                answer=inputdlg(prompt,title,numlines,defaultanswer);

                % Display

                byte=166;length=16; disp([ num2str(mainHeader(byte+1:byte+length)) mainHeader(byte+1:byte+length)]' );disp('-----');
                byte=182;length=32; disp([ num2str(mainHeader(byte+1:byte+length)) mainHeader(byte+1:byte+length)]' );disp('-----');
                byte=154;length=12; disp([ num2str(mainHeader(byte+1:byte+length)) mainHeader(byte+1:byte+length)]' );disp('-----');
                byte=296;length=32; disp([ num2str(mainHeader(byte+1:byte+length)) mainHeader(byte+1:byte+length)]' );disp('-----');
                byte=434;length=10; disp([ num2str(mainHeader(byte+1:byte+length)) mainHeader(byte+1:byte+length)]' );disp('-----');

                % Convert
                oldString=answer{1};
                byte=166;length=16; newString=[ oldString repmat(char(0),1,length)];newString=newString( 1:length);
                mainHeader(byte+1:byte+length)=newString;

                oldString=answer{2};
                byte=182;length=32; newString=[ oldString repmat(char(0),1,length)];newString=newString( 1:length);
                mainHeader(byte+1:byte+length)=newString;

                oldString=answer{3};
                byte=154;length=12; newString=[ oldString repmat(char(0),1,length)];newString=newString( 1:length);
                mainHeader(byte+1:byte+length)=newString;

                oldString=answer{4};
                byte=296;length=32; newString=[ oldString repmat(char(0),1,length)];newString=newString( 1:length);
                mainHeader(byte+1:byte+length)=newString;

                oldString=answer{5};
                byte=434;length=10; newString=[ oldString repmat(char(0),1,length)];newString=newString( 1:length);
                mainHeader(byte+1:byte+length)=newString;
            function LocalSaveDICOM(handles, matrix)
                
                        % Fix DICOM y-axis
                            matrix=imlook4d_fliplr(matrix);  % Flip row vector (which is the y direction of the matrix)
                
                        % Remove out of range values
                            matrix(isnan(matrix)) = 0;
                            matrix(isinf(matrix)) = 0;

                        % Read stored information
                            rows=size(matrix,2);
                            cols=size(matrix,1);

                            headers=handles.image.dirtyDICOMHeader;
                            matrix=reshape(matrix,rows,cols,[]);  % Matrix reshaped to 3D matrix (x,y,file nr) 

                            fileNames=handles.image.dirtyDICOMFileNames;
                            %indecesToScaleFactor=handles.image.dirtyDICOMIndecesToScaleFactor;
                            mode=handles.image.dirtyDICOMMode;

                        % USER INPUT:  Modify Patient ID, Patient Name, Series Description

                            try
                                % Get struct ,where patientName1.string is the
                                % string itself
                                try 
                                    patientName1=dirtyDICOMHeaderData(headers, 1,'0010', '0010',mode); 
                                catch
                                    patientName1.string=''
                                end
                                try  
                                    patientID1=dirtyDICOMHeaderData(headers, 1,'0010', '0020',mode);
                                catch
                                    patientID1.string='' 
                                end
                                try  
                                    seriesDesc1=dirtyDICOMHeaderData(headers, 1,'0008', '103E',mode);
                                catch
                                    seriesDesc1.string=''
                                end
                                try  
                                    accessionNumber=dirtyDICOMHeaderData(headers, 1,'0008', '0050',mode);
                                catch
                                    accessionNumber.string='';
                                end
                                seriesNo1=dirtyDICOMHeaderData(headers, 1,'0020', '0011',mode);

                                defaultSeriesDescription=[ handles.image.history ' ' seriesDesc1.string];

                                prompt={'Patient Name: ',...
                                        'Patient ID: ',...
                                        'Series Description: ',...
                                        'Series number',...
                                        'Accesion number'};
                                title='Modify DICOM header info';
                                numlines=1;
                                defaultanswer={patientName1.string,patientID1.string, defaultSeriesDescription ,seriesNo1.string, accessionNumber.string};
                                answer=inputdlg(prompt,title,numlines,defaultanswer);
                                % Strings containing the patientName etc
                                patientName=answer{1};
                                patientID=answer{2};
                                seriesDesc=answer{3};
                                seriesNo=answer{4};
                                accessionNumberString=answer{5};
                            catch
                            end

                        % USER INPUT:  Modify DICOM mode (commented out)

                            defaultanswer{1}=handles.image.dirtyDICOMPixelSizeString;
                            defaultanswer{2}=handles.image.dirtyDICOMSlicesString;
                            defaultanswer{3}=handles.image.dirtyDICOMMachineFormat;
                            answer=defaultanswer;

                            % Input pixels and slices
    %                         prompt={'Pixels',...
    %                                 'Slices',...
    %                                 'Byte order - b or l (little L)'};
    %                         title='Input data dimensions';
    %                         numlines=1;
    %                         answer=inputdlg(prompt,title,numlines,defaultanswer);
    % 
                             ByteOrder=answer{3};

                        % Calculate DICOM volume's min and max
                            volumeMax=max(matrix(:));
                            volumeMin=min(matrix(:));


                        % Get new file paths
                            suggestedDirName=get(handles.figure1, 'Name');
                            cleanedDirName=regexprep(suggestedDirName, '[*"/[]:;|=\\]', '_');  % Avoid characters that are not accepted in Windows file names

                            % Create new directory describing DICOM file
                            previousDirectory=pwd();
                            cd .. 
                            guessedDirectory=pwd();
                            %%guessedDirectory=[previousDirectory filesep cleanedDirName];
                            %%mkdir(previousDirectory,cleanedDirName);        % Guess a directory
                            %%cd(guessedDirectory);                           % Go to guessed directory (uigetdir will be placed here)                

                           %newPath=uigetdir(guessedDirectory,'Select directory to save files to');
                          %newPath=java_uigetdir(guessedDirectory,'Make an empty directory to save all DICOM files within'); % Use java directory open dialog (nicer than windows)
                          newPath=java_uigetdir(previousDirectory,'Select/create directory to save files to'); % Use java directory open dialog (nicer than windows)
                          
                          % Make directory if not existing
                          fn = fullfile(newPath);
                          if ~exist(fn, 'dir')
                              disp(['Make directory = ' newPath ]);
                              mkdir(fn);
                          end

                            try
                                cd(newPath);                                    % Go to selected directory
                            catch
                                try
                                    mkdir(newPath);
                                catch
                                    error(['imlook4d ERROR - failed creating directory' newPath]);
                                end
                            end

                            if( ~strcmp( guessedDirectory,newPath) )                   % If guessed wrong directory
                                try
                                    rmdir([previousDirectory filesep cleanedDirName])
                                catch
                                end
                            end




    %                         newPath=uigetdir(pwd(),'Select directory to save files to');
    %                         cd(newPath);



                        % Modify headers

                            iNumberOfSelectedFiles = size(headers,2);
                            iNumberOfSelectedFiles=size(matrix,3);  % This definition allows for truncated matrices, as for instance from Patlak model


                            seriesInstanceUID=generateUID();
                             for i=1:iNumberOfSelectedFiles
                                 %disp(i)

                                 % Change image properties
                                     headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008', '0008',mode, 'DERIVED\SECONDARY'); % ImageType
                                     headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008' ,'2111',mode, 'imlook4d - not for clinical use'); % Derivation Description


                                 % Set scale factors (Fails if scale factor not existing)
                                 try

                                    % Get indeces to header
                                        scaleFactor=dirtyDICOMHeaderData(headers, i, '0028', '1053',mode);
                                        intercept=dirtyDICOMHeaderData(headers, i, '0028', '1052',mode);

                                    %Calculate scale factor
                                        maxval = max(max(abs(matrix(:,:,i))));  %Maximum absolute value in image.
                                        scale_factor = maxval/32767;
                                        scale_factor=1.01*scale_factor;   % Play it safe

                                        %%%scale_factor=1;

                                        valueString=num2str(scale_factor);

                                    % Find out scaling to use for matrix data, assuming zero intercept
                                         scale_factor=str2num(valueString);  % This is a smaller value due to truncation of decimals in scale factor

                                    % Divide by scale factor
                                        matrix(:,:,i) = matrix(:,:,i)./scale_factor;  %Divide by scale factor.     

                                    % Slope + Intercept   
                                        headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0028', '1053',mode, valueString);
                                        headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0028', '1052',mode, '0');
                                 catch
                                        disp('caught error in imlook4d/LocalSaveDICOM - scale factor problem');
                                 end


                                % Pixel representation (Make it signed) 
                                try
                                    headers{i}=dirtyDICOMModifyHeaderUS(headers{i}, '0028', '0103',mode, 1); % Make signed (0=unsigned)
                                catch
                                end

                                % Pixels (Value representation US)
                                    headers{i}=dirtyDICOMModifyHeaderUS(headers{i}, '0028', '0010',mode, rows); % rows
                                    headers{i}=dirtyDICOMModifyHeaderUS(headers{i}, '0028', '0011',mode, cols); % columns

                                    % Set value length for image (7FE0,0010)
                                    goalValueLength=2*rows*cols;
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '7FE0', '0010',mode, num2str(goalValueLength)); % New valuelength for image

                                    % Set pixel size
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0028', '0030',mode, [ num2str(handles.image.pixelSizeX) '\' num2str(handles.image.pixelSizeY)]);


                                % Unit
                                    try
                                        headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0054', '1001',mode, handles.image.unit);  % Unit
                                        headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0028', '1054',mode, handles.image.unit);  % Rescale type (unit after rescale slope/intercept is applied)
                                    catch end

                                % UIDs
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0020', '000E',mode, seriesInstanceUID);  % Series Instance UID

                                    SOPInstanceUID=generateUID();
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008', '0018',mode, SOPInstanceUID);      % SOP Instance UID
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0002', '0003',mode, SOPInstanceUID);      % Media Storage UID

                                 % Patient 
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0010', '0010',mode,patientName); 
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0010', '0020',mode,patientID); 

                                 % Series 
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008', '103E',mode,seriesDesc);              % Study number
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0020', '0011',mode, seriesNo);

                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008', '0050',mode, accessionNumberString);

                                 % File names
                                    %newFileNames{i}=SOPInstanceUID;
                                    newFileNames{i}=num2str(i);



                                 % TO DO - 
                                 % number of images
                                 % instance number
                                 % image position

                                 % Make static
                                 if size(matrix,4)==1
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0054', '1000',mode, 'STATIC\IMAGE');  % Series Type
                                    headers{i}=dirtyDICOMModifyHeaderUS(headers{i}, '0054', '0101',mode, 1);  % Number of Time Slices
                                 end

                                 %
                             end

                        % If multiple images in one dicom file, reshape
                            %if size(fileNames,2)~=size( unique(fileNames),2 )   % Multiple images in the same file is characterized by having the same file name for each slice
                            if size( unique(fileNames),2 )==1   % Multiple images in the same file is characterized by having the same file name for each slice
                              matrix=matrix(:);

                               %tempFileName=fileNames(1);
                               tempFileName=newFileNames(1);
                               fileNames=0;
                               fileNames=tempFileName;

                               tempHeader=headers(1);
                               headers=0;
                               headers=tempHeader;

                               iNumberOfSelectedFiles=1;

                               % Set value length for image (7FE0,0010)
                               i=1;
                               headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '7FE0', '0010',mode, num2str(length(matrix)*2 )); % New valuelength for image
                            end


                        % Write to DICOM
                            % This function reuses file names (good for traceability)

                            %Dirty_Write_DICOM(matrix, headers(1:iNumberOfSelectedFiles), fileNames(1:iNumberOfSelectedFiles), ByteOrder);
                            Dirty_Write_DICOM(matrix, headers(1:iNumberOfSelectedFiles), newFileNames(1:iNumberOfSelectedFiles), ByteOrder);

                        % Clean up
                            cd('..');   % Move out of DICOM directory
                        
   % Save State
        function SaveMat_Callback(hObject, eventdata, handles)
             % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end
         % Save Data and header as .mat file
         %
         % Flip and rotate, and swap head-feet are performed on Save according
         % to radio buttons
         %
            try  
                [file,path] = uiputfile(['filename' '.mat'] ,'Save as .mat file (only matrix, no header)');
                fullPath=[path file];
                disp(['Writing matlab-file='  path file ]);  
                %disp([path file ]);
                Data=single(handles.image.Cdata);  % Single is enough for PET data, gives half the file size

    %             % Rotate and flip 
    %             if get(handles.FlipAndRotateRadioButton,'Value') 
    %                 disp('START Flip and rotate of images');
    %                 
    %                 slices= size(handles.image.Cdata,3);
    %                 frames= size(handles.image.Cdata,4);
    %                 
    %                 for i=1:slices
    %                     for j=1:frames
    %                         Data(:,:,i,j)=orientImage(Data(:,:,i,j));
    %                     end
    %                 end
    %                 disp('END Flip and rotate of images');
    %             end

                %save(fullPath, 'Data', 'header');


                % Get time and duration
                try
                    time=handles.image.time;
                    duration=handles.image.duration;
                catch
                    disp('imlook4d/Savemat_Callback:ERROR time or duration not available');
                end

                % Save mat file
                % Try the following alternatives:
                %   1) Data, time, and duration
                %   2) Data, time
                %   3) Data

                try % 1)
                    save(fullPath, 'Data','time', 'duration');
                catch 
                    disp('imlook4d/Savemat_Callback:ERROR did not save duration (maybe was not available)');
                    try % 2) 
                        save(fullPath, 'Data','time');
                    catch % 3)
                        save(fullPath, 'Data');
                        disp('imlook4d/Savemat_Callback:ERROR did not save time (maybe was not available)');
                    end
                end

                % Save 2D time and duration (for each slice and frame)
                %
                try
                    disp('Appending time2D');
                    time2D=handles.image.time2D;
                    save(fullPath, '-append', 'time2D');
                catch
                    disp('imlook4d/Savemat_Callback:ERROR  Failed appending time2D');
                end

                try
                    disp('Appending duration2D');
                    time2D=handles.image.time2D;
                    save(fullPath, '-append', 'duration2D');
                catch
                    disp('imlook4d/Savemat_Callback:ERROR  Failed appending duration2D');
                end


                % Save ECAT headers
                %
                try
                    disp('Appending ECAT headers');
                    subHeader= handles.image.subHeader;
                    mainHeader=handles.image.mainHeader;
                    dirstruct= handles.image.ECATDirStruct;

                    disp('Sizes subHeader mainHeader dirstruct');
                    size(handles.image.subHeader)
                    size(handles.image.mainHeader)
                    %size(handles.image.dirstruct)

                    save(fullPath, '-append', 'subHeader', 'mainHeader', 'dirstruct');
                catch
                    disp('imlook4d/Savemat_Callback:ERROR  Failed appending ECAT headers');
                end


                % Save DICOM headers
                %
                try
                    disp('Appending DICOM headers');
                    DICOMHeader=handles.image.DICOMHeader;

                    save(fullPath, '-append', 'DICOMHeader');
                catch
                    disp('imlook4d/Savemat_Callback:ERROR  Failed appending DICOM headers');
                end           

                % Save isotope half time
                %
                try
                    disp('Appending halflife');
                    halflife=handles.image.halflife;
                    save(fullPath, '-append', 'halflife');
                catch
                    disp('imlook4d/Savemat_Callback:ERROR  Failed appending isotope halflife');
                end

                % Save file type
                %
                try
                    disp('Appending file type ');
                    fileType=handles.image.fileType;
                    save(fullPath, '-append', 'fileType');
                catch
                    disp('imlook4d/Savemat_Callback:ERROR  Failed appending fileType');
                end    
                
                 try
                    pixel_dims=[handles.image.pixelSizeX handles.image.pixelSizeY handles.image.sliceSpacing];
                    save(fullPath, '-append', 'pixel_dims');
                 catch
                    disp('imlook4d/Savemat_Callback:ERROR  Failed appending pixel_dims');
                 end 
                
%                 try
%                     handles_image=handles.image;
%                     save(fullPath, '-append', 'handles_image');
%                  catch
%                     disp('imlook4d/Savemat_Callback:ERROR  Failed appending fileType');
%                 end 
%                 
%                 try
%                     handles_model=handles.model;
%                     save(fullPath, '-append', 'handles_model');
%                 catch
%                     disp('imlook4d/Savemat_Callback:ERROR  Failed appending fileType');
%                 end                    
            catch
                disp(['imlook4d/Savemat_Callback:ERROR Save Data was not completed']);
            end  
            
    % Load ROI
       function LoadRoiPushbutton_Callback(hObject, eventdata, handles, fullPath)
            % Display HELP and get out of callback
            if DisplayHelp(hObject, eventdata, handles) 
                return 
            end
            
            % Make axial     
                handles = resetOrientation(handles);
                
            % GUI input
            
            if nargin==3
            % Dialog option
               % [file,path] = uigetfile('*.mat;*.roi','ROI Open file name');
                [file,path] = uigetfile( ...
                            {'*.mat;*.roi','imlook4d ROI'; ...
                             '*.nii', 'ROI from Nifti'  } ...
                           ,'ROI Open file name');
                
                fullPath=[path file];
                %load(fullPath,'-mat');
                cd(path);
            end

 
                        
            % No GUI input
            
            if nargin==4
                %load(fullPath,'-mat');
                cd(pathstr);
            end   

            
            % Put ROI in rois
            [pathstr,name,ext] = fileparts(fullPath) 
            
            if strcmp(ext,'.roi')|| strcmp(ext,'.mat')
                load(fullPath,'-mat');
            end         
            
            if strcmp(ext,'.nii')
                nii = load_nii(fullPath);
                rois= nii.img;
                roiSize = size(rois);
                
                %roiNames
                pixelValues = unique(rois);
                roiNames={};
                for i=1:length(pixelValues)
                    if ( pixelValues(i) ~= 0)
                        value = pixelValues(i);
                        roiNames{end+1} =num2str(value);
                    end
                end
                
                % Visible and locked ROIs
                handles.image.VisibleROIs(1:length(roiNames)-1)=1;
                handles.image.LockedROIs(1:length(roiNames)-1) = 0; 
            end 

            handles.image.ROI= reshape(uint8(full(rois)), roiSize); % Make (sparse double 1D) matrix to (int 8 4D) matrix 
            
%             % Flip y if old ROI format
%             if strcmp(ext,'.roi')|| strcmp(ext,'.mat')
%                 % DICOM files before version variable was introduced were upside down
%                 % No version variable, means DICOM files  were upside down.  
%                 % Hence, reverse ROI if no version variable
%                 if ~exist('version','var')
%              %   	handles.image.ROI = imlook4d_fliplr(handles.image.ROI);
%                 end 
%             end   
            

            % Make ROIs with correct head-feet swapping
            %if( get(handles.SwapHeadFeetRadioButton, 'Value')==1)
            %    handles.image.ROI=flipdim(handles.image.ROI,3);
            %end
            
            % Bail out if ROI doesn't match image
            roiSize = size(handles.image.ROI);
            imageVolumeSize = size(handles.image.Cdata(:,:,:,1) );
            if ( ~isequal( roiSize, imageVolumeSize ) )
                displayMessageRowError( ['ERROR -- ROI size wrong -- Image=[' num2str(imageVolumeSize) '] ROI=[' num2str(roiSize) ']' ] );
                return
            end
            
            

            set(handles.ROINumberMenu,'String', roiNames);
            set(handles.ROINumberMenu,'Value', size(roiNames,2) ); %Set to highest ROI number
            try
                handles.image.VisibleROIs=VisibleROIs;
            catch
                handles.image.VisibleROIs=[1:length(roiNames)-1];
            end
            
            % Visible ROIs are saved
            if ~exist('VisibleROIs','var')
                handles.image.VisibleROIs(1:length(roiNames)-1)=1;
            end
            
            % Locked ROIs are not saved
                handles.image.LockedROIs(1:length(roiNames)-1) = 0;           
            
            
            %handles.image.VisibleROIs=[1:size(roiNames,1)-1];  % Set all ROIs to visible
            guidata(handles.ROINumberMenu,handles);  % Save handles

            updateImage(hObject, eventdata, handles);                  
    % Save ROI
        function SaveRoiPushbutton_Callback(hObject, eventdata, handles)
                 % Display HELP and get out of callback
                     if DisplayHelp(hObject, eventdata, handles) 
                         return 
                     end
                     
                % Make axial     
                handles = resetOrientation(handles);

                [file,path] = uiputfile('ROIs.roi','ROI Save file name');
                fullPath=[path file];
                cd(path);
                rois=sparse(double(handles.image.ROI(:)));

                % Always save ROIs
                % in state without flipping of head-feet direction
                if( get(handles.SwapHeadFeetRadioButton, 'Value')==1)
                    rois=flipdim(handles.image.ROI,3);
                    rois=sparse(double(rois(:)));
                end

                roiNames=get(handles.ROINumberMenu,'String'); % Cell array
                roiSize=size(handles.image.ROI); % Array
                
                VisibleROIs=handles.image.VisibleROIs;
                
                try
                   version = getImlook4dVersion(); 
                catch
                   version = [];
                end
                    
                

                save(fullPath, 'rois', 'roiNames', 'roiSize','VisibleROIs', 'version' );
                             
% Print image
        function Print_Image_Callback(hObject, eventdata, handles)
            DISPLAY_ON_SCREEN = true;
            GenerateScreenDump(hObject, eventdata, handles,DISPLAY_ON_SCREEN);
            printpreview(gcf);
            close(gcf);
            
   % Close window(s)        
        function Close_many_Callback(hObject, eventdata, handles)
         % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        
        % Find figures
            g=findobj('Type', 'figure');
            
        % Show only figures and imlook4d instances
            j=1;
            for i=1:size(g)
                % Mark current window with a checkbox
                if ( strcmp( get(g(i),'Tag'), 'imlook4d' ) || strcmp( get(g(i),'Tag'), '' ) )
                     h(j,1) = g(i);
                     get(h(j),'Tag')
                     j = j+1;
                end
            end      
           % h=g;

        % Create html-formatted list of windows
            [windowDescriptions h]= htmlWindowDescriptions(h);  % Sorted html list
        
        % Find index to current window
            thisWindow=1;
            for i=1:size(h)
                % Mark current window with a checkbox
                if (h(i) == handles.figure1)
                     thisWindow=i;
                end
            end
            
        % Display list
            [s,v] = listdlg('PromptString','Select windows to close:',...
                'SelectionMode','multiple',...
                'ListSize', [700 400], ...
                'ListString',windowDescriptions,...
                'InitialValue', thisWindow);
            

        % Close selected windows
            for i=1:size(s,2)
                close( h(s(i)) );
            end

    % --------------------------------------------------------------------
    % EDIT 
    % --------------------------------------------------------------------
    % Copy Image
        function Copy_Image_Callback(hObject, eventdata, handles)
            GenerateScreenDump(hObject, eventdata, handles,false);
            function GenerateScreenDump(hObject, eventdata, handles,DISPLAY_ON_SCREEN)
            
            % Display clipboard on screen?
              %DISPLAY_ON_SCREEN=false;
              %DISPLAY_ON_SCREEN=true;
              
            % Display HELP and get out of callback
               if DisplayHelp(hObject, eventdata, handles) 
                   return 
               end
 
            % New figure
            h1=figure('Visible','off','NumberTitle','off','Name', 'Clipboard');         % New HIDDEN figure
            if DISPLAY_ON_SCREEN
                set(h1,'Visible','on');
            end
            
            % Copy axes
            copyobj(handles.axes1,h1); % Hx(2) is one of the axes objects on your
            
            % Copy colorbar
            colormap( colormap(handles.axes1) );% Copy current colormap to current figure
            colorBarHandle=colorbar('FontSize', 9);            % Display
            
            
            % Set size in new figure
            c=get(h1,'Children');
            set(c(2),'Unit','normalized')
            set(c(2),'Position', [ (0.05-0.05) 0.05 0.9 0.9] ) % Subtract 0.05 for approximate width of color bar
            
            %pos1=get(c(1),'Position'); % Colorbar
            %pos2=get(c(2),'Position'); % Image

           % set(h1,'PaperPositionMode','auto')
            %print(h1,'-dbitmap')
            
            try
                print(h1,'-clipboard','-dbitmap')
            catch
                print(h1,'-dmeta')
            end
            
            if ~DISPLAY_ON_SCREEN
                close(h1)
            end            
                            
    % Copy TACT to Clipboard                     
        function copy_TACT_to_clipboard_Callback(hObject, eventdata, handles)
           % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end
                 
                 displayMessageRow('Calculating ...');
                 
                 contents = get(handles.ROINumberMenu,'String'); % Cell array
                 
                  TAB=sprintf('\t');
                  EOL=sprintf('\n');
                  
                 [activity, NPixels, stdev]=generateTACT(handles, handles.image.ROI);

                 N=size(activity,1);  %Number of ROIs
                 M=size(activity,2);  %Number of frames
                 
                 s='';
                 
                 %%for i=1:N % Loop number of ROIs
                 for i=find(handles.image.VisibleROIs) 
                     s=[ s contents{i} TAB];
                 end
                 s=[ s(1:end-1) EOL];
                 
                 for j=1:M % Loop number of frames
                     %for i=1:N % Loop number of ROIs
                     for i=find(handles.image.VisibleROIs) 
                        s=[ s num2str(activity(i,j)) TAB];
                     end
                     s=[ s(1:end-1) EOL];
                 end
                 
                 disp(s)

                 clipboard('copy',s)  
                 
                 displayMessageRow('Done!');
       
    % Window Title            
        function Edit_window_title_Callback(hObject, eventdata, handles)
            % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end

            % Input dialog texts     
                prompt={'New window title'};
                title='Edit window title'; 
                defaultanswer={ get(handles.figure1, 'Name') };

            % Define size of text field
                numlines=1; 
                extraChars=12;  % Number of extra charactes that fit the dialog (over the current window title length)
                width=50;       % Default max length
                
                % Extend text field if needed
                if length(defaultanswer{1})>width
                    width=length(defaultanswer{1});
                end
                numCols=width+extraChars;

            % Show dialog, and set window title    
                answer=inputdlg(prompt,title,[numlines  numCols ],defaultanswer);
                set(handles.figure1, 'Name', answer{1});
                
    % Matlab menu
        function MatlabMenu_Callback(hObject, eventdata, handles)
             % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end

            %get(handles.figure1);

            if  strcmp( get(handles.figure1, 'MenuBar') , 'none'  );
                set(handles.figure1, 'MenuBar', 'figure');
                set(handles.MatlabMenu, 'Checked', 'on');
            else
                set(handles.figure1, 'MenuBar', 'none');
                set(handles.MatlabMenu, 'Checked', 'off');
            end    

    % Window-levels submenu   
        % Generated at program start
        function EditScale_Callback(hObject, eventdata, handles,varargin)
         % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
             
         try
            h=handles.ColorBar;  % Get handle to colorbar
            CLim=get(h,'YLim');  % Read limits from current color bar
            slice=round(get(handles.SliceNumSlider,'Value'));
            frame=round(get(handles.FrameNumSlider,'Value'));
            tempData=handles.image.CachedImage;      % Read cached image, Image data (not flipped or rotated)
            disp('drawCursorInYokes2 - Read CachedImage');
            %CLim=[min(tempData(:)) max(tempData(:) )]; % Calculated min and max
            %
            % Dialog for Colorbar
            %
            
            disp('ColorBar_ButtonDownFcn');

            prompt={'Min','Max'};
            title='Set color range';
            numlines=1;
            defaultanswer={...
                num2str(CLim(1)),...
                num2str(CLim(2))...
                };
            if nargin==3
                answer=inputdlg(prompt,title,numlines,defaultanswer);
            else
                answer=varargin{1};
            end

            CLim=[str2num(answer{1})  str2num(answer{2})]; % Convert to numbers

            setColorBar( handles, CLim)
            

        catch
         end
         updateImage(hObject, eventdata, handles)
         
    
    % Color submenu   
        function Color_Callback(hObject, eventdata, handles, functionName)
%            % General callback for all Colormaps in COLORMAPS folder
%            
%            % Determine correct object (dynamically generated callbacks)
%            temp=findobj('Label', functionName);
%            hObject=temp(1);
%            
%            
%            % Checkmarks
%            hColorMenuObjects=get( get(hObject,'Parent'), 'Children');  % All other
%            for i=1:size(hColorMenuObjects)
%                set(hColorMenuObjects(i),'Checked','off')
%            end
%            set(hObject,'Checked','on')
% 
%            
%            
%            %hObject=findobj(handles,'Label', functionName)
%            %set(hObject,'Label', 'Color_Callback');
           
           % Display HELP and get out of callback
           %
           %    This requires a separate help file for each color map
           %    For instance Sokolof.txt
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end
             Color(hObject, eventdata, handles,functionName)
            
            updateImage(hObject, eventdata, handles)
            function Color(hObject, eventdata, handles, functionName)
              % General callback for Colormap in COLORMAPS folder, which
              % has name functionName

               % Determine correct object (dynamically generated callbacks)
               temp=findobj('Label', strrep(functionName,'_', ' '));
               hObject=temp(1);


               % Checkmarks
               hColorMenuObjects=get( get(hObject,'Parent'), 'Children');  % All other
               for i=1:size(hColorMenuObjects)
                   set(hColorMenuObjects(i),'Checked','off')
               end
               set(hObject,'Checked','on')

                % Clean out spaces and replace with "_"
                htable = feval(functionName);
                set(handles.figure1,'Colormap',htable); 
                if handles.imSize(3)> 1 
                %set(handles.SliceNumEdit,'BackgroundColor',[.1 .1 .1],'ForegroundColor','r');
                end
                
                handles.ColormapName = functionName;
                guidata(handles.figure1,handles)

                updateImage(hObject, eventdata, handles)                

    % EDIT/ROI submenu
        function ColorfulROI_Callback(hObject, eventdata, handles)
           % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end
 
           
           % Checkmarks
           hROIObjects=get( get(hObject,'Parent'), 'Children');  % All other
           for i=1:size(hROIObjects)
               set(hROIObjects(i),'Checked','off')
           end
           set(hObject,'Checked','on')

            updateImage(hObject, eventdata, handles)
        function GrayROI_Callback(hObject, eventdata, handles)
           % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end
 
           
           % Checkmarks
           hROIObjects=get( get(hObject,'Parent'), 'Children');  % All other
           for i=1:size(hROIObjects)
               set(hROIObjects(i),'Checked','off')
           end
           set(hObject,'Checked','on')

            updateImage(hObject, eventdata, handles)     
       function GuessRoiColor_Callback(hObject, eventdata, handles)
           
           % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end
 
           
           % Checkmarks
           hROIObjects=get( get(hObject,'Parent'), 'Children');  % All other
           for i=1:size(hROIObjects)
               set(hROIObjects(i),'Checked','off')
           end
           set(hObject,'Checked','on')

           updateImage(hObject, eventdata, handles)   
            
    % Preferences submenu
        function show_patient_info_Callback(hObject, eventdata, handles)

           % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end

           % Toggle Check mark

           if strcmp(get(hObject,'Checked'),'on')
               set(hObject,'Checked','off')
           else
               set(hObject,'Checked','on')
           end
        function interpolate2_Callback(hObject, eventdata, handles)

           % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end

           % Toggle Check mark

           if strcmp(get(hObject,'Checked'),'on')
               set(hObject,'Checked','off')
               set(handles.interpolate4,'Checked','off')
           else
               set(hObject,'Checked','on')
               set(handles.interpolate4,'Checked','off')
           end
           
           % Update image
           updateImage(hObject, eventdata, handles)
           updateROIs(handles)
        function interpolate4_Callback(hObject, eventdata, handles)

           % Display HELP and get out of callback
                 if DisplayHelp(hObject, eventdata, handles) 
                     return 
                 end

           % Toggle Check mark

           if strcmp(get(hObject,'Checked'),'on')
               set(hObject,'Checked','off')
           else
               set(hObject,'Checked','on')
               set(handles.interpolate2,'Checked','off')
           end
           
           % Update image
           updateImage(hObject, eventdata, handles)
           updateROIs(handles)
       
    % Zoom menu        
        function Zoom_Callback(hObject, eventdata, handles)
          % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
             
        % Input dialog texts     
            prompt={'Zoom factor ( formula such as 7/5 is allowed)'};
            title='Input zoom factor (no zoom = 1)'; 
            defaultanswer={ num2str(handles.image.zoomFactorFormula) };
            
        % Define size of text field
            numlines=1; 
            extraChars=12;  % Number of extra charactes that fit the dialog (over the current window title length)
            numCols=size( defaultanswer{1} ,2)+extraChars;
            
        % Show dialog, and set window title    
            %answer=inputdlg(prompt,title,[numlines  numCols ],defaultanswer);
            answer=inputdlg(prompt,title, numlines, defaultanswer);
            handles.image.zoomFactorFormula=answer{1}; %str2num( eval( defaultanswer{1} ))
            updateImage(hObject, eventdata, handles);

%             
%         % Set axes
%              ratio=1/eval(handles.image.zoomFactorFormula);  % Evaluate formula in string
%             
%             
%             % X 
%             pixels=size(handles.image.Cdata,1); 
%             limits=get(handles.axes1,'XLim');   % Current limits
%             origin=( limits(2)-limits(1) )/2;       % Midpoint
%             delta=ratio*pixels/2;               % Distance from midpoint to either limit
% 
%             newLimits=[ origin-delta origin+delta];
%             set(handles.axes1,'XLim', newLimits)
%             
%             % Y 
%             pixels=size(handles.image.Cdata,2); 
%             limits=get(handles.axes1,'YLim');   % Current limits
%             origin=( limits(2)-limits(1) )/2;       % Midpoint
%             delta=ratio*pixels/2;               % Distance from midpoint to either limit
% 
%             newLimits=[ origin-delta origin+delta];
%             set(handles.axes1,'YLim', newLimits)
% 
%             
        % zoom(ratio)    
            zoom out                                           % Zoom to initial state
            zoom(eval(handles.image.zoomFactorFormula) );      % Zoom factor

    % --------------------------------------------------------------------
    % IMTOOLS 
    % -------------------------------------------------------------------- 
    function imHistogram_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
           
        myhistogram(handles,1)
    function imProfile_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
           
        improfile;
    function MontageFrames_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
           
    % Graph images

        % Initialize
            slice=round(get(handles.SliceNumSlider,'Value'));
            frame=round(get(handles.FrameNumSlider,'Value')); 
            numberOfFrames=size(handles.image.Cdata,4);

        % Figure
            scrsz = get(0,'ScreenSize');    %screen coordinates, [left bottom width height]
            figure('Name', ['Montage (slice=' num2str(slice) ')'],...
                'Position',[150 40 scrsz(3)-180 scrsz(4)-100]);

            NCols=5;NRows=ceil(numberOfFrames/NCols);
            GI=1;
                            
                
            for i=1:numberOfFrames  
                subplot(NRows,NCols,GI), imagesc (handles.image.Cdata(:,:,slice,i)); title(['Frame ' num2str(i)],'fontsize',6);GI=GI+1;  
                
                pos = get(gca,'position');set(gca,'position',[pos(1) pos(2) pos(3)*1.2  pos(4)*1.2]); % Make width and height larger
                
                axis('off');
                colormap(jet);
            end
    function MontageSlices_Callback(hObject, eventdata, handles)
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end


        % Initialize
            slice=round(get(handles.SliceNumSlider,'Value'));
            frame=round(get(handles.FrameNumSlider,'Value')); 
            numberOfSlices=size(handles.image.Cdata,3);

        % Figure
            scrsz = get(0,'ScreenSize');    %screen coordinates, [left bottom width height]
            figure('Name', ['Montage (frame=' num2str(frame) ')'],...
                'Position',[150 40 scrsz(3)-180 scrsz(4)-100]);



            NCols=8;NRows=ceil(numberOfSlices/NCols);
            GI=1;     
                
            for i=1:numberOfSlices  
                subplot(NRows,NCols,GI), imagesc (handles.image.Cdata(:,:,i,frame)); title(['Slice ' num2str(i)],'fontsize',6);GI=GI+1;  
                
                pos = get(gca,'position');set(gca,'position',[pos(1) pos(2) pos(3)*1.1  pos(4)*1.1]); % Make width and height larger
                
                axis('off');
                colormap(jet);
                
            end
            
           
            
            
            %
            %TRIAL
            %
                rememberSlice=round(get(handles.SliceNumSlider,'Value'));

%                 for i=1:numberOfSlices  % Flip through slices
%                             set(handles.SliceNumSlider,'Value',i);
%                             updateImage(hObject, eventdata, handles);
%                 end
%
%                 set(handles.SliceNumSlider,'Value',rememberSlice);          % Restore


                % Figure
                scrsz = get(0,'ScreenSize');    %screen coordinates, [left bottom width height]
                figure('Name', ['TEST Montage (frame=' num2str(frame) ')'],...
                    'Position',[150 40 scrsz(3)-180 scrsz(4)-100]);



                NCols=7;NRows=ceil(numberOfSlices/NCols);
                GI=1;     

                for i=1:numberOfSlices  
                    set(handles.SliceNumSlider,'Value',i);
                    updateImage(hObject, eventdata, handles);
                    colorbar('fontsize',6);

                    tempData=get(handles.ImgObject,'Cdata');

                    subplot(NRows,NCols,GI), imagesc(tempData); title(['Slice ' num2str(i)],'fontsize',6);GI=GI+1;  

                    pos = get(gca,'position');set(gca,'position',[pos(1) pos(2) pos(3)*1.1  pos(4)*1.1]); % Make width and height larger

                    axis('off');
                    %colormap(jet);
                    
                end
                
                colorbar('fontsize',6); %Needed to update last colorbar
                drawnow;
                
                set(handles.SliceNumSlider,'Value',rememberSlice);          % Restore   
                
    % --------------------------------------------------------------------
    % WORKSPACE 
    % --------------------------------------------------------------------            
    function WorkspaceMenu_Callback(hObject, eventdata, handles)   
    function exportAsViewedToWorkspace_Callback(hObject, eventdata, handles)
        % This function exports data as viewed

        % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
             

             
       % Generate 4D image according to slice and frame defined in GUI
            tempData=generateImage(handles, 1:size(handles.image.Cdata,3) ,  1:size(handles.image.Cdata,4)); % All slices, all frames
       
       % Export untouched     
         exportToWorkspace_Callback(hObject, eventdata, handles);
         
        % Export imlook4d data "as viewed" to base workspace
        % overwriting previous imlook4d_Cdata
        try 
            assignin('base', 'imlook4d_Cdata', tempData);
        catch
            disp('failed exporting imlook4d_Cdata');
        end;       
    function exportToWorkspace_Callback(hObject, eventdata, handles)
        % This function exports original(untouched) data
        
        
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
        
         TAB=sprintf('\t');
        %disp('Window selected (figure1_ButtonDownFcn)');
        %disp('Set imlook4d_current_handle to current imlook4d instance');
        %disp([ TAB get(hObject,'Name')]);
        
        % Export handles to base workspace
        %assignin('base', 'imlook4d_current_handle', hObject);
        %disp(get(hObject,'Name'));
        %assignin('base', 'imlook4d_current_handle', handles.axes1);
        %disp(get(handles.axes1,'Name'));
        assignin('base', 'imlook4d_current_handle', handles.figure1);
        %disp(get(handles.figure1,'Name'));

        %assignin('base', 'handles', handles);
        assignin('base', 'imlook4d_current_handles', handles);
         
        % Export imlook4d data to base workspace
        %disp('Export handles.image.Cdata to imlook4d_Cdata');
        try 
            assignin('base', 'imlook4d_Cdata', handles.image.Cdata);
        catch
            disp('failed exporting imlook4d_Cdata');
        end;
        
        %disp('Export handles.image.duration to imlook4d_time');
        try 
            assignin('base', 'imlook4d_duration', handles.image.duration); 
        catch
            %disp('failed exporting imlook4d_duration');
        end;
         
        %disp('Export handles.image.time to imlook4d_time');
        try 
            assignin('base', 'imlook4d_time', handles.image.time); 
        catch
            %disp('failed exporting imlook4d_time');
        end;
        
        % Export imlook4d ROIs to base workspace
        %disp('Export handles.image.ROI to imlook4d_ROI');
        try 
            assignin('base', 'imlook4d_ROI', handles.image.ROI); 
        catch
            disp('failed exporting imlook4d_ROI');
        end;
        
        roiNames=get(handles.ROINumberMenu,'String'); % Cell array
        %disp('Export roiNames to imlook4d_ROINames');
        try 
            assignin('base', 'imlook4d_ROINames', roiNames); 
        catch
            disp ('failed exporting imlook4d_ROINames');
        end;

        % Export imlook4d current slice, frame, ROI number to base workspace
        slice=round(get(handles.SliceNumSlider,'Value'));
        frame=round(get(handles.FrameNumSlider,'Value')); 
        selectedROI=get(handles.ROINumberMenu,'Value');
        %disp('Export slice to imlook4d_slice');
        try 
            assignin('base', 'imlook4d_slice', slice); 
        catch
            disp ('failed exporting imlook4d_slice');
        end;
        %disp('Export frame to imlook4d_frame');
        try 
            assignin('base', 'imlook4d_frame', frame); 
        catch
            disp ('failed exporting imlook4d_frame');
        end;        
        %disp('Export ROI number to imlook4d_ROI_number');
        try 
            assignin('base', 'imlook4d_ROI_number', selectedROI); 
        catch
            disp ('failed exporting imlook4d_frame');
        end;
    function importFromWorkspace_Callback(hObject, eventdata, handles,varargin)
        % Imports everything where and letting imlook4d-variables override
        % imlook4d_current_handles
        
               % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
            
        %
        % Import handles structure
        %
           handles=evalin('base', 'imlook4d_current_handles');

        %
        % Overwrite data in handles structure with defined variables in
        % base workspace
        % 
        
         try  
             handles.image.Cdata=evalin('base', 'imlook4d_Cdata');
         catch
             disp('failed importing imlook4d_Cdata');
         end;
         
         %disp('Import handles.image.time from imlook4d_time');
         try 
             handles.image.time=evalin('base', 'imlook4d_time');
         catch
             %disp('failed importing imlook4d_time');
         end;
         
         %disp('Import handles.image.duration from imlook4d_duration');
         try 
             handles.image.duration=evalin('base', 'imlook4d_duration');
         catch
             %disp('failed importing imlook4d_duration');
         end;
         
         % Import imlook4d ROIs from base workspace
         %disp('Import handles.image.ROI from imlook4d_ROI');
         try 
             handles.image.ROI=evalin('base', 'imlook4d_ROI');
         catch
             disp('failed importing imlook4d_ROI');
         end;
         
         
         %disp('Import roiNames to imlook4d_ROINames');
         try 
             roiNames=evalin('base', 'imlook4d_ROINames');
             set(handles.ROINumberMenu,'String', roiNames); 
         catch
             disp('failed importing imlook4d_ROINames');
         end;
         
                 
         % Create ROI status for additional ROIs
         for i = length(handles.image.VisibleROIs)+1 : length(roiNames)-1
                handles.image.VisibleROIs=[ handles.image.VisibleROIs 1];
                handles.image.LockedROIs=[ handles.image.LockedROIs 0];
         end
         
         
         

         % NOT imported: imlook4d current slice and frame 

         
         
         %setSliderRanges(handles);
         %setSliderRanges(handles.figure1);
         
         % Resize images
%          for h = get(handles.axes1, 'Children')
%              set(h,'XData', [ 0.5 size(handles.image.Cdata,1)+0.5 ]);
%              set(h,'YData', [ 0.5 size(handles.image.Cdata,2)+0.5 ]);
%          end
         
         % Save modified data
         guidata(hObject,handles);          

         
         % Redraw
         %axis(handles.axes1, 'auto'); % Needs to set handle to auto to fit strange matrix sizes (i.e. RDF data)

         adjustSliderRanges(handles);
         updateImage(hObject, eventdata, handles);       
    function importUntouched_Callback(hObject, eventdata, handles,varargin)
        
        % NOTE: This function is not used right now, anywhere, and it is questionable if it works 
        
        % Imports everything, but corrects the import of imlook4d_Cdata
        % 
        %  importFromWorkspace_Callback  has imported imlook4d_Cdata 
        %  but this function should not do that
        %
        %  Fix this by: handles.image.Cdata is restored to value of imlook4d_current_handles.image.Cdata
        
       % Display HELP and get out of callback
             if DisplayHelp(hObject, eventdata, handles) 
                 return 
             end
         
        % Import everything except Cdata matrix     
        importFromWorkspace_Callback(hObject, eventdata, handles,varargin)
         
        % Restore so that the imlook4d_current_handles.image.Cdata is
        % stored instead  of imlook4d_Cdata
         try  
             handles.image.Cdata=evalin('base', 'imlook4d_current_handles.image.Cdata');
         catch
             disp('failed restoring imlook4d_current_handles.image.Cdata');
         end;

        
          % Save modified data
         guidata(hObject,handles);   
         
         adjustSliderRanges(handles);
         updateImage(hObject, eventdata, handles);
                
    % --------------------------------------------------------------------
    % 
    % SCRIPTS 
    % --------------------------------------------------------------------
    function ScriptsMenu_Callback(hObject, eventdata, handles)
    % hObject    handle to ScriptsMenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    
    %disp('ScriptsMenu_Callback, exporting to workspace:')
%     disp('     imlook4d_current_handle          (handle to current imlook4d)')
%     disp('     handles         (copy of handles to GUI)')
%     disp('     handles.image   (copy of stored variables)')
%     disp('to workspace')
    
        % Export handles to base workspace
        assignin('base', 'imlook4d_current_handle', get(hObject,'Parent'))
        assignin('base', 'imlook4d_current_handles', handles)         

    % --------------------------------------------------------------------
    % MODELS 
    % --------------------------------------------------------------------
    function ModelsMenu_Callback(hObject, eventdata, handles)
        
    % --------------------------------------------------------------------
    % WINDOWS 
    % --------------------------------------------------------------------
    function windows_Callback(hObject, eventdata, handles)
        
        % Display HELP and get out of callback
            if DisplayHelp(hObject, eventdata, handles) 
                 return 
            end

        % Clear sub-menues
            subMenuHandles=get(handles.windows,'Children');
%             for i=1:size(subMenuHandles)
%                 delete(subMenuHandles(i))
%             end
            delete(subMenuHandles);
        
        % Find all windows            
        g=findobj('Type', 'figure');
            
        % Show only figures and imlook4d instances
            j=1;
            for i=1:size(g)
                % Mark current window with a checkbox
                if ( strcmp( get(g(i),'Tag'), 'imlook4d' ) || strcmp( get(g(i),'Tag'), '' ) )
                     h(j,1) = g(i);
                     get(h(j),'Tag')
                     j = j+1;
                end
            end   
         
        % Create html-formatted text
            [windowDescriptions h]= htmlWindowDescriptions(h);  % Sorted html list

        
        % Create menues            
             for i=1:size(h,1)
                 % Submenu items
                    callback='imlook4d(''windowsSubMenu_Callback'',gcbo,[],guidata(gcbo))';

                    htemp=uimenu(handles.windows,'Label', windowDescriptions{i},'Callback', callback, 'UserData', h(i));  % Store handle to window in 'UserData'
                                    
                   
                        % Mark current window with a checkbox
                        if (h(i) == handles.figure1)
                            set(htemp, 'Checked', 'on')
                        end
             end                  
    function windowsSubMenu_Callback(hObject, eventdata, handles)
               
        % Call Display HELP and get out of callback
        % This is only used for the scripting in DisplayHelp
        % since this submenu will never be reached for interactive help
        % (due to windows_Callback being called before)
            if DisplayHelp(hObject, eventdata, handles) 
                 return 
            end
        
        
        % This function chooses  the window-name selected in the "Windows" menu
        h=get(gcbo,'UserData');
        %set( h, 'Visible','off');
        % set(findobj('Type', 'figure'),'Visible','off') DEMONSTRATION ON HOW TO HIDE WINDOWS FROM WINDOWS TASKBAR
        %set(h, 'Visible', 'off');  
         %%set(h, 'Visible', 'on'); 
         figure(h);
            
    % --------------------------------------------------------------------
    % HELP 
    % --------------------------------------------------------------------   
    function About_Callback(hObject, eventdata, handles)
        DisplayHelp(hObject, eventdata, handles)
        % Display HELP and get out of callback
         if DisplayHelp(hObject, eventdata, handles) 
             return 
         end

         % Get path to help directory
               [pathstr1,name,ext] = fileparts(which('imlook4d'));
               helpFilePath=[pathstr1 filesep 'HELP' filesep get(hObject,'Label') '.txt' ];
               %footerFilePath=[pathstr1 '\HELP\Footer.txt' ];
               text =  fileread(helpFilePath);
               %footer =  fileread(footerFilePath);
               
               % Put imlook4d version into text place-holder
               text = strrep(text, 'VERSIONPLACEHOLDER', getImlook4dVersion() );
               
               text = [ text, ...
                  '<p><b>Bugs: </b>' ...
                  '<a href="mailto:axelsson.jan@gmail.com?subject=imlook4d&body='...
                    'Bug report'...
                    'Java:' version('-java') ...
                    'Matlab:' version() ...
                  '">' 'Bug report</a> ' ...
                  '</p>' ...
                  'Please report the following:' ...
                  ...
                   '<p><b>OS:</b> ' computer '</p>' ...
                   '<p><b>Java:</b> ' version('-java') '</p>' ...
                   '<p><b>Matlab:</b> ' version() '</p>' ...
                   ];
               
               web(['text:// ' '<html>' text  '</html>' ],'-notoolbar','-noaddressbox')    
    function Acknowledgements_Callback(hObject, eventdata, handles)
        DisplayHelp(hObject, eventdata, handles)
        % Display HELP and get out of callback
         if DisplayHelp(hObject, eventdata, handles) 
             return 
         end

         % Get path to help directory
               %[pathstr1,name,ext] = fileparts(which('imlook4d'));
               %helpFilePath=[pathstr1 '\HELP\' get(hObject,'Label') '.txt' ];
               helpFilePath=[get(hObject,'Label') '.txt' ];
               %footerFilePath=[pathstr1 '\HELP\Footer.txt' ];
               text =  fileread(helpFilePath);
               %footer =  fileread(footerFilePath);
               
               web(['text:// ' '<html>' text  '</html>' ],'-notoolbar','-noaddressbox')

% =========================================================================
%
% NON-Callback FUNCTIONS, this is where the real calculations takes place
%
% =========================================================================

    % --------------------------------------------------------------------
    % Image functions
    % --------------------------------------------------------------------   
        function updateImage(hObject, eventdata, handles)
            % ------------------------------------------------------------------------------------------
            % This routine caches a 2D image which is massaged according to radio buttons.
            % The image is generated by function generateImage.
            % The display is modified by this function according to GUI
            % features such as Intensity scale and Orientation buttons.
            % Flip-and-rotate radio button does NOT affect cached image (but displayed image is affected)

                SetColorBarUpdateState(handles.axes1, 'off');  % Stop updating colorbar (othwerwise slowing down image refresh alot)

                 numberOfFrames=size(handles.image.Cdata,4);
                 numberOfSlices=size(handles.image.Cdata,3);
                 Y=size(handles.image.Cdata,2);
                 X=size(handles.image.Cdata,1);
                try
                    slice=round(get(handles.SliceNumSlider,'Value'));
                    frame=round(get(handles.FrameNumSlider,'Value'));  % Used for both PC or frame     
                    PC=frame;
                catch
                    slice=1;
                    frame=1;  % Used for both PC or frame     
                    PC=frame;
                end
                
                if frame>numberOfFrames
                    frame=numberOfFrames;set(handles.ImgObject3,'Cdata',tempData);
                end
                if slice>numberOfSlices
                    slice=numberOfSlices;
                end               

                % Generate 2D image according to slice and frame defined in GUI 
                % (REAL pixel coordinates)
                [tempData, explainedFraction, fullEigenValues]=generateImage(handles,slice,frame);  

                % -------------------------------------------------
                % Information texts
                % -------------------------------------------------
                try
                    
                    if get(handles.PCImageRadioButton,'Value')  
                        % PC image
                        explainedFraction=fullEigenValues(PC)/sum(fullEigenValues);  % Calculate explanation factor for the single PC image
                        set(handles.ExplainedFractionText,'String', [sprintf('%6.3f',100*explainedFraction) '%']);         
                        set(handles.KaiserText,'String', ['EV:' sprintf('%6.3f', fullEigenValues(PC)) ]);
                        try set(handles.frameTimeText,'String', ''); catch end
                        try set(handles.frameTimeMinutesText,'String', ''); catch end

                        % Guess if PC image needs to be inverted, and set invert radio button
                        if get(handles.PCAutoInvert,'Value')
                            if (max(tempData(:)) + min(tempData(:)) <0)
                                set(handles.invertRadiobutton,'Value',1)  
                            else
                                set(handles.invertRadiobutton,'Value',0)  
                            end
                        end
 
                    else
                        % Not PC image
                        
                        % Set time texts
%                         try 
%                             set(handles.frameTimeMinutesText,'String', [sprintf('%5.1f',handles.image.time(frame)/60) ' (' sprintf('%3.1f',handles.image.duration(frame)/60) ') min']);
%                         catch
%                             set(handles.frameTimeMinutesText,'String','unknown'); 
%                         end
% 
%                         try set(handles.frameTimeText,'String', [num2str(handles.image.time(frame)) ' (' num2str(handles.image.duration(frame)) ') s']);
%                         catch 
%                         end
                        
                        try
                            timeTextSec = sprintf('%5.1f', handles.image.time(frame)) ;
                            timeTextMin = sprintf('%5.1f', handles.image.time(frame)/60) ;
                        catch
                            timeTextSec = ' ';
                            timeTextMin = ' ';
                        end
                        try
                            durationTextSec = sprintf('%5.1f', handles.image.duration(frame)) ;
                            durationTextMin = sprintf('%5.1f', handles.image.duration(frame)/60);
                        catch
                            durationTextSec = ' ';
                            durationTextMin = ' ';
                        end
                        try 
                            set(handles.frameTimeText,'String', [ timeTextSec ' (' durationTextSec ') s'] );
                            set(handles.frameTimeMinutesText,'String', [ timeTextMin ' (' durationTextMin ') min'] );
                        catch
                            set(handles.frameTimeText,'String','unknown'); 
                            set(handles.frameTimeMinutesText,'String','unknown');
                        end
                        
                        
                        
                         % Set matrix size text
                        try 
                            set(handles.matrixSize,'String', [ '[' num2str(X) ',' num2str(Y) '] pixels' ]);
                        catch
                            set(handles.matrixSize,'String','unknown'); 
                        end                 
                        

                        % Set PCA info
                        set(handles.ExplainedFractionText,'String', [sprintf('%6.3f',100*explainedFraction) '%']);

                        if (size(fullEigenValues,1)>1 )
                            set(handles.KaiserText,'String', ['EV:' sprintf('%6.3f',fullEigenValues(round(get(handles.PC_high_slider, 'Value')))) ]);
                        else
                            set(handles.ImgObject,'Cdata',tempData);
                            set(handles.KaiserText,'String','');
                        end
                    end
                catch
                    %disp('imlook4d/updateImage ERROR: Caught error in displaying information texts');
                end

                % -------------------------------------------------
                % Manipulate Intensity values (of current image)
                % -------------------------------------------------

                   % Invert image 
                   if get(handles.invertRadiobutton,'Value')                      
                        tempData=-tempData;     
                   end

                   % Remove negatives - delete negroiative values
                   if get(handles.removeNegativesRadioButton,'Value') 
                        tempData(tempData<0) = 0;
                   end 

                % -------------------------------------------------
                % Create picture
                % -------------------------------------------------

                    % Update Colorbar (based on intensity color scale from current image )
                      try
                          h=handles.ColorBar;                        % Get handle to colorbar
                          LOWEST = realmin('single');
                          LOWEST = 1e-23;
                          if get(handles.autoColorScaleRadioButton,'Value')==1
                                 %CLim=[( min(tempData(:))-realmin('single')) ...
                                 %    (max(tempData(:) )+ LOWEST)]; % Calculated min and max (put minimal values if min=max=0)
                                 
                                 % Remove INF from range 
                                 CLim=[   min( tempData(~isinf(tempData(:) ))) - realmin('single')  ,   ...
                                      max( tempData(~isinf(tempData(:) ))) + LOWEST  ]; % Calculated min and max (put minimal values if min=max=0)
                                
                                 set(h,'YLim', CLim)    % Set min and max scale values, for new colorbar
                                 
                                set(handles.axes1,'CLim', CLim);
                           end
                      catch
                          disp('Error in imlook4d updateImage');
                      end
                    
                %
                % Cache foreground image
                %
                         % Rotate and flip 
                        if get(handles.FlipAndRotateRadioButton,'Value') 
                            tempData=orientImage(tempData);
                        else
                            
                        end

                            
                        % Store original size
                            XLim = [ 0 size(tempData,2)];
                            YLim = [ 0 size(tempData,1)];
                                    
                        
                        % interpolate
                         if strcmp( get(handles.interpolate2,'Checked'),'on')
                              tempData = interpolate(handles, tempData ,2);
                         end
                         if strcmp( get(handles.interpolate4,'Checked'),'on')
                              tempData = interpolate(handles, tempData ,4);
                         end

                        
                        % Make RGB, and Cache
                
                        CLimits=get(handles.axes1,'CLim');
                        minValue=CLimits(1);
                        maxValue=CLimits(2);

                        colormap=get(handles.figure1,'Colormap');
                        faktor=(size(colormap,1)+1);
                        tempData=ind2rgb(round( faktor*( tempData-minValue) /(maxValue -minValue) ),get(handles.figure1,'Colormap')); 
                        
                        handles.image.CachedImage = tempData;
                    
                %
                % Cache  background image
                %
                
                    try     
                        handles.image.CachedImage2 = [];
                        tempData2 = [];
                        if ~isempty(handles.image.backgroundImageHandle)

                            h2 = handles.image.backgroundImageHandle;
                            handles2 = guidata(h2);
                            frame2 = round(get(handles2.FrameNumSlider,'Value'));

                            [tempData2, explainedFraction, fullEigenValues]=generateImage(handles2,slice,frame2); %same size

                            % Rotate and flip 
                            if get(handles.FlipAndRotateRadioButton,'Value') 
                                tempData2=orientImage(tempData2);
                            end
                            
                        % Store original size
                            XLim = [ 0 size(tempData2,2)];
                            YLim = [ 0 size(tempData2,1)];
                            
                        % interpolate

                          if strcmp( get(handles.interpolate2,'Checked'),'on');
                              tempData2 = interpolate(handles, tempData2 ,2);
                          end
                          if strcmp( get(handles.interpolate4,'Checked'),'on');
                              tempData2 = interpolate(handles, tempData2 ,4);
                          end
                          
                            % Make RGB, and Cache
                            CLimits2=get(handles2.axes1,'CLim');
                            minValue2=CLimits2(1);
                            maxValue2=CLimits2(2);
                            colorMap2 = get(handles2.figure1,'Colormap');
                            factor2 = size(colorMap2,1);
                            tempData2=ind2rgb(  round( factor2 * (tempData2-minValue2) /(maxValue2 -minValue2) ),colorMap2);

                            handles.image.CachedImage2 = tempData2;                           
                            
                        end                 
                    catch
                       %disp('No background image');
                    end
                 
                %
                % Put images in layers
                %

                    imAlphaData1 = 1;   % bottom-layer
                    imAlphaData2 = 0.7; % overlay-layer
                    imAlphaDataROI =0.5;% roi-layer

                    % First image
                    try
                        set(handles.ImgObject,'CData',tempData);
                        set(handles.ImgObject,'AlphaData',imAlphaData1);
                    catch
                        disp('First image drawing failed');
                    end

                    % Second image
                    try
                %        hold on
                        % Foreground layer
                        set(handles.ImgObject2,'CData',tempData2);
                        set(handles.ImgObject2,'AlphaData',imAlphaData2);
                    catch
                    end
                    
                %
                % Setup
                %                   
                    try
                            mmX=handles.image.pixelSizeX; % X pixel size (mm)
                            mmY=handles.image.pixelSizeY; % Y pixel size (mm)
                            mmZ=handles.image.sliceSpacing; % Y pixel size (mm)
                    catch
                            mmX=1;
                            mmY=1;
                            mmZ=1;
                    end    
                    
                    try
                            set(handles.ImgObject, 'XData',XLim);
                            set(handles.ImgObject, 'YData',YLim);
                            set(handles.ImgObject2,'XData',XLim);
                            set(handles.ImgObject2,'YData',YLim);
                            set(handles.ImgObject3,'XData',XLim);
                            set(handles.ImgObject3,'YData',YLim);
                            
                            %tempAlphaData = get(handles.ImgObject3,'AlphaData');
                            %set(handles.ImgObject3,'CData', zeros( [size(tempData) 3]), 'AlphaData', zeros(size(tempData) ) );
                            
                           % set(handles.axes1,'XLim', XLim);
                           % set(handles.axes1,'YLim', YLim);
                            set(handles.axes1,'DataAspectRatio', [ 1 1 1]);
                            set(handles.axes1,'DataAspectRatio', [ 1/mmX 1/mmY 1]);
                            
                    catch
                        disp('caught error updateImage');
                    end

                    
                    
                % Update message row
                    displayMessageRowImageInfo(hObject, eventdata, handles)
                    
                % Draw ROIs
                    %guidata(hObject,handles); %Save handles
                    updateROIs(handles)     
        	function [modelOutput, explainedFraction, fullEigenValues] = generateImage(handles, outputSliceRange, outputFrameRange)  
            % function generateImage
            %
            % Jan Axelsson 081105
            %
            % PURPOSE:
            % --------
            % GenerateImage is the key function in imlook4d.  
            % The purpose of this function is to generate (but not display) one
            % of the following:
            %   a) a PCA-filtered image modified by a modelling function
            %   b) a residual (difference):
            %      [modelfunction applied on a non-filtered time series]-[modelfunction applied on a PCA-filtered time series]
            %   c) a PC-image (model function is not applied)
            % If a model function is not selected, the modelling is ignored.
            %
            %
            % USEAGE:
            % -------
            % The generateImage function is called from one of the following:
            % 1) updateImage  - GUI update.  
            %     Description:  generateImage gives for instance a single [128,128] image
            %
            % 2) generateTACT - TACT calculations.  
            %     Description:
            %     Alt 1:  if VOI in a single slice, generateImage gives [128,128,1,16] matrix 
            %             (special case, handled in generateTACT)
            %     Alt 2:  if VOI in more than one slice, generateImage gives [128,128,47,16] matrix
            %             with zeros in slices that does not have a VOI (same dimension as dynamic data)
            %     
            % 
            % 3) SaveFile_Callback - Save image
            %     Description: calculates all slices and frames, generateImage gives [128,128,47,16] matrix
            %             with all slices calculated
            %        
            % (Examples above is for a 47 slice 16 time frame dynamic PET scan, with 128*128 pixel images)
            %
            %
            % INPUTS/OUTPUTS
            % --------------
            % The GUI gives the following input directly to this function:
            %    - Radiobuttons: PC-image and Residual radiobuttons
            %    - Sliders:      PC-sliders defines the PCA-filter
            %
            % input arguments: 
            %   - handles
            %   - outputSliceRange     range or single value
            %   - outputFrameRange     range or single value
            %
            %       ALLOWED combinations:
            %       outputSliceRange, outputFrameRange are single values;  example: generateImage(handles, 3,17)
            %       outputSliceRange, outputFrameRange are ranges;         example: generateImage(handles, 3:10 ,1:numberOfFrames)
            %
            % output arguments:   
            %   - modelOutput  - 2D image when outputSliceRange, outputFrameRange are single values
            %                  - 3D or 4D image when outputSliceRange, outputFrameRange are ranges. 
            %                    Model function decides.
            %

                %
                % Initialize
                %

                    numberOfFrames=size(handles.image.Cdata,4);
                    numberOfSlices=size(handles.image.Cdata,3);

                    PC=outputFrameRange;


                    inputSliceRange=outputSliceRange;   % Store input slices

                    % If single time-series, modify output into slice 1
                    if (size(outputSliceRange(:))==1)
                        outputSliceRange=1; %Place output into slice 1 of temp
                    end

                % ---------------------------
                % FLOW CHART
                % ---------------------------
                %
                % FOR GUI UPDATES
                % ---------------
                %
                % When:  size(outputSliceRange(:))=1
                %
                % PCA-filter generates 4D image
                % time-serie => 1-slice time-serie [:,:,1,:] (outputSliceRange is a number)
                % filterOutput will be in slice 1 of output matrix
                %
                % Model
                % 1-slice time-serie => 2Dimage
                %
                % No model
                % 1-slice time-serie => 2Dimage
                %
                %
                % FOR SAVE OPERATIONS 
                % -------------------
                %
                % When:  size(outputSliceRange(:))>1
                %
                % PCA-filter generates 4D image
                % multi-slice time-series => multi-slice time-series  [:,:,:,:](outputSliceRange is a range)
                %
                % Model
                % multi-slice time-series => 4D image, or 3D image
                %
                % No model
                % multi-slice time-series => 4D image

                % -------------------------------------------------
                % PCA filter both single and multi-slice time-series
                % -------------------------------------------------

                    % Define default size for output from PCA-filter
                    %filterOutput=zeros(size(handles.image.Cdata));  % THIS IS TOO BIG FOR MANY CASES
                    

                    filterOutput=zeros( size(handles.image.Cdata,1), size(handles.image.Cdata,2), length(outputSliceRange), numberOfFrames, 'single');
                    filterOutput(:,:,outputSliceRange,:)=handles.image.Cdata(:,:,inputSliceRange,:);

                    % Handles both theses scenarios:
                    % 1) outputSliceRange=1         => filteredOutput [:,:,1,:]
                    % 2) outputSliceRange=range     => filteredOutput [:,:,range,:]
                       fullEigenValues=1;   % Must be defined so it can be stored.
                       explainedFraction=1; % Must be defined so it can be stored.               

                    %
                    % Do PCA calculations if needed
                    %

                    % Necessary:
                    IsDynamic=(numberOfFrames>1);

                    % One of the following must be true
                    IsPCAFilter=not( (get(handles.PC_low_slider, 'Value')==1) &&  (get(handles.PC_high_slider, 'Value')==numberOfFrames) ); % PCA-filter selected with sliders
                    IsPCImage=get(handles.PCImageRadioButton,'Value');      % PC images radio button selected

                    % Test if needs to calculate following (save time otherwise)
                    if ((IsPCAFilter || IsPCImage   ) && IsDynamic  )   % PC image or PCA-filtering   (AND, of course, dynamic scan)          

                        % Calculate PCA filter always
                        % 
                            try
                                firstFrame=str2num(get(handles.FirstFrame,'String'));
                                lastFrame=size(handles.image.Cdata,4);
                            catch
                               firstFrame=1;
                            end
                            
%                              [filterOutput(:,:,outputSliceRange,:), explainedFraction, fullEigenValues,fullEigenVectors,PCMatrix]= ...
%                                  PCAFilter(handles.image.Cdata(:,:,inputSliceRange,:),...
%                                  round(get(handles.PC_low_slider, 'Value')),...
%                                  round(get(handles.PC_high_slider, 'Value')));

                            % Build output from
                            % 1) not filtered first frames
                            % 2) filtered frames
                            if (firstFrame>1)
                                filterOutput(:,:,outputSliceRange,1:firstFrame-1)=handles.image.Cdata(:,:,inputSliceRange,1:firstFrame-1);
                            end

                            [filterOutput(:,:,outputSliceRange,firstFrame:lastFrame), explainedFraction, fullEigenValues,fullEigenVectors,PCMatrix]= ...
                                PCAFilter(handles.image.Cdata(:,:,inputSliceRange,firstFrame:lastFrame),...
                                    round(get(handles.PC_low_slider, 'Value')),...
                                    round(get(handles.PC_high_slider, 'Value'))...
                                 );
                            
                            % Set PC components to zero to have something to display when not using all frames.
                            % (This reflects that all data is explained
                            % when getting same number of principal
                            % components as we had frames).
                            PCMatrix(:,:,:, (size(handles.image.Cdata,4)-firstFrame+1):size(handles.image.Cdata,4) )=0;


                        % Test if PC image
                        if IsPCImage
                              %filterOutput(:,:,outputSliceRange,PC)=PCMatrix(:,:,outputSliceRange,PC);  % PC Image (not flipped or rotated)
                              filterOutput(:,:,outputSliceRange,PC)=PCMatrix(:,:,:,PC);  % PC Image (not flipped or rotated)
                              %filterOutput=PCMatrix;  % PC Image (not flipped or rotated)
                        end

                    end %if


                % -------------------------------------------------
                % If MODEL is selected, apply model on PCA-filtered data
                % -------------------------------------------------

                % Run if a function handle is defined, BUT not if PC image (should not be modelled)
                if isa(handles.model.functionHandle, 'function_handle')&& not(IsPCImage)     

                   %
                   % Single image
                   %
                   if (outputSliceRange==1)  
                       % modelOutput should be a single 2D image
                       frame=outputFrameRange;            % Some models generate a dynamic time-series.  Select frame to use.  
                                                          % For models generating static images from a time-series, frame is ignored.
                       input=filterOutput(:,:,1,:);       % Time series created by PCA-filter, used for model

                       % Calculate model output for PCA-filtered data
                       % [MODEL ON PCA-FILTERED DATA] 
                       modelOutput=handles.model.functionHandle( handles, input, frame); % One image [:,:,1,1]

                        % IF RESIDUAL IS SELECTED:
                        %
                        % THE DIFFERENCE  
                        % [MODEL ON ORIGINAL DATA] -  [MODEL ON PCA-FILTERED DATA]
                        % COULD BE CALCULATED HERE.
                        %
                        if get(handles.ResidualRadiobutton,'Value')
%                             modelOutput=handles.model.functionHandle( handles, handles.image.Cdata(:,:,inputSliceRange,:) , outputFrameRange)...
%                             - modelOutput;
                            modelOutput=modelOutput-handles.model.functionHandle( handles, handles.image.Cdata(:,:,inputSliceRange,:) , outputFrameRange);
                            disp('Residual image, single image, model');
                        end
                   %
                   % Multiple time series
                   %
                   else
                       % Initialize
                        waitBarHandle = waitbar(0,'Calculating model for slices'); 
                        modelOutput4D=zeros(size(handles.image.Cdata),'single' );  % Fill 4D matrix
                        mode='3D';  % Guess


                        % LOOP multiple slices and fill 4D matrix
                        for j=1:size(inputSliceRange(:))
                            i=inputSliceRange(j);

                            waitbar(i/inputSliceRange(end) );
                            input=filterOutput(:,:,i,:);   % Time series created by PCA-filter, used for model

                            % Calculate model output for PCA-filtered data
                            % [MODEL ON PCA-FILTERED DATA]
                            tempModelOutput=handles.model.functionHandle( handles, input, outputFrameRange);

                            % IF RESIDUAL IS SELECTED:
                            %
                            % THE DIFFERENCE  
                            % [MODEL ON ORIGINAL DATA] -  [MODEL ON PCA-FILTERED DATA]
                            % COULD BE CALCULATED HERE.
                            %
                            if get(handles.ResidualRadiobutton,'Value')
    %                            tempModelOutput=handles.model.functionHandle( handles, handles.image.Cdata(:,:,inputSliceRange,:) , outputFrameRange)...
    %                             - tempModelOutput;
%                                tempModelOutput=handles.model.functionHandle( handles, handles.image.Cdata(:,:,i,:) , outputFrameRange)...
%                                 - tempModelOutput;
                               tempModelOutput=tempModelOutput-handles.model.functionHandle( handles, handles.image.Cdata(:,:,i,:) , outputFrameRange);
                            end

                            % Handle 3D or 4D output depending on model

                            if (size(tempModelOutput,4)>1)
                                % 3D from model of one slice, gives 4D after looping slices
                                modelOutput4D(:,:,i,:)=tempModelOutput;
                                mode=3';
                            else
                                % 2D from model of one slice, gives 3D after looping slices
                                modelOutput4D(:,:,i,1)=tempModelOutput;
                                mode=2;
                            end
                        end % LOOP
                        close(waitBarHandle);

                        % In case the model creates 3 dimensions after loop (instead of 4)
                        % the original 4D output should be truncated.  
                        % Otherwise, the output is 4 dimensions.
                        if (mode==3)
                            % Model gives all frames
                            modelOutput=modelOutput4D;
                        else
                            % Model gives only one frame
                            modelOutput=modelOutput4D(:,:,:,1);
                        end


                   end %IF (outputSliceRange==1) 


                % -------------------------------------------------
                % If NOT MODEL 
                % -------------------------------------------------
                else
                    if (outputSliceRange==1)  
                        % single slice (outputSlice=1 in initialization above)
                        modelOutput=filterOutput(:,:,1,outputFrameRange);

                        % If Residual
                        if get(handles.ResidualRadiobutton,'Value')
%                             modelOutput=handles.image.Cdata(:,:,inputSliceRange,outputFrameRange) - modelOutput; 
                            modelOutput=modelOutput-handles.image.Cdata(:,:,inputSliceRange,outputFrameRange); 
                        end
                    else
                        % multiple slices
                        modelOutput=zeros(size(handles.image.Cdata),'single');
                        modelOutput(:,:,inputSliceRange,outputFrameRange)=filterOutput(:,:,outputSliceRange,outputFrameRange);

                        % If Residual
                        if get(handles.ResidualRadiobutton,'Value')
                            %modelOutput=handles.image.Cdata(:,:,inputSliceRange,outputFrameRange) - modelOutput(:,:,inputSliceRange,outputFrameRange);
                            %modelOutput=handles.image.Cdata - modelOutput;
                            modelOutput=modelOutput-handles.image.Cdata;

                        end
                    end
                end % NOT MODEL
            function newMatrix2D = interpolate( hObject,  matrix2D, pixelMultiplicator)
                        newMatrix2D=matrix2D;
                        %return

                % -------------------------------------------------
                % Interpolated image (current image)
                % -------------------------------------------------
                
                    % The CachedImage is handled as follow:
                    % 1) updateROI (this function):
                    %       It is stored in  with the interpolated
                    %       resolution (higher than original resolution)
                    % 2) updateImage:
                    %       new CachedImage with original resolution is
                    %       created when new frame or slice is created
                
                  % 1) Values if no interpolation
                      % Set coordinate values for pixels
%                       numberOfPixels=size(matrix2D,1);
%                       numberOfPixels2=size(matrix2D,2);
                      numberOfPixelsX=size(matrix2D,1);
                      numberOfPixelsY=size(matrix2D,2); %Y
           %           set(handles.ImgObject, 'XData', [0 numberOfPixels]+0.5,'YData',[0 numberOfPixels2]+0.5);
            
% %                             numberOfPixels=size(matrix2D,1);
%                             step=1/pixelMultiplicator;
%                             start=0.5+step/2;
%                             stop=numberOfPixelsX+0.5-step/2;


                            % New grid
                            %[x,y]   = meshgrid(1:1:numberOfPixels );        % Old grid
                            %[xi,yi] = meshgrid(start:step:stop);            % New grid, more steps but same x,y coordinate system

                            %New grid (non-square images)
                                %set(handles.axes1,'XTickMode', 'auto', 'YTickMode', 'auto');
%                                 numberOfPixels=size(matrix2D,1);
                                step=1/pixelMultiplicator;
                                start=0.5+step/2;
                                stop=numberOfPixelsX+0.5-step/2;


                                numberOfPixels2=size(matrix2D,2);
                                step2=1/pixelMultiplicator;
                                start2=0.5+step2/2;
                                stop2=numberOfPixelsY+0.5-step2/2;

                                [x,y]   = meshgrid(1:1:numberOfPixelsX,1:1:numberOfPixelsY );        % Old grid
                                [xi,yi] = meshgrid(start:step:stop, start2:step2:stop2);            % New grid, more steps but same x,y coordinate system

                                % Zoom-bug fixed:  Commented out, because it caused zoomed window to reset when changing slice
                                 %set(handles.axes1,'XLim',[1 numberOfPixelsX]);
                                 %set(handles.axes1,'YLim',[1 numberOfPixelsY]); 
                                 g=hObject;
                                 set(g.ImgObject, 'XData', [0 numberOfPixelsX]+0.5,'YData',[0 numberOfPixelsY]+0.5);
                                 set(g.ImgObject, 'XData', [0 numberOfPixelsX]+0.5,'YData',[0 numberOfPixelsY]+0.5);


                            % Interpolate
                                %newMatrix2D =interp2(x,y,matrix2D',xi,yi,'bicubic')';
                               newMatrix2D = interp2(x,y,matrix2D',xi,yi,'bilinear')';
                                %newMatrix2D = interp2(x,y,matrix2D',xi,yi,'nearest')';

                            % Fix NaNs at border
                            newMatrix2D(isnan(newMatrix2D))=0;               
            function setColorBar( handles, CLim)
            %
            % setColorBar from 
            % inputs 
            %           handles structure containing ColorBar, autoColorScaleRadioButton
            %           Clim    [low high] limits
            %
            colorBarHandle=handles.ColorBar;                    % Get handle to colorbar
            set(handles.autoColorScaleRadioButton,'Value', 0);  % Set autoscale to off
            
            if CLim(1)~=0
                set(handles.removeNegativesRadioButton,'Value', 0);  % Set autoscale to off
            end

            set(colorBarHandle,'YLim', CLim);    % Set min and max scale values, for new colorbar
          %set(colorBarHandle,'CLim', CLim);    % Set min and max of colorscale, for new colorbar
           set(handles.axes1,'CLim', CLim);
            function SetColorBarUpdateState( axis_handle, state)
            % Stop listeners for update (to save time when doing ROI updates)
            % Possible states are:
            %  state = 'on'
            %  state = 'off'
            % where 'off' does not update the ColorBar when graphics is
            % refreshed
%             
%            try
%                a=get(gca,'LegendColorbarListeners');
%                 for i=1:length(a)
%                     set(a(i),'Enabled',state);
%                 end
%             catch
%                 disp('error')
%            end   
            try
                for a=get(axis_handle,'LegendColorbarListeners')
                    set(a,'Enabled',state);
                end
            catch
                %disp('error')
            end     
            function updateAspectRatio(handles, matrix2D)
                % -------------------------------------------------
                % Calculate aspect ratio
                % ------------------------------------------------- 
                    try
                         nX=size(matrix2D',1);
                         nY=size(matrix2D',2);
                         
                         mmX=handles.image.pixelSizeX; % X pixel size (mm)
                         mmY=handles.image.pixelSizeY; % Y pixel size (mm)                        
                         set(handles.axes1,'DataAspectRatio', [ 1  mmY/mmX  1]);
                         
                         if get(handles.FlipAndRotateRadioButton,'Value')
                             XLim0 = get(handles.axes1,'XLim');
                             YLim0 = get(handles.axes1,'YLim');
                             set(handles.axes1,'XLim', YLim0 );
                             set(handles.axes1,'YLim', XLim0 );
                         end

                    catch
                        mmX=1;
                        mmY=1;
                        set(handles.axes1,'DataAspectRatio', [  mmY mmX  1]);
                        disp('imlook4d/updateROI:  Error calculating DataAspectRatio');
                    end  
            function imgOut=orientImage(img)
                imgOut=imlook4d_fliplr(rot90(img,3));                              
            function displayMessageRowImageInfo(hObject, eventdata, handles)
%                -------------------------------------------------
%                Print DICOM info to MATLAB window
%                -------------------------------------------------
                    numberOfSlices=size(handles.image.Cdata,3);
                    numberOfPixelsX=size(handles.image.Cdata,1);
                    numberOfPixelsY=size(handles.image.Cdata,2); %Y

                    slice=round(get(handles.SliceNumSlider,'Value'));
                    frame=round(get(handles.FrameNumSlider,'Value'));
               try
                    if strcmp(handles.image.fileType,'DICOM')
                        mode=handles.image.dirtyDICOMMode;
                        i=slice+numberOfSlices*(frame-1);
                        sortedHeaders=handles.image.dirtyDICOMHeader;
                        %versn will be removed new matlab versions:  [pathstr, name, ext, versn] = fileparts(handles.image.dirtyDICOMFileNames{i});
                        [pathstr, name, ext] = fileparts(handles.image.dirtyDICOMFileNames{i});

                        try
                            out1=dirtyDICOMHeaderData(sortedHeaders, i, '0008', '0032',mode); 
                            acqTime=out1.string;
                        catch
                            acqTime='      ';
                        end

                        try
%                             %out2=dirtyDICOMHeaderData(sortedHeaders, i, '0020', '0032',mode);
%                             %temp=strfind(out2.string,'\'); location=out2.string(temp(2)+1:end);  % Position  
% 
%                             out2=dirtyDICOMHeaderData(sortedHeaders, i, '0020', '1041',mode);
%                             location=out2.string;
% 
%                             location=[location '               '];
%                             location=location(1:7);
                            
                            % NEW
                            location=num2str( handles.image.sliceLocations(i));
                            
                            
                        catch
                            location='      ';
                        end

                        try
                            out3=dirtyDICOMHeaderData(sortedHeaders, i, '0018', '1242',mode);
                            duration=[num2str(str2num(out3.string)/1000 ) '      ']; duration=duration(1:5);
                        catch
                            duration='     ';
                        end

                        try
                            out4=dirtyDICOMHeaderData(sortedHeaders, i, '0054', '1300',mode);
                            time=    [num2str(str2num(out4.string)/1000 ) '      ']; time=time(1:6);
                        catch
                            time='      ';
                        end

                        % Different displays for different Plane Views
                        % (Axial, Coronal, Sagital)
                        if strcmp(handles.image.plane, 'Axial')
                            infoString={[ 'Acq. Time=' acqTime(1:6) ...
                                '   Frame Time=' time ...
                                ' (s)   Duration=' duration ...
                                ' (s)  Slice location =' location     ], ...
                                ['File=' name ext ]};
                        else
                           infoString={[ 'Acq. Time=' acqTime(1:6) ...
                                '   Frame Time=' time ...
                                ' (s)   Duration=' duration  ]}; 
                        end
                        
                        
                        %disp(infoString{1,1});
                        %set(handles.infoText1, 'String', infoString);
                        displayMessageRow(infoString);
                    end
               catch
               end
               
               % Empty message row if not DICOM
               try
                   if ~strcmp(handles.image.fileType,'DICOM')
                        displayMessageRow('');
                   end
               catch
                   % fileType variable non-existing
                   displayMessageRow('');
               end
               
            function updateROIs(handles)
            % ------------------------------------------------------------------------------------------
            % This function draws ROIs on top of cached image (not flipped and
            % rotated)
            % Flip-and-rotate is performed on both ROI and image
            %
            % Interpolation of displayed image is performed here.
            %    
            % This routine is responsible for updating the screen display
            % It is called two different ways:
            % 1) wmb                (when drawing ROI with mouse)
            %       drawROI         (draws ROI pixels in ROI matrix)
            %           updateROI   (CachedImage is used here, so it does not need to be recalculated)
            %
            % 2) updateImage        (for instance when changing slice or frame.  CachedImage is generated here)
            %       updateROI       (CachedImage is used here, so it does not need to be recalculated)
            %
            % THEORY:
            %
            % ImgObject data is plotted inside axes1
            % axes1     -coordinate system is defined by XLim=[min max], YLim=[min max]
            %           -DataAspectRatio defines how much space the plot takes in x,y direction 
            %
            % ImgObject (data) coordinates are defined by XData, YData
            %           This is the coordinate system used when clicking
            %           the mouse
            % 
                % -------------------------------------------------
                % Initialize
                % -------------------------------------------------
                    numberOfSlices=size(handles.image.Cdata,3);
                    numberOfPixelsX=size(handles.image.Cdata,1);
                    numberOfPixelsY=size(handles.image.Cdata,2); %Y

                    slice=round(get(handles.SliceNumSlider,'Value'));
                    frame=round(get(handles.FrameNumSlider,'Value'));
                    
                    rois=handles.image.ROI(:,:,slice);                           % ROIs
                    
                    % Rotate and flip
                    if get(handles.FlipAndRotateRadioButton,'Value')
                        rois=orientImage(rois);
                        tempAlphaData = get(handles.ImgObject3,'AlphaData');
                        set(handles.ImgObject3,'CData', zeros( [size(rois) 3]), 'AlphaData', zeros(size(rois) ) );
                    else
                        tempAlphaData = get(handles.ImgObject3,'AlphaData');
                        set(handles.ImgObject3,'CData', zeros( [size(rois) 3]), 'AlphaData', zeros(size(rois) ) );
                    end

                    
                    % Work matrices

                    activeRoiPicture=zeros(size(handles.image.Cdata,1), size(handles.image.Cdata,2),'single');
                    activeRoiPicture=zeros(size(rois),'single');
                    inActiveRoiPicture=zeros(size(activeRoiPicture),'single');

                % -------------------------------------------------
                % Create image and ROI pixel values
                % -------------------------------------------------


                    % ROI display things
                       activeROI=get(handles.ROINumberMenu,'Value');             
  
                       
                       % Remove non-visible ROIs from pixels
                       for i=1:length(handles.image.VisibleROIs)
                           if (handles.image.VisibleROIs(i)==0)
                               rois(rois==i)=0;       % All ROIs
                           end
                       end

                       % Set pixels in active ROI                              set(handles.ImgObject3,'AlphaData', 0.5);  


                       % Set pixels in all other ROIs
                       logicalA=(rois==activeROI);          % Active ROI
                       logicalB=(rois~=0);                  % All ROIs
                       logicalC=xor(logicalA , logicalB);   % Removes Active ROI from All ROIs
                       
                       activeRoiPicture(logicalA)=1;    
                       inActiveRoiPicture(logicalC) = 1;
                       
                       % Modify activeRoiPicture (to show only contour)
                       if ( get(handles.ContourCheckBox,'Value')==1 ) 
                           a = max( activeRoiPicture(:));
                           b = max( inActiveRoiPicture(:));
                            
                            lineThickness = 1;
                            
                            xrange = (lineThickness + 1) : ( size(activeRoiPicture,1) - lineThickness-1 ); 
                            yrange = (lineThickness + 1) : ( size(activeRoiPicture,2) - lineThickness-1 );

    
                            activeRoiPicture( xrange, yrange) = ...
                                  activeRoiPicture( xrange , yrange+lineThickness) ...
                                  + activeRoiPicture( xrange , yrange-lineThickness) ...
                                  + activeRoiPicture( xrange+lineThickness , yrange) ...
                                  + activeRoiPicture( xrange-lineThickness , yrange) ...
                                ;                               

                            
                            level = 3*a;
                            activeRoiPicture( activeRoiPicture > level ) = 0; % hide inside pixels
                            
                                
                            inActiveRoiPicture( xrange, yrange) = ...
                                  inActiveRoiPicture( xrange , yrange+lineThickness) ...
                                  + inActiveRoiPicture( xrange , yrange-lineThickness) ...
                                  + inActiveRoiPicture( xrange+lineThickness , yrange) ...
                                  + inActiveRoiPicture( xrange-lineThickness , yrange) ...
                                ;
                            
                            
                            level = 3*b;
                            inActiveRoiPicture( inActiveRoiPicture > level) = 0;
                       end
                       
                % -------------------------------------------------
                % Draw ROIs in image (SKIP THIS IF HIDE ROIS IS ON)
                % -------------------------------------------------   
                        ColorfulROI = false;
                        GrayROI = false;
                                        
                        if ( get(handles.hideROIcheckbox,'Value')==0 )
                            
                            % 0) Guess ROI Color 
                            if strcmp( get(handles.GuessRoiColor,'Checked'),'on')
                                if (  strcmp( handles.ColormapName, 'Gray') || strcmp( handles.ColormapName, 'Gray_inverted')  )
                                    ColorfulROI=true;
                                else
                                    GrayROI=true;
                                end 
                            end
                            
                            if strcmp( get(handles.ColorfulROI,'Checked'),'on')
                                ColorfulROI=true;
                            end
                            
                            if strcmp( get(handles.GrayROI,'Checked'),'on')
                                GrayROI=true;
                            end
                            
  
                            % 1) ColorFul ROI  
                            if ColorfulROI
                                        tempData = activeRoiPicture;
                                        xSize = size(get(handles.ImgObject3,'CData'),1);
                                        ySize = size(get(handles.ImgObject3,'CData'),2);
                                        
                                        act =  ( reshape( reshape(activeRoiPicture,1,[])' * [ 0 1 0 ] , xSize, ySize, []) > 0  );
                                        inact =  ( reshape( reshape(inActiveRoiPicture,1,[])' * [ 1 0 0 ]*0.6 , xSize, ySize, []) > 0  );
                                        set(handles.ImgObject3,'Cdata', act + inact  );

                                       if ( get(handles.ContourCheckBox,'Value')==1 )
                                            set(handles.ImgObject3,'AlphaData', 1*(activeRoiPicture>0) + 1*(inActiveRoiPicture>0)  );
                                       else
                                            set(handles.ImgObject3,'AlphaData', 0.5*(activeRoiPicture>0) + 0.3*(inActiveRoiPicture>0)  );
                                       end
                                       
                              end
  
                            % 2) Gray ROI 
                              if GrayROI
                                  
                                       set(handles.ImgObject3,'Cdata', zeros(size(activeRoiPicture) ) );
                                       
                                       % 2a) Gray ROI - contour 
                                       if ( get(handles.ContourCheckBox,'Value')==1 )
                                            set(handles.ImgObject3,'AlphaData', 1*(activeRoiPicture>0) + 0.4*(inActiveRoiPicture>0)  );

                                       % 2b) Gray ROI - solid  
                                       else
                                            set(handles.ImgObject3,'AlphaData', 0.5*(activeRoiPicture>0) + 0.3*(inActiveRoiPicture>0)  );
                                       end
                              end
                              
                        else
                              set(handles.ImgObject3,'Cdata', zeros(size(activeRoiPicture)));  
                              set(handles.ImgObject3,'AlphaData', 0.0);  
                        end % END DRAWING ROIS         
     
    % --------------------------------------------------------------------
    % Help and HTML functions
    % --------------------------------------------------------------------
       function trueIfChecked = DisplayHelp(hObject, eventdata, handles)
            
               %ScriptFlag=true;  % Turn scripting ON (true)  or  OFF (false)
               ScriptFlag = handles.record.enabled;
               HelpFlag=strcmp( get(handles.helpToggleTool, 'State'), 'on') ;

 
           
               EOL=sprintf('\r\n');  % Windows end-of-line (used for nicer formatting of page source for generated HTML file)
               trueIfChecked=false;
               temp=dbstack();
               callBackFunctionName=temp(2,1).name;
               callbackString=['imlook4d(''' callBackFunctionName ''', imlook4d_current_handles.' get(hObject,'Tag') ',{} ,imlook4d_current_handles)'];
               

                   
                   % Notes:buttonsSameNameAsPressed
                   % SCRIPT, MODEL, COLOR, WINDOW LEVEL  submenu - called directly from callback, must be intercepted directly in script
                   % See commented example in SCRIPTS menu defintions, on
                   % how to call two callbacks.b.
                   

               title= 'imlook4d help';


               %
               % If toolbar Help button is pressed, display html-help
               %
                   %if strcmp(get(handles.helpToggleTool, 'State'), 'on') || strcmp(callBackFunctionName, 'Help_Callback')
                    if HelpFlag
                       %disp('imlook4d/DisplayHelp entered');

                       % Get path to help directory
                       [pathstr1,name,ext] = fileparts(which('imlook4d'));

                       % Get path to help file
                       try
                            %helpFilePath=[pathstr1 filesep 'HELP' filesep get(hObject,'Label') '.txt' ];
                            helpFilePath=[get(hObject,'Label') '.txt' ];
                       catch
                            % Toolbar buttons don't have 'Label', use 'Tag' instead
                            %helpFilePath=[pathstr1 filesep 'HELP' filesep get(hObject,'Tag') '.txt' ];
                            helpFilePath=[get(hObject,'Tag') '.txt' ];

                       end
                       %disp(['Help file path=' helpFilePath]); 

                       % Read text and footer
                       try
                           % Replace spaces with underscores in file name
                           % (as in SCRIPT file naming rules)
                            [pathstr,name,ext] = fileparts(helpFilePath);
                            name1=strrep(name,' ','_');
                            name=strrep(name,'_',' ');
                            helpFilePath=[ pathstr filesep name ext];
                            text =  fileread(helpFilePath);
                       catch
                           % Read from parent object instead (useful for
                           % submenues that do not have any help
                           % file.
                           disp([ 'Missing help file - could not find file=' helpFilePath]);
                           
                           try
                                parentObject=get(hObject,'Parent');
                                helpFilePath=[pathstr1 'HELP' get(parentObject,'Label') '.txt' ];
                                text =  fileread(helpFilePath);
                           catch
                               % Read from Parent object again
                                parentObject=get(parentObject,'Parent');
                                try
                                    helpFilePath=[ get(parentObject,'Label') '.txt' ];
                                    text =  fileread(helpFilePath);
                                catch                                     
                                    helpFilePath=[ get(parentObject,'Tag') '.txt' ];
                                    text =  fileread(helpFilePath);   
                                end
                           end
                       end
                       footerFilePath=[ 'Footer.txt' ];
                       footer =  fileread(footerFilePath);

                       % Developers reference 
                       %        (as defined in /HELP/About.txt)
                       %        info about: callback function, help file, etc
                       %if strcmp(getImlook4dVersion(),'DEVELOP')
                       if true % Always show developers reference
                            % Title
                                %developersText=[  '<HR><BR><BR><BR><BR>' '<h3><U>Developers reference:</U></h3>' EOL];  
                                
                                
                                % The footer.txt has javascripts common to all help files.  
                                % This allows to toggle Developers reference on/off
                                displayStyle='font-size: 9px;';
                                %displayStyle='none';
                                developersText=[  '<div id="test" style="display:block;' displayStyle ' ">' '<HR>' '<h3><U>Developers reference:</U></h3>' EOL];
                            % Start table
                                developersText=[ developersText '<table style="display:block;' displayStyle ' ">' EOL];
                                 
                            % Link to edit help file
                                developersText=[ developersText  parseHTMLTableRow(  ...
                                    '<B>Help file=</B>',...
                                     ['<a href="matlab:edit ''' helpFilePath '''">'   helpFilePath '</a>']) ...
                                     ];  
                            % Object tag
                               developersText=[ developersText  parseHTMLTableRow(  ...
                                    '<B>Object tag=</B>',...
                                    get(hObject,'Tag') )...
                                    ];             
                                
                            % Label tag
                                try
                                    developersText=[ developersText  parseHTMLTableRow(  ...
                                    '<B>Object Label=</B>',...
                                    get(hObject,'Label') )...
                                    ];  
                                catch
                                    developersText=[ developersText  parseHTMLTableRow(  ...
                                    '<B>Object Label=</B>',...
                                    ' ' ) ...
                                    ];  
                                end
                                
                            % Callback function
                                developersText=[ developersText  parseHTMLTableRow(  ...
                                    '<B>Callback=</B>',...
                                    callBackFunctionName)...
                                    ];  

                                developersText=[ developersText  parseHTMLTableRow(  ...
                                    '<B>Callback from script=</B>',...
                                    ['   ' ...
                                        callbackString...
                                    '   '] ...
                                    )...
                                    ];  
                                
                            % Handle to object
                                try
                                    hObjectHandle = num2str(hObject);
                                    figureHandle = num2str(handles.figure1);
                                catch
                                    % Newer Matlabs from cirka 2014
                                    hObjectHandle = 'only in earlier versions of Matlab';
                                    figureHandle = 'only in earlier versions of Matlab';
                                end
                                
                                developersText=[ developersText  parseHTMLTableRow(  ...
                                    '<B>Handle to object=</B>', ...
                                    [ hObjectHandle '  (' get(hObject,'Type') ')']) ...
                                    ];  
                            % Imlook4d-instance handle
                                developersText=[ developersText  parseHTMLTableRow(  ...
                                    '<B>Handle to imlook4d instance (handles.figure1)=</B>',...
                                    figureHandle )...
                                    ]; 
                            % Link to Matlab code
                                developersText=[ developersText  parseHTMLTableRow(  ...
                                    '<B>Matlab code=</B>',...
                                     ['<a href="matlab:edit(''' which(name1) ''')">'   which(name1) '</a>']) ...
                                     ];
                            % End table
                                developersText=[ developersText '</table>' EOL];

                       else
                            developersText=''; % No text
                       end
                       
                       developersText=[ developersText '</div>' EOL];


                           % Show HELP
                           
                           % Create and display html file
                                webhandle=displayHTML(pathstr1, title, text,footer,developersText);  % Display html, adding footer and developers reference

                           % Store handle to web browser

                                handles.webbrowser=webhandle;
                                guidata(hObject,handles);


                           % Return value true (which is used to stop callback function from being further executed
                                trueIfChecked=true;

                    end
                   
               %
               % SCRIPTING
               %
                   if ScriptFlag
                       EOL = sprintf('\n');

                       try
                           switch get(hObject,'Type')
                               case 'figure'
                                   % This is for instance figures from such
                                   % as water_control
                                   try 
                                       if ~strcmp( get(hObject,'Tag'), 'imlook4d')
                                            cmd = [ 'Menu(''' get(hObject,'Tag') ''')' ];
                                       end
                                   catch
                                   end
                                   
                               case 'uimenu'
                                   % This is the important one -- the
                                   % others are only visual things which
                                   % should not be scriptable
                                   
                                   % Guess that not SCRIPTS menu
                                   
                                   cmd = [ 'Menu(''' get(hObject,'Label') ''')' ];
                                   
                                   % Open menu
                                   try
                                       menuName = get(hObject,'Label');
                                       if strcmp( 'Open', menuName )
                                           %cmd = [cmd '; imlook4d_current_handle = gcf;']
                                           cmd = ['imlook4d_current_handle = Open(INPUTS{1}); % Handle to imlook4d window']
                                       end
                                   catch 
                                   end
                                   
                                   
                                   % SCRIPTS menu
                                   try
                                       menuName = get( get( get(hObject,'Parent'),'Parent' ),'Label');
                                       if strcmp( 'SCRIPTS', menuName )
                                           cmd = get(hObject,'Label');
                                           cmd = strrep( cmd, ' ', '_');  % Make proper names ('_' was removed when making menues far above)
                                           
                                           % Duplicate
                                           if strcmp( 'Duplicate', get(hObject,'Label') )
                                                cmd = [cmd '; MakeCurrent;'];
                                           end
                                       end
                                           
                                   catch
                                       disp('Not SCRIPTS');
                                   end
                                   
                                                                      
%                                    % Windows menu
%                                    try
%                                        menuName = get( get( hObject,'Parent' ),'Label');  % Is "Windows" if we are in a submenu of windows
%                                        if strcmp( 'Windows', menuName )
%                                            cmd = [ 'Windows' get(hObject,'Position') ];
%                                        end
%                                    catch
%                                        disp('Not SCRIPTS');
%                                    end
                                   
%                                    
%                                    
%                                    
%                                case 'uitoggletool'
%                                    cmd = (['REC: ' get(hObject,'Tag') '(' get(hObject,'State') ')']);
                                case 'uipushtool'
                                    %cmd = (['REC: ' get(hObject,'Tag') ]);
                                    cmd = [ 'ToolbarButton(''' get(hObject,'Tag') ''')' ];
%                                case 'figure'
%                                    % Do nothing
                              case 'uicontrol'
                                    switch get(hObject,'Style')
                                        case 'popupmenu'
                                           cmd = get(hObject,'Tag');
                                           cmd = ['SelectROI( ' num2str(get(hObject,'Value')) ' );'];
                                           % ROINumberMenu
                                           if strcmp( get(hObject,'Tag'), 'ROINumberMenu')
                                               if (  get(hObject,'Value') == length( get(hObject,'String') ) )
                                                   cmd = 'MakeROI';
                                               else
                                                   cmd = ['SelectROI( ' num2str(get(hObject,'Value')) ' );'];
                                               end
                                           end
                                           
                                           % orientationMenu
                                           if strcmp( get(hObject,'Tag'), 'orientationMenu')
                                               %cmd = ['SelectOrientation( ' num2str(get(hObject,'Value')) ' );'];
                                               index=get(hObject,'Value');
                                               strings=get(hObject,'String');
                                               cmd = ['SelectOrientation(''' strings{index} ''');'];
                                           end
                                        
                                        case 'radiobutton'
                                            cmd = [ 'Radiobutton(''' get(hObject,'String') ''')' ];
%                                        case 'checkbox'
%                                            cmd = (['REC: ' get(hObject,'Tag') '(' num2str(get(hObject,'Value')) ')']);
                                       case 'pushbutton'
                                            %cmd = (['REC: ' get(hObject,'String') ]);
                                            cmd = [ 'Button(''' get(hObject,'String') ''')' ];
                                       case 'checkbox'
                                            %cmd = (['REC: ' get(hObject,'String') ]);
                                            cmd = [ 'Checkbox(''' get(hObject,'String') ''')' ];
                                        case 'edit'
                                            cmd = (['EditField(''' get(hObject,'Tag') ''', ''' get(hObject,'String') ''')']);
%                                        case 'slider'
%                                            cmd = (['REC: ' get(hObject,'Tag') '(' num2str(get(hObject,'Value')) ')']);

% 
%                                        otherwise
%                                            disp('NO MATCH Style');
                                    end
% 
                                otherwise
%                                    disp('NO MATCH Type');

                           end % switch get(hObject,'Type')


                           handles.record.editor.insertTextAtCaret([cmd EOL EOL]);  % Insert text at caret

                       catch
                       end

                   end % if ScriptFlag


                    
                   if ScriptFlag   % true is normal mode, false displays command that could be useful for scripting
                           % Show scripting command
                           disp(callbackString)
                           disp(' ')
                   end
               
               %
               % If toolbar Help button is pressed,
               % toggle radio-buttons and check boxes
               % (thus keeping state before being pressed)
               %
                   try
                       if trueIfChecked
                     
                           if get( hObject,'Value')==1
                               set( hObject,'Value', 0);
                           else
                               set(hObject,'Value', 1);
                           end

                           restoreImageRadioButtonGroup(handles);
                       end
                   catch
                       % Property 'Value' not existing for this GUI widget
                   end                              
       function [windowDescriptions sortedListOfWindows ] = htmlWindowDescriptions( listOfWindows )
        % Create html-formatted list of windows
        % Input:    handles to all windows
        % Output:   cell array of html-strings, sorted according to
        % rules in end of this function
            %disp('ENTERED htmlWindowDescriptions');
            
            
            
                            TAB=' . .  ';
            
            %
            % Generate list
            %
                            
            for i=1:size(listOfWindows,1)
                figureName=get(listOfWindows(i),'Name');
                windowDescriptions{i}=figureName;
                
                % Guess
                table{i,1}=i;          % original index
                table{i,2}='';
                table{i,3}='';
                table{i,4}='';
                table{i,5}='';
 
                

                
                %
                % Fill in table, and generate html
                %
                if not( isempty( guidata(listOfWindows(i) ) ) ) 
                    
                    % Here we have gui applications (i.e. imlook4d)
                    tempHandles=guidata(listOfWindows(i));
                    
                    %
                    % Yoke
                    %
                    try
                        currentYoke=get( getappdata(tempHandles.figure1,'currentYoke'), 'Tag');
                        if isempty(currentYoke)
                            Yoke=' ';
                        else
                            Yoke=currentYoke;
                        end
                        switch Yoke
                            case 'A'
                                yokeBackgroundColor='style="background-color: #FF0000;"';
                            case 'B'
                                yokeBackgroundColor='style="background-color: #00FF00;"';
                            case 'C'
                                yokeBackgroundColor='style="background-color: #FFC000;"';
                            otherwise
                                yokeBackgroundColor='style="background-color: #FFFFFF;"';
                        end
                    catch
                    end
                        
                        try

                            tempDicomHeader=tempHandles.image.dirtyDICOMHeader;
                            mode=tempHandles.image.dirtyDICOMMode;

                            Modality=tempHandles.image.modality;table{i,2}=Modality;

                            %dirtyDICOMHeaderData(tempDicomHeader, 1, group, element,mode);
                            %trypatientID=dirtyDICOMHeaderData(tempDicomHeader, 1,'0010', '0020',mode); catch end
                            try patientName=dirtyDICOMHeaderData(tempDicomHeader, 1,'0010', '0010',mode); table{i,3}=patientName.string; catch end
                            try studyDesc=dirtyDICOMHeaderData(tempDicomHeader, 1,'0008', '1030',mode); table{i,4}=studyDesc.string; catch end
                            try seriesDesc=dirtyDICOMHeaderData(tempDicomHeader,1,'0008', '103E',mode); table{i,5}=seriesDesc.string;catch end

                            try StudyDate=dirtyDICOMHeaderData(tempDicomHeader, 1, '0008', '0020',mode);StudyDate=StudyDate.string; catch end
                            try ScanTime=dirtyDICOMHeaderData(tempDicomHeader, 1, '0008', '0031',mode);ScanTime=ScanTime.string; catch end
                            DateTime=[StudyDate '@' ScanTime(1:end-2)];


                            History=tempHandles.image.history;
                            table{i,1}=i;          % original index

                          % Colored text in listdlg
                          % PatientName [Modality] SeriesDesc figureName          
                          temp=[ '<HTML>' ...
                                        '<FONT ' yokeBackgroundColor ' color="blue">' Yoke '</FONT> '...
                                        '<FONT color="blue">' patientName.string TAB '</FONT>' ...
                                        '<FONT color="gray">[' Modality ']' TAB  '</FONT>'...
                                        '<FONT color="black">' seriesDesc.string TAB '</FONT>'...
                                        '<FONT color="red">' figureName TAB '</FONT>' ...
                                        '</HTML>' ];  
                          % Remove null-characters (DICOM can have that)
                          windowDescriptions{i}=strrep(temp,char(0),'');          


                        catch
                        % NOT DICOM 
                        %disp('htmlWindowDescriptions - PROBLEM');
                           temp=[ '<HTML>' ...
                                        '<FONT ' yokeBackgroundColor ' color="blue">' Yoke '</FONT> '...
                                        '<FONT color="black">' figureName TAB '</FONT>' ...
                                        '</HTML>' ];                         
                        windowDescriptions{i}=strrep(temp,char(0),'');  
                    end

                else  
                        % Here we have non-gui applications (such as normal plot figures)
                end
            end
            
            %
            % Sort in a nice order
            %

                % Sort rows
                [table, index] = sortrows(table,[3,4,2,5]);

                % Set sorted handles
                sortedListOfWindows=listOfWindows(index);
                windowDescriptions=windowDescriptions(index);
                  
    % --------------------------------------------------------------------
    % Other functions
    % --------------------------------------------------------------------
        function activity=newTACT(hObject, eventdata, handles)
            %
            % Initialize
            %
                contents = get(handles.ROINumberMenu,'String'); % Cell array  
                numberOfROIs=size(contents,1)-1;
                numberOfFrames=size(handles.image.Cdata,4);
                numberOfSlices=size(handles.image.Cdata,3);
                
                IsPCImage=get(handles.PCImageRadioButton,'Value');      % PC images radio button selected
                IsResidualImage=get(handles.ResidualRadiobutton,'Value'); % Redisual image radio button selected

            %
            % Plot TACT curve
            %  
                try
                    [activity, NPixels, stdev]=generateTACT(handles, handles.image.ROI);
                catch
                    % NEW version 
                    [activity, NPixels, stdev]=generateTACT_new(handles, handles.image.ROI);
                end
                
%                 % Use ExportROI script internally
%                 imlook4d_current_handle=hObject;
%                 imlook4d_current_handles=handles;
%                 imlook4d_Cdata=handles.image.Cdata;
%                 imlook4d_ROI=handles.image.ROI;
%                 imlook4d_frame=round(get(handles.FrameNumSlider,'Value')); 
%                 ExportROIs
%                 % Data now in imlook4d_ROI_data

%                 tic
%                     [activity2, NPixels2, stdev2]=generateTACT(handles, handles.image.ROI);
%                 toc;tic
%                     % NEW version 
%                     [activity, NPixels, stdev]=generateTACT_new(handles, handles.image.ROI);
%                 toc  
% 
%                 disp([activity2', activity',stdev', stdev2' ]);
%                 disp([NPixels2', NPixels']);


                windowTitle=['TACT: ' get(handles.figure1, 'Name')];
                h=figure('Name', windowTitle,'NumberTitle' ,'off');
  

                %%for i=1:numberOfROIs
                for i=find(handles.image.VisibleROIs)   
                    disp([num2str(i) '   ' contents{i}])

                        if not(IsPCImage)
                            try
                                timeScale=handles.image.time;

                                timeScale=timeScale(1,1:size(activity,2));  % Make as many x-axis items as there are activity items
                                
                                duration=handles.image.duration;

                            catch
                                timeScale=1:numberOfFrames;
                                duration=zeros(size(timeScale));  % Set duration to zero if not known
                            end
                        end

                    % Plot current ROI
                       try
                            plot( timeScale/60, activity(i,:) , '-o', 'MarkerSize',3);
                            %plot( timeScale, stdev(i,:) , '-o', 'MarkerSize',3);
                            hold all
                            xlabel('Time [min]');
                            ylabel('Intensity');
                       catch
                           plot( activity(i,:) , '-o', 'MarkerSize',3);
                           hold all
                           xlabel('Frame number');
                           ylabel('Intensity');
                       end

                end

            %
            % Adjust labels
            %
                if IsPCImage
                    xlabel('Principal component number');
                end
                                            
            %
            % Adjust axis
            %
            try
                haxis=get(h,'CurrentAxes');
                temp=get(haxis,'YLim');
                
                YLow=temp(1);
                YHigh=temp(2);
            catch
            end
                
%                 if ~IsResidualImage      % NOT residual radio button selected
%                     set(haxis,'YLim', [0 YHigh])
%                 end
                
                if min(activity(:))<0      % If negative values, display whole range
                    set(haxis,'YLim', [YLow YHigh])
                end
            %
            % Add legend to TACT curve
            %

                % Number of pixels
                %for i=1:numberOfROIs 
                j=1;
                for i=find(handles.image.VisibleROIs)  
                    newContents{j}=[contents{i} ' (' num2str(NPixels(i)) ' pixels)' ]; % Add pixel count to legend
                    j=j+1;
                end

                %Legend  (TeX formatting off)
                legend(newContents(1:end),'Interpreter','none');  

           %
           % Output for different file formats
           %
                % Cover case where for instance a parametric image is
                % displayed and the durations are kept for future reference
                frameNumbers=1:size(activity,2);
                if size( frameNumbers,2)==1
                    duration=duration(1,1);
                end

                
                %
                % Make struct to export to button
                % 
                
                contents = get(handles.ROINumberMenu,'String')'; % Cell array
                contents={ contents{1:(end-1)}}; % Put "Add ROI" last
               TACThandles = [];
               
               TACThandles.record = handles.record;
               
               TACThandles.TACT.roiNames = contents;
               
               
               TACThandles.image = handles.image;
                
               TACThandles.TACT.frameNumber = frameNumbers';
                try
               TACThandles.TACT.startTime = timeScale';
               TACThandles.TACT.midTime = (timeScale + duration / 2 )';
               TACThandles.TACT.duration = duration';
                catch
                    disp('newTACT error -- time information missing?');
                end
               TACThandles.TACT.tact = activity';
               TACThandles.TACT.std = stdev';
               TACThandles.TACT.pixels = NPixels'; 
                                
                % Add save button to figure
%                 btn = uicontrol('Style', 'pushbutton', 'String', 'TACT to file',...
%                     'Position', [20 20 80 20],...
%                     'Callback', {@SaveTactToFile,TACThandles}); 

                guidata(h,TACThandles);  % Store struct in figure window (equivalent ot how handles is stored in imlook4d)
                
                btn = uicontrol('Style', 'pushbutton', 'String', 'TACT to file',...
                    'Units', 'normalized', ...
                    'Position', [0.80 0.01 0.15 0.05],...
                    'BackgroundColor', 'yellow', ...
                    'Callback', 'SaveTactToFile(gcf, {},guidata(gcf))' ); 
                    %'Callback', {@SaveTactToFile,TACThandles} ); 
 
            %
            % Move TACT plot to top
            %
                set(h,'Visible','on');   
        function save_cellarray(cellarr, filename, header, latex)
            % function save_cellarray(cellarr, filename, header, latex)
            %
            % Save a cell array to an ASCII openmenu, 
            % cells separated by an arbitrary delimiter
            % (default: tab). In Latex-Mode, the delimiter 
            % is ' & ', and the newline is indicated by '\\ \n'.
            %
            % cellarr: 'm' times 'n' Cell Array
            % filename: string, '.txt' is appended if no extension provided
            %    'filename=[]' prints to stdout.
            % header: arbitrary string that is written to 
            %    the openmenu in the first line, e.g. 'date';
            %    can be ommitted or empty.
            % latex: (boolean)

            % Rev.1.0, 02.11.98 (Armin Günter)
            % Rev.1.1, 16.02.99 (A.G.: 'header' can be ommitted or empty)
            % Rev.1.2, 11.11.99 (A.G.: '.txt' appended only if apparently no
            %    other extension exists)
            % Rev.1.3, 12.07.2000 (A.G.: '\r\n' as newline after the header
            % line;
            %    optional Latex-Mode)
            % Rev.1.4, 26.08.2001 (A.G.: 'filename=[]' prints to stdout.)

            if ~exist('latex','var'), latex = 0; end
            if latex
               nl = '\\\\\r\n';
               del = ' & ';
            else
               nl = '\r\n';
               del = '\t';
            end

            % create new openmenu or write to stdout:
            if ~isempty(filename)
               % check for openmenu extension
               ipt = find(imlook4d_fliplr(filename) == '.'); %#ok<EFIND>
               if isempty(ipt)
                  filename = [filename '.txt'];
               end

               fid = fopen(filename, 'W');
               if fid == -1
                  error(['imlook4d/save_cellarray ERROR1: Problem writing to the file ' filename])
               end
            else
               fid = 1;
            end

            % write header if existent
            if exist('header') %#ok<EXIST>
               if ~isempty(header)
                  success = fprintf(fid, ['%s' nl], header);
                  if ~success
                     error(['imlook4d/save_cellarray ERROR2:Problem writing to the file ' filename])
                  end
               end
            end
            [m, n] = size(cellarr);
            for i = 1:m
               % create new line
               line = [];
               for j = 1:n-1
                  line = [line sprintf(['%s' del], num2str(cellarr{i, j})) ]; %#ok<AGROW>
               end
               line = [line sprintf('%s', num2str(cellarr{i, n}))]; %#ok<AGROW>
               success = fprintf(fid, ['%s' nl], line);
               if ~success
                  error(['imlook4d/save_cellarray ERROR3:Problem writing to the file ' filename])
               end
            end

            if fid ~= 1, fclose(fid); end
        function myhistogram(handles,htype)
            %img = getimage(gcbf);
            slice=round(get(handles.SliceNumSlider,'Value'));
            frame=round(get(handles.FrameNumSlider,'Value')); 
            img=handles.image.Cdata(:,:,slice,frame);
            
            ROINumberMenu=get(handles.ROINumberMenu);
            currentROI=ROINumberMenu.Value;

        % NEW plot displayed and complete histograms
        
            figure;
    
            % Define histogram within displayed range 
            limits=get(handles.ColorBar,'Ylim');

            minvalue=limits(1);
            maxvalue=limits(2);
            step=(maxvalue-minvalue)/30;
            
            % Get approximate step length (from whole range)
            NMAX=100;           % Max number of steps
            SAFENUMBER=200;     % Break out if more than 200 bins (takes forever)
            stepLength=(max(img(:))-min(img(:)) )/NMAX;
            
            % Calculate exact step length (fit exactly within display range)
            NDisplayRange=round((maxvalue-minvalue)/stepLength)+1;  % Can afford one extra histogram bin
            stepLength=(maxvalue-minvalue)/NDisplayRange;
            
            % Create values for histogram BELOW displayed range 
            %(going down from minvalue)
            edges1=minvalue;
            while (edges1(1)>=min(img(:)) )&& length(edges1)<=SAFENUMBER
                edges1=[ (edges1(1)-stepLength) edges1];
            end   
            [freq1,value1]=histc(img(:),edges1);    
            
            % Create edge values for histogram WITHIN displayed range 
            % between minvalue and maxvalue (=displayed range)
            i=1;
            edges2(i)=minvalue;
            while (edges2(i)<=maxvalue)&& length(edges2)<=SAFENUMBER
                i=i+1;
                edges2(i)=edges2(i-1)+stepLength;
            end
            [freq2,value2]=histc(img(:),edges2);
     
            % Create values for histogram ABOVE displayed range
            edges3=maxvalue;
            while (edges3(end)<=max(img(:)) )&& length(edges3)<=SAFENUMBER
                edges3=[ edges3 (edges3(end)+stepLength) ];
                length(edges3)
            end
            [freq3,value3]=histc(img(:),edges3);    
     
            % Create values for histogram in current ROI
            edges4 = unique( [edges1(1:end-1) edges2(1:end-1) edges3] );
            indeces4=find( handles.image.ROI(:,:,slice) == currentROI  );
            [freq4,value4]=histc( img(indeces4), edges4); 
            
            
            % Create statistics
            img=img(:);
            indeces2=find( (img>=minvalue & img<=maxvalue)  );
            indeces3=find( (img>=minvalue));
                        
            myAnnotation={...
                '\bfPixels WITHIN displayed range:\rm', ...
            	[num2str( (mean(img(indeces2))) )...
                ' +/- ' num2str( (std( img(indeces2) ) )) ...
            	'  (median=' num2str( (median(img(indeces2))) ) ')'] , ...
                ...
                '\bfPixels WITHIN and ABOVE displayed range :\rm', ...
            	[num2str( (mean(img(indeces3))) )...
                ' +/- ' num2str( (std( img(indeces3) ) )) ...
            	'  (median=' num2str( (median(img(indeces3))) ) ')']  , ...
                ...
                '\bfAll pixels IN IMAGE :\rm', ...
            	[num2str( (mean(img(:))) )...
                ' +/- ' num2str( (std( img(:) ) )) ...
            	'  (median=' num2str( (median(img(:))) ) ')'], ...
                ...
                '\bfPixels IN ROI :\rm', ...
            	[num2str( (mean(img(indeces4))) )...
                ' +/- ' num2str( (std( img(indeces4) ) )) ...
            	'  (median=' num2str( (median(img(indeces4))) ) ')'] ...
                };            
            
            
            % Plot histograms 
            % (stepLength/2 lets histogram bar-width accurately show range)
            bar( edges1+stepLength/2,freq1,'w');
            hold on
            bar(edges2+stepLength/2,freq2, 'r');
            hold on
            bar(edges3+stepLength/2,freq3, 'b');
            
            bar(edges4+stepLength/2,freq4, 'g');   
            
            legend('pixels below displayed range', 'pixels within displayed range', 'pixels above display range', 'pixels in ROI');
            xlabel('pixel value');
            ylabel('frequency');

            annotation('textbox', [0.3,0.6,0.1,0.1],'FontSize', 9, 'String', myAnnotation);
       
            hold off
            
            % Draw lines indicating ranges
            %YPOS=max([freq1; freq2; freq3])/10; % Position 1/10th of height
            %YPOS=[YPOS YPOS];
            YPOS1=max(freq1); YPOS1=[YPOS1 YPOS1];
            YPOS2=max(freq2); YPOS2=[YPOS2 YPOS2];
            YPOS3=max(freq3); YPOS3=[YPOS3 YPOS3];
            line('XData', [min(img) minvalue],'YData', YPOS1,'Color','k')
            line('XData', [minvalue maxvalue ],'YData', YPOS2,'Color','r')
            line('XData', [maxvalue max(img)],'YData', YPOS3,'Color','b')

            
            % Make editable
            plotedit(gcf,'on')
            return;
        function adjustSliderRanges(handles)
       % This function adjusts the slider ranges
       % when imlook4d is changed.
       %
       % For instance:
       % - import from workspace may change number of frames or slices
       [r,c,z,frames]=size(handles.image.Cdata);
       
     
        % one or multiple slides
        if z == 1
            % Make slice slider and edit invisible
            % disp('Single slice')
            set(handles.SliceNumSlider,'visible','off','Value', 1);
            set(handles.SliceNumEdit,'visible','off');
            set(handles.SliceText,'visible','off');
        else
            % disp('Multiple slices')
            
             % wrong number of slices?
             if ( get(handles.SliceNumSlider,'Max')~=z)
                % Change slider range
                set(handles.SliceNumSlider,'visible','on','Min',1,'Max',z,...
                    'SliderStep',[1.0/double(z-1) 1.0/double(z-1)]);
             end
             
            % slice number > number of slices ?
            if ( get(handles.SliceNumSlider,'Value')>z)
                set(handles.SliceNumSlider,'visible','on','Min',1,'Max',z,...
                    'Value',round(z/2),...
                    'SliderStep',[1.0/double(z-1) 1.0/double(z-1)]);
                set(handles.SliceNumEdit,'String',num2str(round(z/2)) );  
            end

            
            % Show slice slider and edit box
            set(handles.SliceNumEdit,'visible','on');
            set(handles.SliceText,'visible','on');
        end

        % one or multiple frames
        if frames == 1
            % Make frame slider and edit invisible
            % disp('Single frame')
            set(handles.FrameNumSlider,'visible','off','Value',1);
            set(handles.FrameNumEdit,'visible','off');
            set(handles.FrameText,'visible','off');
            
            set(handles.PC_low_slider,'visible','off');
            set(handles.PC_high_slider,'visible','off');
            set(handles.PC_low_edit,'visible','off');
            set(handles.PC_high_edit,'visible','off');
        else
            % disp('Multiple frames')
            
            set(handles.FrameNumSlider,'visible','on','Min',1,'Max',frames,...
                'SliderStep',[1.0/double(frames-1) 1.0/double(frames-1)]);
            set(handles.FrameNumEdit,'visible','on');
            set(handles.FrameText,'visible','on');
            
            set(handles.PC_low_slider,'visible','on');
            set(handles.PC_high_slider,'visible','on');
            set(handles.PC_high_slider, 'Max',frames);
            set(handles.PC_high_edit, 'String',num2str(frames));
            
            % Change number of Principal components if needed
            %if ( get(handles.PC_high_slider,'Value') > frames)
            %if ( true )
            if ( get(handles.PC_high_slider,'Value') > get(handles.PC_high_slider,'Max') )
                set(handles.PC_low_slider,'Min',1,'Max',frames,...
                    'SliderStep',[1.0/double(frames-1) 1.0/double(frames-1)]);
                set(handles.PC_high_slider,'Min',1,'Max',frames,...
                    'SliderStep',[1.0/double(frames-1) 1.0/double(frames-1)],...
                    'Value', frames);
            end
            
%             set(handles.PC_high_slider,'Min',1,'Max',frames,...
%                 'SliderStep',[1.0/double(frames-1) 1.0/double(frames-1)],...
%                 'Value', frames);
            set(handles.PC_high_edit,'visible','on','String',num2str(frames)); 
            
            set(handles.PC_low_edit,'visible','off');  
            set(handles.PC_low_slider,'visible','off'); 
                      
            guidata(handles.figure1, handles)
        end
        function version=getImlook4dVersion()
            % Get version number from About.txt
%                 [pathstr1,name,ext] = fileparts(which('imlook4d'));
%                 vs =  fileread([pathstr1 filesep 'HELP' filesep 'About.txt']);
% 
%                 startIndex=findstr(vs, 'version');
%                 characters=findstr(vs(startIndex:end), '<BR>');
%                 version=vs(startIndex+8:startIndex+characters-2); 


                % Formats from pre-commit-hook.bat, available in
                % version.txt:
                % 510
                % 493:510
                % 510M
                % 493:510M
                % These numbers are one digit behind.
                % I want to extract the last number and add one to it
                
                 str =  fileread('version.txt');
                 t=str2double( regexp(str,'\d+', 'match') ); % get all double values
                 version = num2str( t(end) + 1);  
                 
        function flag=isMultipleCall()
              flag = false; 
              % Get the stack
              s = dbstack();
              if numel(s)<=2
                % Stack too short for a multiple call
                return
              end

              % How many calls to the calling function are in the stack?
              names = {s(:).name};
              TF = strcmp(s(2).name,names);
              count = sum(TF);
              if count>1
                % More than 1
                flag = true; 
              end
            disp(['isMultipleCall depth=' num2str(numel(s))]);

            
% Dummy function to override duration from timefun toolbox in Matlab 2014b
        function duration ()
% 