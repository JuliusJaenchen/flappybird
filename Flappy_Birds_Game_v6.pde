import processing.sound.*;

float birdX;
float birdY;
float pipeGap;
boolean start;
boolean endscreen;
boolean beginning;
boolean blinking;
float birdSpeed;
int blinkDelay = 0;
boolean resetPipes;
boolean resetScore;
int score;
boolean hardcoreMode = false;
float wingrotation;
boolean crashTimeBufferBool = true;
float crashTimeBuffer;
int prevScore;
boolean resetClouds = false;
boolean scoreBuffer = false;
float pipeSpeed;
float greenStripeX;
float nextGreenStripeX;
int pipeTotal = 10;
int cloudTotal = 10;

Clouds[] Cloud = new Clouds[10000];

Pipes[] Pipe = new Pipes[2000];

SoundFile wingflap;
float wingflapBuffer = 0;
SoundFile failAudio;
SoundFile backgroundMusic;

void setup() { 
  //optimal tab size: 600, 500
  size(600, 500);
  frameRate(60);
  background(#43D3FF);


  //Audio----------- 
  wingflap = new SoundFile(this, "wingflap.wav");
  wingflap.amp(0.5);
  wingflap.rate(2);

  failAudio = new SoundFile(this, "losingHorn.wav");
  failAudio.amp(0.6);
  failAudio.rate(1.2);

  backgroundMusic = new SoundFile(this, "hopopono.mp3");
  backgroundMusic.loop();

  //all variables initial value
  score = 0; 
  prevScore = score;

  birdY = height/2;
  birdSpeed = 1;

  pipeGap = 100;  //(should be between 90 and 150)
  pipeSpeed = 2;

  start = false;
  endscreen = false;
  beginning = true;
  blinking=false;

  nextGreenStripeX= -50;

  //CLASSES----------------------
  initializeClouds();

  for (int index = 0; index < Pipe.length; index++) { //initalizes pipes
    Pipe[index]=  new Pipes(random(150, height - 130), width + index*300 + 100);
  }
}



void draw() {


  //RESET VALUES (if all reset booleans are true)------------------------------------------
  if (resetPipes) {
    for (int index = 0; index < Pipe.length; index++) { //Resetst all the pipes
      Pipe[index]=  new Pipes(random(150, height - 130), width + index*300 + 100);
    }
    pipeTotal = 10;
    pipeGap=100;
    pipeSpeed = 2;
    if (hardcoreMode==true) {
      pipeGap=70;
      pipeSpeed = 3;
    }
    resetPipes = false; //makes sure that this is only executed once
  }
  if (resetScore) {  //resets score to 0
    score = 0;
    prevScore = score;
    resetScore = false;   //makes sure that this is only executed once
  }
  if (resetClouds==true) {
    initializeClouds();
    cloudTotal = 10;
    resetClouds = false;  //makes sure that this is only executed once
  }


  //pipegap reductions & pipeTotal Expansion
  if ((pipeGap >= 70)&&(score>prevScore)) {  //executes every time the score increases
    pipeGap = pipeGap - 0.5;
    pipeTotal++;
    prevScore = score;
    if (hardcoreMode==false) {
      pipeSpeed += 0.02;
    } else {
      pipeSpeed += 0.04;
    }
  }

  cloudTotal = score + width/100;

  //BIRD MOVEMENT (up/down)---------------------------------------------
  birdX = width/5;
  if (start == true) {
    birdY = birdY + birdSpeed;
    birdSpeed = birdSpeed+0.5;
    if ((keyPressed==true)&&(key==' ')) {
      if (wingflapBuffer+200 < millis() && birdSpeed > 0) {
        wingflap.play();
        wingflapBuffer=millis();
      }
      birdSpeed = -5;
    }
  }
  //backround music

  if (!backgroundMusic.isPlaying() && !endscreen) {
    backgroundMusic.play();
  } else if (endscreen && backgroundMusic.isPlaying()) {
    backgroundMusic.pause();
  }


  //START and END SCREEN----------------------------------------
  if (beginning == true) {
    startScreen();
    if ((keyPressed==true)&&(key==' ')) {
      beginning = false;
      start = true;
    }
  }

  if (endscreen==true) {
    endScreen(); //draws the endscreen
    printScore(255); //prints the score in white
    if (crashTimeBufferBool) { // executes once 
      crashTimeBuffer = millis(); //markes the time at which the player crashed
      failAudio.play(); //endscreen audio
      crashTimeBufferBool = false;
    }
    if ((keyPressed==true)&&(key==' ')&&(crashTimeBuffer<millis()-500)) { //resests everything for the next attempt(half a second after the crash)
      endscreen = false;
      start = true;
      resetPipes = true;
      resetScore = true;
      birdY = height/2-100;
      crashTimeBufferBool = true; //enables a one-time execution 
    }
  } else {
    failAudio.stop();  //stops the failing music if player starts a new round
  }

  if (start==true) { 
    background(#4DE3FF);

    drawBackground();

    for (int i = 0; i < Cloud.length; i++) {
      Cloud[i].moveCloud();
    }
    for (int i = 0; i < cloudTotal; i++) {
      if (!Cloud[i].isGone()) {
        Cloud[i].drawCloud();
      }
    }

    movePipes(pipeSpeed);    //PipeSpeed
    for (int i = 0; i<pipeTotal; i++) {  //draws all of the clouds that are on or near the screen (that's what PipeTotal is for)
      if (!Pipe[i].isGone()) {
        Pipe[i].drawPipe();
        Pipe[i].crashCheck();
        Pipe[i].checkScore();
      }
    }

    drawFloor();
    drawBird();
    check4floorCrash();
  }

  if (start == true) {
    printScore (100); //color of the score (grayscale)
  }


  fill(0);
  textSize(10);
  textAlign(CORNER);
  text("FPS: "+int(frameRate), 0, 10);

  //debuging
}



void startScreen() { //start screen graphics
  fill(0);
  rectMode(CORNER);
  strokeWeight(20);
  stroke(255);
  rect( width/10, height/10, 8*width/10, 8*height/10);
  fill(255, 0, 0);
  textSize(50);
  textAlign(CENTER);
  text("Flappy Bird ", width/2, height/2 );
  textSize(20);
  text("Press [space] to start", width/2, height/2+50);
  text("(click on tab first)", width/2, height/2+150);
  if (blinking == true) {
    blinking = false;
    blinkDelay = millis();
  } else if (millis()-blinkDelay > 1000) {
    fill(0);
    strokeWeight(0);
    stroke(0);
    rectMode(CENTER);
    rect( width/2, height/2+50, 200, 50);
    if (millis()-blinkDelay > 2000) {
      blinkDelay = millis();
      blinking = true;
    }
  }
}

void endScreen() { //end screen graphics
  fill(0);
  rectMode(CORNER);
  strokeWeight(20);
  stroke(255);
  rect( width/10, height/10, 8*width/10, 8*height/10);
  fill(255, 0, 0);
  textSize(50);
  textAlign(CENTER);
  text("Game Over", width/2, height/2 );
  textSize(20);
  text("Press [space] to restart", width/2, height/2+50);
  //hardcore Mode
  textSize(15);
  if (hardcoreMode==false) {
    text("For hardcore mode: press [h]", width/2, height/1.2);
    if ((keyPressed==true)&&(key=='h')) {
      hardcoreMode = true;
    }
  } else {
    text("For regular mode: press [n]", width/2, height/1.2);
    if ((keyPressed==true)&&(key=='n')) {
      hardcoreMode = false;
    }
  }
  //blinking black box
  if (blinking == true) {
    blinking = false;
    blinkDelay = millis();
  } else if (millis()-blinkDelay > 1000) {
    fill(0);
    strokeWeight(0);
    stroke(0);
    rectMode(CENTER);
    rect( width/2, height/2+50, 230, 50);
    if (millis()-blinkDelay > 2000) {
      blinkDelay = millis();
      blinking = true;
    }
  }
}


void printScore(int scoreShading) {
  textAlign(CENTER);
  strokeWeight(10);
  textSize(50);
  fill(scoreShading);
  text(score, width/2, height/5);
}

void drawBird() {
  stroke(0);
  strokeWeight(1);

  //body
  fill(252, 248, 105); 
  ellipse(birdX, birdY, 30, 20);

  //Eyes
  fill(255); 
  ellipse(birdX+7, birdY-5, 12, 10);

  fill(0);
  rect(birdX+9, birdY-7, 1, 4, 50, 50, 50, 50);

  //Mouth
  fill(234, 28, 42); 
  rect(birdX-1, birdY, 20, 6, 5, 5, 5, 10);
  line(birdX+3, birdY+3, birdX+18, birdY+3);

  //Wings 
  pushMatrix();
  if (birdSpeed<1) {
    wingrotation = radians(-20);
  } else {
    wingrotation = radians(20);
  }
  translate(birdX, birdY);
  rotate(wingrotation);
  fill(255);
  ellipse(-8, 0, 12, 7);
  popMatrix();
}
void drawFloor() {
  fill(#FADB60);
  stroke(#02B20C);
  strokeWeight(5);
  rect(-10, height-20, width+20, 40);

  //floorstripes--------------
  nextGreenStripeX -= pipeSpeed; //moves the next stripe origin point

  fill(#008B01);
  stroke(#008B01);
  strokeWeight(0);
  while (greenStripeX<width+100) { //runs through each individual stripe
    greenStripeX += 30;
    quad(greenStripeX, height-22, greenStripeX+15, height-22, greenStripeX, height-18, greenStripeX-15, height-18);
  }

  greenStripeX = nextGreenStripeX; //resets stripe origin point to the next (moved) GreenStripeX
}
void drawBackground() {
  //BACKROUND BUSHES---------------
  strokeWeight(0);
  stroke(#58FF61);
  fill(#58FF61);
  for (int bushX = -50-millis()/50; bushX <= width+200; bushX = bushX+80) {
    stroke(#58FF61);
    ellipse(bushX, height-30, 150, 100);
    stroke(0);
    arc(bushX-40, height-15, 150, 100, PI+2*PI/6, PI+4*PI/6);
  }
}
void check4floorCrash() { 
  if (birdY+10>=height-20) {
    start = false;
    endscreen = true;
    resetClouds = true;
  }
}

void movePipes(float pipeSpeed) {
  for (int i = 0; i<Pipe.length; i++) {
    Pipe[i].movePipe(pipeSpeed);
  }
}

void initializeClouds() {
  for (int i = 0; i < Cloud.length; i++) {
    Cloud[i] = new Clouds(random(i*200-200, i*200), random(100, 300), random(0.2, 0.4), random(50, 70));
  }
}
//CLASSES------------------CLASSES--------------------------CLASSES------------------
