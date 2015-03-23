function [data] = sedemo_TimeAndPriorityData(choice)
% This function takes a choice as input. If choice is '1' Intergeneration
% time is read from the excel file and returned to MATLAB workspace. If
% choice is '2' Priority values are read from the excel file and returned
% to MATLAB workspace.
switch(choice)
    case 1
        if ispc()
            IntergenerationTime = xlsread('sedemo_TimeAndPriority.xls','Sheet1','A2:A43');
        else
            raw_data = xlsread('sedemo_TimeAndPriority.xls','Sheet1');
            IntergenerationTime = raw_data(:,1);            
        end
        data = IntergenerationTime;        
    case 2
        if ispc()
            PriorityValues = xlsread('sedemo_TimeAndPriority.xls','Sheet1','B2:B43');
        else
            raw_data = xlsread('sedemo_TimeAndPriority.xls','Sheet1');
            PriorityValues = raw_data(:,2);            
        end            
        data = PriorityValues;
    otherwise
        error('Unknown option for TimeAndPriorityData');
end
