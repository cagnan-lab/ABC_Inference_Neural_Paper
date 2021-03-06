function modID = modelCompMaster_160620(R,modlist,WML)
if nargin>2
    save([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingPermModList'],'WML')
end
        closeMessageBoxes

%% Setup for parallelisation (multiple MATLAB sessions)
try
    load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingPermModList'])
    disp('Loaded Perm Mod List!!')
    % If concatanating to previously computed model comp structure
catch
    WML = [];
    save([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingPermModList'],'WML')
    disp('Making Perm Mod List!!')
end

%% Main Loop
for modID = modlist
    load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingPermModList'],'WML')
    permMod = [];
    if ~any(intersect(WML,modID))
        WML = [WML modID];
        save([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingPermModList'],'WML')
        disp('Writing to PermMod List!!')
        fprintf('Now Computing Probabilities for Model %.0f',modID)
        f = msgbox(sprintf('Probabilities for Model %.0f',modID));

        % Get Model Name
        R.out.dag = sprintf([R.out.tag '_M%.0f'],modID);
        
        % Load Config
        load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\' R.out.dag '\R_' R.out.tag '_' R.out.dag  '.mat'])
        
        % Replace with new version but maintain paths and tags
        tmp = varo;
        tmp.path = R.path;
        tmp.plot = R.plot;
        tmp.out = R.out;
        tmp.analysis = R.analysis;
        %% Corrections to file structure to make compatible
        if ~iscell(tmp.data.feat_xscale)
            X = tmp.data.feat_xscale;
            tmp.data.feat_xscale = [];
            tmp.data.feat_xscale{1} = X;
        end
        if ~iscell(tmp.data.feat_emp)
            X = tmp.data.feat_emp;
            tmp.data.feat_emp = [];
            tmp.data.feat_emp{1} = X;
        end        
        if ~iscell(tmp.data.datatype)
            X = tmp.data.datatype;
            tmp.data.datatype = [];
            tmp.data.datatype{1} = X;
        end
        
        if ~isfield(tmp,'chdat_name')
            tmp.chdat_name = tmp.chsim_name;
        end
        %%
        R  = tmp;
        
        [~,m,p,parBank] = loadABCData_160620(R);

        R.analysis.modEvi.eps = parBank(end,R.SimAn.minRank);
        R.analysis.BAA.flag = 0; % Turn off BAA flag (time-locked analysis)
        parOptBank = parBank(1:end-1,parBank(end,:)>R.analysis.modEvi.eps);
        
        if  size(parOptBank,2)>1
            R.parOptBank = parOptBank;
            R.obs.gainmeth = R.obs.gainmeth(1);
            permMod = modelProbs_160620(m.x,m,p,R);
        else
            permMod = [];
        end
        saveMkPath([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\' R.out.dag '\modeProbs_' R.out.tag '_' R.out.dag '.mat'],permMod)
        pause(10)
        closeMessageBoxes
        close all
    end
end