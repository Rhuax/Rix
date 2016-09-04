(defglobal ?*highest-priority* = 999)
(defglobal ?*high-priority* = 100)
(defglobal ?*low-priority* = -100)
(defglobal ?*lowest-priority* = -1000)
(defglobal ?*grid_size* = -1)

(deftemplate moving
	(slot direction
		(type SYMBOL)
		(default NORD)
		(allowed-symbols NORD SUD EST OVEST)
		)
	)
(deftemplate position
	(slot entity
		(type SYMBOL)
		(allowed-symbols ME GOAL)
		)
	(slot x
		(type INTEGER)
		)
	(slot y
		(type INTEGER)
		)

	)
(deftemplate go
	(slot where
		(type SYMBOL)
		(allowed-symbols NORD SUD EST OVEST)
		)

	)


(deftemplate wall_following
	(slot side
		(type SYMBOL)
		(allowed-symbols DX SX)
		)
	)
(deftemplate wall_following_starting_position
	(slot x
		(type INTEGER)
		)
	(slot y
		(type INTEGER)
		)
	)

(deftemplate obstacle
	(slot where
		(type SYMBOL)
		(allowed-symbols NORD SUD EST OVEST)
		)
	)

(deffunction equal_position

	(?firstx ?secondx ?firsty ?secondy)
	(and (= ?firstx  ?secondx) (= ?firsty ?secondy))
	)

(deffunction decision_direction
	(?mx ?my ?gx ?gy)
	(if (= ?mx ?gx)
		then ( if (> ?my ?gy) then (assert (moving (direction OVEST))) else (assert (moving (direction EST)))
			)
		else( if (> ?mx ?gx) then (assert (moving (direction NORD))) else (assert (moving (direction SUD)))
			)
		)

	)
(deffunction retract_surrounding_obstacles
	()
	(do-for-all-facts ((?f obstacle)) TRUE (retract ?f) )
	)


(deffunction euclidean_distance
	(?xf ?xs ?yf ?ys)
	(sqrt (+ (** (- ?xf ?xs) 2) (** (- ?yf ?ys) 2)))
	)


;; Utility function

(deffunction get-all-facts-by-names
  ($?template-names)
  (bind ?facts (create$))
  (progn$ (?f (get-fact-list))
	   (if (member$ (fact-relation ?f) $?template-names)
	       then (bind ?facts (create$ ?facts ?f))))
  ?facts)



;Rules

(defrule first_decision

	;?killme<-(initial-fact)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(not (exists (moving (direction ?d))))
	=>
	(decision_direction ?mx ?my ?gx ?gy)
	;(retract ?killme)
	)

;;Basic movements
(defrule move_nord
	"Regola base per muoversi e trovarsi sulla stessa ordinata dell'obiettivo"
	(declare(salience ?*lowest-priority*))
	(not (exists (wall_following)))
	(moving (direction NORD))
	(not (exists (obstacle (where NORD))));;Se è libero dove voglio andare
	?f<-(position (entity ME) (x ?x) (y ?y))
	=>
	(assert (go (where NORD)))
	(modify ?f (x (- ?x 1)))
	)

(defrule move_sud
	"Regola base per muoversi e trovarsi sulla stessa ordinata dell'obiettivo"
	(declare(salience ?*lowest-priority*))
	(not (exists (wall_following)))
	(moving (direction SUD))
	(not (exists (obstacle (where SUD))));;Se è libero dove voglio andare
	?f<-(position (entity ME) (x ?x) (y ?y))
	=>
	(assert (go (where SUD)))
	(modify ?f (x (+ ?x 1)))
	)

(defrule move_est
	"Regola base per muoversi e trovarsi sulla stessa ordinata dell'obiettivo"
	(declare(salience ?*lowest-priority*))
	(not (exists (wall_following)))
	(moving (direction EST))
	(not (exists (obstacle (where EST))));;Se è libero dove voglio andare
	?f<-(position (entity ME) (x ?x) (y ?y))
	=>
	(assert (go (where EST)))
	(modify ?f (y (+ ?y 1)))
	)

(defrule move_ovest
	"Regola base per muoversi e trovarsi sulla stessa ordinata dell'obiettivo"
	(declare(salience ?*lowest-priority*))
	(not (exists (wall_following)))
	(moving (direction OVEST))
	(not (exists (obstacle (where OVEST))));;Se è libero dove voglio andare
	?f<-(position (entity ME) (x ?x) (y ?y))
	=>
	(assert (go (where OVEST)))
	(modify ?f (y (- ?y 1)))
	)


(defrule change_direction1
	""
	(declare(salience ?*low-priority*))
	(or ?f<-(moving (direction NORD))
		?f<-(moving (direction SUD)))
	(not (exists (wall_following)))
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test(= ?mx ?gx));Se stiamo sulla stessa ordinata
	=>
	(retract ?f)
	(decision_direction ?mx ?my ?gx ?gy)
	)

(defrule change_direction2
	""
	(declare(salience ?*low-priority*))
	(or ?f<-(moving (direction EST))
		?f<-(moving (direction OVEST)))
	(not (exists (wall_following)))
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test(= ?my ?gy));Se stiamo sulla stessa ordinata
	=>
	(retract ?f)
	(decision_direction ?mx ?my ?gx ?gy)
	)


;;Oops obstacle detected! Gonna think were to go
(defrule obstacle_nord_sud1
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction NORD)) (obstacle (where NORD)))
		(and ?f<-(moving (direction SUD)) (obstacle (where SUD)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (> ?my ?gy))
	(not (exists (obstacle (where OVEST))))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(if (eq (fact-slot-value ?f direction) NORD) 
		then (assert (wall_following (side SX)))
		else (assert (wall_following (side DX)))
		)
	(retract ?f)
	(assert (moving (direction OVEST)))
	)

(defrule obstacle_nord_sud1_2
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction NORD)) (obstacle (where NORD)))
		(and ?f<-(moving (direction SUD)) (obstacle (where SUD)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (> ?my ?gy))
	(exists (obstacle (where OVEST)))
	(not (exists (obstacle (where EST))))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(if (eq (fact-slot-value ?f direction) NORD) 
		then (assert (wall_following (side DX)))
		else (assert (wall_following (side SX)))
		)
	(retract ?f)
	(assert (moving (direction EST)))
	)
(defrule obstacle_nord_sud1_3
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction NORD)) (obstacle (where NORD)))
		(and ?f<-(moving (direction SUD)) (obstacle (where SUD)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (> ?my ?gy))
	(exists (obstacle (where OVEST)))
	(exists (obstacle (where EST)))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(if (eq (fact-slot-value ?f direction) NORD) 
		then (assert (moving (direction SUD))) 
			 (assert (wall_following (side SX)))
		else (assert (moving (direction NORD)))
			 (assert (wall_following (side DX)))
		)
	
	(retract ?f)
	)



(defrule obstacle_nord_sud2
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction NORD)) (obstacle (where NORD)))
		(and ?f<-(moving (direction SUD)) (obstacle (where SUD)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (< ?my ?gy))
	(not (exists (obstacle (where EST))))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(if (eq (fact-slot-value ?f direction) NORD) 
		then (assert (wall_following (side DX)))
		else (assert (wall_following (side SX)))
		)
	(retract ?f)
	(assert (moving (direction EST)))
	)

(defrule obstacle_nord_sud2_2
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction NORD)) (obstacle (where NORD)))
		(and ?f<-(moving (direction SUD)) (obstacle (where SUD)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (< ?my ?gy))
	(exists (obstacle (where EST)))
	(not (exists (obstacle (where OVEST))))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(if (eq (fact-slot-value ?f direction) NORD) 
		then (assert (wall_following (side SX)))
		else (assert (wall_following (side DX)))
		)
	(retract ?f)
	(assert (moving (direction OVEST)))
	)
(defrule obstacle_nord_sud2_3
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction NORD)) (obstacle (where NORD)))
		(and ?f<-(moving (direction SUD)) (obstacle (where SUD)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (< ?my ?gy))
	(exists (obstacle (where EST)))
	(exists (obstacle (where OVEST)))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(if (eq (fact-slot-value ?f direction) NORD) 
		then (assert (moving (direction SUD)))
			(assert (wall_following (side DX)))
		else (assert (moving (direction NORD)))
			(assert (wall_following (side SX)))
		)
	(retract ?f)
	)




(defrule obstacle_nord_sud3
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction NORD)) (obstacle (where NORD)))
		(and ?f<-(moving (direction SUD)) (obstacle (where SUD)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (= ?my ?gy))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(if (> ?my (/ ?*grid_size* 2))
		then (assert (moving (direction OVEST))) 
			(if (eq (fact-slot-value ?f direction) NORD)
				then (assert (wall_following (side SX)))
				else (assert (wall_following (side DX)))
				)
		else (assert (moving (direction EST)))
			(if (eq (fact-slot-value ?f direction) NORD)
				then (assert (wall_following (side DX)))
				else (assert (wall_following (side SX)))
				)
		)
	(retract ?f)
	)


(defrule obstacle_est_ovest
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction EST)) (obstacle (where EST)))
		(and ?f<-(moving (direction OVEST)) (obstacle (where OVEST)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (= ?mx ?gx))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(if (> ?mx (/ ?*grid_size* 2))
		then (if (not (any-factp ((?f obstacle)) (eq ?f:where NORD)) ) 
				then  (assert (moving (direction NORD))) 
				(if (eq (fact-slot-value ?f direction) EST)
					then (assert (wall_following (side SX)))
					else (assert (wall_following (side DX)))
					)
				else
				(assert (moving (direction SUD)))
			(if (eq (fact-slot-value ?f direction) EST)
				then (assert (wall_following (side DX)))
				else (assert (wall_following (side SX)))
				)
			)
		else (if (not (any-factp ((?f obstacle)) (eq ?f:where SUD)))
				then  (assert (moving (direction SUD)))
					(if (eq (fact-slot-value ?f direction) EST)
						then (assert (wall_following (side DX)))
						else (assert (wall_following (side SX)))
						)
				else
					 (assert (moving (direction NORD)))
					 (if (eq (fact-slot-value ?f direction) EST)
					then (assert (wall_following (side SX)))
					else (assert (wall_following (side DX)))
					)
					 )
		)
	(retract ?f)
	)
(defrule obstacle_est_ovest2
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction EST)) (obstacle (where EST)))
		(and ?f<-(moving (direction OVEST)) (obstacle (where OVEST)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (> ?mx ?gx))
	(not (exists (obstacle (where NORD))))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(assert (moving (direction NORD))) 
	(if (eq (fact-slot-value ?f direction) EST)
		then (assert (wall_following (side SX)))
		else (assert (wall_following (side DX)))
		)
	(retract ?f)
	)
(defrule obstacle_est_ovest3
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction EST)) (obstacle (where EST)))
		(and ?f<-(moving (direction OVEST)) (obstacle (where OVEST)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (> ?mx ?gx))
	(obstacle (where NORD))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(assert (moving (direction SUD))) 
	(if (eq (fact-slot-value ?f direction) EST)
		then (assert (wall_following (side DX)))
		else (assert (wall_following (side SX)))
		)
	(retract ?f)
	)
(defrule obstacle_est_ovest4
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction EST)) (obstacle (where EST)))
		(and ?f<-(moving (direction OVEST)) (obstacle (where OVEST)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (< ?mx ?gx))
	(not (exists (obstacle (where SUD))))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(assert (moving (direction SUD))) 
	(if (eq (fact-slot-value ?f direction) EST)
		then (assert (wall_following (side DX)))
		else (assert (wall_following (side SX)))
		)
	(retract ?f)
	)
(defrule obstacle_est_ovest5
	""
	(declare (salience ?*lowest-priority*))
	(or (and ?f<-(moving (direction EST)) (obstacle (where EST)))
		(and ?f<-(moving (direction OVEST)) (obstacle (where OVEST)))
		)
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (< ?mx ?gx))
	(obstacle (where SUD))
	(not (exists (wall_following)))
	=>
	(assert (wall_following_starting_position (x ?mx) (y ?my)))
	(assert (moving (direction NORD))) 
	(if (eq (fact-slot-value ?f direction) EST)
		then (assert (wall_following (side SX)))
		else (assert (wall_following (side DX)))
		)
	(retract ?f)
	)







;;Wall-following mode: on

(defrule terminate_wallfollowing1
	(declare (salience ?*low-priority*))
	?f<-(wall_following)
	?ff<- (wall_following_starting_position (x ?xx) (y ?yy)) 
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))

	(and (or ?fff<-(moving (direction EST)) ?fff<-(moving (direction OVEST)))
		 (test (< ?mx ?gx) )
		 (not (exists (obstacle (where SUD))))
		)
	(test (< (euclidean_distance ?mx ?gx ?my ?gy) (euclidean_distance ?xx ?gx ?yy ?gy)))
	=>
	(retract ?f)
	(retract ?ff)
	(retract ?fff)
	(assert (moving (direction SUD)))
	)
(defrule terminate_wallfollowing2
	(declare (salience ?*low-priority*))
	?f<-(wall_following)
	?ff<- (wall_following_starting_position (x ?xx) (y ?yy)) 
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (< (euclidean_distance ?mx ?gx ?my ?gy) (euclidean_distance ?xx ?gx ?yy ?gy)))
	(and (or ?fff<-(moving (direction EST)) ?fff<-(moving (direction OVEST)))
		 (test (> ?mx ?gx) )
		 (not (exists (obstacle (where NORD))))
		)
	=>
	(retract ?f)
	(retract ?ff)
	(retract ?fff)
	(assert (moving (direction NORD)))
	)
(defrule terminate_wallfollowing5
	(declare (salience ?*low-priority*))
	?f<-(wall_following)
	?ff<- (wall_following_starting_position (x ?xx) (y ?yy)) 
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
(test (< (euclidean_distance ?mx ?gx ?my ?gy) (euclidean_distance ?xx ?gx ?yy ?gy)))
	(and (or (and ?fff<-(moving (direction EST)) (not (exists (obstacle (where EST)))) )
			 (and ?fff<-(moving (direction OVEST)) (not (exists (obstacle (where OVEST)))))
		 	 )
		(test (= ?mx ?gx) )
		)
	=>
	(retract ?f)
	(retract ?ff)
	)





(defrule terminate_wallfollowing3
	(declare (salience ?*low-priority*))
	?f<-(wall_following)
	?ff<- (wall_following_starting_position (x ?xx) (y ?yy)) 
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (< (euclidean_distance ?mx ?gx ?my ?gy) (euclidean_distance ?xx ?gx ?yy ?gy)))
	(and (or ?fff<-(moving (direction NORD)) ?fff<-(moving (direction SUD)))
		 (test (< ?my ?gy) )
		 (not (exists (obstacle (where EST))))
		)
	=>
	(retract ?f)
	(retract ?ff)
	(retract ?fff)
	(assert (moving (direction EST)))
	)

(defrule terminate_wallfollowing4
	(declare (salience ?*low-priority*))
	?f<-(wall_following)
	?ff<- (wall_following_starting_position (x ?xx) (y ?yy)) 
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
(test (< (euclidean_distance ?mx ?gx ?my ?gy) (euclidean_distance ?xx ?gx ?yy ?gy)))
	(and (or ?fff<-(moving (direction NORD)) ?fff<-(moving (direction SUD)))
		 (test (> ?my ?gy) )
		 (not (exists (obstacle (where OVEST))))
		)
	=>
	(retract ?f)
	(retract ?ff)
	(retract ?fff)
	(assert (moving (direction OVEST)))
	)
(defrule terminate_wallfollowing6
	(declare (salience ?*low-priority*))
	?f<-(wall_following)
	?ff<- (wall_following_starting_position (x ?xx) (y ?yy)) 
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (< (euclidean_distance ?mx ?gx ?my ?gy) (euclidean_distance ?xx ?gx ?yy ?gy)))
	(and (or (and ?fff<-(moving (direction NORD)) (not (exists (obstacle (where NORD)))) (test (> ?mx ?gx)))
			 (and ?fff<-(moving (direction SUD)) (not (exists (obstacle (where SUD)))) (test (< ?mx ?gx)))
		)
		(test (= ?my ?gy) )
	)
	=>
	(retract ?f)
	(retract ?ff)
	)

(defrule continue_wallfollowing_without_edge1
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	(moving (direction NORD))
	(or (and (wall_following (side DX)) (obstacle (where OVEST)))
		(and (wall_following (side SX)) (obstacle (where EST)))
		)
	(not (exists (obstacle (where NORD))))
	=>
	(modify ?f (x (- ?x 1)))
	(assert (go (where NORD)))
	)

(defrule continue_wallfollowing_without_edge2
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	(moving (direction SUD))
	(or (and (wall_following (side DX)) (obstacle (where EST)))
		(and (wall_following (side SX)) (obstacle (where OVEST)))
		)
	(not (exists (obstacle (where SUD))))
	=>
	(modify ?f (x (+ ?x 1)))
	(assert (go (where SUD)))
	)
(defrule continue_wallfollowing_without_edge3
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	(moving (direction EST))
	(or (and (wall_following (side DX)) (obstacle (where NORD)))
		(and (wall_following (side SX)) (obstacle (where SUD)))
		)
	(not (exists (obstacle (where EST))))
	=>
	(modify ?f (y (+ ?y 1)))
	(assert (go (where EST)))
	)
(defrule continue_wallfollowing_without_edge4
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	(moving (direction OVEST))
	(or (and (wall_following (side DX)) (obstacle (where SUD)))
		(and (wall_following (side SX)) (obstacle (where NORD)))
		)
	(not (exists (obstacle (where OVEST))))
	=>
	(modify ?f (y (- ?y 1)))
	(assert (go (where OVEST)))
	)

(defrule continue_wallfollowing_with_external_edge1
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction NORD))
	(wall_following (side DX)) 
	(not (exists(obstacle (where OVEST))))
		
	=>
	(modify ?f (y (- ?y 1)))
	(retract ?ff)
	(assert (moving (direction OVEST)))
	(assert (go (where OVEST)))
	)

(defrule continue_wallfollowing_with_external_edge2
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction NORD))
	(wall_following (side SX)) 
	(not (exists(obstacle (where EST))))
		
	=>
	(modify ?f (y (+ ?y 1)))
	(retract ?ff)
	(assert (moving (direction EST)))
	(assert (go (where EST)))
	)

(defrule continue_wallfollowing_with_external_edge3
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction SUD))
	(wall_following (side SX)) 
	(not (exists(obstacle (where OVEST))))
		
	=>
	(modify ?f (y (- ?y 1)))
	(retract ?ff)
	(assert (moving (direction OVEST)))
	(assert (go (where OVEST)))
	)
(defrule continue_wallfollowing_with_external_edge4
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction SUD))
	(wall_following (side DX)) 
	(not (exists(obstacle (where EST))))
		
	=>
	(modify ?f (y (+ ?y 1)))
	(retract ?ff)
	(assert (moving (direction EST)))
	(assert (go (where EST)))
	)

(defrule continue_wallfollowing_with_external_edge5
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction EST))
	(wall_following (side SX)) 
	(not (exists(obstacle (where SUD))))
		
	=>
	(modify ?f (x (+ ?x 1)))
	(retract ?ff)
	(assert (moving (direction SUD)))
	(assert (go (where SUD)))
	)

(defrule continue_wallfollowing_with_external_edge6
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction EST))
	(wall_following (side DX)) 
	(not (exists(obstacle (where NORD))))
		
	=>
	(modify ?f (x (- ?x 1)))
	(retract ?ff)
	(assert (moving (direction NORD)))
	(assert (go (where NORD)))
	)


(defrule continue_wallfollowing_with_external_edge7
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction OVEST))
	(wall_following (side SX)) 
	(not (exists(obstacle (where NORD))))
		
	=>
	(modify ?f (x (- ?x 1)))
	(retract ?ff)
	(assert (moving (direction NORD)))
	(assert (go (where NORD)))
	)
(defrule continue_wallfollowing_with_external_edge8
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction OVEST))
	(wall_following (side DX)) 
	(not (exists(obstacle (where SUD))))
		
	=>
	(modify ?f (x (+ ?x 1)))
	(retract ?ff)
	(assert (moving (direction SUD)))
	(assert (go (where SUD)))
	)



(defrule continue_wallfollowing_with_internal_edge1
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction NORD))
	(wall_following (side DX)) 
	(exists(obstacle (where OVEST)))
	(exists(obstacle (where NORD)))
	(not (exists (obstacle (where EST))))
	=>
	;(modify ?f (y (+ ?y 1)))
	(retract ?ff)
	(assert (moving (direction EST)))

	)

(defrule continue_wallfollowing_with_internal_edge2
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction NORD))
	(wall_following (side SX)) 
	(exists(obstacle (where EST)))
	(exists(obstacle (where NORD)))
	(not (exists (obstacle (where OVEST))))
	=>
	;(modify ?f (y (- ?y 1)))
	(retract ?ff)
	(assert (moving (direction OVEST)))
	)

(defrule continue_wallfollowing_with_internal_edge3
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction SUD))
	(wall_following (side DX)) 
	(exists(obstacle (where EST)))
	(exists(obstacle (where SUD)))
	(not (exists (obstacle (where OVEST))))
	=>
	;(modify ?f (y (- ?y 1)))
	(retract ?ff)
	(assert (moving (direction OVEST)))
	)

(defrule continue_wallfollowing_with_internal_edge4
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction SUD))
	(wall_following (side SX)) 
	(exists(obstacle (where OVEST)))
	(exists(obstacle (where SUD)))
	(not (exists (obstacle (where EST))))
	=>
	;(modify ?f (y (+ ?y 1)))
	(retract ?ff)
	(assert (moving (direction EST)))
	)


(defrule continue_wallfollowing_with_internal_edge5
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction EST))
	(wall_following (side DX)) 
	(exists(obstacle (where EST)))
	(exists(obstacle (where NORD)))
	(not (exists (obstacle (where SUD))))
	=>
	;(modify ?f (x (+ ?x 1)))
	(retract ?ff)
	(assert (moving (direction SUD)))
	)

(defrule continue_wallfollowing_with_internal_edge6
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction EST))
	(wall_following (side SX)) 
	(exists(obstacle (where EST)))
	(exists(obstacle (where SUD)))
	(not (exists (obstacle (where NORD))))
	=>
	;(modify ?f (x (- ?x 1)))
	(retract ?ff)
	(assert (moving (direction NORD)))
	)

(defrule continue_wallfollowing_with_internal_edge7
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction OVEST))
	(wall_following (side DX)) 
	(exists(obstacle (where OVEST)))
	(exists(obstacle (where SUD)))
	(not (exists (obstacle (where NORD))))
	=>
	;(modify ?f (x (- ?x 1)))
	(retract ?ff)
	(assert (moving (direction NORD)))
	)

(defrule continue_wallfollowing_with_internal_edge8
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction OVEST))
	(wall_following (side SX)) 
	(exists(obstacle (where OVEST)))
	(exists(obstacle (where NORD)))
	(not (exists (obstacle (where SUD))))
	=>
	;(modify ?f (x (+ ?x 1)))
	(retract ?ff)
	(assert (moving (direction SUD)))
	)
;;Vicoli ciechi
(defrule continue_wallfollowing_with_internal_edge9
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction OVEST))
	(or ?fff<-(wall_following (side SX)) ?fff<-(wall_following (side DX)))
	(obstacle (where OVEST))
	(obstacle (where NORD))
	(obstacle (where SUD))
	=>
	;(modify ?f (x (+ ?x 1)))
	(retract ?ff)
	(assert (moving (direction EST)))
	;(if (eq (fact-slot-value ?fff side) SX)
		;then (modify ?fff (side DX))
		;else (modify ?fff (side SX)))

	)
(defrule continue_wallfollowing_with_internal_edge10
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction EST))
	(or ?fff<-(wall_following (side SX)) ?fff<-(wall_following (side DX)))
	(obstacle (where EST))
	(obstacle (where NORD))
	(obstacle (where SUD))
	=>
	;(modify ?f (x (+ ?x 1)))
	(retract ?ff)
	(assert (moving (direction OVEST)))
	;(if (eq (fact-slot-value ?fff side) SX)
		;then (modify ?fff (side DX))
		;else (modify ?fff (side SX)))

	)

(defrule continue_wallfollowing_with_internal_edge11
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction NORD))
	(or ?fff<-(wall_following (side SX)) ?fff<-(wall_following (side DX)))
	(obstacle (where OVEST))
	(obstacle (where NORD))
	(obstacle (where EST))
	=>
	;(modify ?f (x (+ ?x 1)))
	(retract ?ff)
	(assert (moving (direction SUD)))
	;(if (eq (fact-slot-value ?fff side) SX)
		;then (modify ?fff (side DX))
		;else (modify ?fff (side SX)))

	)

(defrule continue_wallfollowing_with_internal_edge12
	(declare (salience ?*lowest-priority*))
	?f<-(position (entity ME) (x ?x) (y ?y))
	?ff<-(moving (direction SUD))
	(or ?fff<-(wall_following (side SX)) ?fff<-(wall_following (side DX)))
	(obstacle (where OVEST))
	(obstacle (where EST))
	(obstacle (where SUD))
	=>
	;(modify ?f (x (+ ?x 1)))
	(retract ?ff)
	(assert (moving (direction NORD)))
	;(if (eq (fact-slot-value ?fff side) SX)
		;then (modify ?fff (side DX))
		;else (modify ?fff (side SX)))

	)










;;Damn! Goal's position changed :|
(defrule goal_changed
	""
	(declare (salience ?*high-priority*))
	?killme<-(GOAL_pos_changed)
	=>
	;; Old direction and other infos were based on old goal's position, so retract them
	(retract ?killme);;
	(do-for-all-facts ((?f moving go wall_following wall_following_starting_position  )) TRUE (retract ?f))
	;;(printout t "In goal changed" crlf)
	)


;;Damn! My position changed :|
(defrule my_position_changed
	""
	(declare (salience ?*high-priority*))
	?killme<-(ME_pos_changed)
	=>
	;; Old direction and other infos were based on old agent's position, so retract them
	(retract ?killme);;
	(do-for-all-facts ((?f moving go wall_following wall_following_starting_position  )) TRUE (retract ?f))
	;;(printout t "In goal changed" crlf)
	)



(defrule goal_achieved
	"Regola che verifica il raggiungimento dell'obiettivo e halta l'esecuzione"
	(declare(salience ?*highest-priority*))
	(position (entity ME) (x ?mx) (y ?my))
	(position (entity GOAL) (x ?gx) (y ?gy))
	(test (equal_position ?mx ?gx ?my ?gy))
	=>
	(assert (goal))
	(halt)
	
	
	)