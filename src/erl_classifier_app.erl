%%%-------------------------------------------------------------------
%%% File    : erl_classifier_app.erl
%%% Author  : James Lindstorff <james@ind-x301>
%%% Description : Application behaviour for the Naive Bayes Classifier
%%%
%%% Created : 15 Mar 2011 by James Lindstorff <james@ind-x301>
%%%-------------------------------------------------------------------
-module(erl_classifier_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% Application callbacks
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start(Type, StartArgs) -> {ok, Pid} |
%%                                     {ok, Pid, State} |
%%                                     {error, Reason}
%% Description: This function is called whenever an application 
%% is started using application:start/1,2, and should start the processes
%% of the application. If the application is structured according to the
%% OTP design principles as a supervision tree, this means starting the
%% top supervisor of the tree.
%%--------------------------------------------------------------------
start(_Type, _StartArgs) ->
    case erl_classifier_sup:start_link() of
	{ok, Pid} -> 
	    %% Attach the classification event handler
	    ec_handler_classifier:add_handler(),
	    {ok, Pid};
	Other ->
	    {error, Other}
    end.

%%--------------------------------------------------------------------
%% Function: stop(State) -> void()
%% Description: This function is called whenever an application
%% has stopped. It is intended to be the opposite of Module:start/2 and
%% should do any necessary cleaning up. The return value is ignored. 
%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
