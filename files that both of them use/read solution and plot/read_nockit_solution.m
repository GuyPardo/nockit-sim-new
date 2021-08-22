function [t,r] = read_nockit_solution(nockit_params, G, t_edges, r_edges)
%converts from t_edges and r_edges that are vectors of length G.numedges,
%to t and r:  MxN+1 matrices which are more user friendly and specific to the
%nockit geometry and represent the transmitted and reflected amlitudes in
%the traces (the outputs t and r don't store any information about the couplers)

N = nockit_params.N;
M = nockit_params.M;
nodes = reshape(1:M*(N+2),M,N+2 );  

% read solution: this part is specific to the NOCKIT geometry 
 t = reshape(t_edges(G.findedge(nodes(:,1:N+1) ,nodes(:,2:N+2) )), M,N+1);
 r = reshape(r_edges(G.findedge(nodes(:,1:N+1) ,nodes(:,2:N+2) )), M,N+1);


end

