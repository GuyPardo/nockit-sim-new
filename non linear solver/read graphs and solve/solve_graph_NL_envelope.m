function [t_edges, r_edges] = solve_graph_NL_envelope(graph_data,freq, iterations,plot_iterations)

if nargin<4
    plot_iterations=false;
end
% read input
    nodes_num = graph_data.node_num;
    edge_num= graph_data.edge_num;
    Len_arr = graph_data.Len_arr;
    L_arr =  graph_data.L_arr;
    C_arr = graph_data.C_arr;
    BC_arr = graph_data.BC_arr; 
    BCval_arr = graph_data.BCval_arr;
    Ic_arr = graph_data.Ic_arr;
    I_star_arr = Ic_arr;
    v_ph_arr = 1./sqrt(L_arr.*C_arr);
    Y_arr = sqrt(C_arr./L_arr);
    
%     
%     v_ph_arr = 1./sqrt(L_arr.*C_arr);
%     Y_arr = sqrt(C_arr./L_arr);
    k_arr = 2*pi*freq*(v_ph_arr).^-1;

     % solve linearly:
 [t,r] = solve_graph_NL(graph_data, freq);
 
 % loop on iterations
 diff_all = zeros(1,iterations);
 sum_all = zeros(1,iterations);
 for i=1:iterations   
   

 t_previous = t;
 r_previous = r;
 % calculate current (taking the middle point along the segment)
 I_avr = real(Y_arr.*(t.*exp(1i*k_arr.*0.5.*Len_arr)  - r.*exp(-1i*k_arr.*0.5.*Len_arr)));
 
 % correct inductance:
%  graph_data.L_arr = L_arr.*(1+(I_avr./I_star_arr).^2);
 
 % correct inductance acording to https://iopscience.iop.org/article/10.1088/0957-4484/21/44/445202
 I_norm = abs(I_avr./Ic_arr);
 
 L_ratio = zeros(size(I_norm)); 
 
 for idx = 1:length(I_norm)
    if I_norm(idx)>=1
        x=0.3;
    else
     fun = @(x) 1.897*exp(-3*pi*x/8)*sqrt(x)*(pi/2 - 2*x/3) - I_norm(idx);
    
        x = fzero(fun,[0,0.3]);
    end
   
    L_ratio(idx)  = exp(pi*x/4);
 end
 
 graph_data.L_arr = L_arr.*L_ratio;
 
 % correct v_ph, Y and k:   
 v_ph_arr = 1./sqrt(graph_data.L_arr.*C_arr);
 Y_arr = sqrt(C_arr./graph_data.L_arr);
 k_arr = 2*pi*freq*(v_ph_arr).^-1;   
 
 %solve again
 [t,r] = solve_graph_NL(graph_data, freq);
 
 %calculate difference:
 
 diff_r = r-r_previous;
 diff_t = t-t_previous;
 
 
 diff_all(i) = sum(diff_r) + sum(diff_t);
 sum_all(i) = sum(r) + sum(t); 
 end
 

 if plot_iterations
figure(568)
subplot(2,1,1);  plot(1:iterations, abs(diff_all)); title("diffrences"); xlabel("iterations");
 subplot(2,1,2); plot(1:iterations, abs(sum_all)); title("values"); xlabel("iterations");
 
 end
 t_edges = t;
 r_edges = r;
 
end

