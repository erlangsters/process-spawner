%%
%% Copyright (c) 2024, Byteplug LLC.
%%
%% This source file is part of the Erlang Term Validator project which is
%% released under the MIT license. Please refer to the LICENSE.txt file that
%% can be found at the root of the project directory.
%%
%% Written by Jonathan De Wachter <jonathan.dewachter@byteplug.io>, February 2024
%%
-module(spawner).

-export_type([mode/0]).

-export([spawn/2, spawn/3, spawn/4, spawn/5]).
-export([setup/2]).

-type link() ::
    no_link |
    link |
    monitor |
    {monitor, [erlang:monitor_option()]}
.
-type option() ::
    {priority, Level :: erlang:priority_level()} |
    {fullsweep_after, Number :: pos_integer()} |
    {min_heap_size, Size :: pos_integer()} |
    {min_bin_vheap_size, VSize :: pos_integer()} |
    {max_heap_size, Size :: erlang:max_heap_size()} |
    {message_queue_data, MQD :: erlang:message_queue_data()} |
    {async_dist, Enabled :: boolean()}
.
-type mode() :: link() | {link(), [option()]}.

-type spawn_return() :: pid() | {pid(), reference()}.

-spec spawn(mode(), function()) -> spawn_return().
spawn(Mode, Fun) ->
    spawn_opt(mode_to_options(Mode), Fun).

-spec spawn(mode(), node(), function()) -> spawn_return().
spawn(Mode, Node, Fun) ->
    spawn_opt(mode_to_options(Mode), Node, Fun).

-spec spawn(mode(), module(), function(), [term()]) -> spawn_return().
spawn(Mode, Module, Function, Args) ->
    spawn_opt(mode_to_options(Mode), Module, Function, Args).

-spec spawn(mode(), node(), module(), function(), [term()]) -> spawn_return().
spawn(Mode, Node, Module, Function, Args) ->
    spawn_opt(mode_to_options(Mode), Node, Module, Function, Args).

-spec setup(pid(), mode()) -> spawn_return().
setup(_Pid, _Mode) ->
    % XXX: To be implemented.
    ok.

%%
%% Convert our spawn mode to the options suitable for the `spawn_request/x`
%% functions.
%%
-spec mode_to_options(mode()) -> ok.
mode_to_options(Link) when is_atom(Link) ->
    mode_to_options({Link, []});
mode_to_options({monitor, Options}) ->
    mode_to_options({{monitor, Options}, []});
mode_to_options({Link, Options}) ->
    case Link of
        no_link ->
            [];
        link ->
            [link];
        monitor ->
            [monitor];
        {monitor, MonitorOptions0} ->
            [{monitor, MonitorOptions0}]
    end ++ Options.
