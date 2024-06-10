direzione(nord).
direzione(sud).
direzione(est).
direzione(ovest).

applicabile(nord, pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci):-
R>1,
RS is R-1,
\+muro(pos(RS,C)),
pos(RS,C)\= pos(R1,C1),
pos(RS,C)\= pos(R2,C2),
pos(RS,C)\= pos(R3,C3),
    \+member(pos(RS, C), NewGhiacci).

applicabile(sud, pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci):-
num_righe(NR),
R<NR,
RS is R+1,
\+muro(pos(RS,C)),
pos(RS,C)\= pos(R1,C1),
pos(RS,C)\= pos(R2,C2),
pos(RS,C)\= pos(R3,C3),
\+member(pos(RS, C), NewGhiacci).

applicabile(est, pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci):-
num_righe(NC),
C<NC,
CD is C+1,
\+muro(pos(R,CD)),
pos(R,CD)\= pos(R1,C1),
pos(R,CD)\= pos(R2,C2),
pos(R,CD)\= pos(R3,C3),
\+member(pos(R, CD), NewGhiacci).

applicabile(ovest, pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci):-
C>1,
CS is C-1,
\+muro(pos(R,CS)),
pos(R,CS)\=pos(R1,C1),
pos(R,CS)\=pos(R2,C2),
pos(R,CS)\=pos(R3,C3),
\+member(pos(R, CS), NewGhiacci).



trasformazione(A,pos(R,C), PFin, pos(R1,C1),PFinG1,pos(R2,C2),PFinG2,pos(R3,C3),PFinG3,Flag,NewGhiacci,FinNewGhiacci):-
(
(%si sposta il mostro
controlla_Ghiaccio_in_rotta(A,pos(R,C),Flag,NewGhiacci, NuovoMG),
applicabile(A,pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NuovoMG),
spostamento(A,pos(R,C),NuovaPos,pos(R1,C1),pos(R2,C2),pos(R3,C3),NuovoMG),
trasformazione(A,NuovaPos, PFin, pos(R1,C1),PFinG1,pos(R2,C2),PFinG2,pos(R3,C3),PFinG3,Flag,NuovoMG,FinNewGhiacci));

(%si sposta la prima gemma
applicabile(A,pos(R1,C1), pos(R,C),pos(R2,C2),pos(R3,C3),NewGhiacci),
spostamento(A,pos(R1,C1),NewPG1, pos(R,C),pos(R2,C2),pos(R3,C3),NewGhiacci),
trasformazione(A,pos(R,C), PFin,NewPG1,PFinG1,pos(R2,C2),PFinG2,pos(R3,C3),PFinG3,Flag,NewGhiacci,FinNewGhiacci));

(%si sposta la seconda gemmma
applicabile(A,pos(R2,C2),pos(R,C),pos(R1,C1),pos(R3,C3),NewGhiacci),
spostamento(A,pos(R2,C2),NPosGemma2, pos(R,C),pos(R1,C1),pos(R3,C3),NewGhiacci),
trasformazione(A,pos(R,C), PFin,pos(R1,C1),PFinG1,NPosGemma2,PFinG2,pos(R3,C3),PFinG3,Flag,NewGhiacci,FinNewGhiacci));

(%si sposta la terza gemma
applicabile(A,pos(R3,C3),pos(R,C),pos(R1,C1),pos(R2,C2),NewGhiacci),
spostamento(A,pos(R3,C3),NPosGemma3, pos(R,C),pos(R1,C1),pos(R2,C2),NewGhiacci),
trasformazione(A,pos(R,C), PFin,pos(R1,C1),PFinG1,pos(R2,C2),PFinG2,NPosGemma3,PFinG3,Flag,NewGhiacci,FinNewGhiacci))
).


trasformazione(A,pos(R,C),pos(R,C),pos(R1,C1),pos(R1,C1),pos(R2,C2),pos(R2,C2),pos(R3,C3),pos(R3,C3),_,NewGhiacci,NewGhiacci):-
\+applicabile(A,pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci),
\+applicabile(A,pos(R1,C1),pos(R,C),pos(R2,C2),pos(R3,C3),NewGhiacci),
\+applicabile(A,pos(R2,C2),pos(R,C),pos(R1,C1),pos(R3,C3),NewGhiacci),
\+applicabile(A,pos(R3,C3),pos(R,C),pos(R1,C1),pos(R2,C2),NewGhiacci).


spostamento(A,pos(R,C),NuovaPos,pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci):-
(
(A = nord,
applicabile(nord,pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci),
RS is R-1,
spostamento(nord,pos(RS,C),NuovaPos,pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci)
);
(A = sud,
applicabile(sud,pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci),
RS is R+1,
spostamento(sud,pos(RS,C),NuovaPos,pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci)
);
(A = est,
applicabile(est,pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci),
ColonnaDX is C+1,
spostamento(est,pos(R,ColonnaDX),NuovaPos,pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci)
);
(A = ovest,
applicabile(ovest,pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci),
ColonnaSX is C-1,
spostamento(ovest,pos(R,ColonnaSX),NuovaPos,pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci)
)).

spostamento(A,pos(R,C),pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci):-
\+applicabile(A,pos(R,C),pos(R1,C1),pos(R2,C2),pos(R3,C3),NewGhiacci).


cerca_martello(pos(X,Y),0,FlagNuovo,_,NuovaVistitati) :-
    martello(pos(A,B)),
    X = A, 
    Y=B,
    write('sei affianco al martello\n'),
    FlagNuovo is 1,
    NuovaVistitati = [].

cerca_martello(_, 1, 1,Visitati,Visitati) :- !.
cerca_martello(_, 0, 0,Visitati,Visitati) :- !.


controlla_Ghiaccio(pos(X,Y),1,NewGhiacci,NuovoMG) :-
    member(pos(A,B), NewGhiacci), 
    (
        (X = A, (Y is B - 1; Y is B + 1));
        (Y = B, (X is A - 1; X is A + 1))
    ),
    delete(NewGhiacci, pos(A,B), NuovoMG).


controlla_Ghiaccio(_, 0, NewGhiacci,NewGhiacci).

controlla_Ghiaccio(_, 1, NewGhiacci,NewGhiacci):-!.

controlla_Ghiaccio_in_rotta(_,_,0,NewGhiacci,NewGhiacci):-!.

controlla_Ghiaccio_in_rotta(Az,pos(X,Y), 1, NewGhiacci, NuovoMG) :- 
    Az = ovest,
    member(pos(A,B), NewGhiacci), 
    X = A,
    C is Y - 1,
    B = C,
    delete(NewGhiacci, pos(A,B), NuovoMG).

controlla_Ghiaccio_in_rotta(Az, pos(X,Y), 1, NewGhiacci, NuovoMG) :- 
    Az = nord,
    member(pos(A,B), NewGhiacci), 
    Y = B,
    R is X - 1,
    A = R,
    delete(NewGhiacci, pos(A,B), NuovoMG).

controlla_Ghiaccio_in_rotta(Az,pos(X,Y), 1, NewGhiacci, NuovoMG) :- 
    Az = sud,
    member(pos(A,B), NewGhiacci), 
    Y = B,
    R is X + 1,
    A = R,
    delete(NewGhiacci, pos(A,B), NuovoMG).

controlla_Ghiaccio_in_rotta(Az,pos(X,Y), 1, NewGhiacci, NuovoMG) :- 
    Az = est,
    member(pos(A,B), NewGhiacci), 
    X = A,
    C is Y + 1,
    B = C,
    delete(NewGhiacci, pos(A,B), NuovoMG).

controlla_Ghiaccio_in_rotta(_,_, 1,NewGhiacci,NewGhiacci).