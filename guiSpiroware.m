function varargout = guiSpiroware(varargin)
% GUISPIROWARE M-file for guiSpiroware.fig
%      GUISPIROWARE, by itself, creates a new GUISPIROWARE or raises the existing
%      singleton*.
%
%      H = GUISPIROWARE returns the handle to a new GUISPIROWARE or the handle to
%      the existing singleton*.
%
%      GUISPIROWARE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUISPIROWARE.M with the given input arguments.
%
%      GUISPIROWARE('Property','Value',...) creates a new GUISPIROWARE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUISPIROWARE before gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiSpiroware_OpeningFcn via varargin.
%
%      *See GUISPIROWARE Options on GUIDE's Tools menu.  Choose "GUISPIROWARE allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiSpiroware

% Last Modified by GUIDE v2.5 29-Mar-2017 11:03:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiSpiroware_OpeningFcn, ...
                   'gui_OutputFcn',  @guiSpiroware_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% Using non-native system dialogs as workaround for an error occuring
% for large directory listings in uigetfile....
setappdata(0,'UseNativeSystemDialogs',false);

% --- Executes just before guiSpiroware is made visible.
function guiSpiroware_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiSpiroware (see VARARGIN)

% Choose default command line output for guiSpiroware
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiSpiroware wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if isempty(get(hObject,'UserData'))
    parameters=setParametersSpirowareMassSpec('realBreath',1);
    
    parameters.Simulation.torontoFile = 0;
    parameters.Simulation.torontoFile = 0.005;

    defaultParameters=setParametersSpirowareMassSpec('realBreath',0);
    oldVersionString=parameters.Simulation.versionString;
    newVersionString=defaultParameters.Simulation.versionString;
    
    foundPattern=findstr(oldVersionString,'.');
    if length(foundPattern)>1
        oldVersionString=oldVersionString(1:foundPattern(2)-1);
    end
    foundPattern=findstr(newVersionString,'.');
    if length(foundPattern)>1
        newVersionString=newVersionString(1:foundPattern(2)-1);
    end
    
    if ~strcmp(oldVersionString,newVersionString)
        warningString=sprintf('%s of parametersSpiroware.mat is older than %s! Default settings used instead!',oldVersionString,newVersionString);
        handle=warndlg(warningString,'Warning (parametersSpiroware.mat)','non-modal');
        uiwait(handle);
        parameters=defaultParameters;
    else
        parameters.Simulation.versionString=defaultParameters.Simulation.versionString;
    end
    
    set(handles.output,'UserData',parameters);
end
initializeParameters(hObject, handles)

% --- Outputs from this function are returned to the command line.
function varargout = guiSpiroware_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in choiceButton.
function choiceButton_Callback(hObject, eventdata, handles)
% hObject    handle to choiceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    interfaceObject=findobj(handles.output,'Enable','on'); % disable interface during evaluation
    set(interfaceObject,'Enable','off');
    drawnow;
    
    parameters=get(handles.output,'UserData');
    
    pathName=get(handles.filePath,'String');
    if ~exist(pathName,'dir')
        if exist(parameters.Simulation.directoryDatafiles,'dir')
            pathName=parameters.Simulation.directoryDatafiles;
        else
            pathName=pwd;
        end
    end
    [fileName,pathName] = guiFileDialog(pathName,'on');
    if ~isequal(pathName,0)
        parameters.Simulation.directoryDatafiles=pathName;
    end
    if isequal(fileName,0)
        set(interfaceObject,'Enable','on');
        return;
    end
    set(handles.filePath,'String',pathName)
    set(handles.fileList,'String',fileName)
    set(handles.fileList,'Value',1)             % reset choice to 1st entry.
    
    set(handles.output,'UserData',parameters);

catch err
    fclose('all');
    warning('(choiceButton_Callback): %s (in %s on line %g)\n', err.message,err.stack(1).name,err.stack(1).line);
end % try/catch

set(interfaceObject,'Enable','on');

%set(handles.resultDirPath,'String','ResultDirPath')



% --- Executes on selection change in fileList.
function fileList_Callback(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns fileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileList

try
    interfaceObject=findobj(handles.output,'Enable','on'); % disable interface during evaluation
    set(interfaceObject,'Enable','off');
    drawnow;

    sourcePathName=get(handles.filePath,'String');
    choice=get(hObject,'Value');
    fileList=get(hObject,'String');
    if ~iscell(fileList)
        fileList={fileList};
    end
    fileName=fileList(choice);
    parameters=get(handles.output,'UserData');
    destinationPathName=get(handles.resultDirPath,'String');
    if ~exist(destinationPathName,'dir')
        buttonString = questdlg('Destination path does no longer exist...!','Warning','Choose new path','Use default','Use default');
        if strcmp(buttonString,'Use default')
            destinationPathName=getenv('TEMP');
        else
            destinationPathName=uigetdir(sourcePathName,'select result directory'); % starts at the present choice file directory!
            if isequal(destinationPathName,0)
                warning('(fileList_Callback): setting default destination path: no regular user choice!')
                destinationPathName=getenv('TEMP');
            end
        end
        set(handles.resultDirPath,'String',destinationPathName)
        parameters.Simulation.resultDirPath=destinationPathName;
    end
    
    if exist(strcat(sourcePathName,cell2mat(fileName)),'file')
        parameters=applyCorrectionSpirowareMassSpec(sourcePathName,fileName,destinationPathName,parameters,1);
        if parameters.Simulation.manualState    % reflect changed parameters in Calibration section
            coefficientsOptimal =	parameters.Calibration.coefficientsOptimal;
            time                =   parameters.Calibration.time;
            filePath=fullfile(sourcePathName,cell2mat(fileName(end)));
            set(handles.calibrationPath,'String',filePath);         % reflect last parameter settings
            set(handles.settingsPath,   'String','settingPath');    % reset parameter settings file
            set(handles.valDelayCO2,    'String',num2str(coefficientsOptimal(1)))
            set(handles.valDelayCO2,	'String',num2str(coefficientsOptimal(1)))
            set(handles.valDelayO2,     'String',num2str(coefficientsOptimal(2)))
            set(handles.valTauCO2,      'String',num2str(coefficientsOptimal(3)))
            set(handles.valkCO2,        'String',num2str(coefficientsOptimal(4)))
            set(handles.valkO2,         'String',num2str(coefficientsOptimal(5)))
            set(handles.valkMMss,       'String',num2str(coefficientsOptimal(6)))
            set(handles.valtmin,        'String',num2str(time.min))
            set(handles.valtmax,        'String',num2str(time.max))
        end
        set(handles.output,         'UserData',parameters);
    else
        disp('no valid file selected')
    end
    
catch err
    fclose('all');
    warning('(fileList_Callback): %s (in %s on line %g)\n', err.message,err.stack(1).name,err.stack(1).line);
end % try/catch

set(interfaceObject,'Enable','on');



% --- Executes during object creation, after setting all properties.
function fileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calbrationButton.
function calbrationButton_Callback(hObject, eventdata, handles)
% hObject    handle to calbrationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    interfaceObject=findobj(handles.output,'Enable','on'); % disable interface during evaluation
    set(interfaceObject,'Enable','off');
    drawnow;
    
    parameters=get(handles.output,'UserData');

    pathName=get(handles.calibrationPath,'String');
    if ~exist(pathName,'file')
        if exist(parameters.Simulation.directoryCalibration,'dir')
            pathName=parameters.Simulation.directoryCalibration;
        else
            pathName=pwd;
        end
    else
        pathName = fileparts(pathName);
    end
    
    [fileName,pathName] = guiFileDialog(pathName,'off');
    if ~isequal(pathName,0)
        parameters.Simulation.directoryCalibration=pathName;
    end
    if isequal(fileName,0)
        set(interfaceObject,'Enable','on');
        return;
    end
    
    parameters=setSpirowareType(fileName,parameters);
    filePath=fullfile(pathName,fileName);
    set(handles.calibrationPath,'String',filePath);
    
    set(handles.valDelayCO2,    'String','delay')
    set(handles.valDelayO2,     'String','delay')
    set(handles.valTauCO2,      'String','tau')
    set(handles.valkCO2,        'String','k')
    set(handles.valkO2,         'String','k')
    set(handles.valkMMss,       'String','k')
    
    set(handles.valtmin,        'String','tmin')
    set(handles.valtmax,        'String','tmax')
    
    set(handles.valBTPSexp,     'String','BTPSexp');
    set(handles.valBTPSinsp,    'String','BTPSinsp');
    
    recalibrationState=get(handles.recalibrationButton,'Value');
    
    [parameters]=getCorrectionCoeff(recalibrationState,filePath,parameters,1,1);
    set(handles.output,'UserData',parameters);
    
    coefficientsOptimal =	parameters.Calibration.coefficientsOptimal;
    time                =   parameters.Calibration.time;
    
    set(handles.valDelayCO2,    'String',num2str(coefficientsOptimal(1)))
    set(handles.valDelayO2,     'String',num2str(coefficientsOptimal(2)))
    set(handles.valTauCO2,      'String',num2str(coefficientsOptimal(3)))
    set(handles.valkCO2,        'String',num2str(coefficientsOptimal(4)))
    set(handles.valkO2,         'String',num2str(coefficientsOptimal(5)))
    set(handles.valkMMss,       'String',num2str(coefficientsOptimal(6)))
    
    set(handles.valtmin,        'String',num2str(time.min))
    set(handles.valtmax,        'String',num2str(time.max))
    
    set(handles.settingsPath,   'String','settingPath')
    
    parameters=setBTPS(handles,parameters);
    
    set(handles.output,'UserData',parameters);
    
catch err
    fclose('all');
    warning('(calbrationButton_Callback): %s (in %s on line %g)\n', err.message,err.stack(1).name,err.stack(1).line);
end % try/catch

set(interfaceObject,'Enable','on');




% --- Executes on button press in repeatButton.
function repeatButton_Callback(hObject, eventdata, handles)
% hObject    handle to repeatButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    interfaceObject=findobj(handles.output,'Enable','on'); % disable interface during evaluation
    set(interfaceObject,'Enable','off');
    drawnow;
    
    pathName=get(handles.calibrationPath,'String');
    if ~exist(pathName,'file')
        error(sprintf('INFO: file %s does not exist, use Calibrate instead',pathName));
    end
    
    recalibrationState=get(handles.recalibrationButton,'Value');
    parameters=get(handles.output,'UserData');
    
    [parameters]=getCorrectionCoeff(recalibrationState,pathName,parameters,0,1);
    set(handles.output,'UserData',parameters);
    
    coefficientsOptimal =	parameters.Calibration.coefficientsOptimal;
    time                =   parameters.Calibration.time;
    
    set(handles.valDelayO2,     'String',num2str(coefficientsOptimal(2)))
    set(handles.valTauCO2,      'String',num2str(coefficientsOptimal(3)))
    set(handles.valkCO2,        'String',num2str(coefficientsOptimal(4)))
    set(handles.valkO2,         'String',num2str(coefficientsOptimal(5)))
    set(handles.valkMMss,       'String',num2str(coefficientsOptimal(6)))
    
    set(handles.valtmin,        'String',num2str(time.min))
    set(handles.valtmax,        'String',num2str(time.max))
    
    set(handles.settingsPath,   'String','settingPath')
    
catch err
    fclose('all');
    warning('(repeatButton_Callback): %s (in %s on line %g)\n', err.message,err.stack(1).name,err.stack(1).line);
end % try/catch

set(interfaceObject,'Enable','on');



% --- Executes on button press in recalibrationButton.
function recalibrationButton_Callback(hObject, eventdata, handles)
% hObject    handle to recalibrationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of recalibrationButton
recalibrationState=get(hObject,'Value');
parameters=get(handles.output,'UserData');
parameters.Operation.recalibration=recalibrationState;
set(handles.output,'UserData',parameters);
fprintf('recalibration is equal %d\n',recalibrationState);



% --- Executes on button press in btpsButton.
function btpsButton_Callback(hObject, eventdata, handles)
% hObject    handle to btpsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btpsButton
btpsState=get(hObject,'Value');
parameters=get(handles.output,'UserData');
parameters.Operation.BTPS=btpsState;
fprintf('BTPS is equal %d\n',btpsState);
parameters=setBTPS(handles,parameters);
set(handles.output,'UserData',parameters);



function tEnv_Callback(hObject, eventdata, handles)
% hObject    handle to tEnv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tEnv as text
%        str2double(get(hObject,'String')) returns contents of tEnv as a double
parameters=get(handles.output,'UserData');
parameters.Operation.Tenv=str2double(get(hObject,'String'));
parameters=setBTPS(handles,parameters);
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function tEnv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tEnv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tBody_Callback(hObject, eventdata, handles)
% hObject    handle to tBody (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tBody as text
%        str2double(get(hObject,'String')) returns contents of tBody as a double
parameters=get(handles.output,'UserData');

parameters.Operation.Tbody=str2double(get(hObject,'String'));

parameters=setBTPS(handles,parameters);

set(handles.output,'UserData',parameters);


% --- Executes during object creation, after setting all properties.
function tBody_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tBody (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEnv_Callback(hObject, eventdata, handles)
% hObject    handle to hEnv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEnv as text
%        str2double(get(hObject,'String')) returns contents of hEnv as a double
parameters=get(handles.output,'UserData');

parameters.Operation.hRelEnv=str2double(get(hObject,'String'));

parameters=setBTPS(handles,parameters);

set(handles.output,'UserData',parameters);


% --- Executes during object creation, after setting all properties.
function hEnv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEnv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hIns_Callback(hObject, eventdata, handles)
% hObject    handle to hIns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hIns as text
%        str2double(get(hObject,'String')) returns contents of hIns as a double
parameters=get(handles.output,'UserData');
parameters.Operation.hRelInsGas=str2double(get(hObject,'String'));
parameters=setBTPS(handles,parameters);
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function hIns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hIns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;
clear;



% --- Executes on button press in oldSetupButton.
function oldSetupButton_Callback(hObject, eventdata, handles)
% hObject    handle to oldSetupButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of oldSetupButton
oldSetupState=get(hObject,'Value');
parameters=get(handles.output,'UserData');
parameters.Simulation.oldSetup=oldSetupState;
set(handles.output,'UserData',parameters);
fprintf('oldSetup input is equal %d\n',oldSetupState);



% --- Executes on button press in verbosityButton.
function verbosityButton_Callback(hObject, eventdata, handles)
% hObject    handle to verbosityButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of verbosityButton
verbosityState=get(hObject,'Value');
parameters=get(handles.output,'UserData');
parameters.Simulation.verb=verbosityState;
set(handles.output,'UserData',parameters);
fprintf('verbosity is equal %d\n',verbosityState);



% --------------------------------------------------------------------
function outputSelection_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to outputSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

parameters=get(handles.output,'UserData');

bfileState=get(handles.bButton,'Value');
parameters.Simulation.bfileOutput=bfileState;
fprintf('bfile is equal %d\n',bfileState);

cfileState=get(handles.cButton,'Value');
parameters.Simulation.cfileOutput=cfileState;
fprintf('cfile is equal %d\n',cfileState);

inselState=get(handles.iButton,'Value');
parameters.Simulation.inselOutput=inselState;
fprintf('insel is equal %d\n',inselState);

leicesterState=get(handles.leicesterButton,'Value');
parameters.Simulation.leicesterOutput=leicesterState;
fprintf('leicester is equal %d\n',leicesterState);

set(handles.output,'UserData',parameters);



% --------------------------------------------------------------------
function inputSelection_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to InputSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData');

aFileState=get(handles.aFileInput,'Value');
parameters.Simulation.aFile=aFileState;
fprintf('aFile input is equal %d\n',aFileState);

bFileState=get(handles.bFileInput,'Value');
parameters.Simulation.bFile=bFileState;
fprintf('bFile input is equal %d\n',bFileState);

if bFileState==1
    %%TODO folgendes im GUI Sperren: Calibration, Signal Correctino,
    %%Report, BTPS, Operation Parameter, Signal Output, per file
    %%calibration
    %set(handle,'enable','on'); 
else
    %%TODO alles obige entsperren
end

sbwMmState=get(handles.sbwMmInput,'Value');
parameters.Simulation.sbwMm=sbwMmState;
fprintf('sbwMm input is equal %d\n',sbwMmState);

sbwPercentState=get(handles.sbwPercentInput,'Value');
parameters.Simulation.sbwPercent=sbwPercentState;
fprintf('sbwPercent input is equal %d\n',sbwPercentState);

heMbwState=get(handles.heMbwInput,'Value');
parameters.Simulation.heMbw=heMbwState;
fprintf('heMbw input is equal %d\n',heMbwState);

set(handles.output,'UserData',parameters);



% --- Executes on button press in quitButton.
function quitButton_Callback(hObject, eventdata, handles)
% hObject    handle to quitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData');
parameters.Calibration.settingsFilePath=strcat(pwd,'\','parametersSpiroware.mat');
save('parametersSpiroware.mat','parameters');
closereq



% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% closing all figures (including MATLAB type figures)
% should be improved to include only children
figureHandles = findall(0,'type','figure');
for h=figureHandles'
    if isempty(strfind(get(h,'name'),'LungSim for '))
        close(h)
    end
end



% --- Executes on button press in loadParameter.
function loadParameter_Callback(hObject, eventdata, handles)
% hObject    handle to loadParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData');

fullPathName=get(handles.settingsPath,'String');
if ~exist(fullPathName,'dir')
    pathName=strcat(pwd,'\*.mat');
end
windowText='Select calibration parameter file';
startDir=fullPathName;
[fileName,pathName] = uigetfile({'*.mat', 'calibration files (*.mat)'},windowText,startDir,'MultiSelect','off');
if ~isequal(fileName,0)
    fullName=strcat(pathName,fileName);
    if exist(fullName,'file')
        actualParameters=parameters;
        load(fullName);
        
        loadedVersionString=parameters.Simulation.versionString;
        actualVersionString=actualParameters.Simulation.versionString;
    
        if ~strcmp(loadedVersionString,actualVersionString)
            warningString=sprintf('%s of parametersSpiroware.mat is older than %s!\nMissing defaults are updated!\n',loadedVersionString,actualVersionString);
            handle=warndlg(warningString,'Warning (parametersSpiroware.mat)','non-modal');
            uiwait(handle);
            
            names1=fieldnames(actualParameters);
            for i=1:length(names1)
                names2=fieldnames(actualParameters.(names1{i}));
                for j=1:length(names2)
                    if ~isfield(parameters.(names1{i}),names2{j})
                        fprintf('(loadParameter) updating %s.%s=%s\n',names1{i},names2{j},mat2str(actualParameters.(names1{i}).(names2{j})));
                        parameters.(names1{i}).(names2{j})=actualParameters.(names1{i}).(names2{j});
                    end
                end
            end
            parameters.Simulation.versionString=actualParameters.Simulation.versionString;	% update of version string
        end
    end
    
    if parameters.Simulation.torontoFile ~= actualParameters.Simulation.torontoFile
        warningString = sprintf('cannot use settings file: torontoFile=%g (instead of %g); using old settings',parameters.Simulation.torontoFile,actualParameters.Simulation.torontoFile);
        msgbox(warningString,'Load settings','warn');
        warning(warningString)
        parameters=actualParameters;
    else
        set(handles.settingsPath,'String',parameters.Calibration.settingsFilePath)
    end

else
    fprintf('cannot load calibration parameter file\n');
end

set(handles.output,'UserData',parameters);

initializeParameters(hObject, handles)




% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData');

fileName=strcat('calibration_',date);
fullName=strcat(pwd,'/',fileName);
[fileName,pathName] = uiputfile({'*.mat', 'calibration files (*.mat)'},'save settings file name',fullName);
if isequal(fileName,0)
    fprintf('cannot save calibration parameter file, no file chosen\n');
else
    fullName=strcat(pathName,fileName);
    parameters.Calibration.settingsFilePath=fullName;
    save(fullName,'parameters');
    set(handles.settingsPath,'String',fullName);
    set(handles.output,'UserData',parameters);
end



function parameters = setBTPS(handles,parameters)
% manipulates BTPS related widgets (and settings)
parameters=evaluateBTPS(parameters);

dynamicState=parameters.Simulation.dynamicState;

set(handles.valBTPSexp, 'String',num2str(parameters.Calibration.factorBTPSexp));
set(handles.valBTPSinsp,'String',num2str(parameters.Calibration.factorBTPSinsp));

backgroundColor=get(0,'defaultUicontrolBackgroundColor');
foregroundColor=get(0,'defaultUicontrolForegroundColor');

if dynamicState 
    set(handles.valBTPSexp, 'Background',backgroundColor);
    set(handles.valBTPSinsp,'Background',backgroundColor);
    set(handles.valBTPSexp, 'Foreground',[0.5 0.5 0.5]);
    set(handles.valBTPSinsp,'Foreground',[0.5 0.5 0.5]);
else
    set(handles.valBTPSexp, 'Background','white');
    set(handles.valBTPSinsp,'Background','white');
    set(handles.valBTPSexp, 'Foreground',foregroundColor);
    set(handles.valBTPSinsp,'Foreground',foregroundColor);
end


function initializeParameters(hObject, handles)
% initializes parameters from file
parameters=get(handles.output,'UserData');

parameters.Simulation.torontoFile = 0;
parameters.Simulation.dt = 0.005;

backgroundColor=get(0,'defaultUicontrolBackgroundColor');
foregroundColor=get(0,'defaultUicontrolForegroundColor');

parameters=evaluateBTPS(parameters);

set(handles.tEnv,                       'String',num2str(parameters.Operation.Tenv))
set(handles.tBody,                      'String',num2str(parameters.Operation.Tbody))
set(handles.tIns,                       'String',num2str(parameters.Operation.TinsGas))
set(handles.hEnv,                       'String',num2str(parameters.Operation.hRelEnv))
set(handles.hIns,                       'String',num2str(parameters.Operation.hRelInsGas))
set(handles.pRef,                       'String',num2str(parameters.Operation.Pref/100))
set(handles.tSensor,	                'String',num2str(parameters.Operation.Tsensor))
set(handles.tExpEff,	                'String',num2str(parameters.Operation.TexpEff))
set(handles.tBody1,                     'String',num2str(parameters.Operation.Tbody1))
set(handles.tBody2,                     'String',num2str(parameters.Operation.Tbody2))

set(handles.delayFlow,                  'String',num2str(parameters.Calibration.delayFlow))

set(handles.vPre,                       'String',num2str(parameters.Device.volumePrecap))
set(handles.vPost,                      'String',num2str(parameters.Device.volumePostcap))

set(handles.vBody1,                     'String',num2str(parameters.Device.volumeBody1))
set(handles.vBody2,                     'String',num2str(parameters.Device.volumeBody2))

set(handles.tauBody1,                   'String',num2str(parameters.Device.tauBody1))
set(handles.tauBody2,                   'String',num2str(parameters.Device.tauBody2))
set(handles.tauTemp,                    'String',num2str(parameters.Device.tauTemp))

set(handles.responseButton,             'Value', parameters.Operation.response)
set(handles.tauFix,                     'String',num2str(parameters.Simulation.tauFix))

set(handles.deltaCO2O2,                 'String',num2str(parameters.Operation.deltaCO2O2))
set(handles.deltaCO2MMss,               'String',num2str(parameters.Operation.deltaCO2MMss))
set(handles.dTauCO2,                    'String',num2str(parameters.Operation.dTauCO2))

if parameters.Operation.response 
    set(handles.tauFix,'Background','white','Foreground',foregroundColor);
else
    set(handles.tauFix,'Background',backgroundColor,'Foreground',[0.5 0.5 0.5]);
end

set(handles.recalibrationButton,        'Value', parameters.Operation.recalibration)
set(handles.btpsButton,                 'Value', parameters.Operation.BTPS)
set(handles.verbosityButton,            'Value', parameters.Simulation.verb)

set(handles.bButton,                    'Value', parameters.Simulation.bfileOutput)
set(handles.cButton,                    'Value', parameters.Simulation.cfileOutput)
set(handles.iButton,                    'Value', parameters.Simulation.inselOutput)
set(handles.leicesterButton,            'Value', parameters.Simulation.leicesterOutput)

set(handles.settingsButton,             'Value', parameters.Simulation.settingsState)
set(handles.manualButton,               'Value', parameters.Simulation.manualState)
set(handles.autoButton,                 'Value', parameters.Simulation.autoState)

set(handles.aFileInput,                 'Value', parameters.Simulation.aFile)
set(handles.bFileInput,                 'Value', parameters.Simulation.bFile)
set(handles.sbwMmInput,                 'Value', parameters.Simulation.sbwMm)
set(handles.sbwPercentInput,            'Value', parameters.Simulation.sbwPercent)
set(handles.heMbwInput,                 'Value', parameters.Simulation.heMbw)

set(handles.slowButton,                 'Value', parameters.Simulation.slowState)
set(handles.fastButton,                 'Value', parameters.Simulation.fastState)

set(handles.staticButton,               'Value', parameters.Simulation.staticState)
set(handles.dynamicButton,              'Value', parameters.Simulation.dynamicState)

set(handles.n2mbwButton,                'Value', parameters.Simulation.n2mbwAnalysis)
set(handles.dtgmbwButton,               'Value', parameters.Simulation.dtgmbw)
set(handles.dtgmbwButtonBaby,           'Value', parameters.Simulation.dtgmbwBaby)
set(handles.dtgsbwButton,               'Value', parameters.Simulation.dtgsbwAnalysis)
set(handles.plainButton,                'Value', parameters.Simulation.plainAnalysis)
set(handles.conversionButton,           'Value', parameters.Simulation.conversionAnalysis)
set(handles.tidalButton,                'Value', parameters.Simulation.tidalAnalysis)

set(handles.exclusionLimit,             'String',num2str(parameters.Simulation.exclusionLimit*100))

if parameters.Simulation.n2mbwAnalysis || parameters.Simulation.dtgmbwAnalysis
    set(handles.ScondSacinButton, 'Enable','on')
    set(handles.exclusionLimit, 'Enable','on')
    set(handles.exclusionLimitText, 'Enable','on')
    set(handles.onlySmallButton, 'Enable','on')
    set(handles.ScondSacinCheckButton, 'Enable','on')
    set(handles.TOevaluationButton, 'Enable','on')
    set(handles.lciStandardButton, 'Enable','on')
    set(handles.lciByFitButton, 'Enable','on')
    set(handles.capnoIndicesButton, 'Enable','on')
else
    set(handles.ScondSacinButton, 'Enable','off')
    set(handles.exclusionLimit, 'Enable','off')
    set(handles.exclusionLimitText, 'Enable','off')
    set(handles.onlySmallButton, 'Enable','off')
    set(handles.ScondSacinCheckButton, 'Enable','off')
    set(handles.TOevaluationButton, 'Enable','off')
    set(handles.lciStandardButton, 'Enable','off')
    set(handles.lciByFitButton, 'Enable','off')
    set(handles.capnoIndicesButton, 'Enable','off')
    set(handles.capnoCheckButton, 'Enable','off')
end

if parameters.Simulation.dtgsbwAnalysis
    set(handles.capnoIndicesButton,     'Enable','on')
    set(handles.capnoCheckButton,       'Enable','on')
end

if parameters.Simulation.tidalAnalysis || parameters.Simulation.n2mbwAnalysis || parameters.Simulation.dtgmbwAnalysis
    set(handles.tidalMeanButton,        'Enable','on')
    set(handles.capnoIndicesButton,     'Enable','on')
    set(handles.capnoCheckButton,       'Enable','on')
else
    set(handles.tidalMeanButton,        'Enable','off')
    set(handles.capnoIndicesButton,     'Enable','off')
    set(handles.capnoCheckButton,       'Enable','off')
end

set(handles.lciStandardButton,      	'Value', parameters.Simulation.lciStandard)
set(handles.lciByFitButton,          	'Value', parameters.Simulation.lciByFit)

set(handles.ScondSacinButton,           'Value', parameters.Simulation.ScondSacin)
if parameters.Simulation.ScondSacin
    set(handles.exclusionLimit,         'Enable','on')
    set(handles.exclusionLimitText,     'Enable','on')
    set(handles.onlySmallButton,        'Enable','on')
    set(handles.ScondSacinCheckButton, 	'Enable','on')
else
    set(handles.exclusionLimit,         'Enable','off')
    set(handles.exclusionLimitText,     'Enable','off')
    set(handles.onlySmallButton,        'Enable','off')
    set(handles.ScondSacinCheckButton,  'Enable','off')
end
set(handles.onlySmallButton,            'Value', parameters.Simulation.onlySmall)
set(handles.ScondSacinCheckButton,      'Value', parameters.Simulation.ScondSacinCheck)

set(handles.capnoIndicesButton,      	'Value', parameters.Simulation.CapnoIndices)
set(handles.capnoCheckButton,           'Value', parameters.Simulation.CapnoCheck)
if parameters.Simulation.CapnoIndices
    set(handles.capnoCheckButton,       'Enable','on')
else
    set(handles.capnoCheckButton,       'Enable','off')
end

set(handles.nBreathTidal,               'String',num2str(parameters.Simulation.nBreathTidal))
set(handles.fromBreathTidal,            'String',num2str(parameters.Simulation.fromBreathTidal))

set(handles.TOevaluationButton,      	'Value', parameters.Simulation.TOevaluation)

set(handles.onlySmallButton,            'Value', parameters.Simulation.onlySmall)

set(handles.croppingButton,             'Value', parameters.Simulation.croppingState)
set(handles.onlyPlotButton,             'Value', parameters.Simulation.onlyPlotState)

set(handles.graphButton,                'Value', parameters.Simulation.graphState)

set(handles.rmsCrit,                    'String',num2str(parameters.Simulation.rmsCrit*100)) % ratio as % value
set(handles.interactiveYesButton,       'Value', parameters.Simulation.interactiveYes)
set(handles.interactiveNoButton,        'Value', parameters.Simulation.interactiveNo)
set(handles.interactiveDeviationButton,	'Value', parameters.Simulation.interactiveDeviation)

if parameters.Simulation.interactiveNo 
    set(handles.rmsCrit,'Background',backgroundColor,'Foreground',[0.5 0.5 0.5]);
else
    set(handles.rmsCrit,'Background','white','Foreground',foregroundColor);
end

set(handles.fileCalibrationModifier,    'String',parameters.Simulation.fileCalibrationModifier)
set(handles.fileCalibrationYesButton,   'Value', parameters.Simulation.fileCalibrationYes)
set(handles.fileCalibrationNoButton,    'Value', parameters.Simulation.fileCalibrationNo)
if parameters.Simulation.fileCalibrationNo
    set(handles.fileCalibrationModifier,'Background',backgroundColor,'Foreground',[0.5 0.5 0.5]);
else
    set(handles.fileCalibrationModifier,'Background','white','Foreground',foregroundColor);
end

set(handles.slopesButton,               'Value', parameters.Simulation.slopesState)
set(handles.minVentButton,              'Value', parameters.Simulation.minVentState)

if ~isempty(parameters.Calibration.coefficientsOptimal)
    set(handles.calibrationPath,        'String',parameters.Calibration.filePath)
    
    set(handles.valDelayCO2,            'String',num2str(parameters.Calibration.coefficientsOptimal(1)))
    set(handles.valDelayO2,             'String',num2str(parameters.Calibration.coefficientsOptimal(2)))
    set(handles.valTauCO2,              'String',num2str(parameters.Calibration.coefficientsOptimal(3)))
    set(handles.valkCO2,                'String',num2str(parameters.Calibration.coefficientsOptimal(4)))
    set(handles.valkO2,                 'String',num2str(parameters.Calibration.coefficientsOptimal(5)))
    set(handles.valkMMss,               'String',num2str(parameters.Calibration.coefficientsOptimal(6)))

    set(handles.valtmin,                'String',num2str(parameters.Calibration.time.min))
    set(handles.valtmax,                'String',num2str(parameters.Calibration.time.max))
end

parameters=setBTPS(handles,parameters);

if ~strcmp('',parameters.Calibration.settingsFilePath)
    set(handles.settingsPath,	        'String',parameters.Calibration.settingsFilePath);
end
set(handles.versionString,              'String',parameters.Simulation.versionString)

set(handles.resultDirPath,              'String',parameters.Simulation.resultDirPath);

switch parameters.Simulation.MMeeMethod
    case 'MMeeR98'
        set(handles.MMeeButtonGroup,            'SelectedObject', handles.MMeeR98);    
    case 'MMeeRMean'
        set(handles.MMeeButtonGroup,            'SelectedObject', handles.MMeeRMean);  
    case 'MMeeRMedian'
        set(handles.MMeeButtonGroup,            'SelectedObject', handles.MMeeRMedian);  
    case 'MMeeRFit'
        set(handles.MMeeButtonGroup,            'SelectedObject', handles.MMeeRFit);  
    otherwise
        set(handles.MMeeButtonGroup,            'SelectedObject', handles.MMeeR98);  
end

set(handles.MMeeTMin,                   'String',   parameters.Simulation.MMeeTMin*100);
set(handles.MMeeTMax,                   'String',   parameters.Simulation.MMeeTMax*100);

set(handles.LCIbyFitAutoVal,            'Value',    parameters.Simulation.LCIbyFitAutoVal);
set(handles.LCIbyFitManVal,             'Value',    parameters.Simulation.LCIbyFitManVal);
set(handles.LCIbyFitMaxStdDev,          'String',   parameters.Simulation.LCIbyFitMaxStdDev);

set(handles.output,'UserData',parameters);


% --- Executes on button press in resultDirButton.
function resultDirButton_Callback(hObject, eventdata, handles)
% hObject    handle to resultDirButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData');

fullName=strcat(pwd);
pathName=uigetdir(fullName,'select result directory');
if ~isequal(pathName,0)
    set(handles.resultDirPath,'String',pathName)
    parameters.Simulation.resultDirPath=pathName;
end

set(handles.output,'UserData',parameters);




% --- Executes on button press in batchProcessingButton.
function batchProcessingButton_Callback(hObject, eventdata, handles)
% hObject    handle to batchProcessingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    interfaceObject=findobj(handles.output,'Enable','on'); % disable interface during evaluation
    set(interfaceObject,'Enable','off');
	drawnow;

    parameters=get(handles.output,'UserData');
    
    sourcePathName=get(handles.filePath,'String');
    fileList=get(handles.fileList,'String');
    if ~iscell(fileList)
        fileList={fileList};
    end
    
    if strcmp('Signal Files to Process',cell2mat(fileList(1)))
        fprintf('INFO: no files chosen / present; use <Data File Choice> first\n');
        return;
    end
    
    destinationPathName=get(handles.resultDirPath,'String');
    if ~exist(destinationPathName,'dir')
        buttonString = questdlg('Destination path does no longer exist...!','Warning','Choose new path','Use default','Use default');
        if strcmp(buttonString,'Use default')
            destinationPathName=getenv('TEMP');
        else
            destinationPathName=uigetdir(sourcePathName,'select result directory'); % starts at the present choice file directory!
            if isequal(destinationPathName,0)
                warning('(fileList_Callback): setting default destination path: no regular user choice!')
                destinationPathName=getenv('TEMP');
            end
        end
        set(handles.resultDirPath,'String',destinationPathName)
        parameters.Simulation.resultDirPath=destinationPathName;
        set(handles.output,'UserData',parameters);
    end
    
    graphState=get(handles.graphButton,'Value');                                        % read user settings graph state
    parameters.Simulation.verb=parameters.Simulation.verb*graphState;                   % suppress graphs if necessary
    parameters=applyCorrectionSpirowareMassSpec(sourcePathName,fileList,destinationPathName,parameters,graphState);
    
    if parameters.Simulation.manualState    % reflect changed parameters in Calibration section
        coefficientsOptimal =	parameters.Calibration.coefficientsOptimal;
        time                =   parameters.Calibration.time;
        
        filePath=fullfile(sourcePathName,cell2mat(fileList(end)));
        set(handles.calibrationPath,'String',filePath);         % reflect last parameter settings
        set(handles.settingsPath,   'String','settingPath');    % reset parameter settings file
        set(handles.valDelayCO2,    'String',num2str(coefficientsOptimal(1)))
        set(handles.valDelayCO2,	'String',num2str(coefficientsOptimal(1)))
        set(handles.valDelayO2,     'String',num2str(coefficientsOptimal(2)))
        set(handles.valTauCO2,      'String',num2str(coefficientsOptimal(3)))
        set(handles.valkCO2,        'String',num2str(coefficientsOptimal(4)))
        set(handles.valkO2,         'String',num2str(coefficientsOptimal(5)))
        set(handles.valkMMss,       'String',num2str(coefficientsOptimal(6)))
        set(handles.valtmin,        'String',num2str(time.min))
        set(handles.valtmax,        'String',num2str(time.max))
    end
    
    set(handles.output,         'UserData',parameters);
    
catch err
    fclose('all');
    warning('(batchProcessingButton_Callback): %s (in %s on line %g)\n', err.message,err.stack(1).name,err.stack(1).line);
end % try/catch

set(interfaceObject,'Enable','on');



% --- Executes on button press in graphButton.
function graphButton_Callback(hObject, eventdata, handles)
% hObject    handle to graphButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of graphButton
graphState=get(hObject,'Value');
parameters=get(handles.output,'UserData');
parameters.Simulation.graphState=graphState;
set(handles.output,'UserData',parameters);
fprintf('graphState is equal %d\n',graphState);



function Vpre_Callback(hObject, eventdata, handles)
% hObject    handle to Vpre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Vpre as text
%        str2double(get(hObject,'String')) returns contents of Vpre as a double
parameters=get(handles.output,'UserData');
parameters.Device.volumePrecap=str2double(get(hObject,'String'));
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function Vpre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Vpre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vPost_Callback(hObject, eventdata, handles)
% hObject    handle to vPost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vPost as text
%        str2double(get(hObject,'String')) returns contents of vPost as a double
parameters=get(handles.output,'UserData');
parameters.Device.volumePostcap=str2double(get(hObject,'String'));
set(handles.output,'UserData',parameters);


% --- Executes during object creation, after setting all properties.
function vPost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vPost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tIns_Callback(hObject, eventdata, handles)
% hObject    handle to tIns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tIns as text
%        str2double(get(hObject,'String')) returns contents of tIns as a double
parameters=get(handles.output,'UserData');
parameters.Operation.TinsGas=str2double(get(hObject,'String'));
parameters=setBTPS(handles,parameters);
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function tIns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tIns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pRef_Callback(hObject, eventdata, handles)
% hObject    handle to pRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pRef as text
%        str2double(get(hObject,'String')) returns contents of pRef as a double
parameters=get(handles.output,'UserData');
parameters.Operation.Pref=100*str2double(get(hObject,'String'));
parameters=setBTPS(handles,parameters);
set(handles.output,'UserData',parameters);


% --- Executes during object creation, after setting all properties.
function pRef_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function correctionMethod_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to InputSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData');

staticState=get(handles.staticButton,'Value');
parameters.Simulation.staticState=staticState;
fsprintf('static state is equal %d\n',staticState);

dynamicState=get(handles.dynamicButton,'Value');
parameters.Simulation.dynamicState=dynamicState;
fprintf('dynamic state is equal %d\n',dynamicState);

parameters=setBTPS(handles,parameters);
set(handles.output,'UserData',parameters);



function tExpEff_Callback(hObject, eventdata, handles)
% hObject    handle to tExpEff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tExpEff as text
%        str2double(get(hObject,'String')) returns contents of tExpEff as a double
parameters=get(handles.output,'UserData');
parameters.Operation.TexpEff=str2double(get(hObject,'String'));
parameters=setBTPS(handles,parameters);
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function tExpEff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tExpEff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in slopesButton.
function slopesButton_Callback(hObject, eventdata, handles)
% hObject    handle to slopesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of slopesButton
slopesState=get(hObject,'Value');
parameters=get(handles.output,'UserData');
parameters.Simulation.slopesState=slopesState;
set(handles.output,'UserData',parameters);
fprintf('slopes in logfile = %d\n',slopesState);



% --- Executes on button press in deleteLogButton.
function deleteLogButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteLogButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('logFile.txt','file')
    answerString = questdlg('Are you sure to delete the log file?','Warning');
    if strcmp(answerString,'Yes')
        disp('deleting log file');
        delete 'logFile.txt'
        if exist('logFile.txt','file')
            warning('(deleteLogButton_Callback): cannot delete log file (probably open in another process)');
        end
    end
else
    fprintf('log file does not exist (aready deleted?)\n');
end



% --- Executes on button press in openLogButton.
function openLogButton_Callback(hObject, eventdata, handles)
% hObject    handle to openLogButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('logFile.txt','file')
    data=fileread('logFile.txt');
    disp('copy log file into clipboard');
else
    data='log file does not exist';
    disp(data);
    data=strcat('<',data,'>');
end
clipboard('copy', data);




function vBody1_Callback(hObject, eventdata, handles)
% hObject    handle to vBody1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vBody1 as text
%        str2double(get(hObject,'String')) returns contents of vBody1 as a double
parameters=get(handles.output,'UserData');
parameters.Device.volumeBody1=str2double(get(hObject,'String'));
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function vBody1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vBody1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tSensor_Callback(hObject, eventdata, handles)
% hObject    handle to tSensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tSensor as text
%        str2double(get(hObject,'String')) returns contents of tSensor as a double
parameters=get(handles.output,'UserData');
parameters.Operation.Tsensor=str2double(get(hObject,'String'));
parameters=setBTPS(handles,parameters);
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function tSensor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tSensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tauBody1_Callback(hObject, eventdata, handles)
% hObject    handle to tauBody1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tauBody1 as text
%        str2double(get(hObject,'String')) returns contents of tauBody1 as a double
parameters=get(handles.output,'UserData');
parameters.Device.tauBody1=str2double(get(hObject,'String'));
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function tauBody1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauBody1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tauBody2_Callback(hObject, eventdata, handles)
% hObject    handle to tauBody2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tauBody2 as text
%        str2double(get(hObject,'String')) returns contents of tauBody2 as a double
parameters=get(handles.output,'UserData');
parameters.Device.tauBody2=str2double(get(hObject,'String'));
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function tauBody2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauBody2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tauTemp_Callback(hObject, eventdata, handles)
% hObject    handle to tauTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tauTemp as text
%        str2double(get(hObject,'String')) returns contents of tauTemp as a double
parameters=get(handles.output,'UserData');
parameters.Device.tauTemp=str2double(get(hObject,'String'));
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function tauTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vBody2_Callback(hObject, eventdata, handles)
% hObject    handle to vBody2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vBody2 as text
%        str2double(get(hObject,'String')) returns contents of vBody2 as a double
parameters=get(handles.output,'UserData');
parameters.Device.volumeBody2=str2double(get(hObject,'String'));
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function vBody2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vBody2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tBody1_Callback(hObject, eventdata, handles)
% hObject    handle to tempBody1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tempBody1 as text
%        str2double(get(hObject,'String')) returns contents of tempBody1 as a double
parameters=get(handles.output,'UserData');
parameters.Operation.Tbody1=str2double(get(hObject,'String'));
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function tBody1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tempBody1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tBody2_Callback(hObject, eventdata, handles)
% hObject    handle to tBody2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tBody2 as text
%        str2double(get(hObject,'String')) returns contents of tBody2 as a double
parameters=get(handles.output,'UserData');
parameters.Operation.Tbody2=str2double(get(hObject,'String'));
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function tBody2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tBody2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function interactiveMethod_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to interactiveMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData');

interactiveYes=get(handles.interactiveYesButton,'Value');
parameters.Simulation.interactiveYes=interactiveYes;
fprintf('interactiveYes is equal %d\n',interactiveYes);

interactiveNo=get(handles.interactiveNoButton,'Value');
parameters.Simulation.interactiveNo=interactiveNo;
fprintf('interactiveNo is equal %d\n',interactiveNo);

interactiveDeviation=get(handles.interactiveDeviationButton,'Value');
parameters.Simulation.interactiveDeviation=interactiveDeviation;
fprintf('interactiveDeviation is equal %d\n',interactiveDeviation);

backgroundColor=get(0,'defaultUicontrolBackgroundColor');
foregroundColor=get(0,'defaultUicontrolForegroundColor');
if ~interactiveDeviation
    set(handles.rmsCrit,'Background',backgroundColor,'Foreground',[0.5 0.5 0.5]);
else
    set(handles.rmsCrit,'Background','white','Foreground',foregroundColor);
end

set(handles.output,'UserData',parameters);



function rmsCrit_Callback(hObject, eventdata, handles)
% hObject    handle to rmsCrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rmsCrit as text
%        str2double(get(hObject,'String')) returns contents of rmsCrit as a double
parameters=get(handles.output,'UserData');
parameters.Simulation.rmsCrit=str2double(get(hObject,'String'))/100;    % expressing as ratio instead of %
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function rmsCrit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rmsCrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fileCalibrationModifier_Callback(hObject, eventdata, handles)
% hObject    handle to fileCalibrationModifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileCalibrationModifier as text
%        str2double(get(hObject,'String')) returns contents of fileCalibrationModifier as a double
parameters=get(handles.output,'UserData');
parameters.Simulation.fileCalibrationModifier=get(hObject,'String');
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function fileCalibrationModifier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileCalibrationModifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function fileCalibration_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to fileCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData');

calibrationYes=get(handles.fileCalibrationYesButton,'Value');
parameters.Simulation.fileCalibrationYes=calibrationYes;
fprintf('calibrationYes is equal %d\n',calibrationYes);

calibrationNo=get(handles.fileCalibrationNoButton,'Value');
parameters.Simulation.fileCalibrationNo=calibrationNo;
fprintf('calibrationNo is equal %d\n',calibrationNo);

backgroundColor=get(0,'defaultUicontrolBackgroundColor');
foregroundColor=get(0,'defaultUicontrolForegroundColor');
if calibrationNo
    set(handles.fileCalibrationModifier,'Background',backgroundColor,'Foreground',[0.5 0.5 0.5]);
else
    set(handles.fileCalibrationModifier,'Background','white','Foreground',foregroundColor);
end

set(handles.output,'UserData',parameters);



% --------------------------------------------------------------------
function analysisSelection_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to analysisSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData');

n2mbwAnalysis=get(handles.n2mbwButton,'Value');
parameters.Simulation.n2mbwAnalysis=n2mbwAnalysis;
dtgmbwAnalysis= get(handles.dtgmbwButton,'Value') || get(handles.dtgmbwButtonBaby,'Value');

parameters.Simulation.dtgmbwAnalysis=dtgmbwAnalysis;
if n2mbwAnalysis || dtgmbwAnalysis
    set(handles.ScondSacinButton,       'Enable','on')
    if parameters.Simulation.ScondSacin
        set(handles.exclusionLimit,     'Enable','on')
        set(handles.exclusionLimitText, 'Enable','on')
        set(handles.onlySmallButton,    'Enable','on')
        set(handles.ScondSacinCheckButton, 'Enable','on')
    else
        set(handles.exclusionLimit,     'Enable','off')
        set(handles.exclusionLimitText, 'Enable','off')
        set(handles.onlySmallButton,    'Enable','off')
        set(handles.ScondSacinCheckButton, 'Enable','off')
    end
    set(handles.TOevaluationButton,     'Enable','on')
    set(handles.lciStandardButton,      'Enable','on')
    set(handles.lciByFitButton,         'Enable','on')
    set(handles.capnoIndicesButton,     'Enable','on')
    set(handles.capnoCheckButton,       'Enable','on')
else
    set(handles.ScondSacinButton,       'Enable','off')
    set(handles.exclusionLimit,         'Enable','off')
    set(handles.exclusionLimitText,     'Enable','off')
    set(handles.onlySmallButton,        'Enable','off')
    set(handles.ScondSacinCheckButton,  'Enable','off')
    set(handles.TOevaluationButton,     'Enable','off')
    set(handles.lciStandardButton,      'Enable','off')
    set(handles.lciByFitButton,         'Enable','off')
    set(handles.capnoIndicesButton,     'Enable','off')
    set(handles.capnoCheckButton,       'Enable','off')
end
fprintf('n2mbwAnalysis is equal %d\n',n2mbwAnalysis);
fprintf('dtgmbwAnalysis is equal %d\n',dtgmbwAnalysis);

dtgsbwAnalysis=get(handles.dtgsbwButton,'Value');
parameters.Simulation.dtgsbwAnalysis=dtgsbwAnalysis;
fprintf('dtgsbwAnalysis is equal %d\n',dtgsbwAnalysis);

parameters.Simulation.dtgmbw     = get(handles.dtgmbwButton,'Value'); 
parameters.Simulation.dtgmbwBaby = get(handles.dtgmbwButtonBaby,'Value');

plainAnalysis=get(handles.plainButton,'Value');
parameters.Simulation.plainAnalysis=plainAnalysis;
fprintf('plainAnalysis is equal %d\n',plainAnalysis);

conversionAnalysis=get(handles.conversionButton,'Value');
parameters.Simulation.conversionAnalysis=conversionAnalysis;
fprintf('conversionAnalysis is equal %d\n',conversionAnalysis);

tidalAnalysis=get(handles.tidalButton,'Value');
parameters.Simulation.tidalAnalysis=tidalAnalysis;
fprintf('tidalAnalysis is equal %d\n',tidalAnalysis);
if n2mbwAnalysis || dtgmbwAnalysis || dtgsbwAnalysis
    set(handles.capnoIndicesButton, 'Enable','on')
    set(handles.capnoCheckButton,  	'Enable','on')
end
if tidalAnalysis || n2mbwAnalysis || dtgmbwAnalysis
    set(handles.tidalMeanButton,    'Enable','on')
    set(handles.nBreathTidal,       'Enable','on')
    set(handles.fromBreathTidal,    'Enable','on')
    set(handles.text97,             'Enable','on')
    set(handles.text98,             'Enable','on')
    set(handles.capnoCheckButton,  	'Enable','on')
else
    set(handles.tidalMeanButton,    'Enable','off')
    set(handles.nBreathTidal,       'Enable','off')
    set(handles.fromBreathTidal,    'Enable','off')
    set(handles.text97,             'Enable','off')
    set(handles.text98,             'Enable','off')
end

set(handles.output,'UserData',parameters);


function delayFlow_Callback(hObject, eventdata, handles)
% hObject    handle to delayFlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delayFlow as text
%        str2double(get(hObject,'String')) returns contents of delayFlow as a double
parameters=get(handles.output,'UserData');
parameters.Calibration.delayFlow=str2double(get(hObject,'String'));
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function delayFlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delayFlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in responseButton.
function responseButton_Callback(hObject, eventdata, handles)
% hObject    handle to responseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of responseButton
responseState=get(hObject,'Value');
parameters=get(handles.output,'UserData');
parameters.Operation.response=responseState;

backgroundColor=get(0,'defaultUicontrolBackgroundColor');
foregroundColor=get(0,'defaultUicontrolForegroundColor');

if responseState 
    set(handles.tauFix,'Background','white','Foreground',foregroundColor);
else
    set(handles.tauFix,'Background',backgroundColor,'Foreground',[0.5 0.5 0.5]);
end

set(handles.output,'UserData',parameters);
fprintf('responseState is equal %d\n',responseState);



function tauFix_Callback(hObject, eventdata, handles)
% hObject    handle to tauFix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tauFix as text
%        str2double(get(hObject,'String')) returns contents of tauFix as a double
parameters=get(handles.output,'UserData');

parameters.Simulation.tauFix=str2double(get(hObject,'String'));

set(handles.output,'UserData',parameters);


% --- Executes during object creation, after setting all properties.
function tauFix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauFix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function slowFastChoice_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to slowFastChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData');

slowState=get(handles.slowButton,'Value');
parameters.Simulation.slowState=slowState;
fprintf('slowState is equal %d\n',slowState);

fastState=get(handles.fastButton,'Value');
parameters.Simulation.fastState=fastState;
fprintf('fastState is equal %d\n',fastState);

set(handles.output,'UserData',parameters);



% --- Executes on button press in deleteAnonymousButton.
function deleteAnonymousButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteAnonymousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

parameters=get(handles.output,'UserData');

[nEntries,mEntries]=size(parameters.Simulation.nameHash);
parameters.Simulation.nameHash = cell(0,2);
fprintf('hash table reset: %d entries deleted\n',nEntries);

set(handles.output,'UserData',parameters);



% --------------------------------------------------------------------
function calibbrationSelection_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to calibbrationSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

parameters=get(handles.output,'UserData');

manualState=get(handles.manualButton,'Value');
parameters.Simulation.manualState=manualState;
fprintf('manual state is equal %d\n',manualState);

settingsState=get(handles.settingsButton,'Value');
parameters.Simulation.settingsState=settingsState;
fprintf('settings state is equal %d\n',settingsState);

autoState=get(handles.autoButton,'Value');
parameters.Simulation.autoState=autoState;
fprintf('auto state is equal %d\n',autoState);

set(handles.output,'UserData',parameters);



% --- Executes on button press in croppingButton.
function croppingButton_Callback(hObject, eventdata, handles)
% hObject    handle to croppingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of croppingButton
parameters=get(handles.output,'UserData');

croppingState=get(hObject,'Value');
parameters.Simulation.croppingState=croppingState;
fprintf('cropping state is equal %d\n',croppingState);

set(handles.output,'UserData',parameters);



% --- Executes on button press in ScondSacinButton.
function ScondSacinButton_Callback(hObject, eventdata, handles)
% hObject    handle to ScondSacinButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ScondSacinButton
parameters=get(handles.output,'UserData');

ScondSacinState=get(hObject,'Value');
parameters.Simulation.ScondSacin=ScondSacinState;
fprintf('ScondSacion = %d\n',ScondSacinState);
if ScondSacinState
    set(handles.exclusionLimitText, 'Enable','on')
    set(handles.exclusionLimit, 'Enable','on')
    set(handles.onlySmallButton, 'Enable','on')
    set(handles.ScondSacinCheckButton, 'Enable','on')
else
    set(handles.exclusionLimit, 'Enable','off')
    set(handles.exclusionLimitText, 'Enable','off')
    set(handles.onlySmallButton, 'Enable','off')
    set(handles.ScondSacinCheckButton, 'Enable','off')
end

set(handles.output,'UserData',parameters);



% --- Executes on button press in capnoCheckButton.
function ScondSacinCheckButton_Callback(hObject, eventdata, handles)
% hObject    handle to capnoCheckButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of capnoCheckButton
parameters=get(handles.output,'UserData');

ScondSacinCheckState=get(hObject,'Value');
parameters.Simulation.ScondSacinCheck=ScondSacinCheckState;
fprintf('ScondSacinCheck = %d\n',ScondSacinCheckState);

set(handles.output,'UserData',parameters);



function exclusionLimit_Callback(hObject, ~, handles)
% hObject    handle to exclusionLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exclusionLimit as text
%        str2double(get(hObject,'String')) returns contents of exclusionLimit as a double
parameters=get(handles.output,'UserData');

exclusionLimit = str2double(get(hObject,'String'));
parameters.Simulation.exclusionLimit=exclusionLimit/100;
fprintf('Exclusion limit = %g\n',exclusionLimit);

set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function exclusionLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exclusionLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function valBTPSexp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valBTPSexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in onlyPlotButton.
function onlyPlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to onlyPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of onlyPlotButton
parameters=get(handles.output,'UserData');

onlyPlotState=get(hObject,'Value');
parameters.Simulation.onlyPlotState=onlyPlotState;
fprintf('only plot state is equal %d\n',onlyPlotState);

set(handles.output,'UserData',parameters);



function deltaCO2O2_Callback(hObject, eventdata, handles)
% hObject    handle to deltaCO2O2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deltaCO2O2 as text
%        str2double(get(hObject,'String')) returns contents of deltaCO2O2 as a double
parameters=get(handles.output,'UserData');

deltaCO2O2 = str2double(get(hObject,'String'));
parameters.Operation.deltaCO2O2=deltaCO2O2;
fprintf('manual change of delay CO2->O2 = %g\n',deltaCO2O2);

set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function deltaCO2O2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deltaCO2O2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dTauCO2_Callback(hObject, eventdata, handles)
% hObject    handle to dTauCO2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dTauCO2 as text
%        str2double(get(hObject,'String')) returns contents of dTauCO2 as a double
parameters=get(handles.output,'UserData');

dTauCO2 = str2double(get(hObject,'String'));
parameters.Operation.dTauCO2=dTauCO2;
fprintf('manual change of tau CO2 = %g\n',dTauCO2);

set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function dTauCO2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dTauCO2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function deltaCO2MMss_Callback(hObject, eventdata, handles)
% hObject    handle to deltaCO2MMss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deltaCO2MMss as text
%        str2double(get(hObject,'String')) returns contents of deltaCO2MMss as a double
parameters=get(handles.output,'UserData');

deltaCO2MMss = str2double(get(hObject,'String'));
parameters.Operation.deltaCO2MMss=deltaCO2MMss;
fprintf('manual change of delay CO2->O2 = %g\n',deltaCO2MMss);

set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function deltaCO2MMss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deltaCO2MMss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in onlysmallbutton.
function onlySmallButton_Callback(hObject, eventdata, handles)
% hObject    handle to onlysmallbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of onlysmallbutton
parameters=get(handles.output,'UserData');

onlySmallState=get(hObject,'Value');
parameters.Simulation.onlySmall=onlySmallState;
fprintf('only small = %d\n',onlySmallState);

set(handles.output,'UserData',parameters);



% --- Executes on button press in minVentButton.
function minVentButton_Callback(hObject, eventdata, handles)
% hObject    handle to minVentButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of minVentButton
minVentState=get(hObject,'Value');
parameters=get(handles.output,'UserData');
parameters.Simulation.minVentState=minVentState;
set(handles.output,'UserData',parameters);
fprintf('minute ventilation in logfile = %d\n',minVentState);



% --- Executes on button press in capnoIndicesButton.
function capnoIndicesButton_Callback(hObject, eventdata, handles)
% hObject    handle to capnoIndicesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of capnoIndicesButton
parameters=get(handles.output,'UserData');

CapnoIndicesState=get(hObject,'Value');
parameters.Simulation.CapnoIndices=CapnoIndicesState;
disp(sprintf('CapnoIndices = %d',CapnoIndicesState))
if CapnoIndicesState
    set(handles.capnoCheckButton, 'Enable','on')
else
    set(handles.capnoCheckButton, 'Enable','off')
end

set(handles.output,'UserData',parameters);



% --- Executes on button press in capnoCheckButton.
function capnoCheckButton_Callback(hObject, eventdata, handles)
% hObject    handle to capnoCheckButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of capnoCheckButton
parameters=get(handles.output,'UserData');

CapnoCheckState=get(hObject,'Value');
parameters.Simulation.CapnoCheck=CapnoCheckState;
fprintf('CapnoCheck = %d\n',CapnoCheckState);

set(handles.output,'UserData',parameters);



% --- Executes on button press in TOevaluationButton.
function TOevaluationButton_Callback(hObject, eventdata, handles)
% hObject    handle to TOevaluationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TOevaluationButton
parameters=get(handles.output,'UserData');

TOevaluationState=get(hObject,'Value');
parameters.Simulation.TOevaluation=TOevaluationState;
fprintf('TO based evaluation = %d\n',TOevaluationState);

set(handles.output,'UserData',parameters);



% --- Executes on button press in lciStandardButton.
function lciStandardButton_Callback(hObject, eventdata, handles)
% hObject    handle to lciStandardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lciStandardButton
parameters=get(handles.output,'UserData');

lciStandardState=get(hObject,'Value');
parameters.Simulation.lciStandard=lciStandardState;
fprintf('LCI standard = %d\n',lciStandardState);

set(handles.output,'UserData',parameters);



% --- Executes on button press in lciByFitButton.
function lciByFitButton_Callback(hObject, eventdata, handles)
% hObject    handle to lciByFitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lciByFitButton
parameters=get(handles.output,'UserData');

lciByFitState=get(hObject,'Value');
parameters.Simulation.lciByFit=lciByFitState;
fprintf('LCI by fit = %d\n',lciByFitState);

set(handles.output,'UserData',parameters);



% --- Executes on button press in tidalMeanButton.
function tidalMeanButton_Callback(hObject, eventdata, handles)
% hObject    handle to tidalMeanButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tidalMeanButton
parameters=get(handles.output,'UserData');

tidalMeanState=get(hObject,'Value');
parameters.Simulation.tidalMeanState=tidalMeanState;
fprintf('Tidal mean state = %d\n',tidalMeanState);

set(handles.output,'UserData',parameters);



function fromBreathTidal_Callback(hObject, eventdata, handles)
% hObject    handle to fromBreathTidal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fromBreathTidal as text
%        str2double(get(hObject,'String')) returns contents of fromBreathTidal as a double
parameters=get(handles.output,'UserData');
fromValue=str2double(get(hObject,'String'));
parameters.Simulation.fromBreathTidal=fromValue;
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function fromBreathTidal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fromBreathTidal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nBreathTidal_Callback(hObject, eventdata, handles)
% hObject    handle to nBreathTidal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nBreathTidal as text
%        str2double(get(hObject,'String')) returns contents of nBreathTidal as a double
parameters=get(handles.output,'UserData');
nValue=str2double(get(hObject,'String'));
parameters.Simulation.nBreathTidal=nValue;
set(handles.output,'UserData',parameters);



% --- Executes during object creation, after setting all properties.
function nBreathTidal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nBreathTidal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MMeeButtonGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MMeeButtonGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in MMeeButtonGroup.
function MMeeButtonGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in MMeeButtonGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters=get(handles.output,'UserData'); 
tag=get(eventdata.NewValue, 'Tag');
parameters.Simulation.MMeeMethod=tag;
set(handles.output,'UserData',parameters);



function MMeeTMax_Callback(hObject, eventdata, handles)
% hObject    handle to MMeeTMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MMeeTMax as text
%        str2double(get(hObject,'String')) returns contents of MMeeTMax as a double
parameters=get(handles.output,'UserData');
parameters.Simulation.MMeeTMax=str2double(get(handles.MMeeTMax, 'String'))/100;
set(handles.output,'UserData',parameters);

% --- Executes during object creation, after setting all properties.
function MMeeTMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MMeeTMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MMeeTMin_Callback(hObject, eventdata, handles)
% hObject    handle to MMeeTMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MMeeTMin as text
%        str2double(get(hObject,'String')) returns contents of MMeeTMin as a double
parameters=get(handles.output,'UserData');
parameters.Simulation.MMeeTMin=str2double(get(handles.MMeeTMin, 'String'))/100;
set(handles.output,'UserData',parameters);

% --- Executes during object creation, after setting all properties.
function MMeeTMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MMeeTMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LCIbyFitAutoVal.
function LCIbyFitAutoVal_Callback(hObject, eventdata, handles)
% hObject    handle to LCIbyFitAutoVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LCIbyFitAutoVal
parameters=get(handles.output,'UserData');
parameters.Simulation.LCIbyFitAutoVal=(get(handles.LCIbyFitAutoVal, 'Value'));
set(handles.output,'UserData',parameters);



function LCIbyFitMaxStdDev_Callback(hObject, eventdata, handles)
% hObject    handle to LCIbyFitMaxStdDev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LCIbyFitMaxStdDev as text
%        str2double(get(hObject,'String')) returns contents of LCIbyFitMaxStdDev as a double
parameters=get(handles.output,'UserData');
parameters.Simulation.LCIbyFitMaxStdDev=str2double(get(handles.LCIbyFitMaxStdDev, 'String'));
set(handles.output,'UserData',parameters);

% --- Executes during object creation, after setting all properties.
function LCIbyFitMaxStdDev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LCIbyFitMaxStdDev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LCIbyFitManVal.
function LCIbyFitManVal_Callback(hObject, eventdata, handles)
% hObject    handle to LCIbyFitManVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LCIbyFitManVal
parameters=get(handles.output,'UserData');
parameters.Simulation.LCIbyFitManVal=(get(handles.LCIbyFitManVal, 'Value'));
set(handles.output,'UserData',parameters);


% --- Executes on button press in MMeeR98.
function MMeeR98_Callback(hObject, eventdata, handles)
% hObject    handle to MMeeR98 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MMeeR98


% --- Executes on button press in MomentRatio.
function MomentRatio_Callback(hObject, eventdata, handles)
% hObject    handle to MomentRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MomentRatio
if get(handles.lciByFitButton, 'Value') == 0 && get(handles.lciStandardButton, 'Value') == 0
    set(handles.MomentRatio, 'Value', 0);
    parameters.Simulation.MomentRatio = 0;
    set(handles.output,'UserData',parameters);
else
    parameters=get(handles.output,'UserData');
    parameters.Simulation.MomentRatio=(get(handles.MomentRatio, 'Value'));
    set(handles.output,'UserData',parameters);
end


% --- Executes on button press in LinearByFit.
function LinearByFit_Callback(hObject, eventdata, handles)
% hObject    handle to LinearByFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LinearByFit
parameters=get(handles.output,'UserData');
parameters.Simulation.LinearByFit=(get(handles.LinearByFit, 'Value'));
parameters.Simulation.ExponentialByFit=(get(handles.ExponentialByFit, 'Value'));
set(handles.output,'UserData',parameters);

% --- Executes on button press in ExponentialByFit.
function ExponentialByFit_Callback(hObject, eventdata, handles)
% hObject    handle to ExponentialByFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExponentialByFit
parameters=get(handles.output,'UserData');
parameters.Simulation.ExponentialByFit=(get(handles.ExponentialByFit, 'Value'));
parameters.Simulation.LinearByFit=(get(handles.LinearByFit, 'Value'));
set(handles.output,'UserData',parameters);






% --- Executes on button press in fastSlow.
function fastSlow_Callback(hObject, eventdata, handles)
% hObject    handle to fastSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fastSlow
parameters=get(handles.output,'UserData');
fastSlow=get(handles.fastSlow,'Value');
parameters.Simulation.fastSlow=fastSlow;
if fastSlow == 0
    set(handles.fastSlowPredict, 'Value', 0);
end
fprintf('fastSlow is equal %d\n',fastSlow);
set(handles.output,'UserData',parameters);




% --- Executes on button press in dtgmbwButton.
function dtgmbwButton_Callback(hObject, eventdata, handles)
% hObject    handle to dtgmbwButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dtgmbwButton
parameters=get(handles.output,'UserData');

parameters.Simulation.dtgmbw=get(hObject,'Value');

set(handles.output,'UserData',parameters);


% --- Executes on button press in dtgmbwButtonBaby.
function dtgmbwButtonBaby_Callback(hObject, eventdata, handles)
% hObject    handle to dtgmbwButtonBaby (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dtgmbwButtonBaby
parameters=get(handles.output,'UserData');

parameters.Simulation.dtgmbwBaby=get(hObject,'Value');

set(handles.output,'UserData',parameters);


% --- Executes when selected object is changed in uibuttongroup5.
function uibuttongroup5_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup5 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters  = get(handles.output,'UserData');
MissPlexy   = get(handles.radioMissPlexy,'Value');
Set1        = get(handles.radioSet1,'Value');
Set2        = get(handles.radioSet2,'Value');
ndd        = get(handles.radioDSNDD,'Value');

parameters.Simulation.Set1      = Set1;             % If the measurements were done with Set1
parameters.Simulation.Set2      = Set2;
parameters.Simulation.MissPlexy = MissPlexy;
parameters.Simulation.nddDS     = ndd;

    if MissPlexy==1;
        parameters.Device.volumePostcap	=   3.50e-06;        %% TODO: Discuss Deadspace of Miss Plexy with penelope
        parameters.Device.volumePrecap	=   2.00e-06;          %% TODO: Discuss Miss Plexy DS and BTPS with penelope
    end
    if  Set1 == 1
        parameters.Device.volumePostcap	=    3.50e-6;
        parameters.Device.volumePrecap	=   11.90e-6;
    end
    if  Set2 == 1
        parameters.Device.volumePostcap =   26.90e-6;        % postcap volume
        parameters.Device.volumePrecap  =   37.90e-6;        % precap volume
    end
    if ndd == 1      
        parameters.Device.volumePostcap =   15.85e-06; 
        parameters.Device.volumePrecap  =   24.75e-06;
    end
set(handles.output,'UserData',parameters);

% --- Executes during object creation, after setting all properties.
function uibuttongroup5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in fastSlowPredict.
function fastSlowPredict_Callback(hObject, eventdata, handles)
% hObject    handle to fastSlowPredict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fastSlowPredict

parameters=get(handles.output,'UserData');
fastSlowPredict=get(handles.fastSlowPredict,'Value');
parameters.Simulation.fastSlowPredict=fastSlowPredict;
if fastSlowPredict == 1
    parameters.Simulation.fastSlow=1;
    set(handles.fastSlow, 'Value', 1);
end
fprintf('fastSlowPrediciton is equal %d\n',fastSlowPredict);
set(handles.output,'UserData',parameters);


% hObject    handle to diffusionCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of diffusionCorrection
