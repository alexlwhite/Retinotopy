function [changemat changetimes] = myMakePrandSeq(c,how_many_events)

% how_many_events = prand_n(1,:);
nframes = c.prand.nframes;


% generate a vectors of 0's and 1's, with 1's indicating that an event
% occurs
changemat = zeros(nframes,length(how_many_events));
changetimes = NaN(c.prand.maxn,length(how_many_events));
for id = 1:length(how_many_events)
    % step 1: initialize matrix
    % step 2: define possible event times
    poss_event_times = 1:3:nframes; % events separated by 2 frames
    % step 3: define a matrix of logical values (each possible time,
    % 0=no event, 1=event)
    events = zeros(size(poss_event_times));
    % step 4: set the first n events to 1
    events(1:how_many_events(id)) = 1;
    % step 5: Shuffle the matrix to have the events occur at
    % random times
    events = Shuffle(events);
    % step 6: define the frames when these events occur
    events_time = poss_event_times(logical(events));
    changetimes(1:length(events_time),id) = events_time;
    % step 7: put these values back into the matrix defininig
    % dot flicker
    changemat(events_time,id) = 1;
end


