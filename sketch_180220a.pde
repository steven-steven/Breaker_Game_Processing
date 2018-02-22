int screenMode = 0;  //0:initScreen 1:gameScreen 2:gameOverScreen 3:gameOverScreen

//gameItems
Ball b;
Racket r;
int initLife = 1;
int life;
ArrayList<Brick> bricks = new ArrayList<Brick>();


/*------ Setup -------*/
void setup() {
  size(500, 500); 
  b = new Ball();
  r = new Racket();
  life = initLife;
}

/*------ DRAW -------*/
void draw() {
  if (screenMode == 0) {
    initScreen();
  } else if (screenMode == 1) {
    gameScreen();
  } else if (screenMode == 2) {
    gameOverScreen();
  } else {
    winScreen();
  }
}

/*------ SCREEN DRAW --------*/
void initScreen() {
  background(0);
  textAlign(CENTER);
  textSize(20);
  text("Click To Begin", height/2, width/2);
}
void gameScreen() {
  background(255);
  drawText();
  brickHandler();
  r.drawRacket();
  b.drawBall(r);
  if (b.keepInScreen()==false) {
    decreaseLife();
  }
  b.watchRacketBounce(r.racketx, r.racketWidth, r.rackety);
}
void gameOverScreen() {
  background(0);
}
void winScreen() {
  background(0);
}

/*--Input Interrupts--*/
public void mousePressed() {
  if (screenMode == 0) {
    startGame();
  } else if (screenMode == 1) {
    if (!b.isBallReleased) {
      b.isBallReleased = true;
    }
  }
}

/*Other Functions*/
void startGame() {
  createBricks();
  screenMode = 1;
}
void gameOver() {
  //Reset Game
  screenMode = 2;
}
void drawText() {
  textAlign(RIGHT);
  textSize(15);
  text("Life: "+life, height-20, width-20);
}
void decreaseLife() {
  life--;
  if (life<0) {
    gameOver();
  }
}
void createBricks() {
  int brickNum = 10;
  int bwidth = width/brickNum;
  int bheight = 20;
  for (int i = 0; i<brickNum; i++) {
    int brickx = i*bwidth;
    int bricky = 30;
    color bcolor = color(255, 0, 0);
    bricks.add(new Brick(brickx, bricky, bheight, bwidth, bcolor));
  }
}
void brickHandler() {
  if (bricks.size() == 0) {
    //Win
    screenMode = 3;
  }

  int indexToRemove = -1;

  for (int i = 0; i< bricks.size(); i++) {
    Brick brick = bricks.get(i);
    if (brick.isDestroying || b.detectBrickCollision(brick.brickx, brick.bricky, brick.brickHeight, brick.brickWidth)) {
      brick.destroyBrick();
    }
    if (brick.isDestroyed) {
      indexToRemove = i;
    }
    brick.drawBrick();
  }

  if (indexToRemove >=0) {
    bricks.remove(indexToRemove);
  }
}



class Brick {
  int brickx, bricky;
  int brickWidth;
  int brickHeight;
  float rotationAngle = 0;
  color brickColor;
  boolean isDestroyed = false;  //out of screen(destroyed)
  boolean isDestroying = false;  //process of destruction

  public Brick(int x, int y, int bheight, int bwidth, color c) {
    brickx = x;
    bricky = y;
    brickWidth = bwidth;
    brickHeight = bheight;
    brickColor = c;
    isDestroyed = false;
  }

  void drawBrick() {
    fill(brickColor);
    rectMode(CORNER);
    if(isDestroying){
      rotationAngle += PI/50;
      pushMatrix();
      translate(brickx+brickWidth/2, bricky+brickHeight/2);
      rotate(rotationAngle);
      rect(-brickWidth/2, -brickHeight/2, brickWidth, brickHeight);
      popMatrix();
      return;
    }
    rect(brickx, bricky, brickWidth, brickHeight);
  }

  void destroyBrick() {
    isDestroying = true;
    bricky +=3;
    if(bricky-brickHeight/2 > height){
      isDestroyed = true;
    }
  }
}
class Racket {
  float racketx, rackety;
  int racketWidth = 100;
  int racketHeight = 10;
  int racketColor;

  public Racket() {
    racketColor = color(0);
    racketx = width/2;
    rackety = height - 50;
  }

  void drawRacket() {
    rectMode(CENTER);
    fill(racketColor);
    racketx = constrain(mouseX, racketWidth/2, width-racketWidth/2);
    rect(racketx, rackety, racketWidth, racketHeight);
  }
}

class Ball {

  float ballx, bally;
  int ballSize;
  int ballColor;
  boolean isBallReleased;
  float ballSpeedVert;
  float ballSpeedHoriz;

  public Ball() {
    ballSize = 20;
    ballColor = color(0);
    isBallReleased = false;
    ballSpeedVert = -4;
    ballSpeedHoriz = 0;
  }

  void drawBall(Racket r) {
    if (!isBallReleased) {
      ballx = r.racketx;
      bally = r.rackety - r.racketHeight/2 - ballSize/2;
      ballSpeedHoriz = 0;
    } else {
      moveBall();
    }
    fill(ballColor);
    ellipse(ballx, bally, ballSize, ballSize);
  }

  void moveBall() {
    bally += ballSpeedVert;
    ballx += ballSpeedHoriz;
  }

  void watchRacketBounce(float racketx, float racketWidth, float rackety) {
    //check ball-racket horizontal allign
    if ((ballx+ballSize/2 > racketx-racketWidth/2) &&  (ballx-ballSize/2< racketx+racketWidth/2)) {
      //check ball-racket vertical allign
      if (dist(ballx, bally, ballx, rackety) <= ballSize/2) {
        makeBounceBottom(rackety);
        ballSpeedHoriz = (ballx - racketx)/6;  //adjust division int for amount of horizontal movement
      }
    }
  }

  boolean detectBrickCollision(int brickx, int bricky, int brickHeight, int brickWidth) {
    if ((bally+ballSize/2 > bricky) &&  (bally-ballSize/2< bricky+brickHeight)) {
      //println("Within height range");
      if (dist(ballx, bally, brickx, bally) <= ballSize/2) {
        println("Hit from left");
        makeBounceRight(brickx);
        return true;
      } else if (dist(ballx, bally, brickx+brickWidth, bally) <= ballSize/2) {
        println("Hit from Right");
        makeBounceLeft(brickx+brickWidth);
        return true;
      }
    }
    if ((ballx+ballSize/2 > brickx) &&  (ballx-ballSize/2< brickx+brickWidth)) {
      //println("Within width range");
      if (dist(ballx, bally, ballx, bricky) <= ballSize) {
        println("Hit from Top");
        makeBounceBottom(bricky);
        return true;
      } else if (dist(ballx, bally, ballx, bricky + brickHeight) <= ballSize/2) {
        makeBounceTop(bricky + brickHeight);
        println("Hit from Bottom");
        return true;
      }
    }
    return false;
  }

  boolean keepInScreen() {
    if (bally + (ballSize/2) > height) {
      isBallReleased = false;
      return false;
    }
    if (bally - (ballSize/2) < 0) {
      makeBounceTop(0);
    }
    if (ballx + (ballSize/2) > width) {
      makeBounceRight(width);
    }
    if (ballx - (ballSize/2) < 0) {
      makeBounceLeft(0);
    }
    return true;
  }
  void makeBounceBottom(float surface) {
    bally = surface - ballSize/2;
    ballSpeedVert *= -1;
  }
  void makeBounceTop(float surface) {
    bally = surface + ballSize/2;
    ballSpeedVert *= -1;
  }
  void makeBounceLeft(float surface) {
    ballx = surface + ballSize/2;
    ballSpeedHoriz *= -1;
  }
  void makeBounceRight(float surface) {
    ballx = surface - ballSize/2;
    ballSpeedHoriz *= -1;
  }
}