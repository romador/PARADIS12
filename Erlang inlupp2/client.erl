-module(client).
-compile(export_all).

start_link() ->
	ok.
listan(OldList, Value) ->
	NewList = OldList ++ [Value],
	NewList.
request(_Pid,[]) ->
	[];
request (Pid, [H|ListOfDocuments]) ->
	%interface:start(),
	[answer([{doc, H}],[]) | request(Pid, ListOfDocuments)].

answer([], Svar)->
	Svar;
answer([{text, Value} | T], Svar) ->
	answer(T, Svar ++ [{text, Value}]);
answer([{Server, Value} | T], Svar) ->
	server ! {self(), make_ref(), Server, Value},
	receive
		{ok, Ref, {doc, Val}} ->
			NySvar = answer(Val, []),
			answer(T, Svar ++ NySvar);
		{ok, Ref, {img, Val}} ->
			answer(T, Svar ++ [{img, Val}]);
		{error, _Ref} ->
			io:format("Fel ! ~n");
		A ->
			io:format("Fel inmatning  ! ~n~p",[A])
	end.
	

		

%request (X) when is_list(X) ->
%	Tmp = dataKoll(X),
%	lists:foreach(Tmp, X).
	
	
