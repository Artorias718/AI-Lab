%costo delle operazioni eseguite uniforme
costo(sud, 1).  
costo(ovest, 1).
costo(nord, 1).
costo(est, 1).


  prova(Sol):-
  iniziale(Start),
  confrontoeuristico(Start, Costo_Euristica),
  aStar([node(Start, Costo_Euristica, [])], [], Sol),
  reverse(SolOrd, Sol),
  costoPassi(SolOrd, CostoNpassi),
  write(SolOrd),
  write(CostoNpassi).

%-------------------------------------------------------------------------------
%Caso 1: la psoizione attuale è quella finale
aStar([node(Start, _, AzioniEseguite)|_], _, AzioniEseguite):-finale(Start).

% Caso 2:  ricerca di tutte le azioni applicabili-> a partire dal node con costo minore -> chiamata ricorsiva 
aStar([node(Start, CostoFinale, AzioniEseguite)|Coda], Visitati, SolParziale):-
    findall(Azione, applicabile(Azione,Start), Applicabili),
    %write(Applicabili),
    nuoviFigli(node(Start, CostoFinale, AzioniEseguite), Applicabili, [Start|Visitati], Coda, NuovaCoda),
    aStar(NuovaCoda, [Start|Visitati], SolParziale).

%Caso 3: ricerca vuota nessuna soluzione
aStar([], _, _):-
  write("Nessun percorso trovato").

%-------------------------------------------------------------------------------
%Quando non vi sono più azioni applicabili la coda finale sarà quella da usare per la prossima ricerca
nuoviFigli(_, [], _, Coda, Coda).

%caso standard con chiamata ricorsiva
nuoviFigli(node(Start, CostoFinale, AzioniEseguitePerS), [Azione|AltreAzioniEseguite], Visitati, Coda, NuovaCoda):-
    muovi(Azione, Start, NuovaPos),    %viene usato uno dei movimenti possibili 
    \+member(NuovaPos, Visitati),       %controllo nuovo stato mai visitato
    costoPassi(AzioniEseguitePerS, CostoPassi),   %passi effettuati per arrivare alla posizione attuale
    confrontoeuristico(NuovaPos, H),    %contronto tramite l'euristica i costo f per arrivare al miglior stato finale
    CostoFinaleTotale is CostoPassi + H,      
    inCoda(node(NuovaPos, CostoFinaleTotale, [Azione|AzioniEseguitePerS]), Coda, CodaParziale),   %inserimento nuovo nodo in coda con priorità
    nuoviFigli(node(Start, CostoFinale, AzioniEseguitePerS), AltreAzioniEseguite, Visitati, CodaParziale, NuovaCoda). %Chiamata ricorsiva

%Caso muovi fa arrivare in  nodo  di arrivo già visitato quindi viene saltato
nuoviFigli(node(Start, CostoFinale, AzioniEseguitePerS), [_|AltreAzioniEseguite], Visitati, Coda, NuovaCoda):-
    nuoviFigli(node(Start, CostoFinale, AzioniEseguitePerS), AltreAzioniEseguite, Visitati, Coda, NuovaCoda).

%-------------------------------------------------------------------------------

disteu(pos(X1, Y1), pos(Xfinale, Yfinale), Distanza):-
  %Manatthan
  %Distanza is abs(X1-Xfinale) + abs(Y1-Yfinale).
  %Euclidea
  Distanza is sqrt((X1 - Xfinale)^2 + (Y1 - Yfinale)^2).
    

%-------------------------------------------------------------------------------
% 0 passi il costo è 0
costoPassi([], 0).

% Somma di tutti i passi effettuati per arrivare al punto attuale ricorsivamente
costoPassi([Azione|AltreAzioniEseguite], CostoPassi_totale):-
  costoPassi(AltreAzioniEseguite, CostoPassi_parziale),
  costo(Azione, CostoPassi),
  CostoPassi_totale is CostoPassi_parziale + CostoPassi.

%-------------------------------------------------------------------------------
%Inserimento figli nella coda

inCoda(node(Start, CostoFinale, AzioniEseguite), CodaAttuale, NuovaCoda):-
  nonIncoda(Start, CodaAttuale),
  inCodaNuovo(node(Start, CostoFinale, AzioniEseguite), CodaAttuale, NuovaCoda).

inCoda(node(Start, CostoFinale, AzioniEseguite), CodaAttuale, NuovaCoda):-
  \+nonIncoda(Start, CodaAttuale),
  confrontoNodi(node(Start, CostoFinale, AzioniEseguite), CodaAttuale, CodaParziale),
  inCodaNuovo(node(Start, CostoFinale, AzioniEseguite), CodaParziale, NuovaCoda).
%-------------------------------------------------------------------------------
% se la coda è vuota l'elemento sarà inserito all'inizio della testa
inCodaNuovo(node(Start, CostoFinale, AzioniEseguite), [], [node(Start, CostoFinale, AzioniEseguite)]).

%se il nuovo elemento è un nuovo minimo viene inserito all'TestaInzio
inCodaNuovo(node(Start, CostoFinale, AzioniEseguite),
                [node(TestaInzio, CostoFinale_minimo, Azionitesta) | RestoCoda],
                [node(Start, CostoFinale, AzioniEseguite), node(TestaInzio, CostoFinale_minimo, Azionitesta) | RestoCoda]) :-
  CostoFinale =< CostoFinale_minimo.

% se il nuovo elemento non è un nuovo minimo si scorre ricorsivamente la coda per arrivare al punto in cui l'elemento va posizionato
inCodaNuovo(node(Start, CostoFinale, AzioniEseguite),
                [node(TestaInzio, CostoFinale_minimo, Azionitesta) | RestoCodaParziale],
                [node(TestaInzio, CostoFinale_minimo, Azionitesta) | RestoCoda]) :-
  inCodaNuovo(node(Start, CostoFinale, AzioniEseguite), RestoCodaParziale, RestoCoda).

%-------------------------------------------------------------------------------
%caso in cui vi sia un nodo già visitato quindi viene visto quello con il costo minore e mantenuto
confrontoNodi(node(Start, CostoFinale, _),
                    [node(TestaInzio, CostoFinale_testa, _) | RestoCoda],
                    RestoCoda) :-
  confrontoPosizione(Start, TestaInzio),
  CostoFinale < CostoFinale_testa.

confrontoNodi(node(Start, CostoFinale, _),
                    [node(TestaInzio, CostoFinale_testa, _) | RestoCoda],
                    [node(TestaInzio, CostoFinale_testa, _) | RestoCodaNuova]) :-
  \+confrontoPosizione(Start, TestaInzio),
  confrontoNodi(node(Start, CostoFinale, _), RestoCoda, RestoCodaNuova).
%-------------------------------------------------------------------------------
%controllo che il nuovo elemento da inserire non sia in coda  
nonIncoda(_, []).

nonIncoda(NuovaPos, [node(TestaInzio, _, _) | RestoCoda]):-
  \+confrontoPosizione(NuovaPos, TestaInzio),
  nonIncoda(NuovaPos, RestoCoda).

confrontoPosizione(pos(X1, Y1), pos(X2, Y2)):-
  X1 = X2,
  Y1 = Y2.

%-------------------------------------------------------------------------------
%utilizzo della funziona euristica per trovare la possibile uscita più vicina 
confrontoeuristico(Attuale, H):-
  findall(Finale, finale(Finale), ListaGoal),
  calcoloDistEuristicaMigliore(Attuale, ListaGoal, H).

%caso in cui vi sia una sola soluzione in elenco
calcoloDistEuristicaMigliore(Attuale, [UscitaCorrente], H):-
  disteu(Attuale, UscitaCorrente, H).

%utilizzo ricrsivo della distanza euristica con tutte le possibili uscita
calcoloDistEuristicaMigliore(Attuale, [UscitaCorrente|RestoUscite], Hcorrente):-
  calcoloDistEuristicaMigliore(Attuale, RestoUscite, HMiglioreparziale),
  disteu(Attuale, UscitaCorrente, Hcorrente),
  Hcorrente < HMiglioreparziale.

calcoloDistEuristicaMigliore(Attuale, [UscitaCorrente|RestoUscite], HMiglioreParziale):-
  calcoloDistEuristicaMigliore(Attuale, RestoUscite, HMiglioreParziale),
  disteu(Attuale, UscitaCorrente, Hcorrente),
  Hcorrente >= HMiglioreParziale.
