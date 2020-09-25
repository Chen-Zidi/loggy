-module(time).
-export([zero/0,inc/2,merge/2,leq/2,clock/1,update/3,safe/2]).

%initialize time stamp
zero()->
    0.

%increase time stamp by 1
inc(_Name,T)->
    T+1.

%merge time stamp with the bigger one
merge(Ti,Tj)->
    if 
        Ti>Tj ->
            Ti;
        true ->
            Tj
        end.

%compare time stamp
leq(Ti,Tj)->
    if
        Tj>=Ti ->
            true;
        true ->
            false
        end.

%initialize clock
clock(Nodes)->
    lists:map(fun(X)->{X,0} end,Nodes).

%update clock
update(Node,Time,Clock)->
    {_, T} = lists:keyfind(Node,1,Clock),
    if 
        T < Time->
            NewClock = lists:delete({Node,T},Clock),
            [{Node,Time}|NewClock];
        true->
            Clock
        end.

%check the safety to print out message
safe(Time,Clock)->
    Result = lists:foldl(fun compare/2, Time,Clock),

if 
Result == Time->
    safe;
true->
    not_safe
end.

%used for comparing the time stamp in the clock
compare({_,X},Y)->
    if 
        X>Y->
            Y;
        true->
            X
        end.