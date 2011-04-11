-module(mqueue).
-behaviour(gen_server).
-compile(export_all).

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%
%% Interface
%%

store(ChatId, Msg) ->
	gen_server:call(?MODULE, {store, ChatId, Msg}).

check_for_me(ChatId) ->
	gen_server:call(?MODULE, {check_for_me, ChatId}).

%%
%% gen_sever callbacks
%%
init(_Args) ->
	Tab = ets:new(queue, [protected, duplicate_bag]),
	{ok, Tab}.

handle_call({store, ChatId, Msg}, _From, Tab) ->
	ets:insert(Tab, {ChatId, Msg}),
	{reply, ok, Tab};

handle_call({check_for_me, ChatId}, _From, Tab) ->
	Entries = ets:lookup(Tab, ChatId),
	ets:delete(Tab, ChatId),
	List = [Msg || {_, Msg} <- Entries],
	{reply, {ok, List}, Tab}.
