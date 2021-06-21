function [C_opt, C_eq, P_alloc, P_equal] = waterfilling(N_subc, channel_info, B);

% N_subc : Number of subchannels 
% P_tot : Total available power for each OFDM symbol (Watt)                        
% channel_info : Channel state information 1xN_subc
% B : Total available bandwidth (Hz)
% N0 : one sided noise spectral density (watt/Hz)

P_tot = 10e-2; %10 dBm      
N0 = 1e-9; %-60 dBm   

subc_noise = (N0*B)/N_subc; % Subchannel noise
CNR = channel_info.^2/subc_noise; % Channel-to-Noise Ratio

% Allocate initialized power to each subchannels
P_initAlloc = (P_tot + sum(1./CNR))/N_subc - (1./CNR);

% Equal power allocated to each channel
P_n = P_tot/N_subc;
P_n = repmat(P_n,1,64);

% Iteration to obtain all allocated powers is positive
    while(length(find(P_initAlloc < 0)) > 0)
        
        pos_ind = find(P_initAlloc >  0);
        neg_ind = find(P_initAlloc <= 0);
        P_initAlloc(neg_ind) = 0;
        rem_subc = length(pos_ind);
        CNR_rem  = CNR(pos_ind);
        
        P_temp  = (P_tot + sum(1./CNR_rem))/rem_subc - (1./CNR_rem);
        P_initAlloc(pos_ind) = P_temp;
    end

% Total capacity of a channel based on Shanon capacity theory (optimally
% allocated)
 C_opt = (B/N_subc)*sum(log2(1 + P_initAlloc.*CNR));
% Total capacity for equally power allocation
 C_eq = (B/N_subc)*sum(log2(1 + P_n.*CNR));
% Amount of optimal power allocated to each subchannel
 P_alloc = P_initAlloc';        
% Amount of equal power allocated to each subchannel
 P_equal = P_n';
 

    f1 = figure(9)
    clf;
    set(f1,'Color',[1 1 1]);
    bar((P_initAlloc + 1./CNR),1,'b')
    hold on
    bar(1./CNR,1,'r')
    xlabel('Subchannel Indices')
    title('Water-Filling Optimal Power Allocation')
    legend('Allocated Power to Each Subchannel','Noise-to-Carrier Ratio')
    
    f2 = figure(10)
    set(f2,'Color',[1 1 1]);
    bar((P_n + 1./CNR),1,'b')
    hold on
    bar(1./CNR,1,'r')
    xlabel('Subchannel Indices')
    title('Equal Power Allocation')
    legend('Allocated Power to Each Subchannel','Noise-to-Carrier Ratio')
    
    