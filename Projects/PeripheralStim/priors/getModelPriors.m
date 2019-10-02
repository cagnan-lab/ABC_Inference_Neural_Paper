function pQ = getModelPriors(m)
for i = 1:m.m
    switch m.dipfit.model(i).source
        case 'Musc1'
            % GPe
            pQ(i).G  = [2]*200;   % synaptic connection strengths (interneuron inhibition)
            pQ(i).T  = [8 8];       % synaptic time constants [str,gpe,stn,gpi,tha];
            pQ(i).S  = [0 0];     % 1st extrinsic; 2nd intrinsic(s)
            pQ(i).C =  [0];
        case 'SpinCrd'
            % GPe
            pQ(i).G  = [2 2]*200;   % synaptic connection strengths
            pQ(i).T  = [8 8];       % synaptic time constants [str,gpe,stn,gpi,tha];
            pQ(i).S  = [0];       % 1st extrinsic
            pQ(i).C =  [0];
    end
    % Convert to seconds
    pQ(i).T = pQ(i).T./1000;
end
