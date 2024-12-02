function process_qor_reports()
    % Read the three input files
    low_vs_high = readtable('low_vs_high_opt_report_DSi.rpt', ...
        'Delimiter', ' ', ...
        'MultipleDelimsAsOne', true, ...
        'FileType', 'text', ...
        'HeaderLines', 3);

    low_vs_med = readtable('low_vs_medium_opt_report_DSi.rpt', ...
        'Delimiter', ' ', ...
        'MultipleDelimsAsOne', true, ...
        'FileType', 'text', ...
        'HeaderLines', 3);

    med_vs_high = readtable('medium_vs_high_opt_report_DSi.rpt', ...
        'Delimiter', ' ', ...
        'MultipleDelimsAsOne', true, ...
        'FileType', 'text', ...
        'HeaderLines', 3);

    % Initialize output array
    output_data = {};
    row_counter = 1;

    % Process each row
    for i = 1:height(low_vs_high)
        % Extract values
        metric = low_vs_high.Var1{i};
        low_val = low_vs_high.Var2(i);
        med_val = low_vs_med.Var3(i);
        high_val = med_vs_high.Var3(i);
        diff_low_med = low_vs_med.Var4(i);
        diff_med_high = med_vs_high.Var4(i);
        diff_low_high = low_vs_high.Var4(i);

        % Convert values to strings for comparison
        low_str = string(low_val);
        med_str = string(med_val);
        high_str = string(high_val);

        % Check if values are numeric and not NaN
        if isnumeric(low_val) && isnumeric(med_val) && isnumeric(high_val) && ...
           ~isnan(low_val) && ~isnan(med_val) && ~isnan(high_val)

            % Store valid data
            output_data{row_counter, 1} = metric;
            output_data{row_counter, 2} = low_val;
            output_data{row_counter, 3} = med_val;
            output_data{row_counter, 4} = high_val;
            output_data{row_counter, 5} = diff_low_med;
            output_data{row_counter, 6} = diff_med_high;
            output_data{row_counter, 7} = diff_low_high;
            row_counter = row_counter + 1;
        end
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
    writetable(output_table, 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_compare\reports_compare\combined_qor_statistics.txt', 'Delimiter', '\t');

    % Write to CSV file
    writetable(output_table, 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_compare\reports_compare\combined_qor_statistics.csv');

    % Display confirmation
    fprintf('Processing complete. Results written to:\n');
    fprintf('1. combined_qor_statistics.txt\n');
    fprintf('2. combined_qor_statistics.csv\n');
end

process_qor_reports();