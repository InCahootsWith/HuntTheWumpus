/*2:*/
#line 27 "HTW.w"

/*3:*/
#line 34 "HTW.w"

#include <iostream>
#include <string>
#include <stdlib.h>
#include <time.h>
#include <iomanip>

using namespace std;

/*:3*/
#line 28 "HTW.w"

/*4:*/
#line 44 "HTW.w"


int withDanger(int&player,int&wumpus,int bats[2],int pits[2]);


void closeDanger(int wumpus,int bats[2],int pits[2],int closeRooms[3]);


int turn(int player,
int closeRooms[3],
int roomsOrder[20],
int&wumpus,
int&arrows,
int roomsIndex[20][3],
int roomsOrderBack[20]);


void shoot(int player,int wumpus,int roomsIndex[20][3],int roomsOrderBack[20]);


int wumpusMove(int wumpus,int roomsIndex[20][3]);

void instructions();

void shuffle(int(&arrayX)[20],int(&arrayY)[20]);


void setDangers(int&wumpus,int(&arrayBats)[2],int(&arrayPits)[2],int(&save)[5]);


void reset(
int&player,
int&wumpus,
int(&arrayBats)[2],
int(&arrayPits)[2],
int(&save)[5],
int arrows
);

bool replay();


/*:4*/
#line 29 "HTW.w"

/*5:*/
#line 87 "HTW.w"

int main(){

/*6:*/
#line 106 "HTW.w"


int player= 0;
int wumpus,bats[2],pits[2];
int arrows= 5;
char reply;
int roomsOrder[20],roomsOrderBack[20];
int closeRooms[3];
int save[5];

int roomsIndex[20][3]= {

{4,7,1},
{0,9,2},
{1,11,3},
{2,13,4},
{3,5,0},
{14,4,6},
{5,16,7},
{6,0,8},
{7,17,9},
{8,1,10},
{9,18,11},
{10,2,12},
{11,19,13},
{12,3,14},
{13,15,5},
{19,14,16},
{15,6,7},
{16,8,18},
{17,10,19},
{18,12,15}

};

/*:6*/
#line 90 "HTW.w"

/*7:*/
#line 144 "HTW.w"

/*8:*/
#line 156 "HTW.w"

shuffle(roomsOrder,roomsOrderBack);

/*:8*/
#line 145 "HTW.w"

/*9:*/
#line 163 "HTW.w"

setDangers(wumpus,bats,pits,save);

/*:9*/
#line 146 "HTW.w"


/*:7*/
#line 91 "HTW.w"

/*10:*/
#line 171 "HTW.w"


cout<<"Instructions (Y | N) : ";
cin>>reply;

if(reply=='Y'or reply=='y'){
instructions();
}else{
cout<<"You're in for a mistake"<<endl;
}

/*:10*/
#line 92 "HTW.w"

/*11:*/
#line 185 "HTW.w"


cout<<"\n --- HUNT DAT WUMPUS --- \n"<<endl;

while(arrows> 0){

int wD= withDanger(player,wumpus,bats,pits);

if(wD==1){
wumpus= wumpusMove(wumpus,roomsIndex);

if(wumpus==player){
cout<<"--- GAME OVER! THE WUMPUS GOT YOU ---"<<endl;
if(replay()){
reset(player,wumpus,bats,pits,save,arrows);
}
}
}else if(wD==2){
if(replay()){
reset(player,wumpus,bats,pits,save,arrows);
}
}

for(int i= 0;i<3;i++){
closeRooms[i]= roomsIndex[player][i];
}

closeDanger(wumpus,bats,pits,closeRooms);

player= roomsOrderBack[turn(player,
closeRooms,
roomsOrder,
wumpus,
arrows,
roomsIndex,
roomsOrderBack)];
}

cout<<"You are out of arrows...rip"<<endl;
if(replay()){
reset(player,wumpus,bats,pits,save,arrows);
}

/*:11*/
#line 93 "HTW.w"


return 0;
}

/*:5*/
#line 30 "HTW.w"

/*12:*/
#line 233 "HTW.w"

/*13:*/
#line 247 "HTW.w"


void shuffle(int(&arrayX)[20],int(&arrayY)[20]){

int j,t;
srand(time(NULL));

for(int i= 0;i<20;i++){
arrayX[i]= i;
}

for(int i= 19;i> -1;i--){
j= rand()%(i+1);
t= arrayX[j];
arrayX[j]= arrayX[i];
arrayX[i]= t;

arrayY[arrayX[i]]= i;

}

}

/*:13*/
#line 234 "HTW.w"

/*14:*/
#line 277 "HTW.w"


void setDangers(int&wumpus,int(&arrayBats)[2],int(&arrayPits)[2],int(&save)[5]){

int v= 19;

for(int i= 0;i<5;i++){
save[i]= rand()%v+1;
v--;
}
srand(time(NULL));

wumpus= save[0];

arrayBats[0]= save[1];
arrayBats[1]= save[2];

arrayPits[0]= save[3];
arrayPits[1]= save[4];


}

/*:14*/
#line 235 "HTW.w"

/*15:*/
#line 309 "HTW.w"


int withDanger(int&player,int&wumpus,int bats[2],int pits[2]){

if(player==wumpus){
return 1;
}

for(int i= 0;i<2;i++){
if(player==bats[i]){
cout<<"Oh!! the bats got you!! Where will you go?!"<<endl;
srand(time(NULL));
player= rand()%20;
}
if(player==pits[i]){
cout<<"AHHHHHHH you fell into a pit"<<endl;
cout<<"HA HA HA - YOU LOSE!"<<endl;
return 2;
}
}

return 0;

}


void closeDanger(int wumpus,int bats[2],int pits[2],int closeRooms[3]){

for(int i= 0;i<3;i++){
if(wumpus==closeRooms[i]){
cout<<"I smell a wumpus..."<<endl;
}
for(int j= 0;j<2;j++){
if(bats[j]==closeRooms[i]){
cout<<"Bats nearby"<<endl;
}
if(pits[j]==closeRooms[i]){
cout<<"I feel a draft"<<endl;
}
}
}
}

/*:15*/
#line 236 "HTW.w"

/*16:*/
#line 358 "HTW.w"


int wumpusMove(int wumpus,int roomsIndex[20][3]){

int closeRooms[3];

srand(time(NULL));
int i= rand()%4;

if(i==4){
return wumpus;
}else{
wumpus= roomsIndex[wumpus][i];
}

return wumpus;
}

/*:16*/
#line 237 "HTW.w"

/*17:*/
#line 393 "HTW.w"


int turn(int player,
int closeRooms[3],
int roomsOrder[20],
int&wumpus,
int&arrows,
int roomsIndex[20][3],
int roomsOrderBack[20]){

char reply;
int roomTo= 0;
int playerRoom= roomsOrder[player];

cout<<"You are in room: "<<playerRoom<<endl;

cout<<"Tunnels lead to: ";
for(int i= 0;i<3;i++){
cout<<roomsOrder[closeRooms[i]]<<"   ";
}
cout<<endl;

cout<<"\nMove or Shoot (M|S): ";
cin>>reply;

if(reply=='M'||reply=='m'){

cout<<"Where to?: ";
cin>>roomTo;
cout<<endl;

for(int i= 0;i<3;i++){
if(roomTo==roomsOrder[closeRooms[i]]){
return roomTo;

}
}

}else if(reply=='S'||reply=='s'){
arrows--;
shoot(player,wumpus,roomsIndex,roomsOrderBack);
}else{
cout<<"Bad input, try again: "<<reply<<endl;
}
cout<<endl;
return playerRoom;

}

void shoot(int player,int wumpus,int roomsIndex[20][3],int roomsOrderBack[20]){

int rooms[5]= {0};
int reply,num,prev= -1;
int arrowsIndex= player;
bool okay= true;
int room;

cout<<"No. of Rooms?: ";
cin>>num;

cout<<"Rooms#? : ";

for(int i= 0;i<num;i++){
cin>>reply;
rooms[i]= roomsOrderBack[reply];
}

int i= 0;
while(okay&&i<num){
for(int j= 0;j<3;j++){
if(rooms[i]==roomsIndex[arrowsIndex][j]){
okay= true;
arrowsIndex= rooms[i];
break;
}
}
okay= false;

i++;
if(arrowsIndex==wumpus&&i<num){
wumpus= wumpusMove(wumpus,roomsIndex);
}
}

prev= arrowsIndex;
if(!okay){
for(int p= i;p<num;p++){
srand(time(NULL));
room= rand()%2;
if(roomsIndex[arrowsIndex][room]!=prev){
arrowsIndex= roomsIndex[arrowsIndex][room];
}else{
arrowsIndex= roomsIndex[arrowsIndex][room+1];
}
prev= arrowsIndex;
if(arrowsIndex==wumpus&&p!=num){
wumpus= wumpusMove(wumpus,roomsIndex);
}
}
}

if(arrowsIndex==wumpus){
cout<<"AHA! YOU GOT THE WUMPUS!"<<endl;
cout<<"!!!THE WUMPUS’LL GETCHA NEXT TIME!!!"<<endl;
exit(0);
}

if(arrowsIndex==player){
cout<<"Shot your own foot there...oops"<<endl;
exit(0);
}
}

/*:17*/
#line 238 "HTW.w"

/*18:*/
#line 515 "HTW.w"


bool replay(){

char reply;
cout<<"_________________________________"<<endl;
cout<<"\nRestart - Same setup? (Y|N) : ";
cin>>reply;

if(reply=='Y'||reply=='y'){
return true;
}else{
return false;
}

}

void reset(
int&player,
int&wumpus,
int(&arrayBats)[2],
int(&arrayPits)[2],
int(&save)[5],
int arrows
){

player= 0;

wumpus= save[0];

arrayBats[0]= save[1];
arrayBats[1]= save[2];

arrayPits[0]= save[3];
arrayPits[1]= save[4];

arrows= 5;

}


/*:18*/
#line 239 "HTW.w"

/*19:*/
#line 560 "HTW.w"



void instructions(){

cout<<"\n --- WELCOME TO HUNT THE WUMPUS --- \n "<<endl;
cout
<<"THE WUMPUS LIVES IN A CAVE OF  20 ROOMS."
<<"EACH ROOM HAS 3 TUNNELS LEADING TO OTHER ROOMS"
<<"(LOOK AT A DODECAHEDRON IS, ASK SOMEONE) \n"
<<"\nHAZARDS: \n"
<<"     BOTTOMLESS PITS - "
<<"TWO ROOMS HAVE BOTTOMS LESS PITS IN THEM."
<<"IF YOU GO THERE, YOU FALL INTO THE PIT (AND LOSE!) \n"
<<"     SUPER BATS - "
<<"TWO OTHER ROOMS HAVE SUPER BATS."
<<"IF YOU GO THERE, A BAT GRABS YOU AND TAKES YOU TO SOME OTHER ROOM AT RANDOM.\n"
<<"\nWUMPUS: \n"
<<"     THE WUMPUS IS NOT BOTHERED BY THE HAZARDS"
<<"(HE HAS SUCKER FEET AND IS TOO FAT)"
<<"USUALLY HE IS ASLEEP."
<<"TWO THINGS WAKE HIM UP: "
<<"YOU'RE ENTERING HIS ROOM OR YOU'RE SHOOTING AN ARROW. \n\n"
<<"IF THE WUMPUS WAKES, HE SOMETIMES RUNS TO THE NEXT ROOM.\n"
<<"IF YOU HAPPEN TO BE IN THE SAME ROOM WITH HIM, YOU LOSE.\n"

<<"\nYOU: \n"
<<"EACH TURN YOU MAY MOVE OR SHOOT A CROOKED ARROW.\n"
<<"     MOVE: YOU CAN MOVE ONE ROOM (THROUGH ONE TUNNEL.) \n"
<<"     SHOOT: YOU HAVE 5 ARROWS."
<<"YOU LOSE WHEN YOU RUN OUT."
<<"EACH ARROW CAN GO FROM 1 TO 5 ROOMS."
<<"YOU AIM BY TELLING THE COMPUTER THE #'S YOU WANT THE ARROW TO GO TO."
<<"IF THE ARROW CAN'T GO THAT WAY, IT MOVES AT RANDOM TO THE NEXT ROOM. \n"
<<"     IF THE ARROW HITS THE WUMPUS, YOU WIN.\n"
<<"     IF THE ARROW HITS YOU, YOU LOSE. \n"

<<"\nWARNINGS: \n"
<<"WHEN YOU ARE ONE ROOM AWAY FROM WUMPUS OR HAZARD, THE COMPUTER SAYS: \n"
<<"     WUMPUS - I SMELL A WUMPUS \n"
<<"     BAT - BATS NEARBY \n"
<<"     PIT - I FEEL A DRAFT \n"

<<endl;
}/*:19*/
#line 240 "HTW.w"



/*:12*/
#line 31 "HTW.w"


/*:2*/
