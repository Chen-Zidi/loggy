-module(worker).
-export([start/6,stop/1,peers/2]).

%start a new worker process
start(Name,Logger,Seed,Sleep,Jitter,TModule)->
    spawn_link(fun()-> init(Name,Logger,Seed,Sleep,Jitter,TModule) end).

%stop the process
stop(Worker)->
    Worker!stop.

%initialize
init(Name,Log,Seed,Sleep,Jitter,TModule)->
    random:seed(Seed,Seed,Seed),
    receive
        {peers,Peers}->

            loop(Name,Log,Peers,Sleep,Jitter,TModule:zero(),TModule);
        stop->
            ok
        end.

%worker sends message to peers
peers(Wrk,Peers)->
    Wrk!{peers,Peers}.

%worker wait for peer message
%after receiving message, worker send the message to logger
loop(Name,Log,Peers,Sleep,Jitter,Stamp,TModule)->
    %generate a random wait time
    Wait = rand:uniform(Sleep),
    %if a message is received, then send to the loggy
    receive 
        {msg,Time,Msg}->

            NewTime = TModule:inc(Name,TModule:merge(Time,Stamp)),



            Log!{log,Name,NewTime,{received,Msg}},
            loop(Name,Log,Peers,Sleep,Jitter,NewTime,TModule);
        stop->
            ok;
        Error->
            Log!{log,Name,time,{error,Error}}
        %after waiting for a random time, if there is no message comes, 
        %then send message and time to a random peer
        after Wait->
            Selected = select(Peers),
            %Time = na,
            Message = {hello,rand:uniform(100)},

            NewStamp = TModule:inc(Name,Stamp),

            %send to random peer
            Selected!{msg,NewStamp,Message},
           


            %sleep
            jitter(Jitter),
            %send to the logger
            Log!{log,Name,NewStamp,{sending,Message}},

            
            loop(Name,Log,Peers,Sleep,Jitter,NewStamp,TModule)
        end.

%select a random peer
select(Peers)->
    lists:nth(rand:uniform(length(Peers)),Peers).

%sleep for a random time
%how activ the worker is sending the message
jitter(0)->ok;
jitter(Jitter)->
    timer:sleep(rand:uniform(Jitter)).
