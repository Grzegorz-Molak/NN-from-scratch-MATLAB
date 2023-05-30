function neural_network = networkSettings(attr_size)
%% Funkcje 
sigmoid = @(x)1./(1+exp(-x));
relu = @(x)max(0,x);
sigmoid_d = @(x)(exp(-x)) ./ ((1+exp(-x)).^2); % sigmoid.*(1-sigmoid)
relu_d = @(x)uint8(x > 0);

%% Parametry sieci
%Wejście
input_layer_size = attr_size-1; %severity jest celem nie wejściem
%W. ukryte
number_of_hidden_layers = 1;
hidden_layer_size = zeros(number_of_hidden_layers, 1);
hidden_layer_size(1) = input_layer_size;
%Wyjście
output_layer_size = 1;
%% Generacja wag
rng('default')
weights = cell(number_of_hidden_layers+1, 1); %1 byłoby bez warstw ukrytych

%Omówienie początkowych wartości w sprawozdaniu
weights_1=normrnd(0,sqrt(2/input_layer_size),hidden_layer_size,input_layer_size);
weights{1}= [weights_1 zeros(hidden_layer_size,1)]; %zeros to wagi biasu

upper = 1/sqrt(hidden_layer_size);
lower = -upper;
weights_2 = lower + rand(output_layer_size,hidden_layer_size).*(upper-lower);
weights{2} = [weights_2 zeros(output_layer_size)];

%% Tworzenie sieci neuronowej
neural_network.weights = weights; %Wagi

%Warstwy
neural_network.input = {input_layer_size}; %Wielkość wektora wejściowego
neural_network.hidden = cell(number_of_hidden_layers, 1);
neural_network.hidden{1} = {zeros(hidden_layer_size(1),1),... %Wartości przed f. aktywacji
    zeros(hidden_layer_size(1),1),... %Tu będą wartości po zast. funkcji aktywacji
    relu,... %Funkcja aktywacji
    relu_d}; %Pochodna funkcji aktywacji
neural_network.output = {zeros(output_layer_size, 1),...
    zeros(output_layer_size, 1),...
    sigmoid,...
    sigmoid_d};
%Inne parametry
neural_network.expectedOutput = zeros(output_layer_size, 1); %Tu będzie wartość severity z danej
neural_network.eta = 0.01;
neural_network.number_of_epochs = 500;
neural_network.training_errors = ones(neural_network.number_of_epochs, 1);
neural_network.sum_train_errors = 0;
 
% %Histogramy wag
% figure
% histfit(reshape(weights_1, 1, []));
% figure
% histogram(weights_2, numel(unique(weights_2)))
