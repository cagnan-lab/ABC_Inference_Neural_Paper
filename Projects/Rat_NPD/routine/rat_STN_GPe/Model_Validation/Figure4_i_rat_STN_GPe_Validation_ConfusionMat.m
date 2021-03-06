function WML = Figure4_i_rat_STN_GPe_Validation_ConfusionMat(R)
R = ABCAddPaths('Rat_NPD','rat_STN_GPe');
%% Set Routine Pars
R.projectn = 'Rat_NPD'; % Project Name
R.out.tag = 'STN_GPe_ModComp'; % Task tag
R = simannealsetup_NPD_STN_GPe(R);
closeMessageBoxes
%STN GPE MOD FIT MASTER
%%%%%%%%%%%%%%%%%%%%%%%%
% IF FRESH!
delete([R.rootn 'outputs\' R.out.tag '\ConfWorkList.mat'])
for modID = 1:3
    Rt = []; % Temp R Struc
    %% First Simulate the Data from the Empirically Fitted Models
    % Recover Fitted Parameters
    dagname = sprintf([R.out.tag '_M%.0f'],modID);
    load([R.rootn 'outputs\' R.out.tag '\NPD_' dagname '\modelfit_' R.out.tag '_NPD_' dagname '.mat'])
    Mfit = varo; %i.e. permMod
    p = Mfit.Pfit;
    load([R.rootn 'outputs\' R.out.tag '\NPD_' dagname '\modelspec_' R.out.tag '_NPD_' dagname '.mat'])
    m = varo; %i.e. permMod
    load([R.rootn 'outputs\' R.out.tag '\NPD_' dagname '\R_' R.out.tag '_NPD_' dagname '.mat'])
    Rt = varo; %i.e. permMod
    Rt.root = R.rootn; %Overwrite root with current
    
    % Now Simulate Fitted Model
    pnew = Mfit.BPfit; % use best draw!
    Rt.obs.SimOrd = 9;
    Rt.obs.trans.gauss = 0;
    [r2,pnew,feat_sim,xsims,xsims_gl,wflag] = computeSimData(Rt,m,[],pnew,512,1);
    Rt.obs.trans.gauss =0;
    Rt.data.feat_emp = feat_sim;
    % squeeze(meannpd_data(1,1,1,1,:))
    Rt.data.feat_xscale = R.frqz;
    RSimData(modID) = Rt;
end
save([R.rootn 'outputs\' R.out.tag '\ConfData'],'RSimData')
load([R.rootn 'outputs\' R.out.tag '\ConfData'],'RSimData')
% Make matrix of combinations for confusion matrix
confmatlist = allcomb(1:3,1:3)';
R.tmp.confmat = confmatlist;
% Create List (for parallelization across multiple MATLAB instances)
% delete([R.rootn 'outputs\' R.out.tag '\ConfWorkList.mat'])

try
    load([R.rootn 'outputs\' R.out.tag '\ConfWorkList'])
    disp('Loaded Mod List!!')
catch
    WML = [];
    mkdir([R.rootn 'outputs\' R.out.tag ]);
    save([R.rootn 'outputs\' R.out.tag '\ConfWorkList'],'WML')
    disp('Making Mod List!!')
end

%% Prepare Model
for i =1:size(confmatlist,2)
    load([R.rootn 'outputs\' R.out.tag '\ConfWorkList'],'WML')
    if ~any(intersect(WML,i))
        WML = [WML i];
        save([R.rootn 'outputs\' R.out.tag '\ConfWorkList'],'WML')
        disp('Writing to Mod List!!')
        
        SimData = confmatlist(1,i);
        SimMod = confmatlist(2,i);
        
        fprintf('Fitting Model %.0f to data %.0f',SimMod,SimData)
        f = msgbox(sprintf('Fitting Model %.0f to data %.0f',SimMod,SimData));
        
        modelspec = eval(['@MS_rat_STN_GPe_ModComp_Model' num2str(SimMod)]);
        [R p m uc] = modelspec(R);
        pause(5)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        R.data = RSimData(SimData).data;
        R.out.dag = sprintf('NPD_STN_GPe_ConfMat_DataM%.0f_ParM%.0f',SimData,SimMod); % 'All Cross'
        R.SimAn.rep = 256;
        R = setSimTime(R,24);
        R.Bcond = 0;
        R.plot.flag = 1;
        R.SimAn.convIt = 7e-5;
        [p] = SimAn_ABC_220219b(R,p,m);
        closeMessageBoxes
    end
end
