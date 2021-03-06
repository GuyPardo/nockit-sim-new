This is the July 2021 version of the linear NOCKIT simulation.
the two "main" scripts: main_single_freq.m and main_freq_scan.m work in three steps:
(1) define a graph object representing the network, (2) solve for the graph , and finally (3) read solution and plot.
 in the following I will describe in more detail each of these stages. 

step 1: constructing the graph:
	a. loading the designed geometrical parameters into a struct named nockit_params
	b. using the fucntion get_nockit_graph_fit to create the digraph object G. that includes all the relevant information of the problem, including boundary conditions.
	c. The function get_nockit_graph_fit accepts as two arguments. one is the struct nockit_params, and the other is a vector X of length 5 that defines how to change the parameters according to a fitting proccess.
	    I explain more about the fitting process later on. 
	d .the fucntion get_nockit_graph_fit also returns a struct called derived, that stores the derived parameters like traces\couplers admittance etc.


step 2: solving:
	a.  the function process_graph extracts all the relevant information from G and stores it in a struct graph_data. This is important for the frequency scans to reduce the runtime as matlab reads information from the struct much faster then from the digraph object G.
	b. the function solve_graph recives the struct graph_data as an input and returns the solutions t_edges and r_edges. both are complex vectors of length G.numedges.

step 3: reading the solution:
	 the function read_nockit_solution recieves the solutions t_edges and r_edges (and also nockit_params and G) and returns two M*(N+1) matrices t and r of the traces amplitudes only.
	 these are easier to work with, but are specific to the nockit geometry.

----------------------------------------------------
on the fitting vector X:
I name the 5 elemets of the fitting vector X in the following way: X  = [t,W,Wc,H,lam2].
the first 4 of them are numerical factors by which we nultiply the geometrical parameters: WSi thickness, traces width, coupler width,  and dielectric height.
the last one that I call lam2 (lambda squared), is a numerical factor by which we multiply all inductances after we calcualte them from the geometrical parameters.
The specific values for X in the main scripts are a result of fitting the experimental data. 

---------------------------------------------------

solving nockit network with deifferent parameters:
You'll have to define your own struct nockit_params with fields:  
      N,M,L0,d,t,W,W_c,H,gap_c (optional),loss_tan, input_idx
and then contiue from step 1b

----------------------------------------------------------
solving a general network
the simulation can solve an arbitrary network, but you'll still have to define the network.
The way to do it is to define a matalb digraph object with edge properties:
    % L - length of the edge
    % v_ph - phase velocity of the edge
    % Y - characteristic admittance of the edge
    % BC - boundary condition for the edge  according the convention:
	% 1 - set t to 0
            % 2 - set r to 0
            % 3 - set t to 1
            % 4 - set r t0 1

then you can use the functions process_graph and solve_graph as in step 2 above.




