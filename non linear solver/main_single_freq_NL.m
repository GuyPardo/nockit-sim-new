% Solving a non-linear NOCKIT\PMT with a single frequency
% written by Guy 08.21
clearvars
% add relevant folders to path:
addpath(genpath('.\')); % adding subfolders of current folder (assuming current folder is nockit sim\non linear solver)
%% config
freq = 6e9;
input_idx = 4;
PMT2_flag = false; % set true for 2 traces network, false for 7 traces network
loss_flag = true; % boolean. decide whether to include dielectric loss. 

input_pwr = -42; % in dbm
% input_pwr =  11.402714422492686; % in dBm. this value give input voltage amplitude of 1 Volt
iterations = 21; % for iterative NL solution
plot_iterations = true; % set to true to look at the graph and check convergence. (automatic convergence check is NOT implemented yet.)
network_plots=true; % network plots that include also the couplers. 
%% define graph
if PMT2_flag
    nockit_params = get_nockit2_params();
    nockit_params.input_idx = input_idx;
    nockit_params.loss_tan = nockit_params.loss_tan*loss_flag; % make loss_tan=zero if loss_flag is off
    X= [0.8218    1.1714    1.5979    0.5225    0.3187]; % 07.21 fit.  X  = [t,W,Wc,H,lam2]; see general readme.
    % construct_graph
    [~, der] = get_nockit_graph_fit_NL(nockit_params,X, 1);
    sig_amp = sqrt(2/der.Y0*10^((input_pwr/10) -3 ));
    [G, derived] = get_nockit_graph_fit_NL(nockit_params,X, sig_amp);
else
    nockit_params = get_nockit6_params();
    nockit_params.input_idx = input_idx;
    nockit_params.loss_tan = nockit_params.loss_tan*loss_flag; % make loss_tan=zero if loss_flag is off
    X = [1.0866    0.8745    0.4216    1.5621    0.3312]; % 07.21 fit.  X  = [t,W,Wc,H,lam2]; see general readme.
    % construct_graph
   
    [~, der] = get_nockit_graph_fit_NL(nockit_params,X, 1);
    sig_amp = sqrt(2/der.Y0*10^((input_pwr/10) -3 ));
    [G, derived] = get_nockit_graph_fit_NL(nockit_params,X, sig_amp);
end

%% process graph and solve
graph_data = process_graph_NL(G);
[t_edges, r_edges] = solve_graph_NL_envelope(graph_data, freq, iterations, plot_iterations);
%% read solution 
[t,r] = read_nockit_solution(nockit_params, G, t_edges,r_edges);
[x, V, I, power_flow] = nockit_calculate_physical_quantuties(nockit_params, derived, freq, t,r);
input_power = real(derived.Y0)/2; % for normalization by the input power
%% plotting
if ~PMT2_flag
    figure(901); clf;
    fz = 15;
    imagesc(power_flow'/input_power, 'xdata', 1e3*x, 'ydata', (1:nockit_params.M));
    colormap jet;
    xlabel('Position along traces (mm)', 'fontsize', fz);
    ylabel('Trace index', 'fontsize', fz);
    cb = colorbar();
    cb.Label.String = 'power flow (a.u.)';
    cb.Label.FontSize = fz;
    title(sprintf('power flow in traces in %.3g GHz', freq*1e-9), 'fontsize', fz)
else
    figure(901); clf;
    fz = 15;
    plot(1e3*x,power_flow/input_power)
    xlabel('Position along traces (mm)', 'fontsize', fz);
    ylabel('power flow', 'fontsize', fz);
    title(sprintf('power flow in traces in %.3g GHz', freq*1e-9), 'fontsize', fz);
    grid on;
end

%% plot network
if network_plots

coordinates = get_nockit_coordinates(G,nockit_params);

figure(802); clf;
plt_nockit_current(G,coordinates, t_edges,r_edges,freq, false,input_pwr);
figure(803); clf;
plt_nockit_voltage(G,coordinates, t_edges,r_edges,freq,false,input_pwr);

figure(804); clf;
% tiledlayout(1,1, 'padding', 'normal' )
plt_nockit_power(G,coordinates, t_edges,r_edges,freq,false, input_pwr);

end




