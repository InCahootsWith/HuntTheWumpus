;; to fix
;; look back
;; the adding shit to the meant to be empty locations array

;;---------------------------------
;; SETTING UP ALL THE STATES
;;---------------------------------
(defun init ()
;; roomsIndex, roomsOrder, roomsOrderBack, Locations, #arrows, dead, won
;; LOCATIONS = player, wumpus, pit1 pit2, bat1 bat2
  (let (
    (state (list
    ;; rooms index connection
    #((4 7 1)(0 9 2)(1 11 3)(2 13 4)(3 5 0)(14 4 6)(5 16 7)
    (6 0 8)(7 17 9)(8 1 10)(9 18 11)(10 2 12)(11 19 13)(12 3 14)
    (13 15 5)(19 14 16)(15 6 7)(16 8 18)(17 10 19)(18 12 15)
  )
  ;; room order
  #(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19)
  ;; backwards room order
  #(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19)
  ;; locations = player wumpus pit1 pit2 bat1 bat2
  ;'(0 4 7 9 9 9)
  (randLoc (list 0) 0)
  ;; arrow number and index for when going astray and final destination
  '(4 0 0)
  ;; dead or won if either == 1 then they're activated
  #(0 0))
  ))

  (start (shuffle state 19 0)))
)

;; setting the random locations for the dangers -> doesn't allow for overlap
(defun randLoc (locations i)
  (cond
    ((= i 5) (return-from randLoc locations))
    (
      (let ((x (+ 1 (random 18))))
        (if (member x locations)
            (randLoc locations i)
            (push x (cdr (last locations)))
        )
        (randLoc locations (1+ i))
      )
    )
  )
)
;;---------------------------------
;; REORDERING THE ROOMS - ORGANISING THE STATES
;; need to do rooms order backwards
;;---------------------------------
(defun shuffle (state s e)
  (setf (aref (nth 2 state) (aref (nth 1 state) s)) s)
  (if (= s e)
    (return-from shuffle state)
    (rotatef (aref (nth 1 state) (random s))
            (aref (nth 1 state) (1- s))))
  (shuffle state (1- s) e)
)
;;---------------------------------
;; SETTING THE OUTPUT AND INSTRUCTIONS UP
;;---------------------------------

(defun start (state)
  ; (format t "~%start state ~s" state)
   (askInstructions (y-or-n-p "Instructions? "))
   (format t "~%~%--------------Hunt the Wumpus--------------~%")
   (game state)
)

;; if the user wants instructions or not
(defun askInstructions (input)
  (cond
    ((and input) (printInstructions))
    ((not input) (format t "~%That's a mistake..."))
  )
)

;;---------------------------------
;; MAIN GAME LOOP
;;---------------------------------

(defun game (state)
  (checkCloseRooms state 0)
  (yourRoom (nth 0 (nth 3 state)) state)
  (format t "~%Tunnels lead to")(closeRooms state 0)

  (let (( new (moveOrShoot state)))
    (checkLife new)
    (checkPit (nth 0 (nth 3 new)) (nth 2 (nth 3 new)) (nth 3 (nth 3 new)) new)
    (game new)
  )
)
;;move or shoot function
(defun moveOrShoot (state)
  (format t "~%Move or Shoot? (m/s) ")
  (turn (validateMS(read)) state)
)

(defun turn (input state)
  ;(format t "~%~s" state)
    ;; 1st is for moving 2nd is for shooting
    (if (string= input 'm)
        (let ((newState
              (list (nth 0 state) (nth 1 state) (nth 2 state)
                (updateLocation (nth 3 state) state)
                )
               ))
          (push (shootReset (nth 4 state) (nth 0 (nth 3 newState))) (cdr (last newState)))
          ;; locations, arrows, map
          (push (updateLife (nth 3 newState) (nth 4 newState) (nth 5 state)) (cdr (last newState)))
          newState
        )
        (let ((newState (list (nth 0 state) (nth 1 state) (nth 2 state) (nth 3 state)
          (shoot (nth 4 state) (nth 0 (nth 3 state)) state ))))
          (checkArrow newState)
          ;; locations, arrows, map
          (push (updateLife (nth 3 newState) (nth 4 newState) (nth 5 state)) (cdr (last newState)))
          newState
        )
    ) ;; end of cond
)

;;---------------------------------
;; FUNCTIONS FOR SHOOTING
;;---------------------------------

(defun shootReset (arrows player)
  (return-from shootReset (list (nth 0 arrows) (nth 1 arrows) player))
)

(defun shoot (arrows index state)
  (format t "~%Number of rooms? ")
  ;;returning one less arrow, setting the position to player and if it hit the wumpus or not
  (return-from shoot (list (- (nth 0 arrows) 1) 0 (getRooms (read) 0 index state)))
)

;;get the rooms to shoot to
;; index = current index of arrow to keep track of it
(defun getRooms (limit i index state)
  (if (= i 0)
    (format t "~%Room numbers "))
  (if (= i limit)
    (return-from getRooms index)
    (getRooms limit (1+ i)
      (shootRooms (aref (nth 2 state) (read)) index state) state))
)

(defun shootRooms (value index state)
  (if (member value (aref (nth 0 state) index))
    (return-from shootRooms value)
    (return-from shootRooms (randRoom state index)))
  ;; get current index -> if == to a close room -> change else rand between 3 and go there but cannot turn back
)

(defun randRoom (state index)
  (let ((x (random 3)))
    (return-from randRoom (nth x (aref (nth 0 state) index))))
)
;;---------------------------------
;; FUNCTIONS FOR UPDATING THE LIFE OF THE PLAYER
;;---------------------------------

(defun updateLife (locations arrows clife)
  (cond
      ((= (nth 0 locations) (nth 1 locations)) (return-from updateLife #(1 0))) ;the player is dead
      ((= (nth 2 arrows) (nth 1 locations)) (return-from updateLife #(0 1)));the player has won
      ((return-from updateLife #(0 0)))
  )
)

;;---------------------------------
;; FUNCTIONS FOR MOVING THE WUMPUS
;;---------------------------------

(defun moveWumpus (player wumpus state)
  (if (= player wumpus)
    (let ((x (random 4)))
      (if (= x 0)
          (return-from moveWumpus wumpus)
          (return-from moveWumpus (nth (- x 1) (aref (nth 0 state) wumpus) ))
      )
    )
    (return-from moveWumpus wumpus)
  )
)

;;---------------------------------
;; FUNCTIONS FOR PROMPTING THE USER
;;---------------------------------

;;validate the input and make sure it's okay
(defun validateMS (input)
	(cond ((or (string= input 'S) (string= input 's) (string= input 'M) (string= input 'm)) input)
		(t (format t "Invalid value ~s. Try again m or s " input) (validateMS (read)))
	)
)

;;---------------------------------
;; FUNCTIONS FOR MANIPULATING THE CURRENT STATE TO THE NEW STATE
;;---------------------------------

(defun updateLocation (locations state)
  ;; locations = player wumpus pit1 pit2 bat1 bat2
  ;; translation done by the look back array

  ;; moves the player to the write place
  (let ((player (translate (move) state)))

    (list (batsMove (batsMove player (nth 4 locations)(nth 5 locations)) (nth 4 locations) (nth 5 locations)) ;; moves if == bats
          (moveWumpus player (nth 1 locations) state) ;; moves wumpus if == player
          (nth 2 locations) (nth 3 locations) (nth 4 locations) (nth 5 locations)) ;; the rest of it
  )
)

(defun translate (value state)
  (aref (nth 2 state) value)
)

(defun batsMove (player bat1 bat2)
  (cond
    ((or (= player bat1) (= player bat2))
        (format t "~%ZEEE (bat sounds) the bats got you! where to now!?! ") (return-from batsMove (random 19)))
    (player)
  )
)

;;---------------------------------
;; FUNCTIONS FOR MOVING AROUND THE MAP
;;---------------------------------

(defun move ()
  (format t "~%Where to? ")(validate(read))
)

(defun validate (input)
  (cond ((< input 20) input)
    (t (format t "Invalid value ~s. Try again: " input) (validate(read)))
  )
)

;;----------------------------------------;;
;; FUNCTIONS FOR DISPLAYING OUTPUT
;;----------------------------------------;;

(defun yourRoom (player state)
  (format t "~%~%You are in room ~s" (aref (nth 1 state) player))
)

(defun closeRooms (state i)
  (if (= i 3)
    (return-from closeRooms state)
    (format t " ~s" (aref (nth 1 state) (nth i (aref (nth 0 state) (nth 0 (nth 3 state))))))
  )
 (closeRooms state (1+ i))
)

;;----------------------------------------;;
;; FUNCTIONS FOR CHECKING CLOSE ROOMS
;;----------------------------------------;;

(defun checkCloseRooms (state i)
  (if (= i 3)
    (return-from checkCloseRooms state)
    (nearDanger (translate (aref (nth 1 state) (nth i (aref (nth 0 state) (nth 0 (nth 3 state))))) state) (nth 3 state))
  )
 (checkCloseRooms state (1+ i))
)

(defun nearDanger (room locations)
  ;;pit1, pit2, bat1, bat2

  (nearPit (nth 2 locations) room)
  (nearPit (nth 3 locations) room)
  (nearBat (nth 4 locations) room)
  (nearBat (nth 5 locations) room)
  (nearWumpus (nth 1 locations) room)
)

;;near bats funciton
(defun nearBat (bat room)
  (cond ((= bat room) bat (format t "~%Bats nearby...")))
)

;;near pit funciton
(defun nearPit (pit room)
  (cond ((= pit room) pit (format t "~%I feel a draft...")))
)

;;near wumpus funciton
(defun nearWumpus (wumpus room)
  (cond ((= wumpus room) wumpus (format t "~%I smell a Wumpus...")))
)

;;----------------------------------------;;
;; FUNCTIONS FOR CHECKING THE ARROW COUNT
;;----------------------------------------;;

(defun checkArrow (state)
  (cond
    ;; they've lost
    ((= (nth 0 (nth 4 state)) 0)
        (format t "~%~%No arrows left...boo hoo ") (restartAsk state))

    ((= (nth 2 (nth 4 state)) (nth 0 (nth 3 state)))
          (format t "~%~%You shot yourself in the bum! HAHAHA ") (restartAsk state))
  )
)

;;----------------------------------------;;
;; FUNCTIONS FOR CHECKING WIN OR LOSE STATE
;;----------------------------------------;;

(defun checkLife (state)
  (cond
    ;; they've lost
    ((= (aref (nth 5 state) 0) 1)
        (format t "~%~%HA HA HA - YOU LOSE ...THE WUMPUS GOT YOU ... DAM HIS WUMPIE ASS ") (restartAsk state))

    ;; they've won ;; game ends here in accordance to the example docs
    ((= (aref (nth 5 state) 1) 1)
          (format t
            "~%~%AHA! YOU GOT THE WUMPUS! ~%HEE HEE HEE - THE WUMPUS’LL GETCHA NEXT TIME!  ")
              (quit))
  )
)

(defun checkPit (player pit1 pit2 state)
  (cond
    ( (or (= player pit1) (= player pit2))
        (format t "~%You fell down a pit...LOSER ") (restartAsk state))
  )
)

;;----------------------------------------;;
;; FUNCTIONS FOR RESTARTING THE GAME
;;----------------------------------------;;

(defun restartAsk (state)
 (restartSet(y-or-n-p "...Same setup? ") state)
)

(defun restartSet (input state)
  (cond
    ((and input) (start (setBack state)))
    ((not input) (init))
  )
)

(defun setBack (state)
  (return-from setBack
     (list (nth 0 state) (nth 1 state) (nth 2 state)
       (cons 0 (cdr (nth 3 state))) '(4 0 0) '(0 0)))
)

;;----------------------------------------;;
;; FUNCTIONS FOR PRINTING THE INSTRUCTIONS
;;----------------------------------------;;

(defun printInstructions ()
 (format t "~%~%Welcome to Hunt the Wumpus")
 (format t "~%~%The Wumpus lives in a cave of 20 rooms. Each room has 3 Tunnels
   leading to other rooms. (Look at a dodecahedron to see how this works...just
     ask someone)")
 (format t "~%~%Hazards: ")
 (format t "~%Bottomless Pits: Two rooms have pits in them. If you go there,
   you fall into the pit and LOSE!!!! sucker... ")
 (format t "~%Super Bats: Two other rooms have super bats. If you go there,
   a bat grabs you and takes you to some other room at random....which is annoying")
 (format t "~%~%Wumpus: ")
 (format t "~%The wumpus is not bothered by the hazards. He is usually asleep.
   Two things wake him up: you entering his room (r00d) or you shooting an arrow (also r00d)")
 (format t "~%~%If the Wumpus wakes up, he sometimes runs to the next room.")
 (format t "~%If you happen to be in the same room with him, you lose.")
 (format t "~%~%You: ")
 (format t "~%Each turn you may move or shoot a crooked arrow.")
 (format t "~%Move: You can move one room")
 (format t "~%Shoot: You have 5 arrows. You lose when you run out. Each arrow
   can go from 1 to 5 rooms. You aim by tellin the computer the rooms #'s you want
   the arrow to go to. If the arrows can't go there, it goes random. ")
 (format t "~%If the arrow hits the wumpus, you win")
 (format t "~%If the arrow hits you, you lose")

 (format t "~%~%Warnings: ")
 (format t "~%When you are one room away from a hazard or wumpus: ")
 (format t "~%~%Wumpus - I smell a wumpus")
 (format t "~%~%Bat - Bats nearby")
 (format t "~%~%Pit - I feel a draft")
)


(init)
