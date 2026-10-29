function p = nkii_calibration()
% NKII: quarterly rates, zero trend inflation, no policy smoothing.
p.beta = 0.99;
p.sigma = 1;
p.varphi = 1;
p.epsilon = 6;
p.theta = 0.75;
p.lambda_p = (1-p.theta)*(1-p.beta*p.theta)/p.theta;
p.kappa = p.lambda_p*(p.sigma+p.varphi);
p.phi_pi = 1.5;
p.phi_x = 0.125;
p.rho_d = 0.8;
p.rho_u = 0.8;
p.rho_v = 0.5;
p.rho_a = 0.9;
p.sd_d = 0.01; % IS-intercept innovation; natural-rate innovation is sigma*sd_d.
p.sd_u = 0.01; % One percentage point innovation in NKPC residual.
p.sd_v = 0.01; % One percentage point policy-rule innovation.
p.sd_a = 0.01; % One percent technology innovation.
p.psi_ya = (1+p.varphi)/(p.sigma+p.varphi);
p.lambda_x = p.kappa/p.epsilon; % Efficient steady state: subsidy offsets markup.
p.horizon = 40;
end
