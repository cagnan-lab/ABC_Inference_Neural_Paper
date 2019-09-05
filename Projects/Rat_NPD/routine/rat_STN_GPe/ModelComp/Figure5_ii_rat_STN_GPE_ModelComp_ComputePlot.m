%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 3- Example Model Comparison with the STN/GPe subcircuit
% (i) Ensure that script 'Figure3_i_rat_NPD_STN_GPe_Fitting.m' has run
% first.
% (ii) Run this script second too compute model space statistics and plot
% results.
%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all
closeMessageBoxes

%% Add Paths
R = ABCAddPaths('Rat_NPD','rat_STN_GPe');
%% Set Routine Pars
R.projectn = 'Rat_NPD'; % Project Name
R.out.tag = 'STN_GPe_ModComp'; % Task tag
R = simannealsetup_NPD_STN_GPe(R);

% Get empirical data
R = prepareRatData_STN_GPe_NPD(R,0);

%% Do the model probability computations
% R.comptype = 1;
% modelCompMaster(R,1:3,[])
%% Plot the modComp results
R.modcomp.modN = 1:3;
R.modcompplot.NPDsel = [1:3];
R.plot.confint = 'yes';
cmap = linspecer(numel(R.modcomp.modN));
plotModComp_091118(R,cmap)
figure(2)
subplot(4,1,1); ylim([-2 1])
% subplot(4,1,2); ylim([0 3])

