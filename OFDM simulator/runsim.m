
function runsim(sim_options)

% set constants used in simulation
set_sim_consts;
global sim_consts;
% Set Random number generators initial state
% reset random number generators based on current clock value
rand('state',sum(100*clock));
randn('state',sum(100*clock));

% Main simulation loop

% Initialize simulation timer
start_time = clock;

% Initialize trellis tables for Viterbi decoding
rx_init_viterbi;

% Simulation the number of packets specified under changing SNR

p = 0; %packet count
s = 1; %SNR value
Snr = 0:10; %SNR interval

inf_ber  = zeros(1,length(Snr)); %create the informaiton BER vector for soft decision
inf_ber2 = zeros(1,length(Snr)); %create the informaiton BER vector for hard decision

for s = 1:length(Snr)
    
    sim_options.SNR = Snr(s);
    p = 0;
    
    % counters for information bits (soft decision)
    num_inf_bits          = 0;
    num_inf_bit_errors    = 0;
    num_inf_packet_errors = 0;
    inf_per               = 0;
    
    % counters for information bits (hard decision)
    num_inf_bits2          = 0;
    num_inf_bit_errors2    = 0;
    num_inf_packet_errors2 = 0;
    inf_per2               = 0;

    % counters for raw (undecoded) bits
    num_raw_bits          = 0;
    num_raw_bit_errors    = 0;
    num_raw_packet_errors = 0;
    raw_ber               = 0;
    raw_per               = 0;
    
    while p < sim_options.PktsToSimulate

       p = p + 1;

       % Simulate one packet with the current options
       [inf_bit_cnt, inf_bit_errors, inf_bit_errors2, raw_bits_cnt, raw_bit_errors] = ...
          single_packet(sim_options);

       num_inf_bits          = num_inf_bits + inf_bit_cnt;
       num_inf_bit_errors    = num_inf_bit_errors + inf_bit_errors;
       num_inf_packet_errors = num_inf_packet_errors + (inf_bit_errors~=0);
       inf_ber(s)            = num_inf_bit_errors/num_inf_bits;
       inf_per               = num_inf_packet_errors/p;

       num_inf_bits2          = num_inf_bits2 + inf_bit_cnt;
       num_inf_bit_errors2    = num_inf_bit_errors2 + inf_bit_errors2;
       num_inf_packet_errors2 = num_inf_packet_errors2 + (inf_bit_errors2~=0);
       inf_ber2(s)            = num_inf_bit_errors2/num_inf_bits2;
       inf_per2               = num_inf_packet_errors2/p;

       num_raw_bits          = num_raw_bits + raw_bits_cnt;
       num_raw_bit_errors    = num_raw_bit_errors + raw_bit_errors;
       num_raw_packet_errors = num_raw_packet_errors + (raw_bit_errors~=0);
       raw_ber               = num_raw_bit_errors/num_raw_bits;
       raw_per               = num_raw_packet_errors/p;

    end

end

stop_time = clock;
elapsed_time = etime(stop_time,start_time);

fprintf('Simulation duration: %g seconds\n',elapsed_time);

figure (2)
semilogy(Snr,inf_ber,'-ro')
hold on
semilogy(Snr,inf_ber2,'-bo')
grid on
xlabel('SNR (in dB)')
ylabel('Information BER')
legend('For Soft Decisions','For Hard Decisions')

%Call runsum_2 function to plot information BERs ...
%and subchannels under 5 different RMS delay spread values
[Rms_delay, info_ber, info_ber2] = runsim_2(sim_options);

figure (8)
semilogy(Rms_delay,info_ber,'-ro')
hold on
semilogy(Rms_delay,info_ber2,'-bo')
grid on
xlim([5 100])
xlabel('RMS Delay Spread (in ns)')
ylabel('Information BER')
legend('For Soft Decisions','For Hard Decisions')

% Call Water-filling Algorithm for power allocation
load('chan_amp64','channel_estimate');
channel_info = abs(channel_estimate);
B = sim_consts.SampFreq;
N_subc = 64;
[C_opt, C_eq, P_alloc, P_equal] = waterfilling(N_subc, channel_info, B);

fprintf('Capacity for optimal power allocation: %g\n',C_opt);
fprintf('Capacity for equal power allocation: %g\n',C_eq);



