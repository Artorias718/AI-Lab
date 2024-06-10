% #Vincolo: ogni squadra fa riferimento ad una città, che offre la struttura in cui la squadra gioca gli incontri in casa;
squadra_citta(
    squadraRoma1,roma;
    squadraRoma2,roma;
    squadraTorino1,torino;
    squadraTorino2,torino;
    squadraMilano1,milano;
    squadraCatanzaro,catanzaro;
    squadraVerona,verona;
    squadraBologna,bologna;
    squadraBari,bari;
    squadraSalerno,salerno;
    squadraNapoli,napoli;
    squadraFirenze,firenze;
    squadraUdine,udine;
    squadraPadova,padova;
    squadraCatania,catania;
    squadraPalermo,palermo;
).

% numero di giornate totale diviso a metà tra giornate di andata e giornate di ritorno
giornata(1..30).
giornata_di_andata(1..15).
giornata_di_ritorno(16..30).


% uso di aggregati per definire i match tra le squadre per ogni giornata
8{partita(andata,Squadra1,Squadra2,G):squadra_citta(Squadra1,_),squadra_citta(Squadra2,_),Squadra1 != Squadra2}8:-giornata_di_andata(G). 
8{partita(ritorno,Squadra2,Squadra1,G):partita(andata,Squadra1,Squadra2,_)}8:-giornata_di_ritorno(G).




% vincolo per garantire che ogni squadra giochi esattamente una partita in ciascuna giornata del campionato
:-squadra_citta(Squadra,_),giornata(G), #count{Squadra1: partita(_,Squadra,Squadra1,G)}=PC, #count{Squadra2: partita(_,Squadra2,Squadra,G)}=PF, PC+PF !=1.


% vincolo che assicura che ogni partita avvenga una sola volta durante l'intero campionato.  squadra1 vs. sqadra2 != squadra2 vs. squadra1
:- partita(_,Squadra1,Squadra2, G),partita(_,Squadra1,Squadra2, G1), G != G1.

% vincolo che proibisce che due squadre si incontrino due volte durante le giornate di andata, poi similmente per il ritorno
:- partita(andata,Squadra1,Squadra2, G), partita(andata,Squadra2,Squadra1, G1), G != G1.
:- partita(ritorno,Squadra1,Squadra2, G), partita(ritorno,Squadra2,Squadra1, G1), G != G1.



% vincolo due squadre si incontrano in una specifica giornata durante l'andata, allora non possono incontrarsi nella giornata corrispondente del ritorno,
:- partita(andata,Squadra1,Squadra2, G), partita(ritorno,Squadra2,Squadra1, G1), G1 == (G+15).



%Derby: Due delle 20 squadre fanno riferimento alla medesima città e condividono la stessa struttura di gioco, quindi non possono giocare entrambe in casa nella stessa giornata.
%controllo che le due squadre abbiano la stessa città di appartenenza
citta_uguale(Squadra1, Squadra2) :-
    squadra_citta(Squadra1, C1),
    squadra_citta(Squadra2, C2),
    C1 == C2,
    Squadra1 != Squadra2.

% vincolo che proibisce che due squadre della stessa città giochino una partita nella stessa giornata
:- partita(_,Squadra1, _, G), partita(_,Squadra2, _, G), citta_uguale(Squadra1, Squadra2).


% vincolo ciascuna squadra non deve giocare mai più di due partite consecutive in casa o fuori casa;
:- partita(_,_,S,G), partita(_,_,S,G+1), partita(_,_,S,G+2). 
:- partita(_,S,_,G), partita(_,S,_,G+1), partita(_,S,_,G+2).



#show partita/4.