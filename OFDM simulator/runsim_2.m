function [Rms_delay, inf_ber, inf_ber2] = runsim_2(sim_options)

% set constants used in simulation
set_sim_consts;
global sim_consts;

% Initialize trellis tables for Viterbi decoding
rx_init_viterbi;

% Simulation the number of packets specified under changing delay spread

p = 0; %packet count
r = 1; %rms delay spread value
Rms_delay = [5 10 30 60 100]; %RMS delay spread interval (in ns)

inf_ber  = zeros(1,length(Rms_delay)); %create the informaiton BER vector for soft decision
inf_ber2 = zeros(1,length(Rms_delay)); %create the informaiton BER vector for hard decision

channel_mat = zeros(length(Rms_delay),64);

x = (-32:32)*(sim_consts.SampFreq/64);
x(33)=[];

data_ind = sim_consts.DataSubcIdx;
pilot_ind = sim_consts.PilotSubcIdx;

sim_options.SNR = 4;

for r = 1:length(Rms_delay)
    
    sim_options.ExpDecayTrms = Rms_delay(r);
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

    % counters for raw (uncoded) bits
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
       inf_ber(r)            = num_inf_bit_errors/num_inf_bits;
       inf_per               = num_inf_packet_errors/p;

       num_inf_bits2          = num_inf_bits2 + inf_bit_cnt;
       num_inf_bit_errors2    = num_inf_bit_errors2 + inf_bit_errors2;
       num_inf_packet_errors2 = num_inf_packet_errors2 + (inf_bit_errors2~=0);
       inf_ber2(r)            = num_inf_bit_errors2/num_inf_bits2;
       inf_per2               = num_inf_packet_errors2/p;

       num_raw_bits          = num_raw_bits + raw_bits_cnt;
       num_raw_bit_errors    = num_raw_bit_errors + raw_bit_errors;
       num_raw_packet_errors = num_raw_packet_errors + (raw_bit_errors~=0);
       raw_ber               = num_raw_bit_errors/num_raw_bits;
       raw_per               = num_raw_packet_errors/p;

    end
    
    load('chan_amp','chan')
    channel_mat(r,:) = chan;
    
    figure (r+2)
    for ii = 1:length(x)

        d_i = find(data_ind==ii);
        p_i = find(pilot_ind==ii);

        if ii==data_ind(d_i)
            c = 'r';
            n = 'Data Subcarrier';   

        elseif ii==pilot_ind(p_i)
            c = 'g';
            n = 'Pilot Subcarrier';
        else
            c = 'b';
            n = 'Null Subcarrier';
        end

        stem(x(ii),channel_mat(r,ii),c,'DisplayName',n)
        hold on

    end

    grid on
    xlabel('Frequency (Hz)')
    ylabel('Magnitude response |H(f)|^2')
    % Red represents 48 Data Subcarriers,
    % Green represents 4 Pilot Subcarriers
    % Blue represents 12 Null Subcarriers
    
end







