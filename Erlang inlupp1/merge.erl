-module(merge).
-export([merge_sort/1]).

split(L)->
	split(L, {[],[]}).
split([], {X, Y}) -> 
	{X, Y};
split([H|T], {X, Y}) ->
	split( T, {Y , X++[H]}). 
append(X, Y) ->
	X++Y.
merge(Z, W) ->
	merge(Z,W, []). 
merge([], L, Z) ->
	Z++L;
merge(L, [], Z) ->
	Z++L;
merge([H1|T1], [H2|T2], Z) when H1 >= H2 ->
	merge([H1|T1], T2, Z++[H2]);
merge([H1|T1], [H2|T2], Z) -> 
	merge(T1, [H2|T2],  append(Z, [H1])).
		
merge_sort([]) ->
	[];
merge_sort([A]) ->
	[A];	
merge_sort(L) when is_list(L) ->
	{Lista1, Lista2} = split(L),
	L1 = merge_sort(Lista1),
	L2 = merge_sort(Lista2),
	merge(L1,L2).
		
	

	
	



