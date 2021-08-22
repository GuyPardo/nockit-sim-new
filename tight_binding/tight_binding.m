% this is not a simulation, but a script that plots the tight-binding-like
% analytical solution for 2PMT. see my thesis for explanation.
% Guy. 08.21.

parms = get_nockit2_params();
parms.input_idx = 1; 
 X= [0.8218    1.1714    1.5979    0.5225    0.3187];
[G, derived] = get_nockit_graph_fit(parms, X);
freq = linspace(3,9,401)*1e9;
w = 2*pi*freq;
k0 = w/derived.v_ph;
kc = w/derived.v_ph_c;

Z0 = 1/derived.Y0;
Zc = 1/derived.Yc;
L0 = parms.L0;
d = parms.d;
N = parms.N;
%%
z0 = exp(1i*k0*L0);
zc = exp(1i*kc*d);
e = 1i*(2/Z0*(1+z0.^2)./(1-z0.^2) + 1/Zc*(1+zc.^2)./(1-zc.^2));
h0 = -1i*1/Z0*2*z0./(1-z0.^2);
hc = -1i*1/Zc*2*zc./(1-zc.^2);

Kp = acos(-e./(2*h0) - sqrt(hc.^2./(4*h0.^2)));
Km  = acos(-e./(2*h0) + sqrt(hc.^2./(4*h0.^2)));

%% plot band structure
co = colororder;
fs = 15;
figure(401) ; clf
hold on; grid on
plot(freq,k0*L0*ones,'--', 'color', 'black', 'linewidth',2)
plot(freq,real(Kp), 'color', co(2,:), 'linewidth',2)
plot(freq,imag(Kp), '--','color', co(2,:), 'linewidth',2)
plot(freq,real(Km), 'color', co(1,:), 'linewidth',2)
plot(freq,abs(imag(Km)), '--','color', co(1,:), 'linewidth',2)

ylabel('K', 'fontsize',fs);
xlabel('Frequency (Hz)', 'fontsize',fs);
legend('k_0L', 'Re(K_+)', 'Im(K_+)','Re(K_-)', 'Im(K_-)')

%% plot transmission
tp = (1-z0.^2).*sin(Kp)./(conj(z0).*sin(Kp*(N+1)) - 2*sin(Kp*N) + z0.*sin(Kp*(N-1)));
tm = (1-z0.^2).*sin(Km)./(conj(z0).*sin(Km*(N+1)) - 2*sin(Km*N) + z0.*sin(Km*(N-1)));

% mode transmisison
figure(402)
subplot(2,1,1)
plot(freq,abs(tp),'color', co(2,:) );
ylabel('t^{tot}(K_+)', 'fontsize',fs);
subplot(2,1,2)
plot(freq,abs(tm),'color', co(1,:) );
ylabel('t^{tot}(K_-)', 'fontsize',fs);
xlabel('Frequency (Hz)', 'fontsize',fs);


t1 = 0.5*(tp-tm);
t2 = 0.5*(tp+tm);

%line transmisison
figure(403); clf; hold on
plot(freq,20*log10(abs(t1)),'color', co(1,:) );
plot(freq,20*log10(abs(t2)),'color', co(2,:) );

ylabel('t^{tot} (dB)', 'fontsize',fs);
xlabel('Frequency (Hz)', 'fontsize',fs);

legend('line 1', 'line 2')
