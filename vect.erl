-module(vect).
-export([zero/0,inc/2,merge/2,leq/2,clock/1,update/3,safe/2]).

%initialize time stamp
zero()->
    [].

%increase the time stamp by one
inc(Name, Time) ->
    case lists:keyfind(Name, 1, Time) of
        {N,T} ->
            lists:keyreplace(Name, 1, Time, {N,T+1});
        false ->
            [{Name,1}|Time]
    end.

%To merge two time stamps(use the bigger one)
% the second param is self stamp
% the first param is the received stamp
merge([], Time) ->
    Time;
merge([{Name, Ti}|Rest], Time) ->
    case lists:keyfind(Name, 1, Time) of
    {Name, Tj} ->
        [{Name,max(Ti,Tj)}|merge(Rest, lists:keydelete(Name, 1, Time))];
    false ->
        [{Name,Ti} |merge(Rest, Time)]
end.


%To check the first stamp is less then or equal to the second stamp
leq([],_)->
    true;
leq([{Name,Ti}|Rest],Time)->
    case lists:keyfind(Name,1,Time) of
        {Name,Tj}->
            if
                Ti=<Tj->
                  leq(Rest,Time);
                true->
                    false
            end;
        false->
            false
    end.

%generate am empty clock
clock(Nodes)->
    lists:map(fun(X)->{X,0} end,Nodes).

%update the clock when new time stamp comes
update(From,Time,Clock)->
    {_,Time_l} = lists:keyfind(From,1,Time),

    case lists:keyfind(From,1,Clock) of
        {From,Time_o}->
            lists:keyreplace(From,1,Clock,{From,max(Time_l,Time_o)});
        false->
            [{From,Time_l}|Clock]
        end.

%check if it is safe to print the message
safe([],_)->
    safe;
safe([{Name,Ti}|Rest],Clock)->
    case lists:keyfind(Name,1,Clock) of
        {Name,Tj}->
            if
                Ti=<Tj->
                  safe(Rest,Clock);
                true->
                    not_safe
            end;
        false->
            false
    end.

