% Solving a linear NOCKIT\PMT with a single frequency
% written by Guy 07.21
clearvars
% add relevant folders to path:
addpath(genpath('.\')); % adding subfolders of current folder (assuming current folder is nockit sim\linear solver)
%% config
freq = 8.5e9;
input_idx = 4;
PMT2_flag = false; % set true for 2 traces network, false for 7 traces network
input_pwr = -120; % in dBm
iterations = 30; % for NL solution
plot_iterations = true;
%% define graph
if PMT2_flag
    nockit_params = get_nockit2_params();
    nockit_params.input_idx = input_idx;
    X= [0.8218    1.1714    1.5979    0.5225    0.3187]; % 07.21 fit.  X  = [t,W,Wc,H,lam2]; see general readme.
    % construct_graph
    [G, derived] = get_nockit_graph_fit_NL(nockit_params,X, input_pwr);
else
    nockit_params = get_nockit6_params();
    nockit_params.input_idx = input_idx;
    nockit_params.loss_tan = 0;
    X = [1.0866    0.8745    0.4216    1.5621    0.3312]; % 07.21 fit.  X  = [t,W,Wc,H,lam2]; see general readme.
    % construct_graph
    [G, derived] = get_nockit_graph_fit_NL(nockit_params,X,input_pwr);
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



