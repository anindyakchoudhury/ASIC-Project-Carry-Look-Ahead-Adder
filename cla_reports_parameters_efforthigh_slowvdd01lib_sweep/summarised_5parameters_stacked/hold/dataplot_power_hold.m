% MATLAB script to extract leakage, dynamic, and total power data based on hold times
% Define the hold times (in nanoseconds)
hold_times = [0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50];  % in ns

% Initialize arrays to hold extracted power data
leakage_power = zeros(1, length(hold_times));
dynamic_power = zeros(1, length(hold_times));
total_power = zeros(1, length(hold_times));

% Open the synthesis power report file
report_file = 'power_hold_sweep_data.rpt';  % update with full path if needed
fid = fopen(report_file, 'r');

% Check if the file was opened successfully
if fid == -1
    error('Failed to open the file: %s. Check the file path.', report_file);
end

% Read the file line by line
line = fgetl(fid);
index = 1;

while ischar(line)
    % Look for the line containing 'alu' and ensure it's the instance line
    if contains(line, 'alu') && ~contains(line, 'add_') && ~contains(line, 'increment_') && ~contains(line, 'decrement_')
        % Split the line by whitespace and filter out non-numeric tokens
        tokens = regexp(line, '\s+', 'split');
        numeric_tokens = tokens(cellfun(@(x) ~isnan(str2double(x)), tokens));

        if length(numeric_tokens) >= 4
            % Extract the 2nd, 3rd, and 4th numeric values (Leakage, Dynamic, and Total Power)
            leakage = str2double(numeric_tokens{2});
            dynamic = str2double(numeric_tokens{3});
            total = str2double(numeric_tokens{4});

            % Store the extracted values in respective arrays
            leakage_power(index) = leakage;
            dynamic_power(index) = dynamic;
            total_power(index) = total;

            % Increment the index to move to the next hold time
            index = index + 1;
        end
    end
    line = fgetl(fid);
end

% Close the report file
fclose(fid);

% Write the extracted data to a new text file
output_file = 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\hold\hold_time_power_data.txt';
fid_out = fopen(output_file, 'w');
fprintf(fid_out, 'Hold Time (ns)\tLeakage Power (nW)\tDynamic Power (nW)\tTotal Power (nW)\n');
for i = 1:length(hold_times)
    fprintf(fid_out, '%f\t%f\t%f\t%f\n', hold_times(i), leakage_power(i), dynamic_power(i), total_power(i));
end
fclose(fid_out);

% Create subplots for leakage power, dynamic power, and total power
figure;

% Subplot 1: Leakage Power vs Hold Time
subplot(3,1,1);
plot(hold_times, leakage_power, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'b');
title('Leakage Power vs Hold Time');
xlabel('Hold Time (ns)');
ylabel('Leakage Power (nW)');
grid on;

% Subplot 2: Dynamic Power vs Hold Time
subplot(3,1,2);
plot(hold_times, dynamic_power, '-s', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'g');
title('Dynamic Power vs Hold Time');
xlabel('Hold Time (ns)');
ylabel('Dynamic Power (nW)');
grid on;

% Subplot 3: Total Power vs Hold Time
subplot(3,1,3);
plot(hold_times, total_power, '-d', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'r');
title('Total Power vs Hold Time');
xlabel('Hold Time (ns)');
ylabel('Total Power (nW)');
grid on;

% Save the figure with subplots as a PNG file
saveas(gcf, 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\hold\hold_time_vs_power_subplots.png');
