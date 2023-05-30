function neural_network = backProp(neural_network)
%% NAZWY
NEURONY_BEZ_AKTYWACJI = 1;
NEURONY = 2;
POCHODNA_AKTYWACJI = 4;

% 1. Wartości błędu
% 2. Wartości delt
e = neural_network.expectedOutput - neural_network.output{NEURONY};
deltaWyj = double(neural_network.output{POCHODNA_AKTYWACJI}(neural_network.output{NEURONY_BEZ_AKTYWACJI}).*e);
eUkryte = neural_network.weights{2}'*deltaWyj;
deltyUkryte = double(neural_network.hidden{1}{POCHODNA_AKTYWACJI}([neural_network.hidden{1}{NEURONY_BEZ_AKTYWACJI} ; 1])).*eUkryte;
% 3. Korekty współczynników wagowych warstw
deltaWagUkr = neural_network.eta*deltyUkryte*[neural_network.input{NEURONY_BEZ_AKTYWACJI} ; 1]';
deltaWagWyj = neural_network.eta*deltaWyj*[neural_network.hidden{1}{NEURONY} ; 1]';
% 6. Skoryguj wagi warstwy wyjściowej
neural_network.weights{2} = neural_network.weights{2} + deltaWagWyj;
% 7. Skoryguj wagi warstwy ukrytej
neural_network.weights{1} = neural_network.weights{1} + deltaWagUkr(1:end-1, :);