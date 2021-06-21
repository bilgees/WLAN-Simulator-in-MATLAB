% Channel amplitudes corresponding to bits for Viterbi decoding

function channel_amps = rx_gen_chan_amps(data_len, channel_est, sim_options)

global sim_consts;

bits_per_subc = get_bits_per_symbol(sim_options.Modulation);
amps_mat = repmat(sum(abs(channel_est(sim_consts.DataSubcPatt, :)).^2, 2)', bits_per_subc, 1);
amps_mat = amps_mat(:)';

load('chan_amp64','channel_estimate');
channel_estimate = channel_estimate';

%Create and save the data and pilot subchannel amplitudes
c_est= zeros(64,1);
c_est(sim_consts.DataSubcIdx,:) = channel_estimate(sim_consts.DataSubcIdx,:);
c_est(sim_consts.PilotSubcIdx,:) = channel_estimate(sim_consts.PilotSubcIdx,:);
chan = repmat(sum(abs(c_est).^2, 2)', bits_per_subc, 1);
save('chan_amp','chan');

amps_mat = repmat(amps_mat, 1, ceil(data_len/length(amps_mat)));
channel_amps = amps_mat(1:data_len);
  


