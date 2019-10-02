clear; close all
R = ABCAddPaths('PeripheralStim','firstRun');
R = simannealsetup_periphStim(R);

% get data
R.obs.obsstates = [1 2];
load([R.rootn 'data\mv_20a.mat'])
data{1} = dat';
R.obs.trans.norm = 1;
R.obs.trans.logdetrend = 1;
R.obs.trans.gauss = 1;
[R.data.feat_xscale, R.data.feat_emp] = R.obs.transFx(data,R.chloc_name,R.chsim_name,1/R.IntP.dt,R.obs.SimOrd,R);
npdplotter_110717({R.data.feat_emp},[],R.data.feat_xscale,R,[],[]);
clear data dat

% Peripheral Stim
[R pc m uc] = MS_periphStim_Model1(R);
R = setSimTime(R,32);

% Revert back
R.obs.trans.gauss = 0;
R.obs.trans.logdetrend = 0;

% Model Inversion
R.out.dag = 'firstRun_modelFit_halliday'; % 
R.out.tag = '011019';
R.SimAn.rep = 256;
R.Bcond = 0;
R.plot.flag = 1;
R.SimAn.convIt = 7e-5;
% R.obs.gainmeth = {R.obs.gainmeth{1}};
[p] = SimAn_ABC_220219b(R,pc,m);
