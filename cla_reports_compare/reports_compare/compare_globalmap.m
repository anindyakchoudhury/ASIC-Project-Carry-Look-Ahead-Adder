function process_globalmap_reports()
    % Read the three globalmap reports
    low_vs_high = readtable('low_vs_high_globalmap_report_DSi.rpt', ...
        'Delimiter', ' ', ...
        'MultipleDelimsAsOne', true, ...
        'FileType', 'text', ...
        'HeaderLines', 3);

    low_vs_med = readtable('low_vs_medium_globalmap_report_DSi.rpt', ...
        'Delimiter', ' ', ...
        'MultipleDelimsAsOne', true, ...
        'FileType', 'text', ...
        'HeaderLines', 3);

    med_vs_high = readtable('medium_vs_high_globalmap_report_DSi.rpt', ...
        'Delimiter', ' ', ...
        'MultipleDelimsAsOne', true, ...
        'FileType', 'text', ...
        'HeaderLines', 3);

    % Initialize output array
    output_data = cell(0, 7);

    % Debug: Print number of rows
    fprintf('Number of rows in input files: %d\n', height(low_vs_high));

    % Process each row
    for i = 1:height(low_vs_high)
        % Extract values
        metric = low_vs_high.Var1{i};

        % Debug: Print current metric
        fprintf('Processing metric: %s\n', metric);

        % Extract raw values
        low_val = low_vs_high.Var2(i);
        med_val = low_vs_med.Var3(i);
        high_val = med_vs_high.Var3(i);

        % Debug: Print raw values
        fprintf('Raw values - Low: %s, Med: %s, High: %s\n', ...
            char(low_val), char(med_val), char(high_val));

        % Try to convert to numbers
        if isnumeric(low_val) && isnumeric(med_val) && isnumeric(high_val)
            low_num = low_val;
            med_num = med_val;
            high_num = high_val;
        else
            try
                low_num = str2double(char(low_val));
                med_num = str2double(char(med_val));
                high_num = str2double(char(high_val));
            catch
                fprintf('Conversion failed for row %d\n', i);
                continue;
            end
        end

        % Get difference values
        diff_low_med = str2double(char(low_vs_med.Var4(i)));
        diff_med_high = str2double(char(med_vs_high.Var4(i)));
        diff_low_high = str2double(char(low_vs_high.Var4(i)));

        % Check if we have valid numeric data
        if ~isnan(low_num) && ~isnan(med_num) && ~isnan(high_num) && ...
           ~isinf(low_num) && ~isinf(med_num) && ~isinf(high_num)

            % Debug: Print valid values found
            fprintf('Valid numeric values found for metric: %s\n', metric);

            % Add new row to output_data
            new_row = {metric, low_num, med_num, high_num, diff_low_med, diff_med_high, diff_low_high};
            output_data = [output_data; new_row];
        end
    end

    % Debug: Print number of valid rows found
    fprintf('Number of valid rows found: %d\n', size(output_data, 1));

    % Check if we have any data
    if isempty(output_data)
        error('No valid data found to create table.');
    end

    % Convert cell array to table
    output_table = cell2table(output_data, 'VariableNames', {...
        'Metric', ...
        'Low_Effort', ...
        'Medium_Effort', ...
        'High_Effort', ...
        'Diff_Low_Med', ...
        'Diff_Med_High', ...
        'Diff_Low_High'});

    % Write to text file
    writetable(output_table, 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_compare\reports_compare\combined_globalmap_statistics.txt', 'Delimiter', '\t');

    % Write to CSV file
    writetable(output_table, 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_compare\reports_compare\combined_globalmap_statistics.csv');

    fprintf('\nProcessing complete. Results written to:\n');
    fprintf('1. combined_globalmap_statistics.txt\n');
    fprintf('2. combined_globalmap_statistics.csv\n');
end