function varargout = MTT(varargin)
% MTT MATLAB code for MTT.fig
%      MTT, by itself, creates a new MTT or raises the existing
%      singleton*.
%
%      H = MTT returns the handle to a new MTT or the handle to
%      the existing singleton*.
%
%      MTT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MTT.M with the given input arguments.
%
%      MTT('Property','Value',...) creates a new MTT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      handles.applied to the GUI before MTT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property handles.application
%      stop.  All inputs are passed to MTT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MTT

% Last Modified by GUIDE v2.5 04-May-2017 16:39:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MTT_OpeningFcn, ...
    'gui_OutputFcn',  @MTT_OutputFcn, ...
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


% --- Executes just before MTT is made visible.
function MTT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MTT (see VARARGIN)
global  t SelectedMap segON ab VnewExist

% handles.path_file = cd;
handles.path_file = pwd;
handles.path_save  = handles.path_file;

%default variables
t = 0;   %timer for segmenting structures
segON = 0;   %manual segmentation OFF
ab    = 0;  % ab = 0 indicates if h1 (i.e. the figure where the user performs the segmentation) is not active

handles.tb = 1;   %move the sliders together
set(handles.togglebutton1, 'Value', handles.tb)

handles.slider2.Value  = 1; %original stack
handles.slider1.Value = 1;  %segmented stack

handles.slider1_text = [num2str(handles.slider1.Value), '/', '1'];
set(handles.text1, 'String', handles.slider1_text);
handles.slider1.Enable = 'off';
% set(handles.slider1, 'Value', handles.slider1.Value)

handles.slider2_text = [num2str(handles.slider2.Value), '/', '1'];
set(handles.text2, 'String', handles.slider2_text);
handles.slider2.Enable = 'off';
% set(handles.slider2, 'Value', handles.slider2.Value)

set(handles.popupmenu1, 'Value', 1)
handles.radiobutton5.Value = 1;

handles.transp = 0; %no transparency

SelectedMap = 'gray';  %colormap for both original and segmented stack; 
                       %the choice is available only when transp = 0

handles.firstsegON = 0;
handles.undo = 0;

handles.olddir = pwd;   %the path where ManSegTool is located

VnewExist = 0;

% matrices of zero elements for both original and segmented stack
firstscreen = imread('firstscreen.png');

axes(handles.axes1)
imagesc(firstscreen)%, colormap(handles.axes1, SelectedMap), %truesize
axis off

axes(handles.axes2)
imagesc(false(512, 512)), colormap(handles.axes2, SelectedMap), %truesize
axis off

% flag for segmentation (i.e. RED for OFF; GREEN for ON)
axes(handles.axes3)
pos = [0 0 2 2];
axis([0 3 0 3])
rectangle('Position', pos, 'Curvature', [1 1], 'FaceColor', [1 0 0], 'LineWidth', 3)
axis equal
axis off

onair = 'Segmentation OFF';
set(handles.text3, 'string', onair);
set(handles.text3, 'FontSize', 14);

handles.defaultmap = colormap(gray);
handles.defaultmap(:, 1, :) = zeros(64, 1);
handles.defaultmap(:, 3, :) = zeros(64, 1);

handles.defaultmap2 = colormap(gray);
handles.defaultmap2(:, 2, :) = zeros(64, 1);

handles.nmeno1 = 0;
handles.n = 0;
handles.npiu1  = 0;


% Choose default command line output for MTT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(0, 'userdata', handles);


function hotkey_fig1(hObject, eventdata)
 
% global data
global h1 ab segON SelectedMap
% hObject=h1
% hObject = h1;
% 
% get(data.slider1,'Value')
handles = get(0, 'userdata');
event_fig = eventdata;

switch eventdata.Key
    
    case {'leftarrow', 'downarrow'}
          
        tmp = uint16(handles.slider1.Value);
        
        if tmp == 1
            
            handles.slider1.Value = tmp;
            
        else
            
            handles.slider1.Value = tmp-1;
            
        end
        
        if handles.slider1.Value == 1
            
            set(handles.radiobutton6, 'Value', 1)
            handles.n =1;
            set(handles.radiobutton8, 'Enable', 'off')
            
        end
        
        if handles.slider1.Value-1 < handles.num
            
            set(handles.radiobutton7, 'Enable', 'on') 
            
        end        

        if handles.transp == 0
        
            axes(handles.axes1);
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)),'/', num2str(handles.num)];
            set(handles.text1,'String', handles.slider1_text)

            if handles.tb == 1 %&& tmp ~= 1

                handles.slider2.Value = handles.slider1.Value;

                axes(handles.axes2);
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
                axis off

                handles.slider2_text = [num2str(handles.slider2.Value),'/', num2str(handles.num)];
                set(handles.text2, 'String', handles.slider2_text)

            end
            
        else
            
            if handles.nmeno1 == 1 &&  handles.slider1.Value ~= 1
                
                handles.tb = 1;     %by default
                set(handles.togglebutton1, 'Value', 1);
                handles.transp = 1;
                
                handles.slider2.Value = handles.slider1.Value-1;
                
                axes(handles.axes1);
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
                set(handles.text1, 'String', handles.slider1_text)
                
                axes(handles.axes2);
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

                handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
                set(handles.text2, 'String', handles.slider2_text)
                
            elseif handles.n == 1
                
                handles.tb = 1;     %by default
                set(handles.togglebutton1, 'Value', 1);
                handles.transp = 1;
                
                handles.slider2.Value = handles.slider1.Value;
                
                axes(handles.axes1);
                imshowpair(handles.Vnew(:, :, handles.slider1.Value), handles.NeuSeg(:, :, handles.slider2.Value)), %truesize
                axis off

                handles.slider1_text = [num2str(handles.slider1.Value), '/', num2str(handles.num)];
                set(handles.text1, 'String', handles.slider1_text)
                
                axes(handles.axes2);
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

                handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
                set(handles.text2, 'String', handles.slider2_text)
                
            elseif handles.npiu1 == 1 && handles.slider1.Value ~= handles.num
                
                handles.tb = 1;     %by default
                set(handles.togglebutton1, 'Value', 1);
                handles.transp = 1;
                
                handles.slider2.Value = handles.slider1.Value+1;
                
                axes(handles.axes1);
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                handles.slider1_text = [num2str(handles.slider1.Value),'/',num2str(handles.num)];
                set(handles.text1,'String',handles.slider1_text)
                
                axes(handles.axes2);
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

                handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
                set(handles.text2, 'String', handles.slider2_text)
                
            end
            
        end
            
        
%         datatogui=handles
        set(0, 'userdata', handles)
%         guidata(hObject,handles)
        
        clf(h1, 'reset')
        ab = 0;
            
    case {'rightarrow', 'uparrow'}
        
        tmp = uint16(handles.slider1.Value);
        
        if tmp == handles.num
            
            handles.slider1.Value = handles.num;
            
            set(handles.radiobutton6, 'Value', 1)
            handles.n =1;
            
            set(handles.radiobutton7, 'Enable', 'off');
            
        else
            
            handles.slider1.Value = tmp+1;
            set(handles.radiobutton7, 'Enable', 'on');
            
        end
        
        if handles.slider1.Value > 1
            
            set(handles.radiobutton8, 'Enable', 'on')
            
        end
        
        if handles.slider1.Value+1 == handles.num
            
            set(handles.radiobutton7, 'Enable', 'off') 
            
        end
        
        if handles.transp == 0
        
            axes(handles.axes1);
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off

            handles.slider1_text = [num2str(handles.slider1.Value), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text)

            
            if handles.tb == 1 %&& handles.slider1.Value ~= handles.num

                handles.slider2.Value = handles.slider1.Value;

                axes(handles.axes2);
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
                axis off

                handles.slider2_text = [num2str(handles.slider2.Value), '/', num2str(handles.num)];
                set(handles.text2, 'String', handles.slider2_text)

            end
            
        else
            
            if handles.nmeno1 == 1
                
                handles.slider2.Value = handles.slider1.Value-1;
                
                handles.tb = 1;     %by default
                set(handles.togglebutton1, 'Value', 1);
                handles.transp = 1;                
                
                axes(handles.axes1);
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
                set(handles.text1, 'String', handles.slider1_text)

                axes(handles.axes2);
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

                handles.slider2_text = [num2str(handles.slider2.Value),'/',num2str(handles.num)];
                set(handles.text2, 'String', handles.slider2_text)
                
            elseif handles.n == 1
                
                handles.slider2.Value = handles.slider1.Value;

                handles.tb = 1;     %by default
                set(handles.togglebutton1, 'Value', 1);
                handles.transp = 1;
                
                axes(handles.axes1);
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
                set(handles.text1, 'String', handles.slider1_text)

                axes(handles.axes2);
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

                handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
                set(handles.text2, 'String', handles.slider2_text)
                
            elseif handles.npiu1 == 1 && handles.slider1.Value ~= handles.num
                
                handles.slider2.Value = handles.slider1.Value+1;
                
                handles.tb = 1;     %by default
                set(handles.togglebutton1, 'Value', 1);
                handles.transp = 1;
                
                axes(handles.axes1);
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, handles.slider2.Value)), %truesize
                axis off

                handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
                set(handles.text1, 'String', handles.slider1_text)

                axes(handles.axes2);
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
                axis off

                handles.slider2_text = [num2str(handles.slider2.Value), '/', num2str(handles.num)];
                set(handles.text2, 'String', handles.slider2_text)
                
            end    
            
        end
  
        set(0,'userdata', handles)

        clf (h1, 'reset')
        ab = 0;

    otherwise
        
end
% datatogui=handles;
% set(0,'userdata',datatogui);
if segON == 1; pushbutton2_Callback(handles.pushbutton2, eventdata, handles); end  


function hotkey_fig2(hObject, eventdata)

% global data
global h1 h2 ab segON SelectedMap undo undoON

handles = get(0,'userdata');
event_fig = eventdata;

switch eventdata.Key
    
    case {'leftarrow','downarrow'}
        
        
        tmpslice = handles.slider1.Value;
        
        if tmpslice == 1
            
            handles.slider1.Value = tmpslice;
            
        else
            
            handles.slider1.Value = tmpslice-1;
            
        end
        
        axes(handles.axes1);
        imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
        axis off
     
        handles.slider1_text = [num2str(handles.slider1.Value),'/', num2str(handles.num)];
        set(handles.text1,'String', handles.slider1_text)
        
        handles.slider2.Value = handles.slider1.Value;
        
        axes(handles.axes2);
        imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))); colormap(handles.axes2, SelectedMap), %truesize
        axis off
        
        handles.slider2_text = [num2str(uint16(handles.slider2.Value)),'/',num2str(handles.num)];
        set(handles.text2,'String',handles.slider2_text)

        set(0,'userdata',handles)
        clf(h2,'reset');
        undo =  0;
        
    case {'rightarrow','uparrow'}
        
        tmpslice = get(handles.slider1,'Value');
        
        if tmpslice == handles.num
        
            handles.slider1.Value = handles.num;
        
        else
            
            handles.slider1.Value = tmpslice+1;
        
        end
        
        axes(handles.axes1);
        imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
        axis off
        
        handles.slider1_text = [num2str(uint16(handles.slider1.Value)),'/', num2str(handles.num)];
        set(handles.text1, 'String', handles.slider1_text)
        
        handles.slider2.Value = handles.slider1.Value;
        
        axes(handles.axes2);
        imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))); colormap(handles.axes2, SelectedMap)
        axis off
        
        handles.slider2_text = [num2str(uint16(handles.slider2.Value)),'/',num2str(handles.num)];
        set(handles.text2,'String',handles.slider2_text)
%         
        set(0,'userdata',handles)
        clf(h2,'reset');
        undo =  0;
        
    otherwise
        
end

if undoON==1; pushbutton6_Callback(handles.pushbutton6, eventdata, handles); end
% datatogui=datafromgui;
% set(0,'userdata',datatogui)

%set(handles.text3, 'BackgroundColor', 'r')

function hotkey_fig3(hObject, eventdata)

% global data
global h3  SelectedMap splitON

handles = get(0,'userdata');
event_fig = eventdata;

switch eventdata.Key
    
    case {'leftarrow','downarrow'}        
        
        tmpslice = uint16(handles.slider1.Value);
        
        if tmpslice == 1
            
            handles.slider1.Value = tmpslice;
            
        else
            
            handles.slider1.Value = tmpslice-1;
            
        end
        
        axes(handles.axes1);
        imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
        axis off
     
        handles.slider1_text = [num2str(uint16(handles.slider1.Value)),'/', num2str(handles.num)];
        set(handles.text1,'String', handles.slider1_text)
        
        handles.slider2.Value = handles.slider1.Value;
        
        axes(handles.axes2);
        imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))); colormap(handles.axes2, SelectedMap)
        axis off
        
        handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
        set(handles.text2, 'String', handles.slider2_text)

        set(0, 'userdata', handles)
        clf(h3, 'reset');
        
    case {'rightarrow', 'uparrow'}
           
        tmpslice = uint16(handles.slider1.Value);
        
        if tmpslice == handles.num
        
            handles.slider1.Value = handles.num;
        
        else
            
            handles.slider1.Value = tmpslice+1;
        
        end
        
        axes(handles.axes1);
        imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
        axis off
        
        handles.slider1_text = [num2str(uint16(handles.slider1.Value)),'/', num2str(handles.num)];
        set(handles.text1,'String', handles.slider1_text)
        
        handles.slider2.Value = handles.slider1.Value;
        
        axes(handles.axes2);
        imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))); colormap(handles.axes2, SelectedMap)
        axis off
        
        handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
        set(handles.text2, 'String', handles.slider2_text)
        
        set(0,'userdata', handles)
        clf(h3,'reset');

    otherwise
end

if splitON == 1; pushbutton13_Callback(handles.pushbutton13, eventdata, handles); end

% --- Outputs from this function are returned to the command line.
function varargout = MTT_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
% ---  LOAD THE IMAGE STACK
function pushbutton1_Callback(hObject, eventdata, handles)  
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global t SelectedMap VnewExist h1 h2 h3 h4

if ishandle(h1); close(h1); end
if ishandle(h2); close(h2); end
if ishandle(h3); close(h3); end
if ishandle(h4); close(h4); end

[handles.I_file_tmp, handles.path_file_tmp] = uigetfile('*.tif');

if  handles.I_file_tmp ~= 0
    
%     handles.I_file    = handles.I_file_tmp;
%     handles.path_file = handles.path_file_tmp;
%     cd(handles.path_file)       %original stack path
    
    handles.Vnew    = imread(strcat(handles.path_file_tmp,handles.I_file_tmp));
    info_im = imfinfo(strcat(handles.path_file_tmp,handles.I_file_tmp));
    
    handles.num  = numel(info_im);
    handles.n_y  = info_im.Width;
    handles.n_x  = info_im.Height;
    handles.Vnew = zeros(handles.n_x, handles.n_y, handles.num);    %3D matrix storing the original stack

    
    for k = 1:handles.num
        
        A = imread(strcat(handles.path_file_tmp,handles.I_file_tmp), k);
        handles.Vnew(:, :, k) = A(:, :);
        
    end
    
    VnewExist = 1;
    
    set(handles.pushbutton2, 'Enable', 'on')
    set(handles.pushbutton6, 'Enable', 'on')
    set(handles.pushbutton9, 'Enable', 'on')
    set(handles.pushbutton11, 'Enable', 'on')
    set(handles.pushbutton13, 'Enable', 'on')    
    set(handles.pushbutton10, 'Enable', 'on')
    
    set(handles.radiobutton7, 'Enable', 'on')    
    set(handles.radiobutton8, 'Enable', 'off')    
    set(handles.radiobutton6, 'Enable', 'on')
    
    set(handles.popupmenu1, 'Enable', 'on') 
    handles.slider1.Enable = 'on';
    handles.slider2.Enable = 'on';
    
%     cd(handles.olddir)
    clear Imm_tmp k info_im
    
    set(handles.slider1, 'Min', 1);
    set(handles.slider1, 'Max', handles.num);
    set(handles.slider1, 'Value', 1);
    set(handles.slider1, 'SliderStep', [1/(handles.num-1), 1/(handles.num-1)]);
    
    set(handles.slider2, 'Min', 1);
    set(handles.slider2, 'Max', handles.num);
    set(handles.slider2, 'Value', 1);
    set(handles.slider2, 'SliderStep', [1/(handles.num-1), 1/(handles.num-1)]);
    
    axes(handles.axes1)
    imagesc(handles.Vnew(:, :, 1)), colormap(handles.axes1, SelectedMap), %truesize
    axis off
    
    handles.AnotherNeuron = 0;  %flag: no more segmented neurons within the same dataset
    
    otherone = questdlg ('Have you already segmented any neurons on this dataset?');
    
    switch otherone
        
        case 'Yes'
            
            [handles.nfile_tmp, handles.npath_tmp] = uigetfile('*mat');
            
            if  handles.nfile_tmp ~= 0
                
                handles.nfile = handles.nfile_tmp;
                handles.npath = handles.npath_tmp;
                handles.AnotherNeuron = 1;     
                doIhavetoask = 1;
            else
                
                handles.NeuSeg = false(handles.n_x, handles.n_y, handles.num);
                handles.Neu = 1;
                handles.AnotherNeuron = 0;
                doIhavetoask = 0;
                
                
            end
            
            if doIhavetoask == 1;
            stringa   = strcat(handles.npath, handles.nfile);
            struttura = load(stringa);
            
            otherNeuron = questdlg('Do you want to finish the segmentation of a neuron?');  %?????
            
            set(handles.pushbutton6, 'Enable', 'on')
            set(handles.pushbutton9, 'Enable', 'on')
            set(handles.pushbutton10, 'Enable', 'on')
            set(handles.pushbutton11, 'Enable', 'on')
            
            switch otherNeuron
                
                case 'Yes'
                    
                    lungh           = length(fieldnames(struttura));
                    nometutto       = strcat('Neurone', num2str(lungh));
                    handles.NeuSeg_struct  = getfield(struttura, nometutto);
                    handles.NeuSeg         = handles.NeuSeg_struct.Neuron;
                    handles.Neu             = lungh;
                    
                    axes(handles.axes2)
                    imagesc(handles.NeuSeg(:, :, 1)), colormap(handles.axes2, SelectedMap), %truesize
                    axis off
                    
                    t = handles.NeuSeg_struct.tempo;
                    
                case {'No'}
                    
                    lungh   = length(fieldnames(struttura));
                    handles.NeuSeg = false(handles.n_x, handles.n_y, handles.num);
                    handles.Neu     = lungh +1;
                                        
                    axes(handles.axes2)
                    imagesc(handles.NeuSeg(:, :, 1)), colormap(handles.axes2, SelectedMap), %truesize
                    axis off
                
            end
            end
        case {'No','Cancel'}
            
            handles.NeuSeg = false(handles.n_x, handles.n_y, handles.num);
            handles.Neu = 1;
            
            handles.NeuSeg = false(handles.n_x, handles.n_y, handles.num);
            
            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, 1)), colormap(handles.axes2, SelectedMap), %truesize
            axis off            
                    
    end
    
    handles.slider1_text = ['1/', num2str(handles.num)];
    set(handles.text1, 'string', handles.slider1_text);
    
    handles.slider2_text = ['1/', num2str(handles.num)];
    set(handles.text2, 'string', handles.slider2_text);
    
    handles.slider1.Value = 1;
    
end

% handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
set(0, 'userdata', handles);
handles
set(hObject, 'Enable', 'off')
drawnow;
set(hObject, 'Enable', 'on')


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global  h1 h2 h3 h4 ab segON SelectedMap undoON splitON

% axes(handles.axes1); imagesc(handles.Vnew(:, :, handles.slider1.Value));
guidata(hObject, handles); set(0, 'userdata', handles);
% zstack = handles.slider1.Value;


handles.nmeno1 = get(handles.radiobutton8, 'Value');
handles.n = get(handles.radiobutton6, 'Value');
handles.npiu1  = get(handles.radiobutton7, 'Value');

if handles.radiobutton8.Value == 1 || handles.radiobutton7.Value == 1 || handles.radiobutton6.Value == 1
    
    set(handles.togglebutton1, 'Value', 1);
    handles.tb = 1;
    
    handles.transp = 1;
    
    if uint16(handles.slider1.Value) > 1 && uint16(handles.slider1.Value) < handles.num
        
        set(handles.radiobutton8, 'Enable', 'on');
        set(handles.radiobutton7, 'Enable', 'on');
        set(handles.radiobutton6, 'Enable', 'on');

        if handles.nmeno1 == 1

            handles.slider2.Value = handles.slider1.Value+1;

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

        elseif handles.n == 1

            handles.slider2.Value = handles.slider1.Value;

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, handles.slider2.Value)), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

        elseif handles.npiu1 == 1

            handles.slider2.Value = handles.slider1.Value-1;

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

        end

    elseif uint16(handles.slider1.Value) == 1 
            
            set(handles.radiobutton6,'Value',1)
            handles.n = handles.radiobutton6.Value;
            set(handles.radiobutton8, 'Enable', 'off');
            set(handles.radiobutton7, 'Enable', 'on');
            set(handles.radiobutton6, 'Enable', 'on');
            
            if handles.npiu1 == 1

                handles.slider2.Value = handles.slider1.Value+1;

                axes(handles.axes1)
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                axes(handles.axes2)
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

            elseif handles.n == 1

                handles.slider2.Value = handles.slider1.Value;

                axes(handles.axes1)
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                axes(handles.axes2)
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

            end

    elseif  uint16(handles.slider1.Value) == handles.num 
            
            set(handles.radiobutton6,'Value',1);
            handles.n = handles.radiobutton6.Value;
            set(handles.radiobutton8, 'Enable', 'on');
            set(handles.radiobutton7, 'Enable', 'off');
            set(handles.radiobutton6, 'Enable', 'on');
            
            if handles.n == 1

                handles.slider2.Value = handles.slider1.Value;

                axes(handles.axes1)
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                axes(handles.axes2)
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

            elseif handles.nmeno1 == 1

                handles.slider2.Value = handles.slider1.Value-1;

                axes(handles.axes1)
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                axes(handles.axes2)
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

            end

    end
    
else
    
    handles.transp = 0;
    
    if handles.tb == 1

            handles.slider2.Value = handles.slider1.Value;

            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))); axis off; %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
            axis off        
        
    else
        
            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off  
        
    end
    
    if uint16(handles.slider1.Value) == 1
        
        
        set(handles.radiobutton8, 'Enable', 'off');
        set(handles.radiobutton6, 'Enable', 'on');
        set(handles.radiobutton7, 'Enable', 'on');
        
    elseif uint16(handles.slider1.Value) == handles.num
        
        
        set(handles.radiobutton8, 'Enable', 'on');
        set(handles.radiobutton6, 'Enable', 'on');
        set(handles.radiobutton7, 'Enable', 'off');
        
    else
        
        set(handles.radiobutton8, 'Enable', 'on');
        set(handles.radiobutton6, 'Enable', 'on');
        set(handles.radiobutton7, 'Enable', 'on');        
        
    end
    
end
    
handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
set(handles.text1, 'String', handles.slider1_text);

handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
set(handles.text2, 'String', handles.slider2_text);

%03/05 un po piu tardi
% % % % % % % guidata(hObject, handles);
% set(0,'userdata',handles);
if ishandle(h1)
    
    guidata(hObject, handles); set(0, 'userdata', handles)
    clf (h1, 'reset')
    ab = 0;
    
    figure(h1); imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))); colormap(h1, SelectedMap), %truesize
    axis off
    
end

if ishandle(h2)
    
    guidata(hObject, handles); set(0, 'userdata', handles)
    clf (h2, 'reset')
    
    figure(h2); imagesc(handles.NeuSeg(:, :, uint16(handles.slider1.Value))); colormap(h2, SelectedMap), %truesize
    axis off
    
end

if ishandle(h3)
    
    guidata(hObject, handles); set(0, 'userdata', handles)
    clf (h3, 'reset')
    
    figure(h3); imagesc(handles.NeuSeg(:, :, uint16(handles.slider1.Value))); colormap(h3, SelectedMap), %truesize
    axis off
    
end
guidata(hObject, handles); set(0, 'userdata', handles);
% set(0,'userdata',handles);
if segON == 1; pushbutton2_Callback(hObject, eventdata, handles); end
if undoON == 1; pushbutton6_Callback(hObject, eventdata, handles); end
if splitON == 1; pushbutton13_Callback(hObject, eventdata, handles); end

% %03/05 un po piu tardi
% % % % % % % % guidata(hObject, handles);
% % set(0,'userdata',handles);
% if ishandle(h1)
%     
%     guidata(hObject, handles); set(0, 'userdata', handles)
%     clf (h1, 'reset')
%     ab = 0;
%     
%     figure(h1); imagesc(handles.Vnew(:, :, handles.slider1.Value)); colormap(h1, SelectedMap), %truesize
%     axis off
%     
% end
% 
% guidata(hObject, handles); set(0, 'userdata', handles);
% set(0,'userdata',handles);
% if segON == 1; pushbutton2_Callback(hObject, eventdata, handles); end

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton2.
% ---  START THE SEGMENTATION
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global t  h1 h2 h3 h4 t1  ab segON SelectedMap undoON splitON closedGUI


handles = get(0, 'userdata');
guidata(hObject, handles); 

undoON = 0;
splitON= 0;
if handles.firstsegON == 0  %at the first click, ManSegTool automatically enables all the graphical objects the user need
    
    handles.firstsegON = 1;
    
    set(handles.pushbutton6,'Enable','on')
    set(handles.pushbutton9,'Enable','on')
    set(handles.pushbutton10,'Enable','on')
    set(handles.pushbutton11,'Enable','on')
    set(handles.pushbutton13,'Enable','on')
    
    set(handles.radiobutton6,'Enable','on')
    set(handles.radiobutton7,'Enable','on')
    set(handles.radiobutton8,'Enable','on')
    
end

segON = 1;   %flag for manual segmentation
t1 = tic;   %timer starts running
t1 = uint64(t1);

%flag for manual segmenation GREEN (i.e. ON)
axes(handles.axes3)
pos = [0 0 2 2];
axis([0 3 0 3])
rectangle('Position',pos,'Curvature',[1 1],'FaceColor',[0 1 0], 'LineWidth',3)
axis equal
axis off

onair = 'Segmentation ON';
set(handles.text3,'string',onair);
set(handles.text3, 'FontSize', 14, 'FontWeight', 'bold');


if ishandle(h2); close(h2); end
if ishandle(h3); close(h3); end
if ishandle(h4); close(h4); end

if handles.transp == 1 && handles.tb == 1
    
    if ishandle(h1) == 1
        
        figure(h1); imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider1.Value))); axis off; truesize
        
    else
        
        figure, imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider1.Value))); axis off; truesize; %drawnow
        
    end
    
    h = gca;    
    h1 = gcf;
    set(h1,'KeyPressFcn',@hotkey_fig1)
    set(h1, 'Name', ['Segment slice no.' num2str(uint16(handles.slider1.Value)) '/' num2str(handles.num)]);
    set(h1, 'DeleteFcn', 'ab=1;')

%     handles.zstack = handles.slider1.Value;
    guidata(hObject, handles); set(0,'userdata', handles);
    
% % %     handles
    while ishandle(h1)
        
        try 
            
            mto = imfreehand(gca);
            tmpmask = mto.createMask;
            handles.NeuSeg(:, :, uint16(handles.slider1.Value)) = or(handles.NeuSeg(:, :, uint16(handles.slider1.Value)), tmpmask);
            
            axes(handles.axes1);
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off
            
            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
            axis off
            
            clf(h1, 'reset');
            ab = 0;
            
            figure(h1); imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(h1, SelectedMap); axis off; truesize

            
            set(h1,'KeyPressFcn',@hotkey_fig1)
            set(h1, 'Name', ['Trace slice no.' num2str(uint16(handles.slider1.Value)) '/' num2str(handles.num)]);
            set(h1, 'DeleteFcn', 'ab=1;')
            
            guidata(hObject, handles); set(0, 'userdata', handles);
            
        catch

            %flag for segmentation OFF
            axes(handles.axes3)
            pos = [0 0 2 2];
            axis([0 3 0 3])
            rectangle('Position', pos, 'Curvature', [1 1], 'FaceColor', [1 0 0], 'LineWidth', 3)
            axis equal
            axis off
            
            onair = 'Segmentation OFF';
            set(handles.text3, 'string', onair);
            set(handles.text3, 'FontSize', 14);
            
            segON = 0;
            t = t+toc(t1);
         
            break
            
        end
        
    end
    
else
    
    if ishandle(h1)
        
        figure(h1), imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(h1, SelectedMap); axis off; truesize
        
    else
        
        figure, imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(SelectedMap); axis off; truesize
    end
    
    h = gca;
    h1 = gcf;
    set(h1,'KeyPressFcn',@hotkey_fig1)
    set(h1, 'Name', ['Segment slice no.' num2str(uint16(handles.slider1.Value)) '/' num2str(handles.num)]);
    set(h1, 'DeleteFcn', 'ab=1;')
    
    handles.slider1.Value = get(handles.slider1, 'Value');
    guidata(hObject, handles); set(0, 'userdata', handles);
    
while ishandle(h1)
    
        try 
            
            mto = imfreehand(gca);
            tmpmask = mto.createMask;
            handles.NeuSeg(:, :, uint16(handles.slider1.Value)) = or(handles.NeuSeg(:, :, uint16(handles.slider1.Value)), tmpmask);
            
            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
            axis off
            
            axes(handles.axes1);
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off
            
            clf(h1,'reset');
            ab = 0;
            
            figure(h1); imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(h1, SelectedMap); axis off; truesize
            
            set(h1,'KeyPressFcn',@hotkey_fig1)
            set(h1, 'Name', ['Trace slice no.' num2str(uint16(handles.slider1.Value)) '/' num2str(handles.num)]);
            set(h1, 'DeleteFcn', 'ab=1;')
            
            guidata(hObject, handles); set(0, 'userdata', handles)
            
        catch
            
            %flag for segmentation:OFF
            axes(handles.axes3)
            pos = [0 0 2 2];
            axis([0 3 0 3])
            rectangle('Position', pos, 'Curvature', [1 1], 'FaceColor', [1 0 0], 'LineWidth', 3)
            axis equal
            axis off
            
            onair = 'Segmentation OFF';
            set(handles.text3, 'string', onair);
            set(handles.text3, 'FontSize', 14);
            
            segON = 0;
            t = t+toc(t1);
            
            break
            
        end
        
end
    
end

if segON == 1; pushbutton2_Callback(hObject, eventdata, handles); end

set(hObject, 'Enable', 'off')
drawnow;
set(hObject, 'Enable', 'on')

% --- Executes on button press in pushbutton6.
% --- UNDO BUTTON
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  h1 h2 h3 h4 SelectedMap ab segON undo undoON splitON closedGUI
% 

handles = get(0, 'userdata');
guidata(hObject, handles)


segON  = 0;
splitON= 0;
undoON = 1;

% handles.slider1.Value = get(handles.slider1,'Value');
% handles.slider2.Value = handles.slider1.Value;

handles.radiobutton5.Value = 1;
handles.transp = 0; 

handles.togglebutton1.Value = 1;
handles.tb = 1;

axes(handles.axes3)
pos = [0 0 2 2];
axis([0 3 0 3])
rectangle('Position', pos, 'Curvature', [1 1], 'FaceColor', [1 0 0], 'LineWidth', 3)
axis equal
axis off
onair = 'Segmentation OFF';
set(handles.text3, 'string', onair);
set(handles.text3, 'FontSize', 14);


axes(handles.axes1);
imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
axis off

handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
set(handles.text1, 'String', handles.slider1_text)

handles.slider2.Value = handles.slider1.Value;

axes(handles.axes2)
imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
axis off

handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
set(handles.text2, 'String', handles.slider2_text)

if ishandle(h1); close(h1); end
if ishandle(h3); close(h3); end
if ishandle(h4); close(h4); end

undo = 0;

if ishandle(h2)
    
    figure(h2), imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(SelectedMap), %truesize 
    
else
    
    figure, imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(SelectedMap), %truesize
    
end

axis off
h = gca;
h2 = gcf;

set(h2, 'KeyPressFcn', @hotkey_fig2)
set(h2, 'Name', ['Undo on slice no.' num2str(uint16(handles.slider2.Value)) '/' num2str(handles.num)]);
set(h2, 'DeleteFcn', 'undo = 1;')

% handles.output = hObject;
% Update handles structure

guidata(hObject, handles); set(0, 'userdata', handles);

while ishandle(h2)
    
    try
        hpoint = impoint(gca);
        posiz  = (getPosition(hpoint));
        c      = posiz(1); 
        r      = posiz(2);
        % 05/05/2016
% % % %         [c, r] = ginput(1);
        tmp = squeeze(handles.NeuSeg(:, :, uint16(handles.slider2.Value)));
        % BW2 = bwselect(tmp, uint16(c), uint16(r), 4);
% % % %         BW2 = bwselect(tmp, c, r, 4);
        
        BW2    = bwselect(tmp, c, r, 4);
        
        for i = 1:size(BW2, 1)
            
            for j = 1:size(BW2, 2)
                
                if handles.NeuSeg(i, j, uint16(handles.slider2.Value)) == 0
                    
                    BW2(i, j) = 0;
                    
                else
                    
                    BW2(i,j) = ~ BW2(i,j);
                    
                end
                
            end
            
        end
        
        handles.NeuSeg(:, :, uint16(handles.slider2.Value)) = BW2;
        clear BW2
        
        axes(handles.axes2)
        imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
        axis off
        
        clf(h2, 'reset');
        undo = 0;
        
        figure(h2); imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(SelectedMap); axis off; %truesize
        
        set(h2,'KeyPressFcn',@hotkey_fig2)
        set(h2, 'Name', ['Undo on slice no.' num2str(uint16(handles.slider2.Value)) '/' num2str(handles.num)]);
        set(h2, 'DeleteFcn', 'undo=1;')
        clear hpoint posiz
        guidata(hObject, handles);set(0, 'userdata', handles);
        
    catch
        undoON = 0;
        
        break
        
    end
    
end
% handles.output = hObject;
% Update handles structure
% guidata(hObject, handles);set(0, 'userdata', handles);
if undoON ==1; pushbutton6_Callback(hObject, eventdata, handles); end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)    %does it exist?
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.transp;
% handles.zstack;
% handles.Vnew;
% handles.NeuSeg;

if handles.transp == 0  % user can see just the image selected with the slider
    
    axes(handles.axes1)
    imshowpair(handles.Vnew(:,:,handles.zstack+1), handles.NeuSeg(:,:,handles.zstack)), %truesize
    axis off
    handles.transp = 1;
    
else   
    
    axes(handles.axes1)
    imagesc(handles.Vnew(:,:,handles.zstack)), %truesize
    axis off
    
    handles.transp = 0;
    
end

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)  %does it exist?
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.transp;
% handles.zstack;
% handles.Vnew;
% handles.NeuSeg;
% 
if handles.transp == 0  % user can see just the image elected with the slider
    
    axes(handles.axes1)
    %imshowpair(handles.NeuSeg(:,:,handles.zstack-1), handles.Vnew(:,:,handles.zstack), 'falsecolor')
    imshowpair(handles.Vnew(:,:,handles.zstack), handles.NeuSeg(:,:,handles.zstack-1)), %truesize
    axis off
    handles.transp = 1;
    
else   
    
    axes(handles.axes1)
    imagesc(handles.Vnew(:,:,handles.zstack)), %truesize
    axis off
    
    handles.transp = 0;
    
end

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);set(0,'userdata',handles)


% --- Executes on button press in pushbutton9.
% --- SHOW THE RESULTS
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h1 h2 h3 h4

handles=get(0, 'userdata');
guidata(hObject, handles);

if ishandle(h1); close(h1); end
if ishandle(h2); close(h2); end
if ishandle(h3); close(h3); end

[handles.faces, handles.vertices] = isosurface(handles.NeuSeg , 0.5);
if ishandle(h4)
    
    figure(h4), patch ('Faces', handles.faces, 'Vertices', handles.vertices, 'Facecolor', 'green', 'Edgecolor', 'none'); axis equal;
    camlight; camlight(-80, -10); lighting phong;

else
    figure, patch ('Faces', handles.faces, 'Vertices', handles.vertices, 'Facecolor', 'green', 'Edgecolor', 'none'); axis equal;
camlight; camlight(-80, -10); lighting phong;

end

axis off
h =gca;
h4=gcf;

title('3D VIEW OF THE SEGMENTED STRUCTURE.');

handles.output = hObject;
% Update handles structure

guidata(hObject, handles);
set(0, 'userdata', handles);


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global  h1 ab segON SelectedMap

% axes(handles.axes1); imagesc(handles.Vnew(:, :, handles.slider1.Value));
guidata(hObject, handles); set(0, 'userdata', handles);
% zstack = handles.slider1.Value;

handles.nmeno1 = get(handles.radiobutton8, 'Value');
handles.n = get(handles.radiobutton6, 'Value');
handles.npiu1  = get(handles.radiobutton7, 'Value');

if handles.radiobutton8.Value == 1 || handles.radiobutton7.Value == 1 || handles.radiobutton6.Value == 1
    
    set(handles.togglebutton1, 'Value', 1);
    handles.tb = 1;
    
    handles.transp = 1;
    
    if uint16(handles.slider2.Value) > 1 && uint16(handles.slider2.Value) < handles.num
        
        set(handles.radiobutton8, 'Enable', 'on');
        set(handles.radiobutton7, 'Enabl', 'on');
        set(handles.radiobutton6, 'Enable', 'on');

        if handles.nmeno1 == 1

            handles.slider1.Value = handles.slider2.Value+1;

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

        elseif handles.n == 1

            handles.slider1.Value = handles.slider2.Value;

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, handles.slider2.Value)), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

        elseif handles.npiu1 == 1

            handles.slider1.Value = handles.slider2.Value-1;

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

        end

    elseif uint16(handles.slider2.Value) == 1 
            
            set(handles.radiobutton8, 'Enable', 'off');
            set(handles.radiobutton7, 'Enabl', 'on');
            set(handles.radiobutton6, 'Enable', 'on');
            
            if handles.nmeno1 == 1

                handles.slider1.Value = handles.slider2.Value+1;

                axes(handles.axes1)
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                axes(handles.axes2)
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

            elseif handles.n == 1

                handles.slider1.Value = handles.slider2.Value;

                axes(handles.axes1)
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                axes(handles.axes2)
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

            end

    elseif  uint16(handles.slider2.Value) == handles.num 
            
            set(handles.radiobutton8, 'Enable', 'on');
            set(handles.radiobutton7, 'Enabl', 'off');
            set(handles.radiobutton6, 'Enable', 'on');
            
            if handles.n == 1

                handles.slider1.Value = handles.slider2.Value;

                axes(handles.axes1)
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                axes(handles.axes2)
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

            elseif handles.npiu1 == 1

                handles.slider1.Value = handles.slider2.Value-1;

                axes(handles.axes1)
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                axes(handles.axes2)
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

            end

    end
    
else
    
    handles.transp = 0;
    
    if handles.tb == 1

            handles.slider1.Value = handles.slider2.Value;

            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))); colormap(handles.axes1, SelectedMap), axis off; %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
            axis off        
        
    else
        
            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
            axis off  
        
    end
    
    if uint16(handles.slider2.Value) == 1
        
        set(handles.radiobutton8, 'Enable', 'on');
        set(handles.radiobutton6, 'Enable', 'on');
        set(handles.radiobutton7, 'Enable', 'off');
        
    elseif uint16(handles.slider2.Value) == handles.num
        
        set(handles.radiobutton8, 'Enable', 'off');
        set(handles.radiobutton6, 'Enable', 'on');
        set(handles.radiobutton7, 'Enable', 'on');
        
    else 
        
        set(handles.radiobutton8, 'Enable', 'on');
        set(handles.radiobutton6, 'Enable', 'on');
        set(handles.radiobutton7, 'Enable', 'on');
        
    end
        
end
    
handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
set(handles.text1, 'String', handles.slider1_text);

handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
set(handles.text2, 'String', handles.slider2_text);

%03/05 un po piu tardi
% % % % % % % guidata(hObject, handles);
% set(0,'userdata',handles);
if ishandle(h1)
    
    guidata(hObject, handles); set(0, 'userdata', handles)
    clf (h1, 'reset')
    ab = 0;
    
    figure(h1); imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))); colormap(h1, SelectedMap), %truesize
    axis off
    
end

guidata(hObject, handles); set(0, 'userdata', handles);
% set(0,'userdata',handles);
if segON == 1; pushbutton2_Callback(hObject, eventdata, handles); end


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton10.
% --- SAVE THE NEURON
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global t t1 h1 h2 h3 h4 SelectedMap segON

t = t+toc(t1);

if ishandle(h1); close(h1); end
if ishandle(h2); close(h2); end
if ishandle(h3); close(h3); end
if ishandle(h4); close(h4); end


StrNotSaved = false;    %flag for segmented structure- saving

%flag for segmentation OFF
axes(handles.axes3)
pos = [0 0 2 2];
axis([0 3 0 3])
rectangle('Position', pos, 'Curvature', [1 1], 'FaceColor', [1 0 0], 'LineWidth', 3)
axis equal
axis off

onair = 'Segmentation OFF';
set(handles.text3, 'string', onair);
set(handles.text3, 'FontSize', 14, 'FontWeight', 'bold');

[handles.faces, handles.vertices] = isosurface(handles.NeuSeg , 0.5);

choice = questdlg(['The neuron was segmented in ', num2str(t), ' seconds. Do you want to segment another neuron in this stack?'], 'Continue?', 'Yes', 'No','No');

if handles.AnotherNeuron == 1
    
    switch choice
        
        case 'Yes'
            %             pushbutton9_Callback(hObject, eventdata, handles);
            
            fileout = strcat('Neurone', num2str(handles.Neu));
            varname = genvarname(fileout);
            s = struct('Neuron', handles.NeuSeg, 'faces', handles.faces, 'vertices', handles.vertices,'tempo',t);
            eval([varname '= s;']);
            
%             cd(handles.npath)
            handles.newfile = fullfile(handles.npath, handles.nfile);
            save(handles.newfile,fileout,'-append')    %the command overwrites if the variable already exists
%             cd(handles.olddir)
            
            t = 0;         % azzero il contatore del tempo
            %segON  = 0;         % manual segmentation OFF
            
            handles.vertices = [];
            handles.faces = [];
            handles.tb     = 1;         %move the sliders together
            set(handles.togglebutton1, 'Value',  handles.tb)
            %handles.olddir = pwd;
            
%             close(gcf)
            
% % % % %             axes(handles.axes2)
% % % % %             imagesc(false(512,512)), colormap(SelectedMap)
% % % % %             axis off
            
            handles.Neu = handles.Neu+1;
            
            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, 1)), colormap(handles.axes1, SelectedMap), %truesize
            axis off
            
            handles.NeuSeg = false(handles.n_x, handles.n_y, handles.num);
            
            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, 1)), colormap(handles.axes2, SelectedMap), %truesize
            axis off
            
            t = 0;
            
            if ishandle(h1)
                
                close(h1)
                
            end
            
            %dobbiamo refreshare tutte le variabili di default?
            
        case 'No'
            %             pushbutton9_Callback(hObject, eventdata, handles);
            
            fileout = strcat('Neurone', num2str(handles.Neu));
            s = struct('Neuron', handles.NeuSeg, 'faces', handles.faces, 'vertices', handles.vertices, 'tempo', t);
            varname = genvarname(fileout);
            eval([varname '= s']);
            
%             cd(handles.npath)
            handles.newfile = fullfile(handles.npath, handles.nfile);
            save(handles.newfile, fileout, '-append')
%             cd(handles.olddir)
            
    end
    
else
    
    switch choice
        
        case 'Yes'
            
            %dm_tracing{handles.Neu, 1} = handles.NeuSeg;
            fileout = strcat('Neurone', num2str(handles.Neu));
            varname = genvarname(fileout);
            s = struct('Neuron', handles.NeuSeg, 'faces', handles.faces, 'vertices', handles.vertices, 'tempo',t);
            eval([varname '= s;']);
%             cd(handles.path_file)
            
            if handles.Neu == 1
                
                [handles.filesave, handles.path_save] = uiputfile('*.mat','Save the Neuron', handles.I_file_tmp(1:end-4));
                
                if handles.filesave ~=0
                    
                    handles.newfile = fullfile(handles.path_save, handles.filesave);
                    save(handles.newfile, fileout)
%                     cd (handles.olddir)
                    
                else
                    
                    StrNotSaved = true;
                    %                     warndlg('Neuron was not saved','Warning!')
                    %                     cd (handles.olddir)
                end
                
            else
                
                handles.newfile = fullfile(handles.path_save, handles.filesave);
                save(handles.newfile, fileout, '-append')
%                 cd(handles.olddir)
                
            end
            
            t      = 0;         % t = 0 to start a new one
            segON  = 0;         % manual segmentation OFF
            
            handles.vertices = [];
            handles.faces = [];
            handles.tb     = 1;         %move the sliders together
            set(handles.togglebutton1,'Value', handles.tb)
            handles.olddir = pwd;
            
%             close(gcf)
            
            axes(handles.axes2)
            imagesc(false(512,512)), colormap(handles.axes2, SelectedMap), %truesize
            axis off
                    
            handles.Neu = handles.Neu+1;
            
            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, 1)), colormap(handles.axes1, SelectedMap), %truesize
            axis off
            
            handles.NeuSeg = false(handles.n_x, handles.n_y, handles.num);
            
            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, 1)), colormap(SelectedMap), %truesize
            axis off
            
            t = 0;
            
            if ishandle(h1)
                
                close(h1)
                
            end
            
        case 'No'
            fileout = strcat('Neurone', num2str(handles.Neu));
            s = struct('Neuron', handles.NeuSeg, 'faces', handles.faces, 'vertices', handles.vertices, 'tempo', t);
            varname = genvarname(fileout);
            eval([varname '= s']);
%             cd(handles.path_file)
            
            if handles.Neu == 1
                
                [handles.filesave,handles.path_save] = uiputfile('*.mat', 'Save the neuron', handles.I_file_tmp(1:end-4));
                
                if handles.filesave ~= 0
                    
                    handles.newfile = fullfile(handles.path_save, handles.filesave);
                    save(handles.newfile, fileout)
%                     cd (handles.olddir)
                    
                else
                    
                    StrNotSaved = true;
                    %                     warndlg('Neuron was not saved','Warning!')
                    %                     cd (handles.olddir)
                end
                
            else
                
                handles.newfile = fullfile(handles.path_save, handles.filesave);
                save(handles.newfile, fileout, '-append')
%                 cd(handles.olddir)
                
            end
            
    end
    
end

if StrNotSaved
    
    msgbox('Neuron was not saved','Warning!','warn')
%     cd (handles.olddir)
    
end

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);set(0,'userdata',handles)

% --- Executes on button press in pushbutton11.
% --- MERGE AND GO TO IMAGEJ
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.NeuSeg;
% handles.Vnew;
global h1 h2 h3 h4

if ishandle(h1);close(h1);end
if ishandle(h2);close(h2);end
if ishandle(h3);close(h3);end
if ishandle(h4);close(h4);end
StrNotSaved_tif=false;

out1 = handles.Vnew;
out2 = handles.NeuSeg;

Vindex = find(out2);
VV=uint16(out1);
VV(Vindex)=max(out1(:));


[handles.filesave_tif,handles.path_save_tif] = uiputfile('*.tif', 'Save the neuron in tiff format');

if handles.filesave_tif ~=0;
    if strcmp(handles.filesave_tif(end-3:end), '.tif') == 1
        for K=1:length(VV(1, 1, :))
            imwrite(VV(:, :, K), [strcat(handles.path_save_tif,handles.filesave_tif)], 'WriteMode', 'append');
        end
    else
        for K=1:length(VV(1, 1, :))
            imwrite(VV(:, :, K), [strcat(handles.path_save_tif,handles.filesave_tif),'.tif'], 'WriteMode', 'append');
        end
    end
else
    
    StrNotSaved_tif = true;
    warndlg('Neuron was not saved','Warning!')
    %                     cd (handles.olddir)
end
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in uipanel1.
% --- PANNELLO TRASPARENZA
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global  h1 h2 h3 h4 segON SelectedMap

handles.nmeno1 = get(handles.radiobutton8, 'Value');
handles.n = get(handles.radiobutton6, 'Value');
handles.npiu1 = get(handles.radiobutton7, 'Value');

%WARNING: when you are using the transparency, togglebutton 1 is
          %always set to 1
if ishandle(h1);close(h1);end
if ishandle(h2);close(h2);end
if ishandle(h3);close(h3);end
if ishandle(h4);close(h4);end
          
if handles.radiobutton8.Value == 1 || handles.radiobutton7.Value == 1 || handles.radiobutton6.Value == 1
    
    handles.togglebutton1.Value = 1;
    handles.tb = 1;
    handles.transp = 1;

    if uint16(handles.slider1.Value) > 1 && uint16(handles.slider1.Value) < handles.num

            set(handles.radiobutton8, 'Enable', 'on')
            set(handles.radiobutton6, 'Enable', 'on')
            set(handles.radiobutton7, 'Enable', 'on')

        if handles.nmeno1 == 1

            set(handles.popupmenu1, 'Value', 11)
            SelectedMap = handles.defaultmap;

            handles.slider2.Value = handles.slider1.Value-1;

            set(handles.popupmenu1,'Enable', 'off');

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

            handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
            set(handles.text2, 'String', handles.slider2_text);

        elseif handles.n == 1      

            set(handles.popupmenu1, 'Value', 11)
            SelectedMap = handles.defaultmap;
            set(handles.popupmenu1, 'Enable', 'off');

            handles.slider2.Value = handles.slider1.Value;

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

            handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
            set(handles.text2, 'String', handles.slider2_text);

        elseif handles.npiu1 == 1        

            set(handles.popupmenu1, 'Value', 11)
            SelectedMap = handles.defaultmap;

            handles.slider2.Value = handles.slider1.Value+1;

            set(handles.popupmenu1,'Enable','off');        

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

            handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
            set(handles.text2, 'String', handles.slider2_text);
            
        end

    elseif uint16(handles.slider1.Value) == 1

            set(handles.radiobutton8, 'Enable', 'off')
            set(handles.radiobutton6, 'Enable', 'on')
            set(handles.radiobutton7, 'Enable', 'on')

        if  handles.n == 1

            handles.slider2.Value = handles.slider1.Value;   

            set(handles.popupmenu1, 'Value', 11)
            SelectedMap = handles.defaultmap;

            set(handles.popupmenu1,'Enable','off');

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

            handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
            set(handles.text2, 'String', handles.slider2_text);

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

        elseif handles.npiu1 == 1       

            set(handles.popupmenu1, 'Value', 11)
            SelectedMap = handles.defaultmap;

            set(handles.popupmenu1, 'Enable', 'off');

            handles.slider2.Value = handles.slider1.Value+1;

            axes(handles.axes1)
            imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2); axis off; %truesize

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

            handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
            set(handles.text2, 'String', handles.slider2_text);

        end

    elseif uint16(handles.slider1.Value) == handles.num

            set(handles.radiobutton8, 'Enable', 'on')
            set(handles.radiobutton6, 'Enable', 'on')
            set(handles.radiobutton7, 'Enable', 'off')           

            if handles.nmeno1 == 1

                set(handles.popupmenu1, 'Value', 11)
                SelectedMap = handles.defaultmap;

                handles.slider2.Value = handles.slider1.Value-1;

                set(handles.popupmenu1,'Enable','off');

                axes(handles.axes1)
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                axes(handles.axes2)
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

                handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
                set(handles.text1, 'String', handles.slider1_text);

                handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
                set(handles.text2, 'String', handles.slider2_text);

            elseif handles.n == 1

                set(handles.popupmenu1, 'Value', 11)
                SelectedMap = handles.defaultmap;

                set(handles.popupmenu1,'Enable','off');

                handles.slider2.Value = handles.slider1.Value;

                axes(handles.axes1)
                imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
                axis off

                axes(handles.axes2)
                imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
                axis off

                handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
                set(handles.text1, 'String', handles.slider1_text);

                handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
                set(handles.text2, 'String', handles.slider2_text);

            end
    end
    
else %if ON/OFF is active, togglebotton1 may or may not be active 
    handles.transp = 0;
    
    if handles.tb == 1
        
        if handles.slider1.Value > 1 && handles.slider1.Value < handles.num

            set(handles.radiobutton8, 'Enable', 'on')
            set(handles.radiobutton6, 'Enable', 'on')
            set(handles.radiobutton7, 'Enable', 'on')

            handles.transp = 0;

            handles.slider2.Value = handles.slider1.Value;

            set(handles.popupmenu1,'Enable','On')
            set(handles.popupmenu1, 'Value', 11)

            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

            handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
            set(handles.text2, 'String', handles.slider2_text);

        elseif uint16(handles.slider1.Value) == 1

            set(handles.radiobutton8, 'Enable', 'off')
            set(handles.radiobutton6, 'Enable', 'on')
            set(handles.radiobutton7, 'Enable', 'on')

            handles.transp = 0;

            set(handles.popupmenu1, 'Enable', 'on');

            handles.slider2.Value = handles.slider1.Value;

            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

            handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
            set(handles.text2, 'String', handles.slider2_text);


        elseif uint16(handles.slider1.Value) == handles.num

            set(handles.radiobutton8, 'Enable', 'on')
            set(handles.radiobutton6, 'Enable', 'on')
            set(handles.radiobutton7, 'Enable', 'off')           

            set(handles.popupmenu1,'Enable','on');

            handles.slider2.Value = handles.slider1.Value;

            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off            

            axes(handles.axes2)
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, handles.defaultmap2), %truesize
            axis off

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

            handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
            set(handles.text2, 'String', handles.slider2_text);

        end   
        
    else
       
        if handles.slider1.Value > 1 && handles.slider1.Value < handles.num

            set(handles.radiobutton8, 'Enable', 'on')
            set(handles.radiobutton6, 'Enable', 'on')
            set(handles.radiobutton7, 'Enable', 'on')

            set(handles.popupmenu1,'Enable', 'On')
            set(handles.popupmenu1, 'Value', 11)

            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

    elseif uint16(handles.slider1.Value) == 1

            set(handles.radiobutton8, 'Enable', 'off')
            set(handles.radiobutton6, 'Enable', 'on')
            set(handles.radiobutton7, 'Enable', 'on')

            set(handles.popupmenu1, 'Enable', 'on');

            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

    elseif uint16(handles.slider1.Value) == handles.num

            set(handles.radiobutton8, 'Enable', 'on')
            set(handles.radiobutton6, 'Enable', 'on')
            set(handles.radiobutton7, 'Enable', 'off')           


            set(handles.popupmenu1, 'Enable', 'on');

            axes(handles.axes1)
            imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
            axis off            

            handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
            set(handles.text1, 'String', handles.slider1_text);

        end 
         
    end
        
end

guidata(hObject, handles); 
set(0, 'userdata', handles)

set(hObject, 'Enable', 'off')
drawnow;
set(hObject,'Enable','on')

% if segON == 1
%     
%     clf (h1, 'reset')
%     pushbutton2_Callback(handles.pushbutton2, eventdata, handles);
%     
% end

% handles.output = hObject;
% Update handles structure
% guidata(hObject, handles);



% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SelectedMap
% Hint: get(hObject,'Value') returns toggle state of togglebutton1

handles = get(0, 'userdata');
guidata(hObject, handles)

handles.tb = ~handles.tb;

if handles.tb == 1  %moves the sliders together
    
    set(handles.radiobutton8, 'Enable', 'on');
    set(handles.radiobutton6, 'Enable', 'on');
    set(handles.radiobutton7, 'Enable', 'on');
    
    handles.slider1.Value = get(handles.slider1, 'Value');

    handles.nmeno1 = get(handles.radiobutton8, 'Value');
    handles.n = get(handles.radiobutton6, 'Value');
    handles.npiu1 = get(handles.radiobutton7, 'Value');
    
    if handles.nmeno1 == 1
        
        handles.slider2.Value = handles.slider1.Value-1;
        
        axes(handles.axes1)
        imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
        axis off
       
        axes(handles.axes2)
        imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap)
        axis off
                
    elseif handles.n == 1
        
        handles.slider2.Value = handles.slider1.Value;
        
        axes(handles.axes1)
        imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
        axis off
        
        axes(handles.axes2)
        imagesc(handles.NeuSeg(:, :, handles.slider2.Value)), colormap(handles.axes2, SelectedMap)
        axis off
                
    elseif handles.npiu1 == 1
        
        handles.slider2.Value = handles.slider1.Value+1;
        
        axes(handles.axes1)
        imshowpair(handles.Vnew(:, :, uint16(handles.slider1.Value)), handles.NeuSeg(:, :, uint16(handles.slider2.Value))), %truesize
        axis off
       
        axes(handles.axes2)
        imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
        axis off
                
    else
        
        handles.slider2.Value = handles.slider1.Value;
        
        axes(handles.axes1)
        imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
        axis off
        
        axes(handles.axes2)
        imagesc(handles.NeuSeg(:, :, uint16(handles.slider1.Value))), colormap(handles.axes2, SelectedMap)
        axis off

        
    end
    
    handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
    set(handles.text2, 'string', handles.slider2_text);
    
    handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
    set(handles.text1, 'string', handles.slider1_text);
else
    
    set(handles.radiobutton8, 'Enable', 'off');
    set(handles.radiobutton6, 'Enable', 'off');
    set(handles.radiobutton7, 'Enable', 'off');

end

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
set(0, 'userdata', handles)

set(hObject, 'Enable', 'off')
drawnow;
set(hObject, 'Enable', 'on')


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 

if handles.nmeno1 == 1
    
    axes(handles.axes1)
    imshowpair(handles.Vnew(:, :, handles.slider1.Value), handles.NeuSeg(:, :, handles.slider1.Value+1)), %truesize
    axis off
    
    handles.slider2.Value = handles.slider1.Value-1;
    
elseif handles.n == 1
    
    axes(handles.axes1)
    imshowpair(handles.Vnew(:, :, handles.slider1.Value), handles.NeuSeg(:, :, handles.slider1.Value)), %truesize
    axis off
    
    handles.slider2.Value = handles.slider1.Value;
    
elseif handles.npiu1 == 1
    
    axes(handles.axes1)
    imshowpair(handles.Vnew(:, :, handles.slider1.Value), handles.NeuSeg(:, :, handles.slider1.Value+1)), %truesize
    axis off
    
    handles.slider2.Value = handles.slider1.Value+1;
    
else
    
    axes(handles.axes1)
    imagesc(handles.Vnew(:, :, handles.slider1.Value)), %truesize
    axis off
    
    handles.slider2.Value = handles.slider1.Value;
    
end

if handles.tb ==1
    
    axes(handles.axes2)
    imshow(handles.NeuSeg(:, :, handles.slider2.Value)), %truesize
    axis off
    
end

if segON == 1
    
    pushbutton2_Callback(hObject, eventdata, handles);
end

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)  %????
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global segON

%pushbutton12_Callback(hObject, eventdata, handles);
axes(handles.axes1)
zoom
pause

if segON == 1
    pushbutton2_Callback(hObject, eventdata, handles);
end

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global SelectedMap

switch eventdata.Key
    
    case {'leftarrow','downarrow'}
        
        tmp_z = get(handles.slider1, 'Value');
        
        if tmp_z == 1
            
            handles.slider1.Value = tmp_z;
            
        else
            
            handles.slider1.Value = tmp_z-1;
            
        end
        
        if handles.slider1.Value == 1
            
            set(handles.radiobutton6, 'Value', 1)
            handles.n =1;
            set(handles.radiobutton8, 'Enable', 'off')
            
        end
        
        if handles.slider1.Value-1 < handles.num
            
            set(handles.radiobutton7, 'Enable', 'on') 
            
        end
        
        axes(handles.axes1);
        imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
        axis off
        
        handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
        set(handles.text1, 'String', handles.slider1_text)

        if handles.tb == 1 %&& tmp_z ~= 1

            handles.slider2.Value = tmp_z;  %-1

            axes(handles.axes2);
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
            axis off

            handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
            set(handles.text2, 'String', handles.slider2_text)

        end
        
    case {'rightarrow','uparrow'}
        
        tmp_z = get(handles.slider1,'Value');
        
        if tmp_z == handles.num
            
            handles.slider1.Value = tmp_z;
            
        else
            
            handles.slider1.Value = tmp_z+1;
            
        end
        
        if handles.slider1.Value > 1
            
            set(handles.radiobutton8, 'Enable', 'on')
            
        end
        
        if handles.slider1.Value+1 == handles.num
            
            set(handles.radiobutton6, 'Value', 1)
            handles.n =1;
            set(handles.radiobutton7, 'Enable', 'off') 
            
        end
        
        axes(handles.axes1);
        imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
        axis off
        
        handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
        set(handles.text1, 'String', handles.slider1_text)
        
        if handles.tb == 1 %&& tmp_z ~= handles.num
  
            handles.slider2.Value = handles.slider1.Value;

            axes(handles.axes2);
            imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
            axis off
        
            handles.slider2_text = [num2str(uint16(handles.slider2.Value)),'/', num2str(handles.num)];
            set(handles.text2, 'String', handles.slider2_text)
            
        end        
        
    otherwise
        
end

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
set(0, 'userdata', handles);


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2

%set(hObject, handles.axes2)
%
% %axes(handles.axes2)
% imagesc(handles.NeuSeg(:, :, handles.zstack))
% axis off


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global h1 h2 h3 h4 segON undoON splitON SelectedMap

if ishandle(h1)
    
    close(h1);
%     figure1_CloseRequestFcn(hObject,eventdata,handles);

elseif ishandle(h2)
    
    close(h2)
%     figure1_CloseRequestFcn(hObject,eventdata,handles);

elseif ishandle(h3)
    
    close(h3)
%     figure1_CloseRequestFcn(hObject,eventdata,handles);

elseif ishandle(h4)
    
    close(h4)
%     figure1_CloseRequestFcn(hObject,eventdata,handles);

else
    
    delete(hObject);
    clear all
    % clc
    msgbox('Thank you for using ManSegTool, see you soon!','Goodbye')

end

% --- Executes on button press in pushbutton13.
% ---  SPLIT
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.NeuSeg

global  h1 h2 h3 h4 SelectedMap segON splitON undoON closedGUI
% 

handles = get(0, 'userdata');
guidata(hObject, handles)

segON   = 0;
undoON  = 0;
splitON = 1;

handles.radiobutton5.Value = 1;
handles.transp = 0; 

handles.togglebutton1.Value = 1;
handles.tb = 1;

axes(handles.axes3)
pos = [0 0 2 2];
axis([0 3 0 3])
rectangle('Position', pos, 'Curvature', [1 1], 'FaceColor', [1 0 0], 'LineWidth', 3)
axis equal
axis off

onair = 'Segmentation OFF';
set(handles.text3, 'string', onair);
set(handles.text3, 'FontSize', 14);

axes(handles.axes1);
imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %truesize
axis off

handles.slider1_text = [num2str(uint16(handles.slider1.Value)), '/', num2str(handles.num)];
set(handles.text1, 'String', handles.slider1_text)

handles.slider2.Value = handles.slider1.Value;

axes(handles.axes2)
imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
axis off

handles.slider2_text = [num2str(uint16(handles.slider2.Value)), '/', num2str(handles.num)];
set(handles.text2, 'String', handles.slider2_text)


if ishandle(h1)
    
    close(h1)

end

if ishandle(h2)
    
    close(h2)

end

if ishandle(h4)
    
    close(h4)

end

if ishandle(h3)
    
    figure(h3), imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(h3, SelectedMap), %truesize
    
else
    
    figure, imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(SelectedMap), %truesize
    
end

axis off
h = gca;
h3 = gcf;

set(h3, 'KeyPressFcn', @hotkey_fig3)
set(h3, 'Name', ['Split on slice no.' num2str(uint16(handles.slider2.Value)) '/' num2str(handles.num)]);
set(h3, 'DeleteFcn', 'undo = 1;')


% handles.output = hObject;
% Update handles structure

guidata(hObject, handles); set(0, 'userdata', handles);

while ishandle(h3)
    
    try
        
        im_cut = imfreehand(gca, 'Closed', false); %manual traced object
        tmp = bwmorph(im_cut.createMask, 'thin', Inf);
     
        handles.NeuSeg(:, :, uint16(handles.slider2.Value)) = and(handles.NeuSeg(:, :, uint16(handles.slider2.Value)), ~(tmp));
        
        axes(handles.axes2)
        imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %truesize
        axis off
        
        clf(h3, 'reset');
        
        figure(h3); imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(h3, SelectedMap); axis off; %truesize
        
        set(h3,'KeyPressFcn',@hotkey_fig3)
        set(h3, 'Name', ['Split on slice no.' num2str(uint16(handles.slider2.Value)) '/' num2str(handles.num)]);
        set(h3, 'DeleteFcn', 'split=1;')
    
        guidata(hObject, handles); set(0, 'userdata', handles);
        
    catch 

        splitON = 0;
        
        break 
        
    end
    
end

% handles.output = hObject;
% Update handles structure
% guidata(hObject, handles);set(0, 'userdata', handles);

if splitON ==1; pushbutton13_Callback(hObject, eventdata, handles); end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
global SelectedMap VnewExist h1 h2 h3 h4 segON ab undoON splitON

str = get(hObject, 'String');
val = get(hObject,'Value');

% Set current data to the selected data set.
switch str{val}
    case 'GrayScale' 
       SelectedMap = 'gray';       
    case 'Parula' 
       SelectedMap = 'parula';
    case 'Jet' 
       SelectedMap = 'jet';
    case 'Hsv'
        SelectedMap = 'hsv';
    case 'Hot'
        SelectedMap = 'hot';
    case 'Cool'
        SelectedMap = 'cool';
    case 'Spring'
        SelectedMap = 'spring';
    case 'Summer'
        SelectedMap = 'summer';
    case 'Autumn'
        SelectedMap = 'autumn';
    case 'Winter'
        SelectedMap = 'winter';
    case 'Green'
        SelectedMap = handles.defaultmap;
end

if VnewExist == 1

    axes(handles.axes1)
    imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))), colormap(handles.axes1, SelectedMap), %%truesize
    axis off

    axes(handles.axes2)
    imagesc(handles.NeuSeg(:, :, uint16(handles.slider2.Value))), colormap(handles.axes2, SelectedMap), %%truesize
    axis off
    
else

    axes(handles.axes1)
    imagesc(false(512, 512)), colormap(handles.axes1, SelectedMap)
    axis off

    axes(handles.axes2)
    imagesc(false(512, 512)), colormap(handles.axes2, SelectedMap)
    axis off

end


if ishandle(h1)
    
    guidata(hObject, handles); set(0, 'userdata', handles)
    clf (h1, 'reset')
    
    ab = 0;
    figure(h1); imagesc(handles.Vnew(:, :, uint16(handles.slider1.Value))); colormap(h1, SelectedMap); axis off; %%truesize
    
end
if ishandle(h2)
    
    guidata(hObject, handles); set(0, 'userdata', handles)
    clf (h2, 'reset')
    
    figure(h2); imagesc(handles.NeuSeg(:, :, uint16(handles.slider1.Value))); colormap(h2, SelectedMap), %truesize
    axis off
    
end

if ishandle(h3)
    
    guidata(hObject, handles); set(0, 'userdata', handles)
    clf (h3, 'reset')
    
    figure(h3); imagesc(handles.NeuSeg(:, :, uint16(handles.slider1.Value))); colormap(h3, SelectedMap), %truesize
    axis off
    
end
% set(hObject,'Enable','off')
% drawnow;
% set(hObject,'Enable','on')

guidata(hObject, handles); set(0, 'userdata', handles);
% set(0,'userdata',handles);
if segON == 1; pushbutton2_Callback(hObject, eventdata, handles); end
if undoON == 1; pushbutton6_Callback(hObject, eventdata, handles); end
if splitON == 1; pushbutton13_Callback(hObject, eventdata, handles); end
