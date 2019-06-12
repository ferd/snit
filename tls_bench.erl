-module(tls_bench).
-mode(compile).

main(_) ->
    os:cmd("epmd -daemon"),
    net_kernel:start(['script@localhost', shortnames]),
    io:format("~p~n", [node()]),
    application:ensure_all_started(ssl),
    {ok, Sock} = ssl:connect(
        {127,0,0,1},
        8080,
        [{server_name_indication, "snihost.custom"},
         {active, false}]
    ),
    loop(Sock, 0, erlang:monotonic_time(millisecond)).

loop(S, N, T0) ->
    case ssl:recv(S, 0) of
        {ok, _Data} ->
            case N >= 10000 of
                true ->
                    T1 = erlang:monotonic_time(millisecond),
                    io:format("10000 packets in ~pms~n", [T1-T0]),
                    loop(S, 0, T1);
                false ->
                    loop(S, N+1, T0)
            end;
        {error, R} ->
            io:format("Stopping for reason ~p~n", [R]),
            halt(0)
    end.

