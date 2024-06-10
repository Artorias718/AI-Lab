
prova(Soluzione):-
    partenza(PM),
    gemma1(Pgemma1),
    gemma2(Pgemma2),
    gemma3(Pgemma3),
    Gemme = [Pgemma1,Pgemma2,Pgemma3],
    sort(Gemme,GemmeOrdinate),
    GemmeOrdinate = [NGemma1,NGemma2,NGemma3],
    ghiaccio(MG),
    Stato = [PM,NGemma1,NGemma2,NGemma3,0,MG],
    ampiezza(0,[[Stato,[]]],[],SoluzioneInversa),
    inverti(SoluzioneInversa,Soluzione).


ampiezza(F,[[S,Cammino]|_],_,Cammino):-
    S = [M,_,_,_,_,_],
    arrivo(M),
    write(S),
    write(F).

ampiezza(CC,[[S,Cammino]|Tail],Visitati,Risultato):-
    S = [M,G1,G2,G3,_,MG],
    \+arrivo(M),
    \+member(S,Visitati),!,
    findall(Az,mossePossibili(Az,M,G1,G2,G3,MG),ListaAzioni),
    list_to_set(ListaAzioni, ListaAzioniUniche),
    generaNuoviStati([S,Cammino],ListaAzioniUniche,ListaNuoviStati),
    differenza(ListaNuoviStati,Tail,StatiDaAggiungere),
    append(Tail,StatiDaAggiungere,NuovaTail),
    CD is CC+1,
    ampiezza(CD,NuovaTail,[S|Visitati],Risultato).

ampiezza(CC,[_|Tail],Visitati,Risultato):-
    ampiezza(CC,Tail,Visitati,Risultato).

ampiezza(_,[],_,_) :- abort.


generaNuoviStati(_,[],[]).
generaNuoviStati([S,Cammino],[Az|Tail],[[SNuovo,[Az|Cammino]]|ListaTail]):-%Az,Tail sono le possibili mosse.
    S = [M,G1,G2,G3,Flag,MG],
    trasformazione(Az,M,NuovoM,G1,PNgemma1,G2,PNgemma2,G3,PNgemma3,Flag,MG,MGFinale),
    PosizioniGemme = [PNgemma1,PNgemma2,PNgemma3],
    sort(PosizioniGemme,GemmeOrdinate),
    GemmeOrdinate = [NGemma1,NGemma2,NGemma3],
    cerca_martello_amp(NuovoM, Flag, FlagNuovo),
    controlla_Ghiaccio(NuovoM, FlagNuovo,MGFinale,NuovoMG),
    SNuovo = [NuovoM,NGemma1,NGemma2,NGemma3,FlagNuovo,NuovoMG],
    generaNuoviStati([S,Cammino],Tail,ListaTail).


differenza([],_,[]).
differenza([[S,_]|Tail],B,Risultato):-
    member([S,_],B),!, % Se ho la coppia S in B non l'aggiungo nell'iniseme
    differenza(Tail,B,Risultato).
differenza([[S,Cammino]|Tail],B,[[S,Cammino]|RisTail]):- %se non c'e metto S in testa
    differenza(Tail,B,RisTail).

inverti(L,LInv):-inv(L,[],LInv).
inv([],Temp,Temp).
inv([Head|Tail],Temp,LInv):-inv(Tail,[Head|Temp],LInv).

















