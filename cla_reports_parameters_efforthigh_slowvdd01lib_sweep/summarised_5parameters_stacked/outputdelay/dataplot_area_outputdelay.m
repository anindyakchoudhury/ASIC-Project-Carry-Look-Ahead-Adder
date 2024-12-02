% MATLAB script to extract data based on output delays and plot it
% Define the output delays (in nanoseconds)
output_delays = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1];  % in ns

% Initialize arrays to hold extracted total area data
total_areas = zeros(1, length(output_delays));

% Open the synthesis report file
report_file = 'area_output_delay_sweep_data.rpt';  % update with full path if needed
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
            % Extract the 4th numeric value (Total Area)
            total_area = str2double(numeric_tokens{4});
            total_areas(index) = total_area;
            index = index + 1;
        end
    end
    line = fgetl(fid);
end

% Close the report file
fclose(fid);

% Write the extracted data to a new text file
output_file = 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\outputdelay\output_delay_sweep_total_area.txt';
fid_out = fopen(output_file, 'w');
fprintf(fid_out, 'Output Delay (ns)\tTotal Area\n');
for i = 1:length(output_delays)
    fprintf(fid_out, '%f\t%f\n', output_delays(i), total_areas(i));
end
fclose(fid_out);

% Plot the output delay vs total area
figure;
plot(output_delays, total_areas, '-o', 'LineWidth', 2, 'MarkerSize', 8);
title('Output Delay vs Total Area');
xlabel('Output Delay (ns)');
ylabel('Total Area');
grid on;

% Save the plot as a PNG file
saveas(gcf, 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\outputdelay\output_delay_vs_total_area.png');
