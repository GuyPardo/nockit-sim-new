
function [G, derived] = get_nockit_graph_fit_NL(nockit_params,x, input_pwr)
%construct a graph G based on nockit_params nodified according to vector 
% X   = [t,W,Wc,H,lam2]; see fitting sction in general readme.
% derived is a struct with derived parameters (e.g. v_ph, v_ph_c. etc.)



nockit_params_new.N = nockit_params.N; % number of couplers. (= number of unit cells minus 1) 
nockit_params_new.M = nockit_params.M; % number of lines
nockit_params_new.L0 = nockit_params.L0; % length of each line segment
nockit_params_new.d = nockit_params.d; % length of each coupler segment
nockit_params_new.t = nockit_params.t*x(1); % thickness of metal
nockit_params_new.W = nockit_params.W*x(2) ; % width of main traces
nockit_params_new.W_c = nockit_params.W_c*x(3); % width of couplers
nockit_params_new.H = nockit_params.H*x(4); % thickness of dielectric
%nockit_params_new.gap_c = nockit_params.gap_c*x(5); % for coplanar couplers, width of the gap between trace and ground.
nockit_params_new.input_idx =nockit_params.input_idx;
nockit_params_new.loss_tan = nockit_params.loss_tan;
[G, derived] = get_nockit_graph_NL(nockit_params_new, input_pwr);

 lam = x(5); %inductance factor
 
G.Edges.L = G.Edges.L*lam;
derived.L = derived.L*lam;
derived.Lc = derived.Lc*lam;
derived.v_ph = 1/sqrt(derived.C*derived.L);
derived.v_ph_c = 1/sqrt(derived.Cc*derived.Lc);
derived.Y0 = sqrt(derived.C/derived.L);
derived.Yc = sqrt(derived.Cc/derived.Lc);
end

