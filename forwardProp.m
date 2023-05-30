function [neural_network] = forwardProp(neural_network)
%% NAZWY
NEURONY_BEZ_AKTYWACJI = 1;
NEURONY = 2;
FUNKCJA_AKTYWACJI = 3;

% W*neuronyWarstwy = v, wartości neuronów przed aktywacją
    function output = layer(input, weights)
        output = weights*[input ; 1];
    end
    %Obliczenie wartości neuronów warstwy ukrytej przed aktywacją
    neural_network.hidden{1}{NEURONY_BEZ_AKTYWACJI} = layer(neural_network.input{1}, neural_network.weights{1});
    %Aktywacja neuronów warstwy ukrytej
    neural_network.hidden{1}{NEURONY} = neural_network.hidden{1}{FUNKCJA_AKTYWACJI}(neural_network.hidden{1}{NEURONY_BEZ_AKTYWACJI});
    %Obliczenie wartości neuronów warstwy wyjściowej przed aktywacją
    neural_network.output{NEURONY_BEZ_AKTYWACJI} = layer(neural_network.hidden{1}{NEURONY}, neural_network.weights{2});
    %Aktywacja warstwy wyjściowej
    neural_network.output{NEURONY} =  neural_network.output{FUNKCJA_AKTYWACJI}(neural_network.output{NEURONY_BEZ_AKTYWACJI});
    %Obliczenie błędu na wyjściu sieci
    e = neural_network.expectedOutput - neural_network.output{NEURONY};
    neural_network.sum_train_errors = neural_network.sum_train_errors + sumsqr(e);
end
