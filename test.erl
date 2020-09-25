-module(test).
-export([run/3]).

run(Sleep,Jitter,ClockType)->


    %start loggy
    Log = loggy:start([john,paul,ringo,george],ClockType),
    %generate workers
    A = worker:start(john,Log,13,Sleep,Jitter,ClockType),
    B = worker:start(paul,Log,23,Sleep,Jitter,ClockType),
    C = worker:start(ringo,Log,36,Sleep,Jitter,ClockType),
    D = worker:start(george,Log,49,Sleep,Jitter,ClockType),
    %notify other peers
    worker:peers(A,[B,C,D]),
    worker:peers(B,[A,C,D]),
    worker:peers(C,[A,B,D]),
    worker:peers(D,[A,B,C]),
    %time for sending the message
    timer:sleep(5000),
    %stop loggy and workers
    loggy:stop(Log),
    worker:stop(A),
    worker:stop(B),
    worker:stop(C),
    worker:stop(D).
