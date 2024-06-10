prova(Soluzione):-
    partenza(S),
    gemma1(Pgemma1),
    gemma2(Pgemma2),
    gemma3(Pgemma3),
    Gemme = [Pgemma1,Pgemma2,Pgemma3],
    sort(Gemme,GemmeOrdinate),
    Totale = [S|GemmeOrdinate],
    ghiaccio(MG),
    ricerca2(0,S,[Totale],Soluzione,Pgemma1,Pgemma2,Pgemma3,0,MG).

ricerca2(_,S,_,[],_,_,_,_,_):-arrivo(S),!.
ricerca2(M,S,Visitati,[Azione|AltreAzioni],Pgemma1,Pgemma2,Pgemma3,Flag,MG):-
    trasformazione(Azione,S,NuovoS,Pgemma1,PNgemma1,Pgemma2,PNgemma2,Pgemma3,PNgemma3,Flag,MG,MGFinale),
    PosizioniGemme = [PNgemma1,PNgemma2,PNgemma3],
    sort(PosizioniGemme,GemmeOrdinate),
    Posizioni=[NuovoS|GemmeOrdinate],
    \+member(Posizioni,Visitati),
    cerca_martello(NuovoS, Flag, FlagNuovo,Visitati,NuovaVistitati),
    controlla_Ghiaccio(NuovoS, FlagNuovo,MGFinale,NuovoMG),
    % write(M),
    % write(Azione),
    % write(Posizioni),nl,
    %format('Visitati \n~w', [Visitati]), nl,
    N is M+1,
    ricerca2(N,NuovoS,[Posizioni|NuovaVistitati],AltreAzioni,PNgemma1,PNgemma2,PNgemma3,FlagNuovo,NuovoMG).