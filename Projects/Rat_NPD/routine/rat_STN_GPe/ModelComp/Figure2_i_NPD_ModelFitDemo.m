%%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 2- Example inversion of STN/GPe Subcircuit
%%%%%%%%%%%%%%%%%%%%%%%%
% IF FRESH!
%  delete([R.rootn 'outputs\' R.out.tag '\WorkingModList.mat'])

clear ; close all
R = ABCAddPaths('Rat_NPD','rat_STN_GPe');

% Close all msgboxes
closeMessageBoxes
rng(6439735)

%% Set Routine Pars
R.projectn = 'Rat_NPD'; % Project Name
R.out.tag = 'STN_GPe_ModComp'; % Task tag
R = simannealsetup_NPD_STN_GPe(R);

%% Prepare the data
R = prepareRatData_STN_GPe_NPD(R);

%% Prepare Model
modelspec = eval(['@MS_rat_STN_GPe_ModComp_Model' num2str(1)]);
[R,p,m] = modelspec(R);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R.out.dag = sprintf('NPD_ModelFitDemo_M%.0f',1); % 'All Cross'
R.SimAn.rep = 300;
R = setSimTime(R,32);
R.SimAn.convIt = 7e-5;
R.Bcond = 0;
R.plot.flag = 1;
R.plot.save = 1;
[p] = SimAn_ABC_220219b(R,p,m);

