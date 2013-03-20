-module(boolean).
-export([b_not/1, b_and/2, b_or/2, b_nand/2]).

b_not(false) ->
	true;
b_not(true) ->
	false. 

b_and(A,B) ->
	{true,true} =:= {A,B}.

b_or(A,A) ->
	A =:= true;
b_or(A,B) ->
	true.

b_nand(A,B) ->
	b_not(b_and(A,B)).

	