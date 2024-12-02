function process_generic_reports()
    % Read the three generic reports
    low_vs_high = readtable('low_vs_high_generic_report_DSi.rpt', ...
        'Delimiter', ' ', ...
        'MultipleDelimsAsOne', true, ...
        'FileType', 'text', ...
        'HeaderLines', 3);

    low_vs_med = readtable('low_vs_medium_generic_report_DSi.rpt', ...
        'Delimiter', ' ', ...
        'MultipleDelimsAsOne', true, ...
        'FileType', 'text', ...
        'HeaderLines', 3);

    med_vs_high = readtable('medium_vs_high_generic_report_DSi.rpt', ...
        'Delimiter', ' ', ...
        'MultipleDelimsAsOne', true, ...
        'FileType', 'text', ...
        'HeaderLines', 3);

    % Initialize output array
    output_data = cell(0, 7);  % Initialize with correct number of columns

    % Process each row
    for i = 1:height(low_vs_high)
        % Extract values
        metric = low_vs_high.Var1{i};

        % Handle numeric conversion carefully
        try
            low_val = str2double(char(low_vs_high.Var2(i)));
            med_val = str2double(char(low_vs_med.Var3(i)));
            high_val = str2double(char(med_vs_high.Var3(i)));
            diff_low_med = str2double(char(low_vs_med.Var4(i)));
            diff_med_high = str2double(char(med_vs_high.Var4(i)));
            diff_low_high = str2double(char(low_vs_high.Var4(i)));
        catch
            continue;
        end

        % Check if values are numeric and not NaN
        if ~isnan(low_val) && ~isnan(med_val) && ~isnan(high_val)
            % Add new row to output_data
            new_row = {metric, low_val, med_val, high_val, diff_low_med, diff_med_high, diff_low_high};
            output_data = [output_data; new_row];
        end
    end

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
    writetable(output_table, 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_compare\reports_compare\combined_generic_statistics.txt', 'Delimiter', '\t');

    % Write to CSV file
    writetable(output_table, 'C:\SPB_Data\EEE468_Jan2024_byakc\Exp2_ALU_LAYERED_NEW\randomyet\CLA_Focus_For_project\cla_reports_compare\reports_compare\combined_generic_statistics.csv');

    % Display confirmation
    fprintf('Processing complete. Results written to:\n');
    fprintf('1. combined_generic_statistics.txt\n');
    fprintf('2. combined_generic_statistics.csv\n');
end

process_generic_reports();