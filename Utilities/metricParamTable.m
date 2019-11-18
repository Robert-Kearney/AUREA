function [ paramTable ] = metricParamTable( Metric_param, Default_param, Fs, ShowTable )
%metricParamTable Returns a descriptive table of the metric initialization
%  parameters used in CardioRespiratoryMetrics.
%
%	[ paramTable ] = metricParamTable( Metric_param, Default_param, Fs, ShowTable )
%
%   INPUT
%   Metric_param is a struct with the metric parameters
%       used by CardioRespiratoryMetrics.
%   Default_param is a struct with the default metric parameters.
%   Fs is the sampling rate in Hz (Default 50Hz).
%   ShowTable is a flag to indicate whether to plot the table.
%
%   OUTPUT
%   paramTable is a cell matrix containing 5 columns
%   (Parameter name, description, value (samples), value (s), and default value).
%
%   EXAMPLE
%   [ paramTable ] = metricParamTable( Metric_param, [], 50, 1)
%
%   VERSION HISTORY
%   2018_05_17: Created by Lara J. Kanbar.
%
%   REFERENCES
%   [1] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.
%
%Copyright (c) 2018, Lara J. Kanbar and Robert E. Kearney,
%McGill University
%All rights reserved.
%
%Redistribution and use in source and binary forms, with or without modification, are
%permitted provided that the following conditions are met:
%
%1. Redistributions of source code must retain the above copyright notice, this list of
%   conditions and the following disclaimer.
%
%2. Redistributions in binary form must reproduce the above copyright notice, this list of
%   conditions and the following disclaimer in the documentation and/or other materials
%   provided with the distribution.
%
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
%EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
%MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
%COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
%EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
%HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
%TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% Error Handling
if ~exist('Default_param','var') || isempty(Default_param)
    Default_param =[];
end
if ~exist('ShowTable') || isempty(ShowTable)
    ShowTable = false;
end

%1. Get fieldnames at level 1 of the Metric_params struct
fields_L1 = fieldnames(Metric_param);

%2. Fill Table columns
iParam = 1;

for iField1 = 1: length(fields_L1)
    fields_L2 = fields(getfield(Metric_param, fields_L1{iField1}));%Fields at level 2 of struct
    
    for iField2 = 1:length(fields_L2)
        L3_blankflag = isnumeric(getfield(Metric_param.(fields_L1{iField1}), ...
            fields_L2{iField2})) | islogical(getfield(Metric_param.(fields_L1{iField1}), ...
            fields_L2{iField2}));%flag for fields at level 3 of struct
        
        if ~L3_blankflag% Third level struct parameters
            fields_L3 = fields(getfield(Metric_param.(fields_L1{iField1}), fields_L2{iField2}));
            for iField3 = 1: length(fields_L3)
                col1{iParam, 1} = strcat(fields_L1{iField1}, '.', ...
                    fields_L2{iField2}, '.', fields_L3{iField3} ); %Codename
                col2(iParam, 1) = metricParamDescription( col1{iParam, 1} ); %Description
                col3{iParam,1}  = eval(strcat('Metric_param.', col1{iParam, 1})).*(1/Fs); %Value (s)
                col4{iParam,1} = eval(strcat('Metric_param.', col1{iParam, 1})); %Value (samples)
                
                if ~isempty(Default_param)
                    col5{iParam,1} = eval(strcat('Default_param.', col1{iParam, 1} ));%Default values
                end
                iParam = iParam +1;
            end
        else%Only 2nd level struct parameters
            col1{iParam, 1} = strcat(fields_L1{iField1}, '.', fields_L2{iField2} ); %Codename
            col2(iParam, 1) = metricParamDescription( col1{iParam, 1} ); %Description
            col3{iParam,1}  = eval(strcat('Metric_param.', col1{iParam, 1})).*(1/Fs); %Value (s)
              col4{iParam,1}  = eval(strcat('Metric_param.', col1{iParam, 1})); %Value (samples)
            if ~isempty(Default_param)
                col5{iParam,1} = eval(strcat('Default_param.', col1{iParam, 1})); %Value (samples);%Default values
            end
            iParam = iParam +1;
        end
    end
end

% 3. Create table content
if ~isempty(Default_param)
    paramTable = [col1 col2 (col3) (col4) (col5)];
    columnName = {'Parameter Name', 'Description', 'Value (s)','Value (samples)', 'Default Value | (samples)'};
    columnFormat = {'char' , 'char' ,'bank','bank','bank'};
    
else
    paramTable = [col1 col2 (col3) (col4) ];
    columnName = {'Parameter Name', 'Description', 'Value (s)','Value (samples)'};
    columnFormat = {'char' , 'char' ,'bank','bank'};
end

% 4. Table
if ShowTable
    fh = figure(1);clf;
    t = uitable('Units','normalized','Position', [0 0 1 1], 'Data', (paramTable),'ColumnName', columnName,'ColumnFormat', columnFormat,'RowName',[], 'ColumnWidth',{120,410,60,90} ,'ColumnEditable', [false true false false]);
    figPos = get(fh,'Position');
    tableExtent = get(t,'Extent');
    set(fh,'Position',[figPos(1:2), figPos(3:4).*tableExtent(3:4)]);
end

end