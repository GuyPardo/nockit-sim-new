%  freqency scan for  linear NOCKIT\PMT 
% written by Guy 07.21
clearvars
% add relevant folders to path:
addpath(genpath('.\')); % adding subfolders of current folder (assuming current folder is nockit sim\linear solver)
%% config
frequency = linspace(3,9,201)*1e9;
input_idx = 1;
PMT2_flag = true; % set true for 2 traces network, false for 7 traces network

%% define graph
if PMT2_flag
    nockit_params = get_nockit2_params();
    nockit_params.input_idx = input_idx;
    X= [0.8218    1.1714    1.5979    0.5225    0.3187]; % 07.21 fit.  X  = [t,W,Wc,H,lam2]; see general readme.
    % construct_graph
    [G, derived] = get_nockit_graph_fit(nockit_params,X);
else
    nockit_params = get_nockit6_params();
    nockit_params.input_idx = input_idx;
    X = [1.0866    0.8745    0.4216    1.5621    0.3312]; % 07.21 fit.  X  = [t,W,Wc,H,lam2]; see general readme.
    % construct_graph
    [G, derived] = get_nockit_graph_fit(nockit_params,X);
end


%% loop on frequencies
trans  =zeros(nockit_params.M, length(frequency));
ref  =zeros(nockit_params.M, length(frequency));
for i = 1:length(frequency)
    graph_data = process_graph(G);
    [t_edges, r_edges] = solve_graph(graph_data, frequency(i));
    % read solution 
    [t,r] = read_nockit_solution(nockit_params, G, t_edges,r_edges);
    trans(:,i) = t(:,end);
    ref(:,i) = r(:,1);
end
trans_dB = 20*log10(abs(trans));



%% plot and compare to experimental data
compare_w_experiment = true; % set true to import the transmission measurement data and plot it against the simulation
fz=15;


if compare_w_experiment

    cc = colororder();
    if PMT2_flag
        load NOCKIT5_2traces_data.mat
  
        figure(501); clf; hold on; grid on;      
   
        atten_slope = linspace(0,9 ,length(freq));
        colororder(cc(1:2,:))
        plot(freq*1e-9, data_dB +21 - 5.5 + [atten_slope', atten_slope'],  'linewidth', 2) %+21 is taking into account atteuations and amplifier
        colororder(cc(1:2,:))
        plot(frequency*1e-9, trans_dB,'--', 'linewidth', 2)
        xlabel("Frequency (GHz)", 'fontsize', fz);
        ylabel("Transmission (dB)", 'fontsize', fz);
        legend(["Measured 1 \rightarrow 1'", "Measured 1 \rightarrow 2'", "Simulated 1 \rightarrow 1'","Simulated 1 \rightarrow 2'" ], 'location', 'southwest', 'fontsize', 15)
        
    else
        % plots
        load nockit6_data.mat
        figure(501); clf;
        tlc = tiledlayout(2,2);
        tlc.Padding = 'compact';
        tlc.TileSpacing = 'compact';
          for i=4:-1:1
           nexttile  
           hold on;
             plot(freq*1e-9, data_dB(i,:)+54, 'color',cc(5-i,:), 'linewidth', 2) %+54 is taking into account atteuations and amplifier
             plot(frequency*1e-9, (trans_dB(i,:)), 'linewidth',2 ,'linestyle', '--','color',cc(5-i,:));
             grid on; xlabel("Frequency (GHz)", 'fontsize', fz);% ylabel(sprintf("$\\left|S_{4\\rightarrow%d'}\\right|^2$ (dB)",i), 'fontsize', fz+2, 'interpreter', 'latex');
             %legend([sprintf("\rMeasured 4 $\\rightarrow$ %d'",i), sprintf("Simulated 4 $\\rightarrow$ %d'",i), ], 'location', 'best', 'fontsize', 15, 'interpreter', 'latex')
             ylabel(sprintf("|S_{4\\rightarrow%d'}|^2 (dB)",i), 'fontsize', fz+2 );

          end

    end
else
        if PMT2_flag
            figure(503); clf; hold on; grid on;
            plot(frequency*1e-9, trans_dB, 'linewidth', 2)
            xlabel("Frequency (GHz)", 'fontsize', fz);
            ylabel("Transmission (dB)", 'fontsize', fz);
        else
            figure(503); clf;  
            imagesc(trans_dB,'xdata',frequency*1e-9, 'ydata', 1:nockit_params.M);  colormap jet
            xlabel("Frequency (GHz)", 'fontsize', fz);
            ylabel("Trace index", 'fontsize', fz);
            cb = colorbar();
            cb.Label.String = 'Transmission (dB)';
            cb.Label.FontSize = fz;
        end

end


%%


