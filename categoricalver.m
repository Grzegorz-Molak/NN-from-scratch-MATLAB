clear
close all
%% Odczyt danych
df = readtable("./Mammographic Mass_MLR/mammographic_masses.dat");

%Wyświetlam wartości unikalne każdej z cech
df{:,:}(ismissing(df))=0; 
disp("BI-RADS: ") 
disp(unique(df.assesment)')
disp("Shape: ")
disp(unique(df.shape)')
disp("Margin: ")
disp(unique(df.margin)')
disp("Density: ")
disp(unique(df.density)')
disp("Severity: ")
disp(unique(df.severity)')

df.assesment(find(df.assesment == 55)) = 5; % W danych jedna wartość zła jest
%df = df(df.age ~= 0,:);

%% Kategoryzowanie danych
df.assesment = categorical(df.assesment, [0 1 2 3 4 5 6], 'Ordinal',true);
df.shape = categorical(df.shape, [0 1 2 3 4], ["NaN" "round", "oval", "lobular", "irregular"]);
df.margin = categorical(df.margin, [0 1 2 3 4 5], ["NaN" "circumscribed", "microlobulated", "obscured", "ill-defined", "spiculated"]);
df.density = categorical(df.density, [0 1 2 3 4], ["NaN" "high", "iso", "low", "fat-containing"], 'Ordinal', true);
df.severity = categorical(df.severity, [0 1], ["bening" "malignant"]);




%% Uzupełnianie brakujących danych
removed_density = false;
df.age(df.age == 0, :) = median(df.age(df.severity == 'malignant')); %Wszystkie brakujące należą do malignant
%Zakomentować poniżej żeby pokazać nienaprawione dane

df.shape(df.shape == 'NaN' & df.severity == 'bening') = mode(df.shape(df.severity == 'bening'));
df.shape(df.shape == 'NaN' & df.severity == 'malignant') = mode(df.shape(df.severity == 'malignant'));

df.margin(df.margin == 'NaN' & df.severity == 'bening') = mode(df.margin(df.severity == 'bening'));
df.margin(df.margin == 'NaN' & df.severity == 'malignant') = mode(df.margin(df.severity == 'malignant'));

df = removevars(df, "density");
removed_density = true;
%Dotąd



%% Ustawienia - dla użytkownika
analyzed_str = 'severity'; % Badana zmienna
%Polecane wartości '' - pokazuje wszystkie dane,
% 'severity' pokazuje histogramy dla klas zmiany łagodnej i złośliwej

%% Run
variables = df.Properties.VariableNames; %Nazwy zmiennych
if(strcmp(analyzed_str, "")) %Wszystkie dane
    figure
    hold on
    sgtitle("Wszystkie dane: "+ "N = " + string(size(df, 1)))
    sub = 1;
    for v = variables() % Iteracja po kolejnych nazwach kolumn
            values = df.(cell2mat(v)); % Wartości z odpowiedniej kolumny
		    subplot(3,2,sub);
		    sub=sub+1;
		    h = histogram(values); % Dane posiadające odpowiednie wartości analizowanego argumentu
            if(~iscategorical(values)) % Jeżeli argument jest numeryczny
                xlim([min(values), max(values)]) % ustaw granice wspólne dla wszystkich i
                m = mean(values);
                s = std(values);
                xline([m-s m m+s], '--r', {'-1 st. dev', 'mean', '+1 st. dev'}, 'LineWidth', 2)
            end
		    title(v);
    end
else %Histogramy w zależności od wartości którejś cechy
    analyzed = df.(analyzed_str); % Kolummna badanej zmiennej
    for i = unique(analyzed)' % musi być wektor kolumnowy, żeby iterowalny był
	    figure;
        if(~strcmp(string(i), '0'))
            sgtitle(analyzed_str + " = " + string(i) + ", N = " + string(size(analyzed(analyzed == i), 1)))
        else
            sgtitle(analyzed_str + " = NaN, N = " + string(size(analyzed(analyzed == i), 1))) 
        end
         
	    hold on;
	    sub=1;
	    for v = variables(~ismember(variables, analyzed_str)) % Iteracja po kolejnych nazwach kolumn
            values = df.(cell2mat(v)); % Wartości z odpowiedniej kolumny
            if(removed_density)
                subplot(2,2,sub)
            else
                subplot(3,2,sub)
            end
            	    
		    sub=sub+1;
		    h = histogram(values(analyzed(:) == i)); % Dane posiadające odpowiednie wartości analizowanego argumentu
            if(~iscategorical(values)) % Jeżeli argument jest numeryczny
                xlim([min(values), max(values)]) % ustaw granice wspólne dla wszystkich i
                m = mean(values(analyzed(:) == i));
                s = std(values(analyzed(:) == i));
                xline([m-s m m+s], '--r', {'-1 st. dev', 'mean', '+1 st. dev'}, 'LineWidth', 2)
                
            end
		    title(v);
	    end
    end
end

