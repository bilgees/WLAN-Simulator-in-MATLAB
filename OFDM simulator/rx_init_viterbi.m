%Create the Trellis diagram for 64 states
function rx_init_viterbi

global sim_consts;

global prev_state;
global prev_state_outbits;

prev_state = zeros(64, 2);
prev_state_outbits = zeros(64, 2, 2);

for state = 0:63
   state_bits = (fliplr(kron(dec2bin(state,6),1))~=48);
   input_bit = state_bits(1);
   for transition = 0:1
      prev_state_bits = [state_bits(2:6) transition];
      prev_state(state+1, transition+1) = base2dec(fliplr(prev_state_bits)+48,2);
      
      prev_state_outbits(state+1, transition+1, 1) = 2*(rem(sum(sim_consts.ConvCodeGenPoly(1,:).* ...
         [input_bit prev_state_bits]),2)) - 1;
      prev_state_outbits(state+1, transition+1, 2) = 2*(rem(sum(sim_consts.ConvCodeGenPoly(2,:).* ...
         [input_bit prev_state_bits]),2)) - 1;
   end
end
