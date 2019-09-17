%
%    MAP OF THE GAME
%

map([0,4,7,1]).
map([1,0,9,2]).
map([2,1,11,3]).
map([3,2,13,4]).
map([4,3,5,0]).
map([5,14,4,6]).
map([6,5,16,7]).
map([7,6,0,8]).
map([8,7,17,9]).
map([9,8,1,10]).
map([10,9,18,11]).
map([11,10,2,12]).
map([12,11,19,13]).
map([13,12,3,14]).
map([14,13,15,5]).
map([15,19,14,16]).
map([16,15,6,7]).
map([17,16,8,18]).
map([18,17,10,19]).
map([19,18,12,15]).

%
%    START FOR SETTING UP AND STARTING THE GAME LOOP
%

start :-
  setup,
  write('------Hunt the Wumpus------'), nl,
  write('Instructions? (y/n) '),
  read_token(X),
  ((X == 'y'; X == 'Y') -> instructions ; write('')),
  game.

%
%    ASSERTS MY BABIES - VARIABLES
%
setup :-
  %sets the random placement of the dangers
  asserta(dang([])),
  randDanger(5),
  dang([B,BB,P,PP,W]),

  asserta(player(0)),
  asserta(bats([B,BB])),
  asserta(pits([P,PP])),

  %arrow count and the second is for arrow current index, previous index, final
  asserta(arrowC(4)),
  asserta(arrowI([-1,-1])),

  asserta(wumpus(W)),
  asserta(wumpusO(W)).

%
% SET OF FUNCTIONS TO the DANGERS
%

randDanger(C) :-
  (C \= 0 ->
    P is C - 1,
    dang(T),
    random(1,20,N),

    (inlist(N,T) -> N =:= 0 -> randDanger(C,T); pushFront(N,T,X), setDang(X)),

    randDanger(P)
    ;
    write('Ready!'),nl
  ).

setDang(X) :-
  dang(D),
  retract(dang(D)),
  asserta(dang(X)).

pushFront(Item, List, [Item|List]).



%
%    SETTERS FOR THE VARIABLES
%
setPlayer(X) :-
  player(P),
  retract(player(P)),
  asserta(player(X)).

setWumpus(X) :-
  wumpus(W),
  retract(wumpus(W)),
  asserta(wumpus(X)).

setBats(X,Z):-
  bats(B),
  retract(bats(B)),
  asserta(bats([X,Z])).

setPits(X,Z) :-
  pits(P),
  retract(pits(P)),
  asserta(pits([X,Z])).

%for the arrow count
setArrow(X) :-
  arrowC(C), %count

  retract(arrowC(C)),
  asserta(arrowC(X)).

%for reset of the arrow index - allows the game to be reset
resetArrowI(C) :-
  arrowI(I), %current index

  retract(arrowI(I)),
  asserta(arrowI([C,-1])). %current, previous

%current, before - for shooting the arrows around
setArrowI(C,B) :-
  arrowI(I), %current index

  retract(arrowI(I)),
  asserta(arrowI([C,B])). %current, previous


%
%    CHECKS IF VALUE IS IN THE LIST
%
inlist(X,[X|_]).
inlist(X,[_|Y]):-inlist(X,Y).

%inlist checks a given value against a list and return true if it's there
%else it gets the f** out of there -- thanks Ian for this code

%
%    CHECKS IF THE PLAYER IS IN DANGER AND REACTS APPROPRIATELY
%
inDanger :-
  batsDanger,
  pitsDanger.

wumpusDanger :-
  player(P),
  wumpus(W),
  (P =:= W -> moveWumpus ; nl).

% calculates when the wumpus needs to move it's bottom
moveWumpus :-
  random(0,4,N),
  wumpus(W),
  map([W,F,S,T]),
  (N =:= 1 -> setWumpus(F);
  (N =:= 2 -> setWumpus(S));
  (N =:= 3 -> setWumpus(T));
  nl).

batsDanger :-
  player(P),
  bats(B),
  (inlist(P,B) -> batsEffect ; write('')).

batsEffect :-
  random(0,19,N),
  setPlayer(N),

  write('ZAPPPPP....the bats got you!'),
  nl,
  write('Where will you go?!'),
  nl.

pitsDanger :-
  player(P),
  pits(B),
  (inlist(P,B) -> pitsEffect ; write('')).

pitsEffect :-
  write('You fell down a Pit!...poor you'), nl,
  reset.

%
%    CHECK IF THE PLAYER IS CLOSE TO DANGER AND PRINTS OUT WARNINGS
%
dangerCheck :-
  batsCheck,
  pitsCheck,
  wumpusCheck.

batsCheck :-
  bats([F,S]),
  player(P),
  map([P|X]),
  (inlist(F,X) -> write('Bats Nearby'), nl; write('')),
  (inlist(S,X) -> write('Bats Nearby'), nl; write('')).

pitsCheck :-
  pits([F,S]),
  player(P),
  map([P|X]),
  (inlist(F,X) -> write('I feel a draft'), nl; write('')),
  (inlist(S,X) -> write('I feel a draft'), nl; write('')).

wumpusCheck :-
  wumpus(F),
  player(P),
  map([P|X]),
  (inlist(F,X) -> write('I smell a wumpus'), nl; write('')).

%
%   RESET FUNCTIONS ALLOW FOR FUN GAME PLAY
%
reset :-
  write('Same set-up? (y/n)? '),
  read_token(X),
  resetArrowI(-1),
  ((X == 'y'; X == 'Y') -> same ; new).

%yes - same setup
same :-
  setPlayer(0),

  player(P),
  setArrow(4),

  wumpusO(W),
  setWumpus(W),

  nl,
  write('------Hunt the Wumpus------'), nl.

%no - new setup
new :-
  start.

%
%    CHECK STATE - CHECKS THE PLAYERS STATE -> WIN OR LOSE ?
%
checkState :-
  wumpus(W),
  player(P),
  %arrowI([0,0,-1]) current, previous, final
  arrowI([X,Y]),

  (W =:= P -> write('The Wumpus got you!!! loser...'), reset ; write('')),
  (W =:= X -> write('Aha! You got the Wumpus!....The Wumpus will get you next time!'), reset; write('')),
  (P =:= X -> write('You shot yourself in the bum!!! oh no...'), reset; write('')),

  resetArrowI(-1).

%
%    DEBUGGING FUNCTION
%
whereIs :-
  bats(B),
  pits(A),
  wumpus(C),
  write('Bats = '), write(B), nl,
  write('Pits = '), write(A), nl,
  write('Wumpus = '), write(C), nl.

%
%    CHECKS THE ARROW COUNT -> IF = 0 THEN GAME OVER
%
arrowCheck :-
  arrowC(C),
  (C < 0 -> write('You are out of arrows! Game Over ...'), reset ; write('')
  ).


%
%    PLAY THE GAME
%
game :-
  %check if you've won or lost?
  checkState,
  %checks the arrow count
  arrowCheck,
  %check if you're in danger
  inDanger,
  %check what danger is close and print
  dangerCheck,
  nl,
%  whereIs,
  %general Game Play
  outPut,
  %question of move or shoot?
  question,
  %checks the wumpus position
  wumpusDanger,
  nl,
  %replays the game
  game.


%
%    ASK THE USER IF THEY WANT TO MOVE OR SHOOT
%
question :-
  write('Move or Shoot? (m/s) '),
  read_token(X),
  ((X == 'M'; X == 'm') -> move;
  (X == 'S'; X == 's') -> shoot;
  write('Bad Input...try again')), nl.

%
%    OUTPUT OF THE PLAYERS CURRENT POSITION
%
outPut :-
  player(P),
  map([P|X]),
  write('You are in room: '),
  write(P), nl,
  write('Tunnels to: '),
  write(X), nl .

%
%    IF THE USER SHOOTS - THIS SETS THAT UP
%
shoot :-
  arrowC(X),

  %sets it up to have the current index of the player
  player(P),
  resetArrowI(P),

  T is X - 1,
  setArrow(T),

  write('Number of rooms? '),
  read_token(E),
  write('What rooms? '),
  getRooms(E, 0).


%
%    THIS GETS THE ROOMS FOR THE SHOOTING ARROW
%
getRooms(E, I) :-
  (E =:= I -> write('');
  I < E -> C is I + 1, read_token(X), shootRooms(X), getRooms(E, C); write('no')).

%get the arrows current map, if index = current map then okay else
%random direction that thing - RANDROOM
shootRooms(I) :-
  arrowI([C|P]),
  map([C|X]),
  (inlist(I,X) -> setArrowI(I,C); randRoom).

randRoom :-
  random(0,3,N),
  arrowI([C|P]),
  map([C,F,S,T]),
  ((N =:= 0 -> P \= F -> setArrowI(F,C));
  (N =:= 1 -> P \= S -> setArrowI(S,C));
  (N =:= 2 -> P \= T -> setArrowI(T,C));
  nl).


%
%    THIS IS FOR WHEN THE USER WANTS TO MOVE
%
move :-
  player(P),
  map([P|L]),
  write('What room?: '),
  read_token(X),
  (inlist(X,L) -> setPlayer(X); write('Bad input...try again')), nl.

%
%    PRINTS THE INSTRUCTIONS
%
instructions :-
  nl,
    write('WELCOME TO HUNT THE WUMPUS!! '),
  nl, write('THE WUMPUS LIVES IN A CAVE OF 20 ROOMS. '),
  nl, write('EACH ROOM HAS 3 TUNNELS LEADNG TO OTHER ROOMS'),
  nl, write('LOOK AT A DODECAHEDRON TO SEE HOW IT WORKS- '),
  nl, write('IF YOU DONNOT KNOW WHAT A DODECAHEDRON IS,'),
  nl, write('ASK SOMEONE '),
  nl, write( 'HAZARDS:  '),
  nl, write('BOTTEMLESS PITS: TWO ROOMS HAVE BOTTOMLESS PITS'),
  nl, write('IF YOU GO THERE, YOU FALL INTO THE PIT AND LOSE '),
  nl, write('SUPER BATS: TWO OTHER ROOMS HAVE SUPER BATS'),
  nl, write('IF YOU GO THERE, A BAT WILL MOVE YOU TO A RANDOM ROOM '),
  nl, write('WUMPUS:'),
  nl, write('THE WUMPUS ONLY BOTHERED BY YOU ENTERING HIS ROOM OR'),
  nl, write('YOUR ARROW SHOOTS INTO HIS ROOM '),
  nl, write('IF HE IS BOTHERED, HE MAY MOVE TO ANOTHER ROOM, '),
  nl, write('OR CHOOSE TO STAY IN THE SAME ROOM '),
  nl, write('IF YOU ARE IN THE SAME ROOM WITH THE WUMPUS, '),
  nl, write('HE WILL EAT YOU UP, AND YOU LOSE '),
  nl,nl, write('YOU: '),
  nl, write('EACH TURN YOU CAN MOVE OR SHOOT A CROOKED ARROW.'),
  nl, write('MOVE: YOU CAN MOVE ONE ROOM (THROUGH ONE TUNNEL.) '),
  nl, write('SHOOT: YOU HAVE 5 ARROWS. YOU LOSE WHEN YOU RUN OUT '),
  nl, write('EACH ARROW CAN GO FROM 1 TO 5 ROOMS. YOU AIM BY TELLING '),
  nl, write('THE COMPUTER THE ROOM #S YOU WANT THE ARROW TO GO TO. '),
  nl, write('IF THE ARROW CANNOT GO THAT WAY,'),
  nl, write('IT MOVES AT RANDOM TO THE NEXT ROOM.'),
  nl, write( 'IF THE ARROW HITS THE WUMPUS, YOU WIN. '),
  nl, write( 'IF THE ARROW HITS YOU, YOU LOSE.'),
  nl,nl, write('WARNINGS: '),
  nl, write('WHEN YOU ARE ONE ROOM AWAY FROM WUMPUS OR HAZARD,'),
  nl, write('THE COMPUTER SAYS '),
  nl, write('WUMPUS: I SMELL A WUMPUS'),
  nl, write('BAT: BATS NEARBY'),
  nl, write('PIT: I FEEL A DRAFT'), nl,nl,
  write('------Hunt the Wumpus------'), nl.
