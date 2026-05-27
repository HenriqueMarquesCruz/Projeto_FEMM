clc;
clear;
close all;

% Harmônicas ímpares até n = 50
n = 1:2:50;        
% Harmônicas ímpares não múltiplas de 3 até n = 50
n = n(mod(n,3) ~= 0); 

% Conversão graus -> radianos
deg = pi/180;

% Espectro 1
B1 = (0.9/0.9577) .* ...
     (sin(n*90*deg)./n) .* ...
     (sin(4*n*7.5*deg) ./ (4*sin(n*7.5*deg)));

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