function R = ABCAddPaths(projpath,routname)
switch getenv('computername')
    case 'SFLAP-2'
        usname = 'Tim'; gitpath = '\Documents\Work\GIT'; madpath = 'MATLAB_ADDONS';
        spmpath = 'C:\Users\Tim\Documents\spm12';
    case 'FREE'
        usname = 'twest'; gitpath = '\Documents\Work\GitHub'; madpath = 'Work\MATLAB ADDONS';
        spmpath = 'C:\spm12';
    case 'DESKTOP-94CEG1L'
        usname = 'timot';
        gitpath =  'C:\Users\timot\Documents\GitHub';
        madpath = 'Work\MATLAB ADDONS';
        spmpath = 'C:\Users\timot\Documents\GitHub\spm12';
        R.path.datapath = 'D:\Data\Shenghong_Tremor';
        
    case 'TIM_PC'
        gitpath = 'D:\GITHUB';
        projpath = projpath;
        madpath = 'D:\MATLAB ADDONS';
        spmpath = 'D:\GITHUB\spm12-master';
    case 'DESKTOP-1QJTIMO'
        gitpath = 'C:\Users\Tim West\Documents\GitHub';
        projpath = projpath;
        madpath = 'C:\Users\Tim West\Documents\MATLAB ADDONS';
        spmpath = 'C:\Users\Tim West\Documents\GitHub\spm12';
        R.path.datapath_shenghong = 'C:\DATA\Shenghong_Tremor';
        R.path.datapath_pedrosa = 'C:\DATA\DP_Tremor_ThalamoMuscular\';

end

% addpath(['C:\Users\' usname '\Documents\' madpath '\ParforProgMon'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\aboxplot'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\ATvDFA-package'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\bplot\'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\Circular_Statistics_Toolbox'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\cirHeatmap'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\DrosteEffect-BrewerMap-221b913'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\export_fig'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\FMINSEARCHBND'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\HotellingT2'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\linspecer'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\MEG_STN_Project'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\Neurospec\neurospec21'])
% addpath(genpath(['C:\Users\' usname '\Documents\' madpath '\ParforProgMon']))
% addpath(['C:\Users\' usname '\Documents\' madpath '\sigstar-master'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\sort_nat'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\SplitVec'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\TWtools'])
% addpath(['C:\Users\' usname '\Documents\' madpath '\violin'])
% addpath(genpath(['C:\spm12\toolbox\xjview96\xjview']))
% addpath(genpath(['C:\Users\' usname '\Documents\' madpath '\boundedline-pkg']))
% addpath(genpath(['C:\Users\' usname '\' gitpath '\BrewerMap']))
% addpath(genpath(['C:\Users\' usname '\' gitpath '\BurstToolbox']))
% addpath(genpath(['C:\Users\' usname '\' gitpath '\highdim']))

pathCell = regexp(path, pathsep, 'split'); onPath = any(strcmpi(spmpath, pathCell));
if ~onPath; addpath(spmpath); spm eeg; close all; end


addpath(genpath([gitpath '\ABC_Inference_Neural_Paper\ABC_dependencies']))
addpath(genpath([gitpath '\ABC_Inference_Neural_Paper\sim_machinery']))
addpath(genpath([gitpath '\Spike-smr-reader']))
addpath(genpath([projpath '\data']));
addpath(genpath([projpath '\model_fx']));
addpath(genpath([projpath '\ModelSpecs']));
addpath(genpath([projpath '\priors']));
addpath(genpath([projpath '\plotting']));
addpath(genpath([projpath '\routine\' routname]))
addpath(genpath([projpath '\external_dependencies']))


R.path.root = [projpath];
R.path.rootn = R.path.root; 
R.path.projectn = routname;
