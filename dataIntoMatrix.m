function [train_data, validate_data, test_data] = dataIntoMatrix()
[train_data_table, validate_data_table, test_data_table]  = prepareData();

%Konwersja z danych numerical na double
train_data = double(table2array(train_data_table))';
% Wiek jako double został utracony przez to, że tabela była numerical
train_data(1,:) = train_data_table.age;

validate_data = double(table2array(validate_data_table))';
validate_data(2,:) = validate_data_table.age;

test_data = double(table2array(test_data_table))';
test_data(2,:) = validate_data_table.age;
end

