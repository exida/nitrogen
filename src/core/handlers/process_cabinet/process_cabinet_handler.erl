% Nitrogen Web Framework for Erlang
% Copyright (c) 2008-2009 Rusty Klophaus
% See MIT-LICENSE for licensing information.

-module (process_cabinet_handler).
-export ([
	behaviour_info/1,
	get_pid/2,
	get_pid/3
]).



% get_pid(Key, Context, State) -> {ok, Pid, NewContext, NewState}.
% Get the process associated with this Key.
get_pid(Key, Context) ->
	_Pid = wf_context:apply_return_raw(process_cabinet, get_pid, [Key], Context).

% get_pid(Key, Function, Context, State) -> {ok, Pid, NewContext, NewState}.	
% Return the process associated with Key. If that process does not
% exist, then create a new process and associate it with Key.
get_pid(Key, Function, Context) ->
	{ok, _Pid, _NewContext} = wf_context:apply(process_cabinet, get_pid, [Key, Function], Context).

		

behaviour_info(callbacks) -> [
	{init, 2},      
	{finish, 2},
	{get_pid, 3},
	{get_pid, 4}
];

behaviour_info(_) -> undefined.