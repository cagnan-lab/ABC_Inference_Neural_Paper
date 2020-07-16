function genplotter_200420(NPD_data,NPD_sim,F,R,bestn,labelna)
if isempty(NPD_data)
    NPD_data = {zeros(size(NPD_sim{1}))};
end
if ~isfield(R.plot,'cmap')
    R.plot.cmap = [1 0 0];
end
if isempty(NPD_sim)
    NPD_sim= {zeros(size(NPD_data{1}))};
end
if nargin<5
    bestn = 1;
end
if isempty(labelna)
    labelna = 'NPD';
end


% Main Function Starts Here
NPD_data_n = NPD_data{1};
O = size(NPD_data_n,1);

for C = 1:O
    figure(C*10)
    clf
    for L = 1:length(NPD_sim)
        NPD_sim_n = NPD_sim{L};
        
        if L == bestn
            lwid = 2;
        else
            lwid = 0.5;
        end
        N = size(NPD_sim_n,2); M = size(NPD_sim_n,3); 
        
        k = 0;
        for i = 1:N
            for j = 1:M
                k = k+1;
                subplot(N,M,k)
                try
                plot(F,squeeze(abs(NPD_sim_n(C,i,j,1,:))),'r--','linewidth',lwid); hold on
                plot(F,squeeze(imag(NPD_sim_n(C,i,j,1,:))),'b--','linewidth',lwid);
                end
                try
                plot(F,squeeze(abs(NPD_data_n(C,i,j,1,:))),'r','linewidth',2);
                plot(F,squeeze(imag(NPD_data_n(C,i,j,1,:))),'b','linewidth',2);
                end
                xlabel('Hz'); ylabel('Power'); %title(sprintf('Ch %1.f Pxx',i))
                xlim([min(R.frqz) max(R.frqz)])
                axis square
                %         ylim([-0.03 0.03])
                if i==1
                    title(R.chsim_name{j})
                elseif j == 1
                    ylabel(R.chsim_name{i})
                end
            end
        end
    end
    set(gcf,'Position',[380         235        1112         893])
end
