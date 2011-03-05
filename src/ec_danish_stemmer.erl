%%%-------------------------------------------------------------------
%%% File    : ec_danish_stemmer.erl
%%% Author  : James Lindstorff <james@ind-w510>
%%% Description : Implements a Danish stemmer based on the snowball
%%% See:  http://snowball.tartarus.org/algorithms/danish/stemmer.html
%%%
%%% Created :  1 Mar 2011 by James Lindstorff <james@ind-w510>
%%%-------------------------------------------------------------------
-module(ec_danish_stemmer).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

%% API
-export([stem/1]).

%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% Function: stem
%% Description: Stems a word using the Danish Snowball stemmer.
%%--------------------------------------------------------------------
stem(Word) ->
    LowerWord = string:to_lower(Word),
    {ok, R1, _R2} = regions(LowerWord), %% R2 unused in danish stemmer
    {ok, NewLowerWord, NewR1} = step1a(LowerWord, R1).

%%====================================================================
%% Internal functions
%%====================================================================
regions(Word) ->
    %% Creates the regions R1 and R2 for the stemmer as defined by:
    %% R1 is the region after the first non-vowel following a vowel,
    %% or is the null region at the end of the word if there is no 
    %% such non-vowel.
    %% R2 is the region after the first non-vowel following a vowel
    %% in R1, or is the null region at the end of the word if there
    %% is no such non-vowel.
    R1 = r1(Word),
    %% TODO: R1 is adjusted so that the region before it contains 
    %% at least 3 letters.
    R2 = r1(R1),
    {ok, R1, R2}.

r1([]) ->
    [];
r1(Word) ->
    %% R1 is the region after the first non-vowel following a vowel,
    %% or is the null region at the end of the word if there is no 
    %% such non-vowel.
    [H | T] = Word,
    r1(T, H).
r1([], _Last) ->
    [];
r1([H | T], Last) ->
    PrevVowel = is_vowel(Last),
    CurrVowel = is_vowel(H),
    if
	(PrevVowel == true) and (CurrVowel == false) ->
	    T;
	true -> %% else
	    r1(T, H)
    end.

is_vowel(Character) ->
    %% Classifies the character as being a vowel or not a vowel 
    lists:member(Character, "aeiouyæøå").

step1a(Word, R1) ->
    %% Search for the longest among the following suffixes in R1, 
    %% and perform the action indicated. Which is delete.
    Step1suffix = ["erendes", "erende", "hedens", "endes", "erede", 
		   "erens", "erets", "ernes", "ethed", "heden",
		   "heder", "ered", "ende", "enes", "eren", "erne",
		   "erer", "eres", "eret", "heds", "ene", "ens",
		   "ere", "ers", "ets", "hed", "en", "er", "es",
		   "et", "e"],
    case step1asuffix(Step1suffix, R1) of
	{ok, MatchedSuffix} ->
	    LenMatchSuffix = string:len(MatchedSuffix),
	    LenWord = string:len(Word),
	    LenR1 = string:len(R1),
	    NewWord = string:substr(Word, 1, LenWord - LenMatchSuffix),
	    NewR1 = string:substr(R1, 1, LenR1 - LenMatchSuffix),
	    {ok, NewWord, NewR1};
	{nomatch} ->
	    {ok, Word, R1}
    end.

step1asuffix([], _R1) ->
    {nomatch};

step1asuffix([H | T], R1) ->
    Match = lists:suffix(H, R1),
    if
	Match == true -> 
	    {ok, H};
	true ->
	    step1asuffix(T, R1)
    end.

%%====================================================================
%% Testing
%%====================================================================
-ifdef(TEST).
regions_test() ->
    %% Tests from: http://snowball.tartarus.org/texts/r1r2.html
    ?assertMatch({ok, "iful", "ul"}, regions("beautiful")),
    ?assertMatch({ok, "y", []}, regions("beauty")),
    ?assertMatch({ok, [], []}, regions("beau")),
    ?assertMatch({ok, "imadversion", "adversion"}, regions("animadversion")),
    ?assertMatch({ok, "kled", []}, regions("sprinkled")),
    ?assertMatch({ok, "harist", "ist"}, regions("eucharist")).

regions_bestemmelse_test() ->
    ?assertMatch({ok, "temmelse", "melse"}, regions("bestemmelse")).

step1a_bestemmelse_test() ->
    Word = "bestemmelse",
    {ok, R1, _R2} = regions(Word),
    ?assertMatch({ok, "bestemmels", "temmels"}, step1a(Word, R1)).

step1a_nomatch_test() ->
    ?assertMatch({ok, "nomatch", "nomatch"}, step1a("nomatch", "nomatch")).

-endif.
