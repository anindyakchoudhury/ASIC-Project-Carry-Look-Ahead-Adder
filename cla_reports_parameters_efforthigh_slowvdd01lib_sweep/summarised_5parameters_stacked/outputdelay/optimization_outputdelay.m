% Define file names for output delay data
power_file = 'output_delay_power_data.txt';
area_file = 'output_delay_sweep_total_area.txt';

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

% Combine power and area data based on output delay
% Using 'OutputDelay_ns_' as the key for merging (updated)
combined_data = outerjoin(power_data, area_data, 'MergeKeys', true, 'Keys', 'OutputDelay_ns_');

% Extract relevant data
output_delay = combined_data.OutputDelay_ns_;  % Output Delay in ns
total_power = combined_data.TotalPower_nW_;    % Total Power in nW
total_area = combined_data.TotalArea;           % Total Area

% Initialize weights for optimization (adjust as needed)
w1 = 0.5;  % Weight for total power
w2 = 0.5;  % Weight for total area

% Objective function: Minimize total power and area
objective = w1 * total_power + w2 * total_area;

% Find the index of the minimum objective value
[~, optimal_index] = min(objective);

% Display the optimal parameter set
disp('Optimal Parameters:');
disp(['Output Delay: ', num2str(output_delay(optimal_index)), ' ns']);
disp(['Total Power: ', num2str(total_power(optimal_index)), ' nW']);
disp(['Total Area: ', num2str(total_area(optimal_index)), ' units']);

% Write optimal parameters to a text file
output_file = 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\outputdelay\optimized_parameters_output_delay.txt';
fid = fopen(output_file, 'w');
fprintf(fid, 'Optimal Parameters:\n');
fprintf(fid, 'Output Delay: %.6f ns\n', output_delay(optimal_index));
fprintf(fid, 'Total Power: %.6f nW\n', total_power(optimal_index));
fprintf(fid, 'Total Area: %.6f units\n', total_area(optimal_index));
fclose(fid);
disp(['Optimal parameters saved to ', output_file]);

% Optionally plot the results for better visualization
figure;
scatter3(total_power, total_area, output_delay, 'filled');
xlabel('Total Power (nW)');
ylabel('Total Area (units)');
zlabel('Output Delay (ns)');
title('Total Power vs Area vs Output Delay');
grid on;

% Save the figure as a PNG file
plot_file = 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\outputdelay\optimized_parameter_output_delay_sweep.png';
saveas(gcf, plot_file);
disp(['Graph saved as ', plot_file]);

% Save results if needed
save('optimal_parameters_output_delay.mat', 'output_delay', 'total_power', 'total_area', 'optimal_index');
