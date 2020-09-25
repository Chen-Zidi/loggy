-module(loggy).
-export([start/2,stop/1,sort/3]).

%start a new process
start(Nodes,TModule) -> 
    spawn_link(fun() -> init(Nodes,TModule) end).

%logger send the stop message to stop the log
stop(Logger)->
    Logger!stop.

%initialize
init(Nodes,TModule)->

    Clock = TModule:clock(Nodes),
    loop(Clock,[],TModule).

%keep listening
loop(Clock,MsgQueue,TModule)->
    receive
        {log,From,Time,Msg} ->


            NewClock = TModule:update(From,Time,Clock),
            %io:format("clock: ~w~n",[NewClock]),
            
            %TempMsgQueue = lists:keysort(2,lists:append([{Msg,Time}],MsgQueue)),
            TempMsgQueue = sort({{From,Msg},Time},MsgQueue,TModule),

            %io:format("MessageQueue: ~w~n",[ TempMsgQueue]),

            %print the message if the time stamp is safe
            NewQueue = processQueue(NewClock,TempMsgQueue,TModule),
 %           NewQueue = lists:takewhile(fun({M,T})->
 %               Safe = TModule:safe(T,NewClock),

 %                if
 %               Safe == safe->
  %                  log(From,NewClock,TempMsgQueue,Time,M),
  %                  false;
  %              true->
  %                  true
  %              end
   %             end,TempMsgQueue),

            loop(NewClock,NewQueue,TModule);
        stop->
            ok
        end.

%put  the new message into the queue and sort
sort({Msg,Time},[],_TModule)->
    [{Msg,Time}];
sort({Msg,Time},[{M,T}|Rest],TModule)->
    Less = TModule:leq(Time,T),
    if
        Less == true->
            [{Msg,Time},{M,T}|Rest];
            %Head = [{Msg,Time}|{M,T}],
            %lists:append(Head,Rest);
        true->
            %lists:append([{M,T}],sort({Msg,Time},Rest,TModule))
            [{M,T}|sort({Msg,Time},Rest,TModule)]
        end.


%process the queue
processQueue(_,[],_)->
    [];
processQueue(Clock,[{{From,Message},Time}|Rest],TModule)->
    Safe = TModule:safe(Time,Clock),
    if 
        Safe == safe->

             log(From,Clock,Time,Message),
             processQueue(Clock,Rest,TModule);
        true->
            [{{From,Message},Time}|Rest]
        end.

%print the message, sender and time
log(From,_Clock,Time,Msg)->
    io:format("log:time stamp:~w from:~w message:~p~n",[Time,From,Msg]).
