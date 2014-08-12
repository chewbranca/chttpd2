-module(chttpd2_config).

-export([
    dispatch/0,
    web_config/0
]).

-spec dispatch() -> [webmachine_dispatcher:route()].
dispatch() ->
    lists:flatten([
        [load_dispatch(A) || {A,_,_} <- application:which_applications()]
    ]).

web_config() ->
    {ok, App} = application:get_application(?MODULE),
    {ok, Ip} = application:get_env(App, web_ip),
    Port = list_to_integer(config:get("chttpd", "port", "5984")) -1,
    %% {ok, Port} = application:get_env(App, web_port),
    [
        {ip, Ip},
        {port, Port},
        {log_dir, "priv/log"},
        {dispatch, dispatch()}
    ].

load_dispatch(App) ->
    try App:couch_dispatch() of
        Dispatchers ->
            Dispatchers
    catch
        error:undef ->
            []
    end.
