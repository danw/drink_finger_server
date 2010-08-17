%%%-------------------------------------------------------------------
%%% File    : finger_server_sup.erl
%%% Author  : Dan Willemsen <dan@csh.rit.edu>
%%% Purpose : 
%%%
%%%
%%% edrink, Copyright (C) 2008 Dan Willemsen
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%                         
%%% You should have received a copy of the GNU General Public License
%%% along with this program; if not, write to the Free Software
%%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
%%% 02111-1307 USA
%%%
%%%-------------------------------------------------------------------

-module (finger_server_sup).
-behaviour (supervisor).

-export ([start/0, start_link/1, init/1]).

start () ->
    start_link([]).

start_link (Args) ->
    supervisor:start_link({local,?MODULE}, ?MODULE, Args).

init ([]) ->
    case application:get_env(port) of
        {ok, Port} ->
            {ok, {{one_for_one, 10, 3},  % One for one restart, shutdown after 10 restarts within 3 seconds
               [{finger_server,        % Our first child, the drink_machine_listener
                 {dw_gen_listener, start_link, [Port, {finger_server, start_link, []}]},
                 permanent,            % Always restart
                 100,                  % Allow 10 seconds for it to shutdown
                 worker,               % It isn't a supervisor
                 [dw_gen_listener, finger_server]}]}};
        Err ->
            error_logger:error_msg("Unknown port ~p~n", [Err]),
            {error, invalid_port}
    end.
