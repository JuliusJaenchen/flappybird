class Clouds {
  float xpos, ypos, speed, cloudSize;

  Clouds(float Cx, float Cy, float Csp, float Csi) {

    xpos = Cx;
    ypos = Cy;
    speed = Csp;
    cloudSize = Csi;
  }



  void moveCloud() {
    xpos -= speed;
  }

  void drawCloud() {
    //draw
    strokeWeight(0);
    stroke(255);
    fill(255);
    rectMode(CENTER);

    rect(xpos, ypos-10, 2*cloudSize, cloudSize-20, 50, 50, 25, 25);
    ellipse(xpos, ypos-cloudSize/2, cloudSize, cloudSize);
    stroke(255);
    strokeWeight(3);
    arc(xpos, ypos-cloudSize/2, cloudSize, cloudSize, 0.02*PI, PI-0.02*PI);
  }
  boolean isGone(){
   if ((xpos+cloudSize<0)&&(xpos-cloudSize>width)) {
     return true;
   }else{
     return false;
   }
  }
}
