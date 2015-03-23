function varargout = evcal
% SEDB.EVCAL  Event calendar of discrete event simulation.
%
%    EVCAL will display the list of events in the event calendar at the
%    current step of a discrete event simulation.
%
%    X = EVCAL will return the state of the event calendar in a structure
%    variable X. 
%
%    The structure variable returned has the following fields:
%      'Time'           current simulation time
%      'ExecutingEvent' event that is currently executing
%      'PendingEvents'  events awaiting execution
%
%    X.ExecutingEvent and X.PendingEvents are structure arrays with the 
%    following fields:
%      'ID'           event identifier
%      'EventType'    type of event
%      'EventTime'    time of event
%      'Priority'     priority of event
%      'Entity'       identifier of entity associated with this event
%      'Block'        block which will execute this event
%
% See also SEDB.SIMTIME, SEDB.CURRENTOP, SEDB

% ensure debugger on
des_validateDebugMode;

if nargout == 0
    
    % then print the event calendar neatly as a table
    fprintf('\nCurrent Time = %.15f\n', sedb.simtime);
    des_dbg_cmd_eventcalendar(); % builtin
    fprintf('\n');
    
else
    
    [IDX_Header, IDX_FirstEvent, IDX_Executing] = deal(1, 2, 1);
    
    % the order of fields; this order should be the same as that returned
    % by function evinfo
    fldNames = { 'ID', 'EventType', 'EventTime', 'Priority', 'Entity', 'Block' };
    
    % else return event calendar as a struct
    data = des_dbg_cmd_eventcalendar();
    
    % data is a cell array of events in the calendar including the header
    % of the table (fieldnames)
    
    % eliminate empty cells
    % temp events and internal events result in empty cells
    idx = cellfun(@isempty, data);
    data = data(~idx);
    
    % if data has only one element then it is the header
    % and the event calendar is empty
    
    if length(data) == 1
    
        % assign empty structs
        executingEvent = createBlankEventStruct();
        pendingEvents = createBlankEventStruct();
        
    else
        
        % the event calendar has at least one event
        
        % check if an executing event is present
        executingEventPresent = strcmp( data{IDX_FirstEvent}{IDX_Executing}, '=>' );
        
        % now that we have checked for executing event, we don't need the
        % first element of each event data which is either '=>' or blank.
        
        % strip the first IsExecuting element from each data element
        % we dont return IsExecuting in the return struct
        data = cellfun( @(x) x(2:end), data, 'uniformoutput', false);
        
        if executingEventPresent
            
            % create the executing event struct
            executingEvent = castEvCellDataIntoEvStruct ( data{IDX_FirstEvent} );
            
            % eliminate this from the data so that the remaining elements in
            % data can all go in PendingEvents structure
            data = data( [IDX_Header, IDX_FirstEvent+1 : end] );
            
        else
            executingEvent = createBlankEventStruct();
        end
        
        % now that we have eliminated the executing event from data, we
        % need to check how many events are left
        
        if length(data) == 1
            % only the header is left, i.e. no pending events in the event
            % calendar
            pendingEvents = createBlankEventStruct();
        else
            % we have some pending events; let's collect up all of them            
            pendingEvents = cellfun( @castEvCellDataIntoEvStruct, data( IDX_FirstEvent : end ) );
        end
        
    end
    
    % form the final struct
    out.Time = sedb.simtime;
    out.ExecutingEvent = executingEvent;
    out.PendingEvents = pendingEvents;
    varargout{1} = out;
    
end


    function evStruct = castEvCellDataIntoEvStruct(evCell)
    % castEvCellDataIntoEvStruct Convert cell array containing event data
    % into structure with appropriate fields
    
        % convert cell to struct
        evStruct = cell2struct( evCell, data{IDX_Header}, 2 );
        
        % convert the event time from string to double
        evStruct.EventTime = str2double(evStruct.EventTime);
        
        % order the fields
        evStruct = orderfields( evStruct, fldNames );
        
        % if entity id is '<none>' then we want to return empty string so
        % that users can use @isempty to check
        if strcmp( evStruct.Entity, '<none>' )
            evStruct.Entity = '';
        end     
    end

    function x = createBlankEventStruct
    % createBlankEventStruct Create empty event structure with appropriate
    % fields.
    
        emptyCells = repmat( {{}}, 1, length(fldNames) );
        allData = [fldNames; emptyCells];
        x = struct( allData{:} );
    end

end

% [eof]
