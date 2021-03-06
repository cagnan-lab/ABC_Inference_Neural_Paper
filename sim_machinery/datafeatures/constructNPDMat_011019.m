function [F meannpd wflag meanconf] = constructNPDMat_011019(dataS,chloc_name,chlist,fsamp,N,R)
if isempty(N)
    N = floor(fsamp/R.obs.csd.df);
end
for C=1:numel(R.condnames)
    data(C,:,:) = dataS{C}(R.obs.obsstates,:);
end

if ~isfield(R.obs,'logscale')
    R.obs.logscale = 1;
end
wflag = 0;
% N = R.obs.csd.pow2;


% Construct NPD matrix from data - take mean across channel replicates
for chloc = 1:size(chloc_name,2)
    chinds{chloc} = strmatch(chloc_name{chloc},chlist);
end
O = numel(R.condnames);
for C = 1:O
    for chI = 1:size(chloc_name,2)
        for chJ = 1:size(chloc_name,2)
            for p = 1:size(chinds{chI},1)
                chindsP = chinds{chI};
                for r = 1:size(chinds{chJ},1)
                    chindsR = chinds{chJ};
                    if chI == chJ
                        [Pxy,F] = pwelch(squeeze(data(C,chindsP(p),:)),hanning(2^N),[],2^(N),fsamp);
                        F_scale = R.frqz;

                        if nargin>5
                            Pxy = interp1(F,Pxy,F_scale);
                        else
                            Pxy =  Pxy(F>4);
                        end
                        if R.obs.trans.logdetrend == 1
                            Pxy = log10(Pxy); F_scale = log10(F_scale);
                            [xCalc yCalc b Rsq] = linregress(F_scale',Pxy');
                            [dum bi] = intersect(F_scale,xCalc);
                            Pxy = Pxy(1,bi)-yCalc';
                            Pxy = 10.^Pxy; F_scale = 10.^(F_scale);
                        else
                            Pxy(isnan(F_scale)) = [];
                            F_scale(isnan(F_scale)) = [];
                        end
                        
                        if R.obs.logscale == 1
                            Pxy = log10(Pxy);
                        end
                        if R.obs.trans.norm == 1
                            Pxy = (Pxy-nanmean(Pxy))./nanstd(Pxy);
                            Pxy = Pxy - min(Pxy);
                        end
                        if R.obs.trans.gauss3 == 1
                            %                             Pxy = smoothdata(Pxy,'gaussian');
                            f = fit(F_scale',Pxy','gauss3');
                            Pxy = f(F_scale)';
                        end
                        
                        if R.obs.trans.gausSm > 0
                            gwid = R.obs.trans.gausSm/diff(F_scale(1:2)); % 10 Hz smoothing
                            Pxy = smoothdata(Pxy,'gaussian',gwid);
                        end
                        Pxy(isnan(Pxy)) = 0;
                        Pxy = Pxy; %.*tukeywin(length(Pxy),0.25)';
                        xcsd(p,r,1:3,:) = repmat(Pxy,3,1);
                        xconf(p,r,1:3) = [0 0 0];
                        
                    else
                        [f13,t,cl]=sp2a2_R2(squeeze(data(C,chindsP(p),:)),squeeze(data(C,chindsR(r),:)),fsamp,N-1);
                        F_scale = R.frqz;
                        F_scale(isnan(F_scale)) = [];
                        if any(any(isnan(f13(:,12))))
                            warning('NPD is returning nans!!')
                            wflag = 1;
                        end
                        %                     [nf13,~,~]=sp2a2_R2(normnoise(1,:)',normnoise(2,:)',fsamp,N-1);
                        F = f13(:,1);
                        zl = [10 11 12];
                        for z = 1:3
                            %                     [Pxy,F] = cpsd(data(chindsP(p),:),data(chindsR(r),:),hanning(N),[],N,fsamp);
                            Pxy = f13(:,zl(z));
                            %                         nPxy = nf13(:,12);
                            if nargin>5
                                Pxy = interp1(F,Pxy,F_scale);
                            else
                                Pxy =  Pxy(F>4);
                            end
                            
                            if R.obs.trans.gauss3 == 1
                                %                             Pxy = smoothdata(Pxy,'gaussian');
                                f = fit(F_scale',Pxy','gauss3');
                                Pxy = f(F_scale)';
                            end
                        if R.obs.trans.gausSm > 0
                            gwid = R.obs.trans.gausSm/diff(F_scale(1:2)); % 10 Hz smoothing
                            Pxy = smoothdata(Pxy,'lowess',gwid);
                        end
                            %                         Pxy = Pxy./max(nPxy);
                            %                             Pxy = Pxy; %.*welchwin(length(Pxy))';
                            %                             Pxy = Pxy.*tukeywin(length(Pxy),0.1)';
                            xcsd(p,r,z,:) = Pxy;
                            xconf(p,r,z) = cl.ch_c95;
                        end
                    end
                end
            end
            meanconf(C,chI,chJ,:) = xconf;
            meannpd(C,chI,chJ,:,:) = (mean(mean(xcsd,1),2));
            clear xcsd
        end
    end
    F = F_scale;
    % % take out symetrical CSD
    % diaginds = [2 1; 3 1; 3 2];
    % for i = 1:3
    %     meancsd(diaginds(i,1),diaginds(i,2),:) = zeros(1,size(meancsd,3));
    % end
    
end