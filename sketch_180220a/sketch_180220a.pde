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
  r.drawRacket();
  b.drawBall(r);
  brickHandler();
  if (b.keepInScreen()==false) {
    decreaseLife();
  }
  b.watchRacketBounce(r.location, r.racketWidth);
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
    if (brick.isDestroying || b.detectBrickCollision(brick.location, brick.brickHeight, brick.brickWidth)) {
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
  
  PVector location;
  int brickWidth;
  int brickHeight;
  
  PVector fallingVelocity;
  float rotationAngle = 0;
  color brickColor;
  boolean isDestroyed = false;  //out of screen(destroyed)
  boolean isDestroying = false;  //process of destruction

  public Brick(int x, int y, int bheight, int bwidth, color c) {
    location = new PVector(x,y);
    fallingVelocity = new PVector(0,3);
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
      translate(location.x+brickWidth/2, location.y+brickHeight/2);
      rotate(rotationAngle);
      rect(-brickWidth/2, -brickHeight/2, brickWidth, brickHeight);
      popMatrix();
      return;
    }
    rect(location.x, location.y, brickWidth, brickHeight);
  }

  void destroyBrick() {
    isDestroying = true;
    location.add(fallingVelocity);
    if(location.y-brickHeight/2 > height){
      isDestroyed = true;
    }
  }
}
class Racket {
  
  PVector location;
  int racketWidth = 100;
  int racketHeight = 10;
  int racketColor;

  public Racket() {
    racketColor = color(0);
    location = new PVector(width/2, height-50);
  }

  void drawRacket() {
    rectMode(CENTER);
    fill(racketColor);
    location.x = constrain(mouseX, racketWidth/2, width-racketWidth/2);
    rect(location.x, location.y, racketWidth, racketHeight);
  }
}

class Ball {

  //float ballx, bally;
  PVector location;
  PVector velocity;
  int ballSize;
  int ballColor;
  boolean isBallReleased;

  public Ball() {
    ballSize = 20;
    ballColor = color(0);
    isBallReleased = false;
    velocity = new PVector(0,-4);  //we will only change the x velocity
  }

  void drawBall(Racket r) {
    if (!isBallReleased) {
      location = new PVector(r.location.x, (r.location.y - r.racketHeight/2 - ballSize/2));
      velocity.x = 0;
    } else {
      moveBall();
    }
    fill(ballColor);
    ellipse(location.x, location.y, ballSize, ballSize);
  }

  void moveBall() {
    location.add(velocity);
  }

  void watchRacketBounce(PVector racketLocation, float racketWidth) {
    //check ball-racket horizontal allign
    if ((location.x+ballSize/2 > racketLocation.x-racketWidth/2) &&  (location.x-ballSize/2 < racketLocation.x+racketWidth/2)) {
      //check ball-racket vertical allign
      if (dist(location.x, location.y, location.x, racketLocation.y) <= ballSize/2) {
        makeBounceBottom(racketLocation.y);
        velocity.x = (location.x - racketLocation.x)/6;  //adjust division int for amount of horizontal movement
      }
    }
  }

  boolean detectBrickCollision(PVector brickLoc, int brickHeight, int brickWidth) {
    if ((location.y+ballSize/2 > brickLoc.y) &&  (location.y-ballSize/2< brickLoc.y+brickHeight)) {
      //println("Within height range");
      if (dist(location.x, location.y, brickLoc.x, location.y) <= ballSize/2) {
        println("Hit from left");
        makeBounceRight(brickLoc.x);
        return true;
      } else if (dist(location.x, location.y, brickLoc.x + brickWidth, location.y) <= ballSize/2) {
        println("Hit from Right");
        makeBounceLeft(brickLoc.x + brickWidth);
        return true;
      }
    }
    if ((location.x + ballSize/2 > brickLoc.x) &&  (location.x-ballSize/2< brickLoc.x + brickWidth)) {
      //println("Within width range");
      if (dist(location.x, location.y, location.x, brickLoc.y) <= ballSize) {
        println("Hit from Top");
        makeBounceBottom(brickLoc.y);
        return true;
      } else if (dist(location.x, location.y, location.x, brickLoc.y + brickHeight) <= ballSize/2) {
        makeBounceTop(brickLoc.y + brickHeight);
        println("Hit from Bottom");
        return true;
      }
    }
    return false;
  }

  boolean keepInScreen() {
    if (location.y + (ballSize/2) > height) {
      isBallReleased = false;
      return false;
    }
    if (location.y - (ballSize/2) < 0) {
      makeBounceTop(0);
    }
    if (location.x + (ballSize/2) > width) {
      makeBounceRight(width);
    }
    if (location.x - (ballSize/2) < 0) {
      makeBounceLeft(0);
    }
    return true;
  }
  
  void makeBounceBottom(float surface) {
    location.y = surface - ballSize/2;
    velocity.y *= -1;
  }
  void makeBounceTop(float surface) {
    location.y = surface + ballSize/2;
    velocity.y *= -1;
  } 
  void makeBounceLeft(float surface) {
    location.x = surface + ballSize/2;
    velocity.x *= -1;
  }
  void makeBounceRight(float surface) {
    location.x = surface - ballSize/2;
    velocity.x *= -1;
  }
}