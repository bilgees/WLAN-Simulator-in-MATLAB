
function [inf_bits_cnt, inf_bit_errs, inf_bit_errs2, raw_bits_cnt, raw_bit_errs] = single_packet(sim_options)

% Generate channel impulse response
cir = get_channel_ir(sim_options);

% Generate tx signal, returns also information bits and raw bits
[txsignal, tx_inf_bits, tx_raw_bits] = transmitter(sim_options);

% Channel model
rxsignal = channel(txsignal, cir, sim_options);

% Receiver, return data bits with hard and soft decisions and undecoded bits
[vit_out, rx_inf_bits, rx_raw_bits] = receiver(rxsignal, cir, sim_options);

% Calculate bit errors

% BER for raw bits
raw_bit_errs = sum(abs(rx_raw_bits(1:length(tx_raw_bits))-tx_raw_bits));
raw_bits_cnt = length(tx_raw_bits);

% BER for soft decisions
inf_bit_errs = sum(abs(rx_inf_bits(1:length(tx_inf_bits))-tx_inf_bits));
inf_bits_cnt = length(tx_inf_bits);

% BER for hard decisions
inf_bit_errs2 = sum(abs(vit_out(1:length(tx_inf_bits))-tx_inf_bits));


  

