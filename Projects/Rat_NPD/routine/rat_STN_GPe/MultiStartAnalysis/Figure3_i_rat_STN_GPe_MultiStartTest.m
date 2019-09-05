%STN GPE MOD FIT MASTER
%%%%%%%%%%%%%%%%%%%%%%%%
% IF FRESH!
%  delete([R.rootn 'outputs\' R.out.tag '\MultiStartList.mat'])

% simAnnealAddPaths()
clear ; close all
R = ABCAddPaths('Rat_NPD','rat_STN_GPe');

% Close all msgboxes
closeMessageBoxes
rng(7654654)

%% Set Routine Pars
R.projectn = 'Rat_NPD'; % Project Name
R.out.tag = 'STN_GPe_ModComp'; % Task tag
R = simannealsetup_NPD_STN_GPe(R);

% function WML = Figure3_i_rat_STN_GPe_MultiStartTest(R)
%% Prepare the data
R = prepareRatData_STN_GPe_NPD(R);

try
    load([R.rootn 'outputs\' R.out.tag '\MultiStartList'])
    disp('Loaded Mod List!!')
catch
    WML = [];
    mkdir([R.rootn 'outputs\' R.out.tag ]);
    save([R.rootn 'outputs\' R.out.tag '\MultiStartList'],'WML')
    disp('Making Mod List!!')
end
N = 10; % number of starts
%% Prepare Model
for multiStart = 1:2*N
    load([R.rootn 'outputs\' R.out.tag '\MultiStartList'],'WML')
    if ~any(intersect(WML,multiStart))
        WML = [WML multiStart];
        save([R.rootn 'outputs\' R.out.tag '\MultiStartList'],'WML')
        disp('Writing to Mod List!!')
        fprintf('Now Fitting Mulitstart %.0f',multiStart)
        f = msgbox(sprintf('Fitting Multistart %.0f',multiStart));
        
        if multiStart < N
            load([R.rootn 'outputs\' R.out.tag '\NPD_STN_GPe_ConfMat_DataM1_ParM1\R_STN_GPe_ModComp_NPD_STN_GPe_ConfMat_DataM1_ParM1.mat'])
            R.data = varo.data;
            figure(1);  R.plot.outFeatFx({R.data.feat_emp},{},R.data.feat_xscale,R,1,[])
        else
            load([R.rootn 'outputs\' R.out.tag '\NPD_STN_GPe_ConfMat_DataM2_ParM1\R_STN_GPe_ModComp_NPD_STN_GPe_ConfMat_DataM2_ParM1.mat'])
            R.data = varo.data;
            figure(1);  R.plot.outFeatFx({R.data.feat_emp},{},R.data.feat_xscale,R,1,[])
        end
        modelspec = eval(['@MS_rat_STN_GPe_ModComp_Model' num2str(1)]);
        [R,p,m] = modelspec(R);
        pause(5)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        R.out.dag = sprintf('NPD_STN_GPe_MultiStart_M%.0f',multiStart); % 'All Cross'
        % Delete Previous Saves
        delete([R.rootn 'outputs\' R.out.tag '\' R.out.dag '\*'])
        R.SimAn.rep = 128;
        R = setSimTime(R,32);
        R.Bcond = 0;
        R.plot.save = 1;
        R.plot.flag = 1;
        R.SimAn.convIt = 7e-5;
        R.SimAn.jitter = 1;
        SimAn_ABC_220219b(R,p,m);
        closeMessageBoxes
    end
end

if i>inf
    modelspec = MS_rat_STN_GPe_ModComp_Model1(R);
    modelspec = MS_rat_STN_GPe_ModComp_Model2(R);
    modelspec = MS_rat_STN_GPe_ModComp_Model3(R);
end
