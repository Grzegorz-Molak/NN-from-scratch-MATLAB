function [train_data, validate_data, test_data]  = prepareData()
clear
close all
%% Odczyt danych
df = readtable("./Mammographic Mass_MLR/mammographic_masses.dat");
df{:,:}(ismissing(df))=0;
df.assesment(find(df.assesment == 55)) = 5; % W danych jedna wartość zła jest
%% Kategoryzowanie danych
%df.assesment = categorical(df.assesment, [0 1 2 3 4 5 6], 'Ordinal',true);
df.shape = categorical(df.shape, [0 1 2 3 4], ["NaN", "round", "oval", "lobular", "irregular"]);
df.margin = categorical(df.margin, [0 1 2 3 4 5], ["NaN", "circumscribed", "microlobulated", "obscured", "ill-defined", "spiculated"]);
df.density = categorical(df.density, [0 1 2 3 4], ["NaN", "high", "iso", "low", "fat-containing"], 'Ordinal', true);
df.severity = categorical(df.severity, [0 1], ["bening", "malignant"]);

df.age(df.age == 0, :) = median(df.age(df.severity == 'malignant')); %Wszystkie brakujące należą do malignant

df.shape(df.shape == 'NaN' & df.severity == 'bening') = mode(df.shape(df.severity == 'bening'));
df.shape(df.shape == 'NaN' & df.severity == 'malignant') = mode(df.shape(df.severity == 'malignant'));

df.margin(df.margin == 'NaN' & df.severity == 'bening') = mode(df.margin(df.severity == 'bening'));
df.margin(df.margin == 'NaN' & df.severity == 'malignant') = mode(df.margin(df.severity == 'malignant'));

df = removevars(df, "density");

%% Przygotowanie do drugiego etapu

%Nazwy kolumn
shapes_names = ["round", "oval", "lobular", "irregular"];
margins_names = ["circumscribed", "microlobulated", "obscured", "ill-defined", "spiculated"];

%Maksymalny wiek
max_age = 120;

%Tworzenie wektorów binarnych
shapes = table(uint8(df.shape == "round"), ...
    uint8(df.shape == "oval"), ...
    uint8( df.shape == "lobular"), ...
    uint8(df.shape == "irregular"), ...
   'VariableNames', shapes_names);
margins = table(uint8(df.margin == "circumscribed"), ...
    uint8(df.margin =="microlobulated"), ...
    uint8(df.margin =="obscured"), ...
    uint8(df.margin =="ill-defined"), ...
    uint8(df.margin =="spiculated"), ...
    'VariableNames', margins_names);
severities = zeros(size(df, 1),1);
severities(df.severity == "malignant") = 1;

converted = table(df.assesment, df.age ./ max_age, shapes, margins, severities, 'VariableNames',df.Properties.VariableNames);
%Rozłączenie tabel wewnętrznych na N kolumn
converted = splitvars(converted, "shape");
converted = splitvars(converted, "margin");

%% Podzielenie danych na testowe, walidacyjne i uczące
rng('default');
train_data = converted(converted.assesment == 0,:); % Bez assesmentu z automatu są uczące
converted = converted(converted.assesment ~= 0, :); % wyrzucamy tamte z puli
temp = cvpartition(height(converted), 'Holdout', 0.15);
trainvalidate = training(temp);
test_data = converted(test(temp), :);

trainvalidate_data = converted(training(temp), :);

temp2 = cvpartition(height(trainvalidate_data), "HoldOut", height(converted) ./ sum(trainvalidate) * 0.15);
train_data = [train_data ; trainvalidate_data(training(temp2), :)];
train_data = removevars(train_data, "assesment");
validate_data = trainvalidate_data(test(temp2), :);

%Sprawdzam czy podział % jest poprawny
%  disp("Trenujące: "+ string(height(train_data)./height(converted))+"%")
%  disp("Walidujące: "+ string(height(validate_data)./height(converted))+"%")
%  disp("Testowe: "+ string(height(test_data)./height(converted))+"%")
% 
% writetable(converted, "data/converted.dat");