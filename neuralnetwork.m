clear
close all

%% Dane
%Podział danych, przetworznie ich na macierz o odpowiedniej orientacji
[train_data, validate_data_table, test_data]  = dataIntoMatrix();
%Wczytanie ustawień ze skryptu networkSettings
neural_network = networkSettings(size(train_data,1));

%% Uczenie
for epoch=1:neural_network.number_of_epochs  
    sum_test_errors = 0;
    r = randperm(size(train_data, 2)); %Permutacja zbioru uczącego
    for p=1:size(r,2) %Pętla po całym zbiorze uczącym
        neural_network.input{1} = train_data(1:end-1, r(p));
        neural_network.expectedOutput = train_data(end, r(p));
        neural_network = forwardProp(neural_network);
        neural_network = backProp(neural_network);
    end
    neural_network.training_errors(epoch) = neural_network.sum_train_errors / size(train_data, 2);
    neural_network.sum_train_errors = 0;
end

%% Testowanie nauczonej sieci
%Sklejamy dane testowe i walidacyjne na rzecz etapu projektu
duzy_test_data = [test_data validate_data_table];

%Do przechowywania historii wyjść sieci neuronowej
outputNR=zeros(size(duzy_test_data,2),1);

%Trafienia sieci
TP = 0;
FP = 0;
TN = 0;
FN = 0;
%Umowny próg, aby wyświetlić pewne wyniki w konsoli
threshold = 0.5;

%Permutacja zbioru testowego
r = randperm(size(duzy_test_data, 2));

%Testowanie sieci, porównanie jej z oczekiwanymi wyjściami
for item = r
    neural_network.input{1} = duzy_test_data(2:end-1, item); %od 2 bo bez BI-RADS Assesment
    neural_network.expectedOutput = duzy_test_data(end, item);
    neural_network = forwardProp(neural_network);

    %Wyznaczanie trafności na podstawie wyjścia sieci
    if neural_network.expectedOutput == 1
        if round(neural_network.output{2} - threshold + 0.5)
            TP = TP + 1;
        else
            FN = FN + 1;
        end
    else
        if round(neural_network.output{2} - threshold + 0.5)
            FP = FP + 1;
        else
            TN = TN + 1;
        end
    end
    %Zapisujemy wyjście sieci do dalszej analizy
    outputNR(item) = neural_network.output{2};
end


%Współczynniki klasyfikacji
specificity = TN/(FP + TN)
sensitivity = TP/(TP + FN)
precision = TP/(TP + FP)
accuracy = (TP + TN)/(TP + TN + FP + FN)

%% Wykresy

%ROC
plotroc(duzy_test_data(end,:), outputNR')
[sens_NN, spec_NN, thres_NN] = roc(duzy_test_data(end,:), outputNR');
title("ROC dla sieci neuronowej")
figure
plotroc(duzy_test_data(end,:), duzy_test_data(1,:)./6)
title("ROC dla orzeczenia lekarzy")
[sens_DOC, spec_DOC, thres_DOC] = roc(duzy_test_data(end,:), duzy_test_data(1,:)./6');

%Błąd w zależności od epoki
figure
plot(neural_network.training_errors);
title("Błąd w zależności od numeru epoki")
xlabel("Numer epoki")
ylabel("Błąd średniokwadratowy uczenia")

%Dokładność, czułość i swoistość w zależności od progu decyzyjnego
figure
thresholds_accuracy = linspace(0,1,200);
accuracies = zeros(size(thresholds_accuracy));
for i = 1:200
    accuracies(i) = sum((outputNR > thresholds_accuracy(i)) == duzy_test_data(end,:)')./size(duzy_test_data, 2);
end
plot(thresholds_accuracy, accuracies, 'LineWidth', 2)
xlabel("Próg decyzyjny")
ylabel("Wartość")
hold on
plot(thres_NN, sens_NN, "--" ,'LineWidth', 2);
hold on
plot(thres_NN, 1-spec_NN, "--" ,'LineWidth', 2)
legend('Dokładność', 'Czułość', 'Swoistość')
