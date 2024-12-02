% Define file names
power_file = 'freq_sweep_power_data.txt';
area_file = 'freq_sweep_total_area.txt';

% Read the power data
power_data = readtable(power_file);

% Read the area data
area_data = readtable(area_file);

% Display the structure of the read tables for verification
disp('Power Data:');
disp(power_data);
disp('Area Data:');
disp(area_data);

% Check the variable names in both tables
disp('Variable Names in Power Data:');
disp(power_data.Properties.VariableNames);
disp('Variable Names in Area Data:');
disp(area_data.Properties.VariableNames);

% Combine power and area data based on frequency
% Note the correct variable name 'Frequency_MHz_' for both tables
combined_data = outerjoin(power_data, area_data, 'MergeKeys', true, 'Keys', 'Frequency_MHz_');

% Extract relevant data
frequency = combined_data.Frequency_MHz_;  % Frequency in MHz
total_power = combined_data.TotalPower_nW_; % Total Power in nW
total_area = combined_data.TotalArea;        % Total Area

% Initialize weights for optimization (adjust as needed)
w1 = 0.5;  % Weight for total power
w2 = 0.5;  % Weight for total area

% Objective function: Minimize total power and area
objective = w1 * total_power + w2 * total_area;

% Find the index of the minimum objective value
[~, optimal_index] = min(objective);

% Display the optimal parameter set
disp('Optimal Parameters:');
disp(['Frequency: ', num2str(frequency(optimal_index)), ' MHz']);
disp(['Total Power: ', num2str(total_power(optimal_index)), ' nW']);
disp(['Total Area: ', num2str(total_area(optimal_index)), ' units']);

% Write optimal parameters to a text file
output_file = 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\freq\optimized_parameters.txt';
fid = fopen(output_file, 'w');
fprintf(fid, 'Optimal Parameters:\n');
fprintf(fid, 'Frequency: %.6f MHz\n', frequency(optimal_index));
fprintf(fid, 'Total Power: %.6f nW\n', total_power(optimal_index));
fprintf(fid, 'Total Area: %.6f units\n', total_area(optimal_index));
fclose(fid);
disp(['Optimal parameters saved to ', output_file]);

% Optionally plot the results for better visualization
figure;
scatter3(total_power, total_area, frequency, 'filled');
xlabel('Total Power (nW)');
ylabel('Total Area (units)');
zlabel('Frequency (MHz)');
title('Total Power vs Area vs Frequency');
grid on;

% Save the figure as a PNG file
plot_file = 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\freq\optimized_parameter_freq_sweep.png';
saveas(gcf, plot_file);
disp(['Graph saved as ', plot_file]);

% Save results if needed
save('optimal_parameters.mat', 'frequency', 'total_power', 'total_area', 'optimal_index');
