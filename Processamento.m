clc;
clear;
close all;

%% ------- Letra b) -------
% Harmônicas ímpares até n = 50
n = 1:2:50;        
% Harmônicas ímpares não múltiplas de 3 até n = 50
n = n(mod(n,3) ~= 0); 

% Conversão graus -> radianos
deg = pi/180;

% Espectro 1
B1 = (0.9/0.9659) .* ...
     (sin(n*90*deg)./n) .* ...
     (sin(2*n*15*deg) ./ (2*sin(n*15*deg)));

% Espectro 2
B2 = (0.9/0.9659) .* ...
     (sin(n*90*deg)./n) .* ...
     (sin(2*n*15*deg) ./ (2*sin(n*15*deg)));

% Espectro 3
B3 = (0.9/0.9330) .* ...
     (sin(n*75*deg)./n) .* ...
     (sin(2*n*15*deg) ./ (2*sin(n*15*deg)));

% Valor absoluto
B1 = abs(B1);
B2 = abs(B2);
B3 = abs(B3);

% Janela 1 - espectros juntos
figure('Name', 'Espectros Sobrepostos', 'NumberTitle', 'off');
stem(n, B1, 'filled', 'LineWidth', 1.3);
hold on;
stem(n, B2, 'filled', 'LineWidth', 1.3);
stem(n, B3, 'filled', 'LineWidth', 1.3);
grid on;
xlabel('Ordem Harmônica n');
ylabel('$|B_{\max}(n)|$', 'Interpreter', 'latex');
title('Espectro Harmônico das 3 Configurações');
legend('Configuração 1', 'Configuração 2', 'Configuração 3', ...
       'Location', 'northeast');
xlim([0 50]);

% Janela 2 - espectros separados
figure('Name', 'Espectros Individuais', 'NumberTitle', 'off');

subplot(3,1,1);
stem(n, B1, 'filled', 'LineWidth', 1.3);
grid on;
title('Espectro Harmônico da Configuração 1');
ylabel('$|B_{\max}(n)|$', 'Interpreter', 'latex');
xlim([0 50]);

subplot(3,1,2);
stem(n, B2, 'filled', 'LineWidth', 1.3);
grid on;
title('Espectro Harmônico da Configuração 2');
ylabel('$|B_{\max}(n)|$', 'Interpreter', 'latex');
xlim([0 50]);

subplot(3,1,3);
stem(n, B3, 'filled', 'LineWidth', 1.3);
grid on;
title('Espectro Harmônico da Configuração 3');
xlabel('Ordem Harmônica n');
ylabel('$|B_{\max}(n)|$', 'Interpreter', 'latex');
xlim([0 50]);

% Laminação M250
H_dados = [0, 2500, 5000, 10000];   % A/m
B_dados = [0, 1.60, 1.70, 1.82];    % T

H_interp = linspace(0, 10000, 20);
B_interp = interp1(H_dados, B_dados, H_interp, 'pchip');

fprintf('\n%-6s  %-12s  %-10s\n', 'Ponto', 'H (A/m)', 'B (T)');
fprintf('%s\n', repmat('-', 1, 32));
for i = 1:length(H_interp)
    fprintf('%-6d  %-12.2f  %.4f\n', i, H_interp(i), B_interp(i));
end

figure('Name', 'Aço M250', 'NumberTitle', 'off');
plot(H_dados, B_dados, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5); hold on;
plot(H_interp, B_interp, 'b.-', 'MarkerSize', 10, 'LineWidth', 1.2);
xlabel('H (A/m)'); ylabel('B (T)');
title('Curva B×H - Interpolação pchip');
legend('Pontos medidos', 'Interpolado', 'Location', 'southeast');
grid on;

%% ------- Letra c) -------
E_rms = 127;
f_e   = 60;
P     = 6;
r     = 115/(2*1000);
l     = 0.140;
g     = 0.0005;
mu0   = 4*pi*1e-7;
B_max = 0.9;

kw = [0.9659, 0.9659, 0.9330];

phi = (2/P) * 2*l*r*B_max;
Nph = (E_rms * sqrt(2)) ./ (2*pi*f_e .* kw * (2/P) * 2*l*r*B_max);

Nph1 = Nph(1);
Nph2 = Nph(2);
Nph3 = Nph(3);

n = 108;
Ia = B_max * (2/3) * (g/mu0) * (pi/4) * P ./ (kw .* n);

Ia1 = Ia(1);
Ia2 = Ia(2);
Ia3 = Ia(3);

fprintf('\nNph1 = %.4f espiras\n', Nph1)
fprintf('Nph2 = %.4f espiras\n', Nph2)
fprintf('Nph3 = %.4f espiras\n', Nph3)
fprintf('\n')
fprintf('Ia1 = %.4f A, Ib1 = Ic1 = %.4f\n', Ia1, -Ia1/2)
fprintf('Ia2 = %.4f A, Ib2 = Ic2 = %.4f\n', Ia2, -Ia2/2)
fprintf('Ia3 = %.4f A, Ib3 = Ic3 = %.4f\n', Ia3, -Ia3/2)

%% ------- Letra d) - Plot Bn interpolado + FFT -------
N_interp = 1024;
N_harm   = 13;

nomes = {'Pontos_Bn_Configuracao1', ...
         'Pontos_Bn_Configuracao2', ...
         'Pontos_Bn_Configuracao3'};
cores = {'b', 'r', 'g'};

% Handles 
fig_bn  = figure('Name','Campo B_n - Interpolado',               'NumberTitle','off');
fig_fft = figure('Name','Espectro FFT - Bn (harmônicas 0–13)',   'NumberTitle','off');

for k = 1:3
    % --- Importação ---
    filepath = fullfile('Graficos_FEMM', [nomes{k} '.txt']);
    dados = importdata(filepath, '\t');
    if isstruct(dados)
        M = dados.data;
    else
        M = dados;
    end
    pos_mm = M(:, 1);
    Bn     = M(:, 2);

    % --- Pré-processamento ---
    [pos_unique, idx] = unique(pos_mm, 'stable');
    Bn_unique = Bn(idx);

    [pos_sorted, idx2] = sort(pos_unique);
    Bn_sorted = Bn_unique(idx2);

    % --- Interpolação uniforme ---
    pos_uniforme = linspace(pos_sorted(1), pos_sorted(end), N_interp);
    Bn_interp    = interp1(pos_sorted, Bn_sorted, pos_uniforme, 'pchip');

    % --- Plot Bn ---
    figure(fig_bn);
    subplot(3, 1, k);
    plot(pos_uniforme, Bn_interp, cores{k}, 'LineWidth', 1.2);
    xlabel('Posição (mm)');
    ylabel('B_n (T)');
    title(strrep(nomes{k}, '_', '\_'));
    grid on;

    % --- FFT ---
    N_fft = length(Bn_interp);
    Y     = fft(Bn_interp);
    amp   = (2/N_fft) * abs(Y(1:N_harm+1));
    amp(1) = amp(1) / 2;        % DC sem fator 2
    harmonicas = (0:N_harm)';

    % --- Plot FFT ---
    figure(fig_fft);
    subplot(3, 1, k);
    stem(harmonicas, amp, 'filled', 'Color', cores{k}, 'MarkerSize', 5);
    xlim([-0.5, N_harm + 0.5]);
    xticks(0:N_harm);
    xlabel('Harmônica n');
    ylabel('Amplitude (T)');
    title(strrep(nomes{k}, '_', '\_'));
    grid on;

    % --- Command Window ---
    fprintf('\n%s\n', nomes{k});
    fprintf('  n  |  Amplitude (T)\n');
    fprintf('-----|----------------\n');
    for nn = 0:N_harm
        fprintf('  %2d |  %.6f\n', nn, amp(nn+1));
    end
end

figure(fig_bn);  sgtitle('Campo B_n - Dados Interpolados Uniformemente');
figure(fig_fft); sgtitle('Espectro de Fourier - Campo B_n (harmônicas 0–13)');