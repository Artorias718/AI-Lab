% %costo delle operazioni eseguite uniforme 
costo(est, 1).
costo(ovest, 1).
costo(nord, 1).
costo(sud, 1).

%calcolo del costo totale del cammino
costoTot([], 0).

% Somma ricorsiva dei costi delle azioni applicate
costoTot([Azione|AltreAzioni], CostoTotale):-
    costoTot(AltreAzioni, CostoParziale),
    costo(Azione, CostoU),
    CostoTotale is CostoParziale + CostoU.

%uso di euristica per trovare la miglior uscita
uscitaEuristica(Attuale, HMigliore):-
  findall(Finale, finale(Finale), ListaUscite),
  uscitaEuristica_C(Attuale, ListaUscite, HMigliore).

%caso singola uscita
uscitaEuristica_C(Attuale, [UscitaAttuale], H):-
  euristica(Attuale, UscitaAttuale, H).


% Passo ricorsivo
%distanza corrente < di quella trovata
uscitaEuristica_C(Attuale, [UscitaAttuale|RestoUscite], DistAttuale):-
  uscitaEuristica_C(Attuale, RestoUscite, HMiglioreParziale),
  euristica(Attuale, UscitaAttuale, DistAttuale),
  DistAttuale < HMiglioreParziale.
 
 %distanza corrente > di quella trovata

 uscitaEuristica_C(Attuale, [UscitaAttuale|RestoUscite], HMiglioreParziale):-
  uscitaEuristica_C(Attuale, RestoUscite, HMiglioreParziale),
  euristica(Attuale, UscitaAttuale, DistAttuale),
  DistAttuale >= HMiglioreParziale.

%Distanza di Manhattan

euristica(pos(Riga1, Colonna1), pos(Riga2, Colonna2), H) :-
  %Manatthan
  H is abs(Riga1-Riga2) + abs(Colonna1-Colonna2).
  %Euclidea
  %H is sqrt((Riga1 - Riga2)^2 + (Colonna1 - Colonna2)^2).

% Aggiornamneto costi
aggiorna_costo_min(TCosto):-
  costo_min(TMin),
  TCosto<TMin,
  retract(costo_min(TMin)),
  assert(costo_min(TCosto)).
  
  % Inizio ricerca
prova(Sol):-
  iniziale(Start),
  uscitaEuristica(Start, SogliaIniziale),
  num_righe(NR),
  num_colonne(NC),
  FCMax is NR * NC,
  assert(costo_min(FCMax)),
  limiteIda(Soluzione, SogliaIniziale, Start),
  reverse(Sol, Soluzione),
  costoTot(Soluzione, CostoCammino),
  write(Soluzione),
  write(CostoCammino).

% Caso cambio di soglia non necessario
limiteIda(Soluzione, Soglia, S_Attuale):-
  ida_C(node(S_Attuale, [], Soglia), Soluzione, [S_Attuale], Soglia).

%N_percorsi = 0 => aggiorno soglia
limiteIda(Soluzione, Soglia, S_Attuale):-
  costo_min(NuovaSoglia),
  retract(costo_min(NuovaSoglia)),
  num_righe(NR),
  num_colonne(NC),
  FCMax is NR * NC,
  assert(costo_min(FCMax)),
  \+NuovaSoglia = Soglia,
  limiteIda(Soluzione, NuovaSoglia, S_Attuale).

%Nodo attuale = finale
ida_C(node(S_Attuale, Azioni, _), Azioni, _, _):-
  finale(S_Attuale).

% Costo <= a soglia si prosegue
ida_C(node(S_Attuale, Azioni, TCosto), Soluzione, Visitati, Soglia):-
  TCosto =< Soglia,
  applicabile(NuovaAzione, S_Attuale),
  muovi(NuovaAzione, S_Attuale, S_Nuovo),
  \+member(S_Nuovo, Visitati),
  uscitaEuristica(S_Attuale, H_Costo),
  costoTot([NuovaAzione|Azioni], CostoU),
  TCostoNuovo is H_Costo + CostoU,
  ida_C(node(S_Nuovo, [NuovaAzione|Azioni], TCostoNuovo), Soluzione, [S_Nuovo|Visitati], Soglia).

% Costo > soglia attuale
ida_C(node(S_Attuale, Azioni, TCosto), Azioni, _, Soglia):-
  TCosto > Soglia,
  aggiorna_costo_min(TCosto),
  finale(S_Attuale).
