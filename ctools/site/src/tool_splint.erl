%% @author exida
%% @doc

-module(tool_splint).
-author('exida').
-export([get/1, element/1, about/1]).

-include_lib("nitrogen_core/include/wf.hrl").

-define(OUTPUT_ID, splint).
-define(FULLNAME, "splint").
-define(TOOL_CMD, "splint").
-define(TOOL_OPTS, "-I data/include -exportlocal -initallelements -noeffect -linelen 500 +matchanyintegral").
-define(SOURCE_PANEL, splint_source).


get(output_id) -> ?OUTPUT_ID;
get(fullname) -> ?FULLNAME;
get(tool_cmd) -> ?TOOL_CMD;
get(tool_opts) -> ?TOOL_OPTS;
get(source_panel) -> ?SOURCE_PANEL;

get(version) -> 
  Cmd = "splint | head -n1",
  {_, Sout} = launch:launch_exec(Cmd),
  erlang:atom_to_list(Sout).

element(TestCase) ->
    #panel {
        body = [
            gen_source:element(?MODULE, TestCase)
        ]
    }.

about(homepage) -> "";
about(general) -> "";
about(ships) -> "";
about(dependency) -> "";
about(performance) -> "";
about(method) -> "";
about(arch) -> "";
about(limitations) -> "";
about(interface) -> "";
about(usage) -> "";
about(extra) -> "".

