Maxim maxim;
AudioPlayer player;

void setup()
{
  size(500, 1200);
  maxim = new Maxim(this);
  player = maxim.loadFile("135 House Beat 38.wav");
  player.setLooping(true);
  player.setAnalysing(true);
  background(0);
}


void draw()
{
    //background(0);
  int r, g, b;
  float pow;
  player.play();
  pow = player.getAveragePower();
  fill(255*pow, 0, 0);
  rect(0,0, pow * width, height);
 

}
