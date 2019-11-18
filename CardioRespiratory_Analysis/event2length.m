function [eventlengths] = event2length(EventMatrix,EVENT)
%EVENT2LENGTH Estimates the length of events in EVENT.
%   [eventlengths] = event2length(EventMatrix,EVENT)
%       converts an event matrix to a sequence of numbers
%       where each number provides the length (in samples)
%       of the ith occurence of the EVENT.
%
%   INPUT
%	EventMatrix: Nx3 matrix where N is the number of
%       events that occurred, and the columns correspond
%       to [EventStartPoint EventEndPoint EventLabel]
%       (see signal2events).
%	EVENT: single value corresponding to the event label
%       of interest (see patternCode). Leaving EVENT
%       empty returns the length of all segments in
%       EventMatrix regardless of type.
%
%   OUTPUT
%	eventlengths: vector of event length values
%       (in samples) corresponding to event EVENT.
%
%   EXAMPLE
%   [eventlengths]=event2length(signal2events(respstt_RCGABD_ubmodkm),stateCode('PAU'));
%
%   VERSION HISTORY
%   2017_01_16 - Added support for default event value (CARR).
%   2013_12_16 - Updated help header based on [1] by Carlos Alejandro Robles-Rubio (CARR).
%   2013_11_13 - Created by: Lara Kanbar.
%
%   REFERENCES
%   [1] NRP group: Naming/Plotting Standards for Code, Figs and Symbols.
%
%   SEE ALSO
%   signal2events

    if ~exist('EventMatrix','var') || isempty(EventMatrix)
        eventlengths =[];
    else
        if ~exist('EVENT','var') || isempty(EVENT)
            occurenceIDs=find(EventMatrix(:, 3)==EventMatrix(:, 3));
        else
            occurenceIDs=find(EventMatrix(:, 3)== EVENT);
        end
        eventlengths = zeros(length(occurenceIDs),1);
        for ix = 1:length(occurenceIDs) %loop through all rows
            eventlengths(ix) = EventMatrix(occurenceIDs(ix), 2) - EventMatrix(occurenceIDs(ix), 1) +1;
        end
    end
end