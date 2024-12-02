% MATLAB script to extract data from a synthesis report and plot it
% Define the clock periods and corresponding frequencies
clock_periods = [5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0];  % in ns
frequencies = 1 ./ (clock_periods * 1e-9) / 1e6;  % convert to MHz

% Initialize arrays to hold extracted total area data
total_areas = zeros(1, length(clock_periods));

% Open the synthesis report file
report_file = 'area_freq_sweep_data.rpt';  % your synthesis report file name
fid = fopen(report_file, 'r');

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
output_file = 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\freq\freq_sweep_total_area.txt';
fid_out = fopen(output_file, 'w');
fprintf(fid_out, 'Frequency (MHz)\tTotal Area\n');
for i = 1:length(frequencies)
    fprintf(fid_out, '%f\t%f\n', frequencies(i), total_areas(i));
end
fclose(fid_out);

% Plot the frequency vs total area
figure;
plot(frequencies, total_areas, '-o', 'LineWidth', 2, 'MarkerSize', 8);
title('Frequency vs Total Area');
xlabel('Frequency (MHz)');
ylabel('Total Area');
grid on;

% Save the plot as a PNG file
saveas(gcf, 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_parameters_efforthigh_slowvdd01lib_sweep\summarised_5parameters_stacked\freq\frequency_vs_total_area.png');
