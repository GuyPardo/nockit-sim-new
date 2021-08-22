function [x, V,I,P] = nockit_calculate_physical_quantuties(nockit_params, derived,freq, t,r)
% reconstruct physical quantities (voltage V, current I, and power flow P) along traces. nockit_params and derived
% are structs with relevant parameters (see general readme). t and r are
% MxN+1 matrices of comlex amplitudes. x is a vector of coordinates along
% the lines


% defining coordinates along the lines:
Npoints = 100; %points per segment

L0 = nockit_params.L0;
N = nockit_params.N;
M = nockit_params.M;
v_ph = derived.v_ph;
k0 = 2*pi*freq/v_ph;
Y0 = derived.Y0;
x = linspace(0,(N+1)*L0,(N+1)*Npoints);


% pre-allocating
V = zeros(length(x),M); % voltage
I = zeros(length(x),M); % current


% calculating
for j=1:M
    for n=1:N+1
       V(Npoints*(n-1)+1:Npoints*n,j) = t(j,n)*exp(1i*k0*x(1:Npoints)) + r(j,n)*exp(-1i*k0*x(1:Npoints));
       
       I(Npoints*(n-1)+1:Npoints*n,j) = Y0*(t(j,n)*exp(1i*k0*x(1:Npoints)) - r(j,n)*exp(-1i*k0*x(1:Npoints)));
       
    end
end

% calculate power flow
P = 0.5*real(V.*conj(I));

end