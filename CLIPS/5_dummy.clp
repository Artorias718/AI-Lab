;; ---------------------------------------------
;; --- Definizione del modulo e dei template ---
;; ---------------------------------------------

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

(defrule start-color-identification
    (status (step ?s&0) (mode computer))
    (not (guess (step 0)))
=>
    (bind ?guess (create$ white orange blue yellow))
    ;;(bind ?guess (create$ blue green yellow orange))
    (assert (guess (step 0) (g $?guess)))
    (assert (last-guess (step ?s) (guess ?guess) ))

    (printout t "Inizio identificazione colori con combinazione: "  ?guess crlf)
    (pop-focus)
)

;; (defrule best-colors-guess
;;     (status (step ?s&~0) (mode computer))
;;     (answer (step ?sp) (right-placed ?rp) (miss-placed ?mp))
;;     (test (= (+ ?rp ?mp) 4))
;;     (guess (step ?sp) (g $?prev-guess))
;;     ?lg <- (last-guess)

;; =>
;;     (printout t "hai preso tutti i colori!" crlf)
;;     (assert (flag))
;;     (pop-focus)
;; )

(defrule best-colors-guess2
    (status (step ?s&~0) (mode computer))
    (answer (step ?sp) (right-placed ?rp) (miss-placed ?mp))
    (test (= (+ ?rp ?mp) 0))
    (guess (step ?sp) (g $?prev-guess))
    ?lg <- (last-guess)
=>
    (bind ?colors (create$ blue green red yellow orange white black purple))

    (bind ?remaining-colors (create$))
    (foreach ?color ?colors
        (if (not (member$ ?color (create$ ?prev-guess)))
            then
            (bind ?remaining-colors (create$ ?remaining-colors ?color))
        )
    )

    (assert (guess (step ?s) (g $?remaining-colors)))
    (printout t "Non ne hai preso nemmeno uno! Nuova guess con i colori rimanenti: " ?remaining-colors crlf)

    (pop-focus)
)

(defrule average-colors-guess
    (status (step ?s&~0) (mode computer))
    (answer (step ?sp) (right-placed ?rp) (miss-placed ?mp))
    (test (and (> (+ ?rp ?mp) 0) (< (+ ?rp ?mp) 4)))
    (guess (step ?sp) (g $?prev-guess))
    ?lg <- (last-guess)

=>

    (printout t "Numero di colori presi da 1 a 3!" crlf)
    (bind ?colors (create$ blue green red yellow orange white black purple))

    (bind ?flag FALSE)

    (bind ?remaining-colors (create$))
    (foreach ?color ?colors
        (if (not (member$ ?color (create$ ?prev-guess)))
            then
            (bind ?remaining-colors (create$ ?remaining-colors ?color))
        )
    )

   	(while (not ?flag) do
        (printout t "WHILE  ")
        (bind ?index (random 1 4))

        (bind ?new-color (nth$ (random 1 (length$ ?remaining-colors)) ?remaining-colors))
        ;;(bind ?prev-guess (replace ?prev-guess ?index ?new-color))

        (bind ?result (create$))
        (loop-for-count (?i (length$ ?prev-guess))
            (if (= ?i ?index)
                then
                (bind ?result (create$ ?result ?new-color))
                else
                (bind ?result (create$ ?result (nth$ ?i ?prev-guess)))
            )
        )

        (bind ?prev-guess ?result)

        (if (eq (find-fact ((?var guess)) (eq ?var:g ?prev-guess)) (create$))
        then
            (bind ?flag TRUE)
        )
    )

    (assert (guess (step ?s) (g $?prev-guess)))
    (printout t "Nuova guess: " $?prev-guess crlf)

    (pop-focus)
)

(defrule shuffle-colors (declare (salience 150))
    (status (step ?s&~0) (mode computer))
    (answer (step ?sp) (right-placed ?rp) (miss-placed ?mp))
    (test (= (+ ?rp ?mp) 4))
    (guess (step ?sp) (g $?prev-guess))
    ?lg <- (last-guess)
=>

    (bind ?flag2 FALSE)

   	(while (not ?flag2) do
        
        (bind ?temp-guess (create$ $?prev-guess)) ; Crea una copia della congettura precedente
        (bind ?shuffled-guess (create$)) ; Crea una nuova lista per i colori mescolati

        (while (> (length$ ?temp-guess) 0) ; Continua finché ci sono elementi nella lista temporanea

            (bind ?random-index (random 1 (length$ ?temp-guess)))
            (bind ?color (nth$ ?random-index ?temp-guess)) ; Ottieni il colore corrispondente all'indice casuale
            ;;(printout t "Selezionato indice: " ?random-index ", colore: " ?color crlf)

            (bind ?shuffled-guess (insert$ ?shuffled-guess 1 ?color)) ; Inserisci il colore nella nuova lista mescolata
            (bind ?temp-guess (delete$ ?temp-guess ?random-index ?random-index)) ; Rimuovi il colore dalla lista temporanea
        )


        (if (eq (find-fact ((?var guess)) (eq ?var:g ?shuffled-guess)) (create$))
        then
            (bind ?flag2 TRUE)
        )
    )

    (assert (guess (step ?s) (g $?shuffled-guess)))
    (printout t "Colori mescolati: " ?shuffled-guess crlf)

    (pop-focus)

)
 
