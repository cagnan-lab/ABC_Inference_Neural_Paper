% MASTER FUNCTION FOR MODEL FITTING
% This function incorporates all of the nodes (including GPi/Thalamus)
% Models are specified in ModelSpecs of project folder. Will batch fit
% models to the data specified in fx prepareRatData. WML stores batch
% progress and can be accessed by multiple MATLAB realizations.
%%%% TO DO
% MODEL 5 HASNT BEEN DONE!temperature
%%%%%%%%%%%%%%%%%%%%%%%%
% IF FRESH START
% delete([R.rootn 'outputs\' R.out.tag '\WorkingModList.mat'])

% simAnnealAddPaths()
clear ; close all

% Close all msgboxes
closeMessageBoxes
% Add relevant paths for toolboxes
% simAnnealAddPaths(
rng(232452)

%% Set Routine Pars
R = ABCAddPaths('Rat_NPD','rat_InDirect_ModelComp');
R.projectn = 'Rat_NPD';
R.out.tag = 'rat_InDirect_ModelComp'; % Task tag
R = simannealsetup_InDirect_ModelComp(R);
% IF FRESH START
% delete([R.rootn 'outputs\' R.out.tag '\WorkingModList.mat'])
%% Prepare the data
R = prepareRatData_InDirect_Group_NPD(R);
WML = [];

try
    load([R.rootn 'outputs\' R.out.tag '\WorkingModList'])
    disp('Loaded Mod List!!')
catch
    WML = [];
    mkdir([R.rootn 'outputs\' R.out.tag ]);
    save([R.rootn 'outputs\' R.out.tag '\WorkingModList'],'WML')
    disp('Making Mod List!!')
end

for modID = 1:10;% 12:-1:1
    if modID>= 7
        R.obs.LF = [1 1 1 1 1 1].*10; % Fit visually and for normalised data
        R.chsim_name = {'MMC','STR','GPE','STN','GPI','THAL'};
    else
        R.chsim_name = {'MMC','STR','GPE','STN'};
        R.obs.LF = [1 1 1 1]*10; % Fit visually and for normalised data
    end
    load([R.rootn 'outputs\' R.out.tag '\WorkingModList'],'WML')
    if ~any(intersect(WML,modID))
        WML = [WML modID];
        save([R.rootn 'outputs\' R.out.tag '\WorkingModList'],'WML')
        disp('Writing to Mod List!!')
        fprintf('Now Fitting Model %.0f',modID)
        f = msgbox(sprintf('Fitting Model %.0f',modID));
        
        %% Prepare Model
        modelspec = eval(['@MS_rat_InDrt_ModCompRevTest_Model' num2str(modID)]);
        [R p m uc] = modelspec(R); % M! intrinsics shrunk"
        pause(5)
        R.out.dag = sprintf('NPD_InDrt_ModCompRevTest_M%.0f',modID); % 'All Cross'
        
        %% Run ABC Optimization
        R = setSimTime(R,32);
        R.Bcond = 0;
        [p] = SimAn_ABC_220219b(R,p,m);
        closeMessageBoxes
    end
end
