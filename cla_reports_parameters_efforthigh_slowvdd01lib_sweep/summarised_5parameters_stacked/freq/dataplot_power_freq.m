% MATLAB script to extract leakage, dynamic, and total power data based on frequencies
% Define the clock periods (in nanoseconds) and calculate the corresponding frequencies (in MHz)
clock_periods = [5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0];  % in ns
frequencies = 1 ./ clock_periods * 1000;  % Convert clock periods (ns) to frequencies (MHz)

% Initialize arrays to hold extracted power data
leakage_power = zeros(1, length(clock_periods));
dynamic_power = zeros(1, length(clock_periods));
total_power = zeros(1, length(clock_periods));

% Open the synthesis power report file
report_file = 'power_freq_sweep_data.rpt';  % update with full path if needed
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
            
            % Increment the index to move to the next clock period
            index = index + 1;
        end
    end
    line = fgetl(fid);
end

% Close the report file
fclose(fid);

% Write the extracted data to a new text file
output_file = 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\freq\freq_sweep_power_data.txt';
fid_out = fopen(output_file, 'w');
fprintf(fid_out, 'Frequency (MHz)\tLeakage Power (nW)\tDynamic Power (nW)\tTotal Power (nW)\n');
for i = 1:length(frequencies)
    fprintf(fid_out, '%f\t%f\t%f\t%f\n', frequencies(i), leakage_power(i), dynamic_power(i), total_power(i));
end
fclose(fid_out);

% Create subplots for leakage power, dynamic power, and total power
figure;

% Subplot 1: Leakage Power vs Frequency
subplot(3,1,1);
plot(frequencies, leakage_power, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'b');
title('Leakage Power vs Frequency');
xlabel('Frequency (MHz)');
ylabel('Leakage Power (nW)');
grid on;

% Subplot 2: Dynamic Power vs Frequency
subplot(3,1,2);
plot(frequencies, dynamic_power, '-s', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'g');
title('Dynamic Power vs Frequency');
xlabel('Frequency (MHz)');
ylabel('Dynamic Power (nW)');
grid on;

% Subplot 3: Total Power vs Frequency
subplot(3,1,3);
plot(frequencies, total_power, '-d', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'r');
title('Total Power vs Frequency');
xlabel('Frequency (MHz)');
ylabel('Total Power (nW)');
grid on;

% Save the figure with subplots as a PNG file
saveas(gcf, 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\freq\frequency_vs_power_subplots.png');
