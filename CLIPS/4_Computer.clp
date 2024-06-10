;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------

(defmodule AGENT (import MAIN ?ALL) (import GAME ?ALL) (export ?ALL))


(deftemplate last-guess
   (slot step)
   (multislot guess)
   (slot mp)
   (slot rp)
)


(deftemplate possible-colors
(slot position)
(multislot colors)
)


 ;; PRIMO TENTATIVO, PROVO 4 COLORI DIVERSI
(defrule first-guess
    (status (step ?s&0) (mode computer))
    =>
    (bind ?colors (create$ blue green red yellow orange white black purple))

    (assert (possible-colors (position 1) (colors ?colors)))
    (assert (possible-colors (position 2) (colors ?colors)))
    (assert (possible-colors (position 3) (colors ?colors)))
    (assert (possible-colors (position 4) (colors ?colors)))
    
    ;; Selezioniamo casualmente un colore e otteniamo il suo indice
    (bind ?index1 (random 1 (length$ ?colors)))
    (bind ?guess1 (nth$  ?index1 ?colors))
    (bind ?colors (delete$ ?colors ?index1 ?index1)) ; Rimuoviamo l'elemento dalla lista
    
    ;; Selezioniamo casualmente un altro colore e otteniamo il suo indice
    (bind ?index2 (random 1 (length$ ?colors)))
    (bind ?guess2 (nth$ ?index2 ?colors))
    (bind ?colors (delete$ ?colors ?index2 ?index2)) ; Rimuoviamo l'elemento dalla lista
    
    ;; Selezioniamo casualmente un altro colore e otteniamo il suo indice
    (bind ?index3 (random 1 (length$ ?colors)))
    (bind ?guess3 (nth$ ?index3 ?colors))
    (bind ?colors (delete$ ?colors ?index3 ?index3)) ; Rimuoviamo l'elemento dalla lista
    
    ;; Selezioniamo casualmente un altro colore e otteniamo il suo indice
    (bind ?index4 (random 1 (length$ ?colors)))
    (bind ?guess4 (nth$ ?index4 ?colors))
    
    ;; Costruiamo la sequenza di indovinamento e la asseriamo
    (bind ?guess (create$ ?guess1 ?guess2 ?guess3 ?guess4))
    (assert (guess (step ?s) (g ?guess)))
    (assert (last-guess (step ?s) (guess ?guess) ))

    ;; Stampiamo il debug
    (printout t "step " ?s crlf)
    (printout t "Debug: Generated guess " ?guess crlf)
    
    (pop-focus)
)

 
;; HO ALMENTO 2 MISS PLACED, RIMESCOLO I COLORI FINO A CHE NON HO SOLO RIGHT PLACE
(defrule recombined-guess
    (status (step ?s&~0) (mode computer))
    (answer (step ?sp) (right-placed ?rp) (miss-placed ?mp))
    (test (= ?sp (- ?s 1)))
    (guess (step ?sp) (g $?prev-guess))
    (test (> (+ ?rp ?mp) 1))
    (test (> ?rp  0))
    (test (neq (+ ?rp ?mp) ?rp)) ;SI ATTIVA SOLO SE I CI SONO MISS PLACE 
    ?lg <- (last-guess)

    ?p1 <- (possible-colors (position 1) (colors $?p1colors))
    ?p2 <- (possible-colors (position 2) (colors $?p2colors))
    ?p3 <- (possible-colors (position 3) (colors $?p3colors))
    ?p4 <- (possible-colors (position 4) (colors $?p4colors))

    =>
    (printout t "step " ?s crlf)

    ;;(printout t "RECOMBINE" crlf)

    (retract ?lg)

    (assert 
    (last-guess 
    (step ?sp)
    (guess ?prev-guess)
    (mp ?mp)
    (rp ?rp)
    ))

    ;; controllo che mescolandosi i colori non vanno in posizioni in cui so già che è sbagliato
    (bind ?all-guess-valid FALSE)
    (while (not ?all-guess-valid) do
      (bind ?guess-valid-1 FALSE)
      (bind ?guess-valid-2 FALSE)
      (bind ?guess-valid-3 FALSE)
      (bind ?guess-valid-4 FALSE)


      (bind ?r-index1 (random 1 (length$ ?prev-guess)))
      (bind ?guess1 (nth$  ?r-index1 ?prev-guess))
      (if (member$ ?guess1 ?p1colors)
        then
            (bind ?guess-valid-1 TRUE)
      )


      (bind ?r-index2 (random 1 (length$ ?prev-guess)))
      (bind ?guess2 (nth$  ?r-index2 ?prev-guess))
      (if (and (not (member$ ?guess2 (create$ ?guess1))) (member$ ?guess2 ?p2colors))
        then
            (bind ?guess-valid-2 TRUE)
      )


      (bind ?r-index3 (random 1 (length$ ?prev-guess)))
      (bind ?guess3 (nth$  ?r-index3 ?prev-guess))
      (if (and (not (member$ ?guess3 (create$ ?guess1 ?guess2))) (member$ ?guess3 ?p3colors))
        then 
            (bind ?guess-valid-3 TRUE)
      )


      (bind ?r-index4 (random 1 (length$ ?prev-guess)))
      (bind ?guess4 (nth$  ?r-index4 ?prev-guess))
      (if (and (not (member$ ?guess4 (create$ ?guess1 ?guess2 ?guess3))) (member$ ?guess4 ?p4colors))
        then
            (bind ?guess-valid-4 TRUE)
      )

     ;; Costruiamo la sequenza di indovinamento  
     (bind ?guess (create$ ?guess1 ?guess2 ?guess3 ?guess4))


     (if (and ?guess-valid-1 ?guess-valid-2 ?guess-valid-3 ?guess-valid-4)
       then
       (if (eq (find-fact ((?g guess)) (eq ?g ?guess)) (create$))
         then
         (bind ?all-guess-valid TRUE)
        )
     )
     )

    (assert (guess (step ?s) (g ?guess)))
    
    ;; Stampiamo il debug
    (printout t "Generated guess " ?guess crlf)
    
    (pop-focus)
)


;; PRIMO TENTATIVO SFORTUNATO, PROVO I COLORI DIVERSI
(defrule bad-start-guess
    (status (step 1) (mode computer))
    (answer (step 0) (right-placed ?rp) (miss-placed ?mp))
    (guess (step 0) (g $?prev-guess))
    (test (eq ?rp 0))
    (test (<  ?mp 2))
    ?lg <- (last-guess)
    =>

    (printout t "step 1" crlf)

    ;;(printout t "BAD START" crlf)

    (retract ?lg)
    (assert 
    (last-guess 
    (step 0) 
    (guess ?prev-guess)
    (mp ?mp)
    (rp ?rp)
    )
    )

    (bind ?colors (create$ blue green red yellow orange white black purple))

    (bind ?first-color (nth$ 1 ?prev-guess))
    (bind ?index1 (member$ ?first-color ?colors))
    (bind ?colors (delete$ ?colors ?index1 ?index1))

    (bind ?second-color (nth$ 2 ?prev-guess))
    (bind ?index2 (member$ ?second-color ?colors))
    (bind ?colors (delete$ ?colors ?index2 ?index2))

    (bind ?third-color (nth$ 3 ?prev-guess))
    (bind ?index3 (member$ ?third-color ?colors))
    (bind ?colors (delete$ ?colors ?index3 ?index3))

    (bind ?fourth-color (nth$ 4 ?prev-guess))
    (bind ?index4 (member$ ?fourth-color ?colors))
    (bind ?colors (delete$ ?colors ?index4 ?index4))


    ;; Selezioniamo casualmente un colore e otteniamo il suo indice
    (bind ?index1 (random 1 (length$ ?colors)))
    (bind ?guess1 (nth$  ?index1 ?colors))
    (bind ?colors (delete$ ?colors ?index1 ?index1)) ; Rimuoviamo l'elemento dalla lista
    
    ;; Selezioniamo casualmente un altro colore e otteniamo il suo indice
    (bind ?index2 (random 1 (length$ ?colors)))
    (bind ?guess2 (nth$ ?index2 ?colors))
    (bind ?colors (delete$ ?colors ?index2 ?index2)) ; Rimuoviamo l'elemento dalla lista
    
    ;; Selezioniamo casualmente un altro colore e otteniamo il suo indice
    (bind ?index3 (random 1 (length$ ?colors)))
    (bind ?guess3 (nth$ ?index3 ?colors))
    (bind ?colors (delete$ ?colors ?index3 ?index3)) ; Rimuoviamo l'elemento dalla lista
    
    ;; Selezioniamo casualmente un altro colore e otteniamo il suo indice
    (bind ?index4 (random 1 (length$ ?colors)))
    (bind ?guess4 (nth$ ?index4 ?colors))

    (bind ?guess (create$ ?guess1 ?guess2 ?guess3 ?guess4))

    
    ;; Costruiamo la sequenza di indovinamento e la asseriamo
    (assert (guess (step 1) (g ?guess)))

    
    ;; Stampiamo il debug
    (printout t "Generated guess " ?guess crlf)
    
    (pop-focus)
)



 ;; SOLO MISS PLACED, SONO SICURO CHE I COLORI IN QUELLE POSIZIONI SONO SBAGLIATI,
(defrule good-guess 
    (status (step ?s&~0) (mode computer))
    (answer (step ?sp) (right-placed ?rp) (miss-placed ?mp))
    (test (= ?sp (- ?s 1)))
    (guess (step ?sp) (g $?prev-guess))
    (test (= ?rp 0))
    (test (> ?mp 1)) 
    ?p1 <- (possible-colors (position 1) (colors $?p1colors))
    ?p2 <- (possible-colors (position 2) (colors $?p2colors))
    ?p3 <- (possible-colors (position 3) (colors $?p3colors))
    ?p4 <- (possible-colors (position 4) (colors $?p4colors))

    =>
    (printout t "step " ?s crlf)

    ;;(printout t "ALL WHITE" crlf)
     
    ;; per ogni posizione elimino il colore dalla lista dei loro possibili colori
    (bind ?color1 (nth$ 1 ?prev-guess))
    (bind ?index1 (member$ ?color1 ?p1colors))
    (bind ?np1colors (delete$ ?p1colors ?index1 ?index1))
    (modify ?p1 (colors ?np1colors))

    (bind ?color2 (nth$ 2 ?prev-guess))
    (bind ?index2 (member$ ?color2 ?p2colors))
    (bind ?np2colors (delete$ ?p2colors ?index2 ?index2))
    (modify ?p2 (colors ?np2colors))

    (bind ?color3 (nth$ 3 ?prev-guess))
    (bind ?index3 (member$ ?color3 ?p3colors))
    (bind ?np3colors (delete$ ?p3colors ?index3 ?index3))
    (modify ?p3 (colors ?np3colors))

    (bind ?color4 (nth$ 4 ?prev-guess))
    (bind ?index4 (member$ ?color4 ?p4colors))
    (bind ?np4colors (delete$ ?p4colors ?index4 ?index4))
    (modify ?p4 (colors ?np4colors))


   ;; rimescolo i colori, stando attento che non si ripetano e che siano validi
    (bind ?all-guess-valid FALSE)
    (while (not ?all-guess-valid) do

      (bind ?guess-valid-1 FALSE)
      (bind ?guess-valid-2 FALSE)
      (bind ?guess-valid-3 FALSE)
      (bind ?guess-valid-4 FALSE)

 
      (bind ?r-index1 (random 1 (length$ ?prev-guess)))
      (bind ?guess1 (nth$  ?r-index1 ?prev-guess))
      (if (member$ ?guess1 ?np1colors)
        then
            (bind ?guess-valid-1 TRUE)
      )


      (bind ?r-index2 (random 1 (length$ ?prev-guess)))
      (bind ?guess2 (nth$  ?r-index2 ?prev-guess))
      (if (and (not (member$ ?guess2 (create$ ?guess1))) (member$ ?guess2 ?np2colors))
        then
            (bind ?guess-valid-2 TRUE)
      )


      (bind ?r-index3 (random 1 (length$ ?prev-guess)))
      (bind ?guess3 (nth$  ?r-index3 ?prev-guess))
      (if (and (not (member$ ?guess3 (create$ ?guess1 ?guess2))) (member$ ?guess3 ?np3colors))
        then 
            (bind ?guess-valid-3 TRUE)
      )


      (bind ?r-index4 (random 1 (length$ ?prev-guess)))
      (bind ?guess4 (nth$  ?r-index4 ?prev-guess))
      (if (and (not (member$ ?guess4 (create$ ?guess1 ?guess2 ?guess3))) (member$ ?guess4 ?np4colors))
        then
            (bind ?guess-valid-4 TRUE)
      )

     ;; Costruiamo la sequenza di indovinamento  
     (bind ?new-guess (create$ ?guess1 ?guess2 ?guess3 ?guess4))


     (if (and ?guess-valid-1 ?guess-valid-2 ?guess-valid-3 ?guess-valid-4)
       then
       (printout t "GUESS SCELTO" ?new-guess crlf)
       (if (eq (find-fact ((?g guess)) (eq ?g ?new-guess)) (create$))
         then
         (bind ?all-guess-valid TRUE)
        )
     )
     )
 
 
    ;; Costruiamo la sequenza di indovinamento e la asseriamo 
    (assert (guess (step ?s) (g ?new-guess)))
    
    ;; Stampiamo il debug
    (printout t "Generated guess " ?new-guess crlf)
    
    (pop-focus)
)


;;TUTTI RIGHT PLACE, SCAMBIO SOLO UN COLORE 
(defrule OneChange-guess
    (status (step ?s&~0) (mode computer))
    (answer (step ?sp) (right-placed ?rp) (miss-placed ?mp))
    (test (= ?sp (- ?s 1)))
    (test (= ?mp 0))
    (guess (step ?sp) (g $?prev-guess))
    (test (> (+ ?rp ?mp) 1))
    ?lg <- (last-guess)

    ?p1 <- (possible-colors (position 1) (colors $?p1colors))
    ?p2 <- (possible-colors (position 2) (colors $?p2colors))
    ?p3 <- (possible-colors (position 3) (colors $?p3colors))
    ?p4 <- (possible-colors (position 4) (colors $?p4colors))

    =>
   (printout t "step " ?s crlf)


    (retract ?lg)

    ;;(printout t "ONE CHANGE" crlf)


    (assert (last-guess (step ?sp) (guess ?prev-guess) (mp ?mp) (rp ?rp)))


    ;; ciclo in cui provo a scambiare un colore, non deve essere uguale ad un altro nel codice 
    (bind ?color-valid FALSE)
    (while (not ?color-valid) do 

    ;; Seleziono casualmente un indice della combinazione precedente per sostituirlo
    (bind ?position (random 1 4))

    ;; Selezioniamo la lista di colori possibili per quella posizione
    (bind ?possible-colors 
        (if (eq ?position 1) then ?p1colors
        else (if (eq ?position 2) then ?p2colors
        else (if (eq ?position 3) then ?p3colors
        else ?p4colors))))
    
    (bind ?pos (random 1 (length$ ?possible-colors)))
    (bind ?new-color (nth$ ?pos ?possible-colors))

    ;; Costruiamo la nuova combinazione
    (bind ?guess (replace$ ?prev-guess ?position ?position ?new-color))

    ;; controllo che finisce il ciclo while    
    (if (not(member$ ?new-color ?prev-guess))
        then
         (if (eq (find-fact ((?g guess)) (eq ?g ?guess)) (create$))
           then
           (bind ?color-valid TRUE)
        )
     ))

    
    ;; Asseriamo la nuova combinazione
    (assert (guess (step ?s) (g ?guess)))
   
    ;; Stampiamo il debug
    (printout t "Generated guess " ?guess crlf)
    
    (pop-focus)
)

;; DOPO UN CAMBIAMENTO I RIGHT SONO DIMINUITI MA I MISS AUMENTATI, PROVO IL NUOVO COLORE IN UN ALTRA POSIZIONE
(defrule NewColorChange-guess
    (status (step ?s&~0) (mode computer)) 
    (answer (step ?sp) (right-placed ?rp) (miss-placed ?mp))
    (test (= ?sp (- ?s 1)))
    (guess (step ?sp) (g $?prev-guess))
    (test (> (+ ?rp ?mp) 1)) 
    (last-guess (step ?ls) (guess $?old-guess) (rp ?vrp&~nil) (mp ?vmp&:(= ?vmp 0)&~nil))
    (test (< ?ls ?sp))
    (test (= ?vrp (+ ?rp 1)))
    (test (= ?vmp (- ?mp 1)))
    ?lg <- (last-guess)

    ?p1 <- (possible-colors (position 1) (colors $?p1colors))
    ?p2 <- (possible-colors (position 2) (colors $?p2colors))
    ?p3 <- (possible-colors (position 3) (colors $?p3colors))
    ?p4 <- (possible-colors (position 4) (colors $?p4colors))

    =>
    (printout t "step " ?s crlf)


    (retract ?lg)

    (assert 
    (last-guess 
    (step ?sp)
    (guess ?prev-guess)
    (mp ?mp)
    (rp ?rp)
    ))

    
    ;;(printout t "NEW COLOR" crlf)

    ;; identifico la posizione in cui è avvenuto il cambiamento
    (loop-for-count (?i 1 4) do
        (bind ?val1 (nth$ ?i ?prev-guess))
        (bind ?val2 (nth$ ?i ?old-guess))    
        (if (neq ?val1 ?val2)
          then
          (bind ?index i?)
          (bind ?e1 ?val1)
          (bind ?e2 ?val2)
        )
    )

   ;; i right sono diminuiti, quindi quello di prima era nella posizione corretta
   (bind ?e2-list (create$ ?e2))

    (if (eq ?index 1) then
        (modify ?p1 (colors ?e2-list))
    )
    (if (eq ?index 2) then
        (modify ?p2 (colors ?e2-list))
    )
    (if (eq ?index 3) then
        (modify ?p3 (colors ?e2-list))
    )
    (if (eq ?index 4) then
        (modify ?p4 (colors ?e2-list))
    )


    ;; cerco un'altra posizione in cui il nuovo colore vada bene
    (bind ?all-change-valid FALSE)
    (while (not ?all-change-valid) do
    	(bind ?change-valid FALSE)
    	(while (not ?change-valid) do
    		(bind ?random-index (random 1 4))
    		(if (neq ?random-index ?index)
        	then
        		(if (and (eq ?random-index 1) (member$ ?e1 ?p1colors)) then (bind ?change-valid TRUE)
        		(if (and (eq ?random-index 2) (member$ ?e1 ?p2colors)) then (bind ?change-valid TRUE)
        		(if (and (eq ?random-index 3) (member$ ?e1 ?p3colors)) then (bind ?change-valid TRUE) 
        		(if (and (eq ?random-index 4) (member$ ?e1 ?p4colors)) then (bind ?change-valid TRUE)
    	))))))


    	(bind ?new-guess (replace$ ?old-guess ?random-index ?random-index ?e1))


	(if (eq (find-fact ((?g guess)) (eq ?g ?new-guess)) (create$))
       		then
         	(bind ?all-change-valid TRUE)
        )
     )

    
    ;; Costruiamo la sequenza di indovinamento e la asseriamo
    (assert (guess (step ?s) (g ?new-guess)))

    ;; Stampiamo il debug
    (printout t "Generated guess " ?new-guess crlf)
    
    (pop-focus)
)



;;CONOSCO COPPIA COLORI SBAGLIATI, DOPO IL CAMBIAMENTO NON CI SONO MISS PLACE e NON SONO AUMENTATI I RIGHT
(defrule NoChange-guess
    (status (step ?s&~0) (mode computer)) 
    (answer (step ?sp) (right-placed ?rp) (miss-placed ?mp))
    (test (= ?sp (- ?s 1)))
    (guess (step ?sp) (g $?prev-guess))
    (test (> (+ ?rp ?mp) 1))
    (test (= ?mp 0)) 
    (last-guess (step ?ls) (guess $?old-guess) (rp ?vrp&~nil) (mp ?vmp&:(= ?vmp 0)&~nil))
    (test (< ?ls ?sp))
    (test (eq ?vrp ?rp))
    ?lg <- (last-guess)

    ?p1 <- (possible-colors (position 1) (colors $?p1colors))
    ?p2 <- (possible-colors (position 2) (colors $?p2colors))
    ?p3 <- (possible-colors (position 3) (colors $?p3colors))
    ?p4 <- (possible-colors (position 4) (colors $?p4colors))
    =>

    (printout t "step " ?s crlf)


    (retract ?lg)

    (assert 
    (last-guess 
    (step ?sp)
    (guess ?prev-guess)
    (mp ?mp)
    (rp ?rp)
    ))

    ;;(printout t "NO CHANGE" crlf)

    ;; cerco la posizione in cui è avvenuto il cambiamento
    (loop-for-count (?i 1 4) do
        (bind ?val1 (nth$ ?i ?prev-guess))
        (bind ?val2 (nth$ ?i ?old-guess))    
        (if (neq ?val1 ?val2)
          then
          (bind ?index ?i)
          (bind ?e1 ?val1)
          (bind ?e2 ?val2) 
        )
    )

   ;; elimino la coppia di colori tra i colori disponibili per quella posizione
   (if (eq ?index 1) then
       (bind ?index1 (member$ ?e1 ?p1colors))
       (bind ?np1colors (delete$ ?p1colors ?index1 ?index1))
       (bind ?index2 (member$ ?e2 ?np1colors))
       (bind ?npcolors (delete$ ?np1colors ?index2 ?index2))
       (modify ?p1 (colors ?npcolors))
    )
    (if (eq ?index 2) then      
       (bind ?index1 (member$ ?e1 ?p2colors))
       (bind ?np2colors (delete$ ?p2colors ?index1 ?index1))
       (bind ?index2 (member$ ?e2 ?np2colors))
       (bind ?npcolors (delete$ ?np2colors ?index2 ?index2))
       (modify ?p2 (colors ?npcolors))
    )
    (if (eq ?index 3) then  
       (bind ?index1 (member$ ?e1 ?p3colors))
       (bind ?np3colors (delete$ ?p3colors ?index1 ?index1))
       (bind ?index2 (member$ ?e2 ?np3colors))
       (bind ?npcolors (delete$ ?np3colors ?index2 ?index2))
       (modify ?p3 (colors ?npcolors))
    )
    (if (eq ?index 4) then
       (bind ?index1 (member$ ?e1 ?p4colors))
       (bind ?np4colors (delete$ ?p4colors ?index1 ?index1))
       (bind ?index2 (member$ ?e2 ?np4colors))
       (bind ?npcolors (delete$ ?np4colors ?index2 ?index2))
       (modify ?p4 (colors ?npcolors))
    )
     

   ;; seleziono un altro colore per la posizione in cui è avvenuto il cambiamento 
    (bind ?change-valid FALSE)
    (while (not chage-valid) do

    	(bind ?color-valid FALSE)
   	(while (not ?color-valid) do
    
		;; Selezioniamo casualmente un colore dalla lista dei colori
    		(bind ?index-color (random 1 (length$ ?npcolors)))
    		(bind ?new-color (nth$ ?index-color ?npcolors))
    		(if (not(member$ ?new-color ?old-guess))
        		then
        		(bind ?color-valid TRUE)
    		))
   
    (bind ?guess (replace$ ?old-guess ?index ?index ?new-color))

    (if (eq (find-fact ((?g guess)) (eq ?g ?guess)) (create$))
       then
       	(bind ?change-valid TRUE)
        )
     )


    ;; Asseriamo la nuova combinazione
    (assert (guess (step ?s) (g ?guess)))

    (assert (last-guess (step ?sp) (guess ?old-guess) (mp ?vmp) (rp ?vrp)))
   
    ;; Stampiamo il debug
    (printout t "Generated guess " ?guess crlf)
    
    (pop-focus)
)




;;I RIGHT PLACED SONO DIMINUITI IL COLORE DI PRIMA ERA CORRETTO. 
;;rifaccio one change sulla vecchia cominazione, più specifico di one change serve saliance
(defrule wrost-guess (declare (salience 100))
    (status (step ?s&~0) (mode computer)) 
    (answer (step ?sp) (right-placed ?rp) (miss-placed ?mp))
    (test (= ?sp (- ?s 1)))
    (guess (step ?sp) (g $?prev-guess))
    (test (= ?mp 0)) 
    (last-guess (step ?ls) (guess $?old-guess) (rp ?vrp&~nil) (mp ?vmp&:(= ?vmp 0)&~nil))
    (test (> (+ ?vrp ?vmp) 1))
    (test (< ?ls ?sp))
    (test (= ?rp  (- ?vrp 1)))
    ?lg <- (last-guess)

    ?p1 <- (possible-colors (position 1) (colors $?p1colors))
    ?p2 <- (possible-colors (position 2) (colors $?p2colors))
    ?p3 <- (possible-colors (position 3) (colors $?p3colors))
    ?p4 <- (possible-colors (position 4) (colors $?p4colors))


    =>

    (printout t "step " ?s crlf)

    (retract ?lg)

    (assert 
    (last-guess 
    (step ?sp)
    (guess ?old-guess)
    (mp ?vmp)
    (rp ?vrp)
    ))

    ;;(printout t "WORST" crlf)

    ;; seleziono l'indice in cui è avvenuto il cambiamento
    (loop-for-count (?i 1 4) do
        (bind ?val1 (nth$ ?i ?prev-guess))
        (bind ?val2 (nth$ ?i ?old-guess))    
        (if (neq ?val1 ?val2)
          then
          (bind ?index ?i)
          (bind ?e1 ?val1)
          (bind ?e2 ?val2) 
        )
    )

   ;; poichè i right sono diminuiti so che il colore di prima era nella posizione corretta
    (bind ?e2-list (create$ ?e2))

    (if (eq ?index 1) then
        (modify ?p1 (colors ?e2-list))
    )
    (if (eq ?index 2) then
        (modify ?p2 (colors ?e2-list))
    )
    (if (eq ?index 3) then
        (modify ?p3 (colors ?e2-list))
    )
    (if (eq ?index 4) then
        (modify ?p4 (colors ?e2-list))
    )


    ;; piu cicli while in cui seleziono un indice diverso e un colore ammissibile per quel indice
    ;;(bind ?guess nil)
    (bind ?change-valid FALSE)
    (while (not ?change-valid) do

    (bind ?color-valid FALSE)
    (while (not ?color-valid) do

    (bind ?position-valid FALSE)
    (while (not ?position-valid) do

    (bind ?position (random 1 (length$ ?prev-guess)))
      (if (neq ?position ?index)
        then
            (bind ?position-valid TRUE)
      )
    )

    (bind ?possible-colors 
        (if (eq ?position 1) then ?p1colors
        else (if (eq ?position 2) then ?p2colors
        else (if (eq ?position 3) then ?p3colors
        else ?p4colors))))
    
    (bind ?pos (random 1 (length$ ?possible-colors)))
    (bind ?new-color (nth$ ?pos ?possible-colors))

    (if (not(member$ ?new-color ?old-guess))
        then
        (bind ?color-valid TRUE)
    ))
    
    ;; Costruiamo la nuova combinazione sostituendo un colore a caso
    (bind ?guess (replace$ ?old-guess ?position ?position ?new-color))

     (if (eq (find-fact ((?g guess)) (eq ?g ?guess)) (create$))
       		then
         	(bind ?change-valid TRUE)
        )
     )

    ;; Asseriamo la nuova combinazione
    (assert (guess (step ?s) (g ?guess)))
   
    ;; Stampiamo il debug
    (printout t "Generated guess " ?guess crlf)
    
    (pop-focus)
)