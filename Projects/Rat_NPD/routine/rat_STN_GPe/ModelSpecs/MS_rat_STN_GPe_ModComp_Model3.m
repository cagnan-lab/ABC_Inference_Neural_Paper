function [R p m uc] = MS_rat_STN_GPe_ModComp_Model3(R)
% THIS IS THE STN/GPE
% Gpe only!
m.m = 2; % # of sources
m.x = {[0 0]  [0 0]}; % Initial states
m.Gint = [1 1];
m.Tint = [1 1];
m.Sint = [2 2];
m.n =  size([m.x{:}],2); % Number of states
% These outline the models to be used in compile function
for i = 1:numel(R.chsim_name)
    m.dipfit.model(i).source = R.chsim_name{i};
end

m.outstates = {[1 0] [1 0]};
R.obs.outstates = find([m.outstates{:}]);
for i=1:numel(R.chloc_name)
    R.obs.obsstates(i) = find(strcmp(R.chloc_name{i},R.chsim_name));
end

% Precompute xinds to make things easier with indexing
% Compute X inds (removes need to spm_unvec which is slow)
xinds = zeros(size(m.x,2),2);
for i = 1:size(m.x,2)
    if i == 1
        xinds(i,1) = 1;
        xinds(i,2) = size(m.x{i},2);
    else
        xinds(i,1) = xinds(i-1,2)+1;
        xinds(i,2) = xinds(i,1) + (size(m.x{i},2)-1);
    end
end
m.xinds = xinds;

% setup exogenous noise
% m.uset.p = DCM.Ep;
m.uset.p.covar = eye(m.m);
m.uset.p.scale = 5e1; %.*R.InstP.dt;
uc = innovate_timeseries(R,m);


%% Prepare Priors
% 1 MMC
% 3 GPE
% 4 STN

% Excitatory connections
p.A{1} =  repmat(-32,m.m,m.m);
p.A_s{1} = repmat(0,m.m,m.m);
p.A{1}(1,2) = -6; % STN -> GPe
p.A_s{1}(1,2) = 0; % STN -> GPe

p.A{2} =  repmat(-32,m.m,m.m);
p.A_s{2} = repmat(0,m.m,m.m);
p.A{2}(2,1) = 0; % GPe -| STN
p.A_s{2}(2,1) = 1/4; % GPe -| STN

% Connection strengths
p.C = zeros(m.m,1);
p.C_s = repmat(1/16,size(p.C));

% Leadfield
p.obs.LF = [1 1];
p.obs.LF_s = repmat(2,size(p.obs.LF));

p.obs.mixing = [1]; %zeros(size(R.obs.mixing));
p.obs.mixing_s = repmat(0,size(p.obs.mixing));

% Delays
p.D = repmat(-32,size(p.A{1})).*~((p.A{1}>-32) | (p.A{2}>-32)) ;
p.D_s = repmat(1/16,size(p.D));

% Sigmoid transfer for connections
% p.S = [0 0];
% p.S_s = [1/8 1/8];

% time constants and gains
for i = 1:m.m
    prec = 1/8;
    p.int{i}.T = zeros(1,m.Tint(i));
    p.int{i}.T_s = repmat(prec,size(p.int{i}.T));
    p.int{i}.G = zeros(1,m.Gint(i));
    p.int{i}.G_s = repmat(prec/2,size(p.int{i}.G));
    p.int{i}.S = zeros(1,m.Sint(i));
    p.int{i}.S_s = repmat(prec,size(p.int{i}.S));
    %     p.int{i}.BT = zeros(1,m.Tint(i));
    %     p.int{i}.BT_s = repmat(prec,size(p.int{i}.T));
end