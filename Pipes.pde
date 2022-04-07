class Pipes {
  float pipeGapMiddle;
  float pipeX;
  float bottomPipeY;
  float topPipeY;
  float pipeSpeed;
  float pipeWidth = 50;

  Pipes (float PpipeGapMiddle, float Px) {
    pipeGapMiddle = PpipeGapMiddle;
    pipeX = Px;
  }

  void movePipe(float pipeSpeed) {
    pipeX -= pipeSpeed;
  }

  void drawPipe() {
    bottomPipeY = pipeGapMiddle+pipeGap;
    topPipeY = pipeGapMiddle-pipeGap;
    fill(90, 229, 81);  //Pipe color
    strokeWeight(1);
    stroke(0);
    rectMode(CORNER);

    //Bottom pipe
    rect(pipeX, bottomPipeY, pipeWidth, height-bottomPipeY); //Pipe 
    rect(pipeX-3, bottomPipeY-19, pipeWidth+pipeWidth/10, 20, 4, 4, 1, 1); //Pipe entry

    //Top pipe  
    rect(pipeX, 0, pipeWidth, topPipeY); //Pipe
    rect(pipeX-3, topPipeY, pipeWidth+pipeWidth/10, 20, 1, 1, 4, 4); //Pipe entry
  }

  void crashCheck() {
    if ((pipeX<=birdX+20)&&(pipeX+pipeWidth>=birdX-15)) {  //X value comparison
      if ((birdY+15>=bottomPipeY-15)||(birdY-15<=topPipeY+15)) {  //Y value comparison
        start = false;
        endscreen = true;
        resetPipes = true;
        resetClouds = true;
      }
    }
  }

  void checkScore() {
    if ((pipeX+50>birdX)&&(pipeX+40<birdX)) {
      if (scoreBuffer==false) {
        score += 1;
        scoreBuffer = true;
      }
    } else if ((pipeX+60>birdX)&&(pipeX+50<birdX)) {
      scoreBuffer = false;
    }
  }
  boolean isGone() {
    if ((pipeX<=-50)&&(pipeX+pipeWidth >= width+50)) {
      return true;
    } else {
      return false;
    }
  }
}
