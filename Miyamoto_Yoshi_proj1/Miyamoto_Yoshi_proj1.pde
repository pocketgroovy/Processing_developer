//The MIT License (MIT) - See Licence.txt for details

//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies


Maxim maxim;
AudioPlayer playerB, playerD, playerG, playerK;
boolean isBassPlaying = false;
boolean isGtPlaying = false;
boolean isDrPlaying = false;
boolean isKeyPlaying = false;
float speedAdjust = 1.0;
int rotateDeck = 0;
float padColorR = 255.0;
float padColorG = 255.0;
float padColorB = 255.0;
float padColorR2 = 255.0;
float padColorG2= 255.0;
float padColorB2 = 255.0;
float cutoff = 10000.0;
float resonance = 0.5;

final String b = "Bass";
final String g = "Scratch";
final String d = "Dr";
final String k = "Key";
final String s = "Scratch Speed Pad";
final String f = "Filter";


void setup()
{
  size(640, 960);

  background(0);
  maxim = new Maxim(this);
  playerB = maxim.loadFile("135 House Bass 17_Bbm.wav");
  playerB.setLooping(true);

  playerD = maxim.loadFile("135 House Beat 38.wav");
  playerD.setLooping(true);

  playerG = maxim.loadFile("Vinyl Scratch 01.wav");
  playerG.setLooping(true);


  playerK = maxim.loadFile("135 House Resonant Chords_Bbm.wav");
  playerK.setLooping(true);
  // playerK.setFilter(playerK.getSample(), resonance);
}

void draw()
{
  // code that happens every frame

  rectMode(CENTER);
  fill(255);
  rect(80, 500, 140, 100, 30);
  rect(230, 500, 140, 100, 30);
  rect(380, 500, 140, 100, 30);
  rect(530, 500, 140, 100, 30);

  textSize(32);
 fill(0, 200, 100);
  text(d, 60, 510);
  text(b, 195, 510);
  text(g, 330, 510);
  text(k, 505, 510);  

  rectMode(CORNER);
  fill(padColorG, padColorB, padColorR);
  rect(0, 0, width, height/3);
  
  textSize(50);
  fill(0, 200, 100);
  text(f, width/5 * 2, 180);

  if (isKeyPlaying)
  {
    padColorR = map(mouseX, 0, width, 0, 255);
    padColorB = map(mouseY, 0, height/2, 0, 255);
    padColorG = dist(pmouseX, pmouseY, mouseX, mouseY);
  }

  fill(padColorR2, padColorG2, padColorB2);
  rect(0, 0+height/2 +100, width, height/2 -100, 30);
  textSize(50);
  strokeWeight(6);
  stroke(0, 255, 0);
  fill(0, 200, 100);
  text(s, width/5-10, height/5 * 4);

  cutoff = map(mouseX, 0, width, 100, 10000);
  resonance = map(mouseY, 0, height/2, 0, 0.5);
  playerK.setFilter(cutoff, resonance);

  playerG.speed(speedAdjust);
  if (isGtPlaying)
  {
    padColorR2 = map(mouseX, 0, width, 0, 255);
    padColorB2 = map(mouseY, height/2, height, 0, 255);
    padColorG2 = dist(pmouseX, pmouseY, mouseX, mouseY);
  }
}


void mousePressed()
{

  // code that happens when the mouse button
  // is pressed
  if (dist(mouseX, mouseY, 230, 500) < 50)
  {
    if (!isBassPlaying)
    {
      playerB.cue(0);
      playerB.play();
      isBassPlaying = true;
    }
    else
    {
      playerB.stop();
      isBassPlaying = false;
    }
  }
  if (dist(mouseX, mouseY, 380, 500) < 50)
  {
    if (!isGtPlaying)
    {
      playerG.cue(0);
      playerG.play();
      isGtPlaying = true;
    }
    else
    {
      playerG.stop();
      isGtPlaying = false;
    }
  }
  if (dist(mouseX, mouseY, 80, 500) < 50)
  {
    if (!isDrPlaying)
    {
      playerD.cue(0);
      playerD.play();
      isDrPlaying = true;
    }
    else
    {
      playerD.stop();
      isDrPlaying = false;
    }
  }

  if (dist(mouseX, mouseY, 530, 500) < 50)
  {


    if (!isKeyPlaying)
    {
      playerK.cue(0);
      playerK.play();
      isKeyPlaying = true;
    }
    else
    {
      playerK.stop();
      isKeyPlaying = false;
    }
  }
}

void mouseReleased()
{
  // code that happens when the mouse button
  // is released
}
void mouseDragged() {

  if (mouseY>height/2) {

    speedAdjust=map(mouseX, -10, width, 0, 2);
  }
}

