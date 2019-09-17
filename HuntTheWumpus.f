      PROGRAM HUNTTHEWUMPUS
*
*       Program for the turn / text based game Hunt the Wumpus
*       Written by: ec898
*       Open date: 10 Mar 2018
*       Completed: 26 March 2018 - full complete with no error testers
*
*


*       RoomsI == rooms indexs
*       RoomsO == rooms order
*       RoomsOB == rooms order backwards
*       Links == Index of the links


*       RoomsI groups = 3n-2, 3n-1, 3n

        INTEGER RoomsI(60)
        INTEGER RoomsO(20)
        INTEGER RoomsOB(20)
        INTEGER Links(3)
        INTEGER Dangers(5)

        CHARACTER MorS
        CHARACTER YorN

*        Game play variables

        INTEGER Bats(2)
        INTEGER Pits(2)
        INTEGER ShootO(5)

        LOGICAL FoundI, REPLAY, OKAY, GotArrows

        INTEGER Arrows, User, Wumpus, I, T, J, RoomNum, ArrowI
        INTEGER testI, CurrentI, x

        COMMON /WM/ RoomsI, Wumpus

        MorS = 'M'
        YorN = 'Y'

*       Connecting the rooms -> done this way for readability

        RoomsI(1)=5
        RoomsI(2)=8
        RoomsI(3)=2
        RoomsI(4)=1
        RoomsI(5)=10
        RoomsI(6)=3
        RoomsI(7)=2
        RoomsI(8)=12
        RoomsI(9)=4
        RoomsI(10)=3
        RoomsI(11)=14
        RoomsI(12)=5
        RoomsI(13)=4
        RoomsI(14)=6
        RoomsI(15)=1
        RoomsI(16)=15
        RoomsI(17)=5
        RoomsI(18)=7
        RoomsI(19)=6
        RoomsI(20)=17
        RoomsI(21)=8
        RoomsI(22)=7
        RoomsI(23)=1
        RoomsI(24)=9
        RoomsI(25)=8
        RoomsI(26)=18
        RoomsI(27)=10
        RoomsI(28)=9
        RoomsI(29)=2
        RoomsI(30)=11
        RoomsI(31)=10
        RoomsI(32)=19
        RoomsI(33)=12
        RoomsI(34)=11
        RoomsI(35)=3
        RoomsI(36)=13
        RoomsI(37)=12
        RoomsI(38)=20
        RoomsI(39)=14
        RoomsI(40)=13
        RoomsI(41)=4
        RoomsI(42)=15
        RoomsI(43)=14
        RoomsI(44)=16
        RoomsI(45)=6
        RoomsI(46)=20
        RoomsI(47)=15
        RoomsI(48)=17
        RoomsI(49)=16
        RoomsI(50)=7
        RoomsI(51)=18
        RoomsI(52)=17
        RoomsI(53)=9
        RoomsI(54)=19
        RoomsI(55)=18
        RoomsI(56)=11
        RoomsI(57)=20
        RoomsI(58)=19
        RoomsI(59)=13
        RoomsI(60)=16

        DO I = 1,20
          RoomsO(I) = I
        END DO

*       Fisher Yates sort on the room order - changes every time

100     CALL SRAND(TIME())

        DO I = 20, 1, -1
          R = RAND()
          J = I * R + 1
          T = RoomsO(I)
          RoomsO(I) = RoomsO(J)
          RoomsO(J) = T
*         backwards index
          RoomsOB(RoomsO(I)) = I
        END DO


*       Actual game time - Placing the characters in their postions -> works off index
*       90 label -> reset the game from same setup -> for pit fall only

        DO I = 1, 5
*         Seperating the Dangers for the start of the game
400       x = MOD(IRAND(),20)
          DO II = 1, I
            IF (Dangers(II) .EQ. x) THEN
              GO TO 400
            END IF
          END DO
          Dangers(I) = x
        END DO

90      Wumpus = Dangers(1)

        Bats(1) = Dangers(2)
        Bats(2) = Dangers(3)

        Pits(1) = Dangers(4)
        Pits(2) = Dangers(5)

        CurrentI = 1

*       Game variables concering the arrows

        Arrows = 5
        GotArrows = .TRUE.
        ArrowI = CurrentI


*       while statement - Actual game play -> game plays till the arrows = 0 or Wumpus or Pit

        WRITE(*,*) '_________HUNT DAT WUMPUS_________'

*       Game Play

200     DO WHILE(GotArrows)

*         gets me the index of roomsI() to work with in rooms0() and comparison

          Links(1) = RoomsI(3 * CurrentI - 2)
          Links(2) = RoomsI(3 * CurrentI - 1)
          Links(3) = RoomsI(3 * CurrentI)

*         Check for bats

          DO I = 1, 2
            IF (Bats(I) .EQ. CurrentI) THEN
                WRITE(*,*) 'Oh!! the bats got you!! Where will you go?!'
                CurrentI = MOD(IRAND(),20)
            END IF
            DO J = 1, 3
              IF (Bats(I).EQ. Links(J) .AND. Arrows .NE. 0) THEN
                WRITE(*,*) '--- Bats Nearby ---'
              END IF
            END DO
          END DO

*         Check for pits

          DO I = 1, 2
            IF (Pits(I) .EQ. CurrentI) THEN
                WRITE(*,*) 'AHHHHHHH you fell into a pit'
                WRITE(*,*) 'HA HA HA - YOU LOSE! '
                WRITE(*,5)
  5             FORMAT(' Restart - Same setup? (Y|N) : ', $)
                READ(*,*) YorN
                IF (YorN .EQ. 'Y') THEN
                  GO TO 90
                ELSE
                  GO TO 100
                END IF
            END IF
            DO J = 1, 3
              IF (Pits(I).EQ. Links(J) .AND. Arrows .NE. 0) THEN
                WRITE(*,*) '---  I feel a draft ---'
              END IF
            END DO
          END DO

*         Check for Wumpus -> if same cave give wumpus a chance to move then check again

          IF (Wumpus .EQ. CurrentI) THEN
              CALL WUMPMOVE()
              IF (Wumpus .EQ. CurrentI) THEN
                WRITE(*,*) '--- GAME OVER! THE WUMPUS GOT YOU ---'
                EXIT
              END IF
          ELSE IF (ArrowI .EQ. Wumpus) THEN
            WRITE(*,*) 'AHA! YOU GOT THE WUMPUS! '
            WRITE(*,*) '!!!THE WUMPUS’LL GETCHA NEXT TIME!!!'
            EXIT
          END IF

          DO I = 1, 3
            IF (Wumpus .EQ. Links(I)) THEN
              WRITE(*,*) '--- I smell a Wumpus... ---'
              EXIT
            END IF
          END DO

*         Check for how many arrows we have left -> if none then leave the loop

          IF (Arrows .EQ. 0) THEN
            WRITE(*,*) ' --- You are out of Arrows! GAME OVER!!! ---'
            GotArrows = .FALSE.
            GO TO 200
          END IF

*          Outputting room options

          WRITE(*,6)
6         FORMAT(' You are in Room ', $)
          WRITE(*,*) RoomsO(CurrentI)
          WRITE(*,7)
7         FORMAT(' Arrows count    ', $)
          WRITE(*,*) Arrows
          WRITE(*,8)
8         FORMAT(' Tunnels lead to ', $)
          WRITE(*,*) RoomsO(Links(1)),RoomsO(Links(2)),RoomsO(Links(3))

*         move or shoot options

          WRITE(*,9)
9         FORMAT(' Move or Shoot (M-S)? : ', $)
          READ(*,*) MorS

*         Move rooms option

          IF(MorS .EQ. 'M') THEN

*         option is a ROOM not an index -> getting user input

            WRITE(*,10)
10          FORMAT(' Room#? : ', $)
            READ(*,*) Option

*         finds the index of the room using the backwards lookup -> checks if actually an option

            DO I = 1, 3
              IF (Option .EQ. RoomsO(Links(I))) THEN
                  CurrentI = RoomsOB(Option)
                  EXIT
              END IF
            END DO

*         Shoot option

        ELSE IF (MorS .EQ. 'S') THEN

          Arrows = Arrows - 1

          WRITE(*,11)
11        FORMAT(' No. of Rooms? : ', $)
          READ(*,*) RoomNum


          WRITE(*,12)
12        FORMAT(' Rooms#? : ', $)
          READ(*,*)(ShootO(I), I=1, RoomNum)

          OKAY = .FALSE.
          ArrowI = CurrentI
          preSet = ArrowI

*           for the number of rooms entered - loop the arrows path

          DO II = 1, RoomNum

*           for the number of paths that actually connect - loop - else will enter FALSE loop for rand paths

            DO III = 1, 3
              testI = RoomsI(preSet)

              IF (testI .EQ. RoomsOB(ShootO(II))) THEN
                ArrowI = RoomsOB(ShootO(II))
                OKAY = .TRUE.
                EXIT
              END IF

              preSet = preSet + 1

            END DO

*             If the arrows shoots past the wumpus -> wumpass moves it's bottom

            IF(ArrowI.EQ.Wumpus .AND. II .NE. RoomNum) THEN
              CALL WUMPMOVE()
            END IF

            preSet = 3 * ArrowI - 2

*             arrows chosen path is no longer true -> random path -> stops the arrow from re-entering where it just came from

            IF(.NOT. OKAY) THEN

*               IN THEORY -> arrowI = testI but not actually yet
*               stop the arrow from entering where it came from -> this is the room you are going to -
*                 these are your connections! -> do not connect to what you already are

              DO J = II + 1, RoomNum
                IF (RoomsI(3 * testI - 2) .EQ. ArrowI) THEN
                  ArrowI = RoomsI(3 * testI - 1)
                ELSE
                  ArrowI = RoomsI(3 * testI - 2)
                END IF

*             If the arrows shoots past the wumpus -> wumpass moves it's bottom

                IF(ArrowI.EQ.Wumpus .AND. J .NE. RoomNum) THEN
                  CALL WUMPMOVE()
                END IF
              END DO

              EXIT
            ELSE
              OKAY = .FALSE.
            END IF

*          END DO FOR II

          END DO
        END IF

        WRITE(*,*)'______________________________'

*         Ending the game loop

        END DO

        WRITE(*,13)
13     FORMAT(' Play Again? (Y|N) : ', $)
        READ(*,*) YorN

        IF (YorN .EQ. 'Y') THEN
          GO TO 100
        END IF

        END


*     calculates where the wumpus moves if the user is in it's cave or if an arrow shoots past it
*     he can get rather lazy 25% of the time and stay in his cave

      SUBROUTINE WUMPMOVE()

        INTEGER x, Wumpus
        INTEGER RoomsI(60)

        COMMON /WM/ RoomsI, Wumpus
        CALL SRAND(TIME())
        x = MOD(IRAND(), 4)

        IF (x .LT. 4) THEN
          IF(x .EQ. 3) THEN
            Wumpus = RoomsI((3 * Wumpus))
          ELSE
            Wumpus = RoomsI((3 * Wumpus) - x)
          END IF
        END IF

      END
