% Definizione delle squadre
squadra_citta(

    udinese,udine;
    padova,padova;
    catania,catania;
    palermo,palermo;
    roma,roma;
    lazio,roma;
    %torino,torino;
    %juventus,torino;
).

numero_squadre(N) :-
   #count {S : squadra_citta(S, _)} = N.

numero_giornate(N) :-
    numero_squadre(NumSquadre),
    N = (NumSquadre - 1) * 2.

giornata(1..N) :-
    numero_giornate(N).

andata(1..X) :-
    numero_giornate(N),
    X = N/2. 

ritorno(X..N) :-
    numero_giornate(N),
    X = (N/2)+1. 

%giornata(1..2).
%andata(1).
%ritorno(2).

N{match(andata,S1,S2,G):squadra_citta(S1,_),squadra_citta(S2,_),S1 != S2}N :-andata(G), numero_squadre(X), N = X/2.
N{match(ritorno,S2,S1,G):match(andata,S1,S2,_)}N :-ritorno(G),numero_squadre(X), N= X/2.


% ogni squadra gioca un solo match per giornata
:-  squadra_citta(Squadra,_),
    giornata(G), 
    #count{S1: match(_,Squadra,S1,G)}=X, 
    #count{S2: match(_,S2,Squadra,G)}=Y, 
    X+Y !=1.

% un match non si ripete nel campionato
:-  match(_,S1,S2, G1),
    match(_,S1,S2, G2), 
    G1 != G2.

% due squadre si scontrano una sola volta all andata 
:-  match(andata,S1,S2, G), 
    match(andata,S2,S1, G1), 
    G != G1.

% due squadre si scontrano una sola volta al ritorno 
:-  match(ritorno,S1,S2, G), 
    match(ritorno,S2,S1, G1), 
    G != G1.

% due squadre che condividono la stessa citta non possono giocari entrambi nella stess giornata
:-  match(_,S1, _, G),
    match(_,S2, _, G), 
    squadra_citta(S1, C1),
    squadra_citta(S2, C2),
    C1 == C2,
    S1 != S2.

% vincolo due squadre si incontrano in una specifica giornata durante l'andata, allora non possono incontrarsi nella giornata corrispondente del ritorno,
%:- match(andata,S1,S2, G), match(ritorno,S2,S1, G1), G1 == (G+15).
% serve? 


% una squadra non può fare più di due match di fila casa
:-  match(_,_,S,G), 
    match(_,_,S,G+1),
    match(_,_,S,G+2). 

% una squadra non può fare più di due match di fila trasferta
:-  match(_,S,_,G), 
    match(_,S,_,G+1), 
    match(_,S,_,G+2).


%#show numero_squadre/1.

#show match/4.