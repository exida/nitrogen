% Nitrogen Web Framework for Erlang
% Copyright (c) 2008-2009 Rusty Klophaus
% See MIT-LICENSE for licensing information.

% This is a "simple as possible" session handler. Unfortunately,
% due to time constraints, had to leave out some great code
% contributed by Dave Peticolas that fit Nitrogen sessions
% into a gen_server. My code below is far inferior. 
% Someone please make it better! - Rusty

-module (simple_session_handler).
-include ("wf.inc").
-behaviour (session_handler).
-export ([
	init/2, 
	finish/2,
	get_value/4, 
	set_value/4, 
	clear_all/2
]).
-record (state, {unique, node}).

init(_Config, _State) -> 
	% Get the session cookie and node...
	State = case wf:depickle(wf:cookie("wf")) of
		undefined -> new_state();
		Other -> Other
	end,
	{ok, State}.

finish(_Config, State) -> 
	% Drop the session cookie...
	Timeout = wf:config_default(session_timeout, 20),
	ok = wf:cookie("wf", wf:pickle(State), "/", Timeout),
	{ok, []}.
	
get_value(Key, DefaultValue, Config, State) -> 
	{ok, Pid} = get_session_pid(Config, State),
	Ref = make_ref(),
	Pid!{get_value, Key, self(), Ref},
	Value = receive 
		{ok, undefined, Ref} -> DefaultValue;
		{ok, Other, Ref} -> Other
	end,
	{ok, Value, State}.
	
set_value(Key, Value, Config, State) -> 
	{ok, Pid} = get_session_pid(Config, State),
	Ref = make_ref(),
	Pid!{set_value, Key, Value, self(), Ref},
	receive {ok, OldValue, Ref} -> ok end,	
	{ok, OldValue, State}.
	
clear_all(Config, State) -> 
	{ok, Pid} = get_session_pid(Config, State),
	Ref = make_ref(),
	Pid!{clear_all, self(), Ref},
	receive {ok, Ref} -> ok end,	
	{ok, State}.
	
get_session_pid(_Config, State) ->
  Timeout = wf:config_default(nitrogen_session_timeout, 20),
  F = fun() -> session_loop([], Timeout) end,
  SessionTag = {session, State#state.unique},
  {ok, _Pid} = process_registry_handler:get_pid(SessionTag, F).
  
session_loop(Session, Timeout) ->
	receive
		{get_value, Key, Pid, Ref} ->
			Value = case lists:keysearch(Key, 1, Session) of
				{value, {Key, V}} -> V;
				false -> undefined
			end,
			Pid!{ok, Value, Ref},
			session_loop(Session, Timeout);
			
		{set_value, Key, Value, Pid, Ref} ->
			OldValue = case lists:keysearch(Key, 1, Session) of
				{value, {Key, V}} -> V;
				false -> undefined
			end,
			Session1 = lists:keystore(Key, 1, Session, {Key, Value}),
			Pid!{ok, OldValue, Ref},
			session_loop(Session1, Timeout);			
			
		{clear_all, Pid, Ref} ->
			Pid!{ok, Ref},
			session_loop([], Timeout)	
				
	after Timeout * 60 * 1000 -> 
			exit(timed_out)
	end.

new_state() ->
  Unique = erlang:md5(term_to_binary({now(), erlang:make_ref()})),
  #state { unique=Unique }.
