function [G, derived_params] = get_nockit_graph(nockit_params)
%constructs a graph G according to nockit_params.
%   nockit_params should be a struct with fields
%           N,M,L0,d,t,W,W_c,H,gap_c (optional), input_idx


% read input:

coplanar_couplers = isfield(nockit_params, 'gap_c');

N = nockit_params.N;
M = nockit_params.M;
L0 = nockit_params.L0;
d = nockit_params.d;
t = nockit_params.t;
W = nockit_params.W;
W_c = nockit_params.W_c;
H = nockit_params.H;
loss_tan = nockit_params.loss_tan;
input_idx = nockit_params.input_idx;

if coplanar_couplers
    gap_c = nockit_params.gap_c;
end

% get properties:

[Y0, v_ph]  = get_microstrip_properties(W,t,H);
if coplanar_couplers
    [Yc, v_ph_c ] = get_CPW_properties(t,W_c,gap_c);
else
    [Yc, v_ph_c ] = get_microstrip_properties(W_c, t,H);
end

% build graph
Y0 = Y0*sqrt(1+1i*loss_tan);
Yc = Yc*sqrt(1+1i*loss_tan);
v_ph = v_ph/sqrt(1+1i*loss_tan);
v_ph_c = v_ph_c/sqrt(1+1i*loss_tan);
% define graph: define an array of nodes with M rows and N+2 columns. the
% nodes are numbered such that nodes 1:M are the first column, M+1:2*M are
% the socond column  etc.
nodes = reshape(1:M*(N+2),M,N+2 );  
G = digraph();
% define main lines:
% connect each node (m,n) to (m, n+1), with weight  2.
% by convention weight 2 means a "main" edge and not a coupler.
s = nodes(:,1:N+1);
t = nodes(:,2:N+2);
w = 2*ones(size(s));
G = G.addedge(s,t,w);

% define coupling lines:
% connect each node (m,n) to (n+1,n) with weight 1.
% by convention weight 1 means a coupling edge.
s = reshape(nodes(1:M-1, 2:N+1), 1,(N)*(M-1));
t = reshape(nodes(2:M, 2:N+1), 1,(N)*(M-1));
w = ones(size(s));
G = G.addedge(s,t,w);


edge_num = G.numedges;
nodes_num = G.numnodes;



% define edges attributres; pahe velocity, length and characteristic
% admittance:
% rememeber weight = 1 means coupler edge, weight = 2 means regular edge:
%clearvars G.Edges.v_ph G.Edges.L G.Edges.Y
G.Edges.v_ph(G.Edges.Weight==2) = v_ph*ones(sum(G.Edges.Weight==2),1);
G.Edges.v_ph(G.Edges.Weight==1) = v_ph_c*ones(sum(G.Edges.Weight==1),1);
G.Edges.L(G.Edges.Weight==2) = L0*ones(sum(G.Edges.Weight==2),1);
G.Edges.L(G.Edges.Weight==1) = d*ones(sum(G.Edges.Weight==1),1);
G.Edges.Y(G.Edges.Weight==2) = Y0*ones(sum(G.Edges.Weight==2),1);
G.Edges.Y(G.Edges.Weight==1) = Yc*ones(sum(G.Edges.Weight==1),1);

% define boundary conditions attribute for each edge according to the
% following convention:
% 0 - do nothing
% 1 - set t to 0
% 2 - set r to 0
% 3 - set t to 1
% 4 - set r t0 1
G.Edges.BC = zeros(edge_num,1);
G.Edges.BC(G.findedge(nodes(:,1),nodes(:,2))) = 1*ones(M,1);
G.Edges.BC(G.findedge(nodes(input_idx,1),nodes(input_idx,2))) = 3;
G.Edges.BC(G.findedge(nodes(:,N+1),nodes(:,N+2))) = 2*ones(M,1);



C = Y0/v_ph; Cc = Yc/v_ph_c;
L = 1/(Y0*v_ph); Lc = 1/(Yc*v_ph_c);

derived_params.C = C;
derived_params.Cc = Cc;
derived_params.L = L;
derived_params.Lc = Lc;
derived_params.v_ph = v_ph;
derived_params.v_ph_c = v_ph_c;
derived_params.Y0 = Y0;
derived_params.Yc = Yc;
% derived_params.sig_amp = sig_amp;
% derived_params.Ic = Ic;
% derived_params.Icc = Icc;


end

