//TUIO library
import TUIO.*;
TuioProcessing tuioClient;

//Minim audio library
import ddf.minim.*;
Minim minim;
AudioPlayer player;

//Video library
import processing.video.*;
Movie movie1;
Movie movie2;

//OSC library
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

//Create arrays of TuioCursors for P1 and P2
ArrayList <TuioCursor> playerOnes = new ArrayList(); 
ArrayList <TuioCursor> playerTwos = new ArrayList();

//Variables used to create scalable graphical feedback
float cursor_size = 50;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

//Game State variables
boolean gameStart = false;
boolean gameDefault = true;
boolean gameOver = false;
boolean playedStartMovie = false;
boolean playerOneWasAdded = false;
boolean playerTwoWasAdded = false;
boolean prepPlayerTwo = false;

//Timer variables
int savedTime;
int totalTime = 4000;
int savedTime2;
int totalTime2 = 2500;

//Button classes
Button[] buttons1 = new Button[5];
Button[] buttons2 = new Button[5];
Button[] buttons3 = new Button[5];
Button[] buttons4 = new Button[5];
Button[] buttons5 = new Button[5];
Button[] buttons6 = new Button[5];

int counter1;
int counter2;
int winner = 0;

String[] WinnerText = {
  " ", "PLAYER ONE WINS!", "PLAYER TWO WINS!"
};

void setup()
{

  size(1200, 700);
  noStroke();
  fill(0);
  
  //Load audio files
  minim = new Minim(this);
  player = minim.loadFile("GOTIT.WAV");

  //Load movie files
  movie1 = new Movie(this, "gameover.mov");
  movie2 = new Movie(this, "gamestarted.mov");

  oscP5 = new OscP5(this, 8888);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  //Set up buttons
  for (int i = 0; i < buttons1.length; i++) {
    buttons1[i] = new Button(0, i*100, 200, 100);
    buttons2[i] = new Button(200, i*100, 200, 100);
    buttons3[i] = new Button(400, i*100, 200, 100);
    buttons4[i] = new Button(600, i*100, 200, 100);
    buttons5[i] = new Button(800, i*100, 200, 100);
    buttons6[i] = new Button(1000, i*100, 200, 100);
  }

  frameRate(30);

  hint(ENABLE_NATIVE_FONTS);
  font = loadFont("Qubix-48.vlw");
  scale_factor = height/table_size;

  //Create an instance of the TuioProcessing client
  tuioClient  = new TuioProcessing(this);
  
  //Functions to reset game state back to default
  resetOne();
  resetTwo();
}

void draw()
{

  background(255);
  textFont(font, 18*scale_factor);
  float obj_size = object_size*scale_factor;
  float cur_size = cursor_size*scale_factor;

  stroke(0);

  fill(0);
  textFont(font, 32);
  
  //Display buttons
  for (int i = 0; i < buttons1.length; i++) {
    buttons1[i].display();
    buttons2[i].display();
    buttons3[i].display();
    buttons4[i].display();
    buttons5[i].display();
    buttons6[i].display();
  }

  Vector tuioCursorList = tuioClient.getTuioCursors();

  //DRAW PLAYER ONE
  //Loop through the current Array List, no matter what the size
  for (int i = 0; i < playerOnes.size(); i++) {

    //Grab the current tuioCursor in the index, store it in "thisCursor"
    TuioCursor thisCursor = (TuioCursor)playerOnes.get(i);  

    //Draw it with our function
    drawCircleOne (thisCursor);

    //How to get all of player one to interact with the grid
    for (int j = 0; j < buttons1.length; j++) {
      buttons1[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
      buttons2[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
      buttons3[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
      buttons4[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
      buttons5[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
      buttons6[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
    }
  }

  //DRAW PLAYER TWO
  //Loop through the current Array List, no matter what the size
  for (int i = 0; i < playerTwos.size(); i++) {
    
    //Grab the current tuioCursor in the index, store it in "thisCursor"
    TuioCursor thisCursor = (TuioCursor)playerTwos.get(i);
    
    //Draw it with our function
    drawCircleTwo (thisCursor);
    
    //How to get all of player two to interact with the grid
    for (int j = 0; j < buttons1.length; j++) {
      buttons1[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
      buttons2[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
      buttons3[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
      buttons4[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
      buttons5[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
      buttons6[j].click(thisCursor.getScreenX(width), thisCursor.getScreenY(height));
    }
  }

  textSize(32);

  //GAME STATES
  //Start game only after both players ready
  if (playerOneWasAdded == true) {  
    prepPlayerTwo = true;
  }
  
  //Default game state remains until both players are added & ready
  if (gameDefault == true) {
    text("WAITING FOR PLAYERS...", 500, 550);
    savedTime2 = millis();
    
    //Start game when both players are ready
    if (playerTwoWasAdded == true) {
      gameStart = true;
      playedStartMovie = false; 
      gameDefault = false;
    }
  }
  
  if (gameStart == true) {

    if (playedStartMovie == false) {
      
      //Send message via OSC to "Scoreboard" sketch to play "Game Started" animation
      OscMessage myMessage = new OscMessage("/test");
      myMessage.add(2);
      oscP5.send(myMessage, myRemoteLocation);
    }

    savedTime = millis();

    int passedTime2 = millis() - savedTime2;
    println(passedTime2);
    
    //Timer so "Game Started" animation stops playing
    if (passedTime2 > totalTime2) {
      movie2.stop();
      playedStartMovie = true; 
      savedTime2 = millis();
    }
    
    //Game over when less than 3 fingers are on the pad at any given moment
    if (tuioCursorList.size() < 3) {
      gameOver = true;
      gameStart = false;
    }
  }

  if (gameOver == true) {
    int passedTime = millis() - savedTime;
      
    //Send message via OSC to "Scoreboard" sketch to play "Game Over" animation
    OscMessage myMessage = new OscMessage("/test");
    myMessage.add(1);
    oscP5.send(myMessage, myRemoteLocation);
    
    //Timer to reset game to default after Game Over
    if (passedTime > totalTime) {
      gameDefault = true;
      gameStart = false;
      gameOver = false;
      resetOne();
      resetTwo();
      savedTime = millis();
    }
  }
}

//Function to draw P1 cursors on screen
void drawCircleOne(TuioCursor thisCursor) {
  stroke(192, 192, 192);
  fill(255, 192, 192);
  ellipse(thisCursor.getScreenX(width), thisCursor.getScreenY(height), 30, 30);
  fill(0);
  text(""+ thisCursor.getCursorID(), thisCursor.getScreenX(width)-5, thisCursor.getScreenY(height)+5);
  //  player.play();
}

//Function to draw P1 cursors on screen
void drawCircleTwo( TuioCursor thisCursor) {
  stroke(192, 192, 192);
  fill(192, 255, 192);
  ellipse(thisCursor.getScreenX(width), thisCursor.getScreenY(height), 30, 30);
  fill(0);
  text(""+ thisCursor.getCursorID(), thisCursor.getScreenX(width)-5, thisCursor.getScreenY(height)+5);
  //  player.play();
}


//These callback methods are called whenever a TUIO event occurs
//Called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());

  player.play();

  //While we still have space in the arraylist
  if (playerOneWasAdded == false) {    

    //Add the new cursor in!
    playerOnes.add(tcur); 
    println ("added to 1, size is: " + playerOnes.size()); 

    //If playerOnes is filled up, then set it to true to prevent anything else from being added
    if (playerOnes.size() > 2) {
      playerOneWasAdded = true;
      println("player one was added!");
    }
  }

  //Only when playerOnes is filled up can playerTwos start filling up
  else if (playerOneWasAdded == true) {
    if (playerTwoWasAdded == false) {
      playerTwos.add(tcur); 
      println ("added to 2, size is: " + playerTwos.size()); 
      if (playerTwos.size() > 2) {
        playerTwoWasAdded = true;
        println("player one was added!");
      }
    }
  }
}

// Called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  //  println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
  //    +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

// Called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  println ("THIS ID IS GONE: " + tcur.getCursorID() ); 

  //First let's figure out which arraylist we put the recently removed cursor in
  if (tcur.getCursorID() > -1 && tcur.getCursorID() < 3) {

    //Once we figure that out, let's find out which of the objects in the array match the removed cursor
    for (int i = 0; i < playerOnes.size(); i++) {
      TuioCursor tempCur = (TuioCursor)playerOnes.get(i); 
      if (tempCur.getCursorID() == tcur.getCursorID()) playerOnes.remove(i); //remove it!
    }

    println ("removed something from 1, new size: " + playerOnes.size());
  } 

  if (tcur.getCursorID() > 2 && tcur.getCursorID() < 6) {
    for (int i = 0; i < playerTwos.size(); i++) {
      TuioCursor tempCur = (TuioCursor)playerTwos.get(i); 
      if (tempCur.getCursorID() == tcur.getCursorID()) playerTwos.remove(i);
    }

    println ("removed something from 2, new size: " + playerTwos.size());
  } 

  //Let's set these to false just to make sure we can get new input
  if (playerOnes.size() < 3 ) playerOneWasAdded = false; 
  if (playerTwos.size() < 3 ) playerTwoWasAdded = false; 

  println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
}

// Called after each message bundle representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}

//Reset function #1
void resetOne() {
  playerOnes.clear();
  playerOneWasAdded = false;
}

//Reset function #2
void resetTwo() {
  playerTwos.clear();
  playerTwoWasAdded = false;
  movie1.stop();
  movie2.stop();

  //Reset the buttons
  for (int i = 0; i < buttons1.length; i++) {
    buttons1[i].on = false;
    buttons2[i].on = false;
    buttons3[i].on = false;
    buttons4[i].on = false;
    buttons5[i].on = false;
    buttons6[i].on = false;
  }
}

void movieEvent(Movie m) {
  m.read();
}

void gameStartMovie() {
  movie2.loop();
  imageMode(CENTER);
  image(movie2, width/2, 600);
}

void gameOverMovie() {
  movie1.loop();
  imageMode(CENTER);
  image(movie1, width/2, 600);
}

//Incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage theOscMessage) {
  //Print the address pattern and the typetag of the received OscMessage
  print("### alex sketch.");
  print(" addrpattern: " + theOscMessage.addrPattern());
  println(" typetag: " + theOscMessage.typetag());

  println(theOscMessage.get(0).intValue());
}
