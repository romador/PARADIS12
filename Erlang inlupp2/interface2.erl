-module(interface2).
-define(REG_NAME, server).
-compile(export_all).

start() ->
	{Pid,Ref} = spawn_monitor(?MODULE, loop,[dbserver:start(), docserver:start(),
	imgserver:start(),dict:new()]),
	try
	register(?REG_NAME, Pid),
	demonitor(Ref,[flush])
	catch
	A:B->
		case whereis(?REG_NAME) of
		RP when is_pid(RP) ->
		    {ok, already_started};
		undefined ->
			io:format("~p:~p~n", [A,B]),
		    {error}
	    end
	end,
	Pid.
	
stop() ->
    Ref = monitor(process,?REG_NAME),
    try
	?REG_NAME ! stop,
	receive
	    {'DOWN',Ref,process,{?REG_NAME,_},_} ->
		{ok,stopped}
	after 3000 ->
		exit(whereis(?REG_NAME),kill),
		receive
		    {'DOWN',Ref,process,_,_} ->
			{ok,killed}
		after 3000 ->
			demonitor(Ref,[flush]),
			{error, timeout}
		end
	end
    catch
	_:_ ->
	    demonitor(Ref,[flush]),
	    {error, noproc}
    end.

proc(DB,DOC,IMG,From, Reqid, ReqTag, Value) ->
	
	 Ref = make_ref(),
		case ReqTag of
			doc ->
				DOC ! {self(), Ref, get, Value};
			img ->
				{V, We, Ha} = Value,
				IMG ! {self(), Ref, get, V, We, Ha};
			dbquery ->
				DB ! {self(), Ref, get, Value};
			ReqTag ->
				io:format("~n******-------- FEL Server---------*******   ~p~n", [ReqTag])
			
		end,
		receive
				%NewDict = dict:store(Ref,{From, Reqid, ReqTag},Actors);
			
			{ok,Ref, Val} ->
				case ReqTag of
					dbquery ->
						{A,B} = Val,
						if 
							B =:= [] ->
								From ! {ok, Reqid,{doc,[{text, A}]}};
					
							true ->		
								An = length(B),
								if
									An =:= 1 ->
										[X] = B,
										if
											is_list(A) and is_list(X) ->
												From ! {ok, Reqid,{doc,[{text, A},{text, X}]}};
											is_list(X) ->
												From ! {ok, Reqid,{doc,[{dbquery, A},{text, X}]}};
											is_list(A) ->
												From ! {ok, Reqid,{doc,[{text, A},{dbquery, X}]}};
											true ->
												From ! {ok, Reqid,{doc,[{dbquery, A},{dbquery, X}]}}
										end;
									true ->	
										[H,T] = B,
										if 
											T /= [] ->
												From ! {ok, Reqid,{doc,[{text, A},{dbquery,H}, {dbquery, T}]}};
											true ->
												if
													is_list(A) and is_list(H) ->
														From ! {ok, Reqid,{doc,[{text, A},{text, H}]}};
													is_list(H) ->
														From ! {ok, Reqid,{doc,[{dbquery, A},{text, H}]}};
													is_list(A) ->
														From ! {ok, Reqid,{doc,[{text, A},{dbquery, H}]}};
													true ->
														From ! {ok, Reqid,{doc,[{dbquery, A},{dbquery, H}]}}
												end
										end
								end
						end;
					ReqTag ->
						From ! {ok, Reqid,{ReqTag, Val}}
				end;
			
			A ->
				io:format("Fel~p~n ", [A])
		
		end.
	
loop(DB, DOC, IMG, Actors) ->	
    receive
	{From,Reqid,ReqTag,Value} ->
		spawn_link(?MODULE,proc,[DB, DOC, IMG, From, Reqid, ReqTag, Value]),
		loop(DB, DOC, IMG, Actors);
	stop ->
		dbserver:stop(DB),
		docserver:stop(DOC),
		imgserver:stop(IMG);
		
	A ->
		io:format("~n Fel inmatning: ~p~n", [A]),
		loop(DB, DOC, IMG, Actors)
	end.

	