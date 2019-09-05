%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 3 - Example Model Comparison with the STN/GPe subcircuit
% (i) Run this script first too compute individual model fits
%%%%%%%%%%%%%%%%%%%%%%%%

% IF STARTING FRESH
%  delete([R.rootn 'outputs\' R.out.tag '\WorkingModList.mat'])

clear ; close all
R = ABCAddPaths('Rat_NPD','rat_STN_GPe');

% Close all msgboxes
closeMessageBoxes
rng(7564332)

%% Set Routine Pars
R.projectn = 'Rat_NPD'; % Project Name
R.out.tag = 'STN_GPe_ModComp'; % Task tag
R = simannealsetup_NPD_STN_GPe(R);

%% Prepare the data
R = prepareRatData_STN_GPe_NPD(R);

try
    load([R.rootn 'outputs\' R.out.tag '\WorkingModList'])
    disp('Loaded Mod List!!')
catch
    WML = [];
    mkdir([R.rootn 'outputs\' R.out.tag ]);
    save([R.rootn 'outputs\' R.out.tag '\WorkingModList'],'WML')
    disp('Making Mod List!!')
end

%% Prepare Model
for modID = 1:3
    load([R.rootn 'outputs\' R.out.tag '\WorkingModList'],'WML')
    if ~any(intersect(WML,modID))
        WML = [WML modID];
        save([R.rootn 'outputs\' R.out.tag '\WorkingModList'],'WML')
        disp('Writing to Mod List!!')
        fprintf('Now Fitting Model %.0f',modID)
        f = msgbox(sprintf('Fitting Model %.0f',modID));
        
        modelspec = eval(['@MS_rat_STN_GPe_ModComp_Model' num2str(modID)]);
        [R,p,m] = modelspec(R);
        pause(5)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        R.out.dag = sprintf('NPD_STN_GPe_ModComp_M%.0f',modID); % 'All Cross'
        R.SimAn.rep = 308;
        R = setSimTime(R,24);
        R.SimAn.convIt = 7e-5;
        R.Bcond = 0;
        R.plot.flag = 1;
        [p] = SimAn_ABC_220219b(R,p,m);
        closeMessageBoxes()
    end
end
