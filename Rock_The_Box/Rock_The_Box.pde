
import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;

// audio stuff

Maxim maxim;
AudioPlayer[] logSounds;
AudioPlayer[] starSounds;
Accelerometer accel;

//Physics Engine
Physics physics; 
Body beater;
Body [] whiteKeys, blackKeys;

Vec2 gravity;
Vec2 screenBeaterPos;
CollisionDetector detector; 
Button btn;
int whiteKeyHeight = 300;
int whiteKeyWidth = 150;

int blackKeyHeight = 140;
int blackKeyWidth = 130;

int beaterSize = 70;

PImage beaterImage, whiteKeyLogImage, blackKeyStarImage, blackKeyStarGrayImage, backgroundImage;

int score = 0;
int score2;
int score3;


boolean isRocked = false;
boolean isFloor = false;
boolean isCeiling = false;
boolean isLeft = false;
boolean isRight = false;
boolean isAlt = false;
boolean isOn = false;

int aFrame =0;


int speed =0;

void setup() {

  frameRate(60);
  orientation(LANDSCAPE);
  accel = new Accelerometer();

  //load all the images
  whiteKeyLogImage = loadImage("log_300_150.png");
  blackKeyStarImage = loadImage("star_140.png");
  backgroundImage = loadImage("woods.png");
  blackKeyStarGrayImage = loadImage("star_gray140.png");
  beaterImage = loadImage("tinkerbell2.gif");

  //images' anchor point   
  imageMode(CENTER);

  //#&b on off button
 btn = new Button("#/b", 10, 100, 100, 100); 

  physics = new Physics(this, width, height, 0, -10, width*2, height*2, width, height, 100);

  physics.setCustomRenderingMethod(this, "myCustomRenderer");
  
  //almost no movement for whitekeys = logs
  physics.setDensity(200.0);

  //assign body phisics to each keys
  whiteKeys = new Body[8];
  blackKeys = new Body[5];
  final int GAP = 20;


  //whitekeys placement
  whiteKeys[0] = physics.createRect(GAP, height-whiteKeyHeight, 0+whiteKeyWidth, height);
  whiteKeys[1] = physics.createRect(GAP+whiteKeyWidth, height-whiteKeyHeight, 0+whiteKeyWidth*2, height);
  whiteKeys[2] = physics.createRect(GAP+whiteKeyWidth*2, height-whiteKeyHeight, 0+whiteKeyWidth*3, height);
  whiteKeys[3] = physics.createRect(GAP+whiteKeyWidth*3, height-whiteKeyHeight, 0+whiteKeyWidth*4, height);
  whiteKeys[4] = physics.createRect(GAP+whiteKeyWidth*4, height-whiteKeyHeight, 0+whiteKeyWidth*5, height);
  whiteKeys[5] = physics.createRect(GAP+whiteKeyWidth*5, height-whiteKeyHeight, 0+whiteKeyWidth*6, height);
  whiteKeys[6] = physics.createRect(GAP+whiteKeyWidth*6, height-whiteKeyHeight, 0+whiteKeyWidth*7, height);
  whiteKeys[7] = physics.createRect(GAP+whiteKeyWidth*7, height-whiteKeyHeight, 0+whiteKeyWidth*8, height);

  //no movement for blackkeys = Stars
  physics.setDensity(0.0);

  //ceiling space
  final int CEILING = 60;

  //blackkeys placement
  blackKeys[0] = physics.createRect(whiteKeyWidth/2, CEILING, whiteKeyWidth/2+blackKeyWidth, blackKeyHeight);
  blackKeys[1] = physics.createRect(whiteKeyWidth*1.5, CEILING, whiteKeyWidth*1.5+blackKeyWidth, blackKeyHeight);
  blackKeys[2] = physics.createRect(whiteKeyWidth*4-whiteKeyWidth/2, CEILING, (whiteKeyWidth*4-whiteKeyWidth/2)+blackKeyWidth, blackKeyHeight);
  blackKeys[3] = physics.createRect(whiteKeyWidth*5-whiteKeyWidth/2, CEILING, (whiteKeyWidth*5-whiteKeyWidth/2)+blackKeyWidth, blackKeyHeight);
  blackKeys[4] = physics.createRect(whiteKeyWidth*6-whiteKeyWidth/2, CEILING, (whiteKeyWidth*6-whiteKeyWidth/2)+blackKeyWidth, blackKeyHeight);

  //density for tinkerbell
  physics.setDensity(2.0);

  //tinkerbells' physics
  beater = physics.createCircle(width/2, 100, beaterSize/2);

  gravity = new Vec2(width/2, 200);
  gravity = physics.screenToWorld(gravity);

  // sets up the collision callbacks
  detector = new CollisionDetector (physics, this);

  maxim = new Maxim(this);

  //loading sounds for Blackkeys
  starSounds = new AudioPlayer[blackKeys.length];
  starSounds[0] = maxim.loadFile("star_di2.wav");
  starSounds[1] = maxim.loadFile("star_ri2.wav");
  starSounds[2] = maxim.loadFile("star_fi2.wav");
  starSounds[3] = maxim.loadFile("star_si2.wav");
  starSounds[4] = maxim.loadFile("star_li2.wav");

  for (int i=0;i<blackKeys.length;i++) {
    starSounds[i].setLooping(false);
    starSounds[i].volume(0.5);
  }

  //loading sound for whitekeys
  logSounds = new AudioPlayer[whiteKeys.length];
  logSounds[0] = maxim.loadFile("log_do3.wav");
  logSounds[1] = maxim.loadFile("log_re3.wav");
  logSounds[2] = maxim.loadFile("log_mi3.wav");
  logSounds[3] = maxim.loadFile("log_fa3.wav");
  logSounds[4] = maxim.loadFile("log_so3.wav");
  logSounds[5] = maxim.loadFile("log_la3.wav");
  logSounds[6] = maxim.loadFile("log_ti3.wav");
  logSounds[7] = maxim.loadFile("log_high_do3.wav");

  for (int i=0;i<whiteKeys.length;i++) {
    logSounds[i].setLooping(false);
    logSounds[i].volume(0.5);
  }
}


void draw() {
  image(backgroundImage, width/2, height/2, width, height);
  
  btn.display();

  //x, y, z position on the screen
  int x, y, z;
  x = (int) ((accel.getX() + 1) * 10)-10;
  y = (int) ((accel.getY() + 1) * 10)-10;
  z = (int) ((accel.getZ() + 1) * 10)-10;

  //white text with size 50
  fill(255);
  textSize(50);


  final int FORWARD = 10;
  final int BACKWARD = 5;
  final int RIGHT_L = 30;
  final int LEFT_L = -30;
  final int RIGHT_H = 50;
  final int LEFT_H = -50;

  //maping x & y coordinate of accelerator to actual screen space coordinate
  float vertical = map(x, -100, 100, 0, width-whiteKeyHeight);
  float horizontal = map(x, -100, 100, 0, height);
  screenBeaterPos = physics.worldToScreen(beater.getWorldCenter());


  //music scale text for each white key
  text("DO", 0, height/3 + 200);
  text("RE", whiteKeyWidth, height/3 + 200);
  text("MI", whiteKeyWidth *2, height/3 + 200);
  text("FA", whiteKeyWidth *3, height/3 + 200);
  text("SO", whiteKeyWidth *4, height/3 + 200);
  text("LA", whiteKeyWidth *5, height/3 + 200);
  text("TI", whiteKeyWidth *6, height/3 + 200);
  text("DO", whiteKeyWidth *7, height/3 + 200);

  //forward speed
  if (x < FORWARD && !isCeiling)
  {
    isRocked = true;
    isFloor = false;
    gravity = new Vec2(screenBeaterPos.x, screenBeaterPos.y-15);
    gravity = physics.screenToWorld(gravity);
    speed = 10;
  }

   //backward speed

  else if (x > BACKWARD && !isFloor )
  {
    isRocked = true;
    isCeiling = false;
    gravity = new Vec2(screenBeaterPos.x, screenBeaterPos.y+15);
    gravity = physics.screenToWorld(gravity);
    speed = 10;
  }

  //right speed slower if the tilt is week
  if (y > RIGHT_L && y < RIGHT_H)
  {
    isRocked = true;
    if (isLeft)
    {
      gravity = new Vec2(screenBeaterPos.x, screenBeaterPos.y);
    }
    else
    {
      gravity = new Vec2(screenBeaterPos.x + 12, screenBeaterPos.y);
    }
    gravity = physics.screenToWorld(gravity);
    isCeiling = false;
    isFloor = false;
    isRight = true;
    isLeft = false;
    speed = 1;
  }
  //left speed slower if the tilt is week
  else if (y < LEFT_L && y > LEFT_H)
  {
    isRocked = true;
    if (isRight)
    {
      gravity = new Vec2(screenBeaterPos.x, screenBeaterPos.y);
    }
    else {
      gravity = new Vec2(screenBeaterPos.x - 8, screenBeaterPos.y);
    }
    gravity = physics.screenToWorld(gravity);
    isCeiling = false;
    isFloor = false;
    isLeft = true;
    isRight = false;
    speed =  1;
  }

  //right speed faster if the tilt is big
  else if (y > RIGHT_H)
  {
    isRocked = true;
    gravity = new Vec2(screenBeaterPos.x + 12, screenBeaterPos.y);
    gravity = physics.screenToWorld(gravity);
    isCeiling = false;
    isFloor = false; 
    isRight = true;
    isLeft = false;
    speed = 1;
  }
  //left speed faster if the tilt is big
  else if (y < LEFT_H)
  {
    isRocked = true;
    if (isRight)
    {
      gravity = new Vec2(screenBeaterPos.x, screenBeaterPos.y);
    }
    else {
      gravity = new Vec2(screenBeaterPos.x - 8, screenBeaterPos.y);
    }
    gravity = physics.screenToWorld(gravity);
    isCeiling = false;
    isFloor = false;
    isLeft = true;
    isRight = false;    
    speed = 1;
  }

    //if tilted start moving
  if (isRocked)
  { 

    Vec2 impulse = new Vec2();
    impulse.set(gravity);
    impulse = impulse.sub(beater.getWorldCenter());
    impulse = impulse.mul(speed);
    beater.applyImpulse(impulse, beater.getWorldCenter());
    isRocked = false;
  }
}

//on off for #/b
void mousePressed()
{
  if(btn.mousePressed())
  {

    isAlt =! isAlt;
  }
}

//rendering
void myCustomRenderer(World world) {


  pushMatrix();
  translate(screenBeaterPos.x, screenBeaterPos.y);
  image(beaterImage, 0, 0, beaterSize, beaterSize);
  popMatrix();


  for (int i = 0; i < whiteKeys.length; i++)
  {
    Vec2 worldCenter = whiteKeys[i].getWorldCenter();
    Vec2 whiteKeysPos = physics.worldToScreen(worldCenter);
    pushMatrix();
    translate(whiteKeysPos.x, whiteKeysPos.y);
    image(whiteKeyLogImage, 0, 0, whiteKeyWidth, whiteKeyHeight);
    popMatrix();
  }

if(isAlt)
{
  for (int i = 0; i < blackKeys.length; i++)
  {
    Vec2 worldCenter = blackKeys[i].getWorldCenter();
    Vec2 blackKeysPos = physics.worldToScreen(worldCenter);
    pushMatrix();
    translate(blackKeysPos.x, blackKeysPos.y);
    image(blackKeyStarImage, 0, 0, blackKeyWidth, blackKeyHeight);
    popMatrix();
  }
}
else
{
  for (int i = 0; i < blackKeys.length; i++)
  {
    Vec2 worldCenter = blackKeys[i].getWorldCenter();
    Vec2 blackKeysPos = physics.worldToScreen(worldCenter);
    pushMatrix();
    translate(blackKeysPos.x, blackKeysPos.y);
    image(blackKeyStarGrayImage, 0, 0, blackKeyWidth, blackKeyHeight);
    popMatrix();
  }
}


} 
  

//collision detector

void collision(Body b1, Body b2, float impulse)
{

  for (int i=0;i<whiteKeys.length;i++) {
    if (b1 == whiteKeys[i] || b2 == whiteKeys[i]) {
      logSounds[i].cue(0);
      logSounds[i].play();
      isFloor = true;
    }
  }

  for (int i=0;i<blackKeys.length;i++) {
    if ((b1 == blackKeys[i] && isAlt)|| (b2 == blackKeys[i] && isAlt)) {
      starSounds[i].cue(0);
      starSounds[i].play();
      isCeiling = true;
    }
  }
}

