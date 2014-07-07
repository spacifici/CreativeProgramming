//The MIT License (MIT) - See Licence.txt for details

//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies


int tvx, tvy;
int animx, animy;
int deck1x, deck1y;
int deck2x, deck2y;

boolean deck1Playing = false;
boolean deck2Playing = false;
float rotateDeck1 = 0;
float rotateDeck2 = 0;
float currentFrame = 0;
int margin = width/40;
PImage [] images;
PImage [] recordPlayer;
PImage TV;
Maxim maxim;
AudioPlayer player1;
AudioPlayer player2;
float speedAdjust1=1.0;
float speedAdjust2=1.0;
float speedAdjust3=0.0;
Fader fader1, fader2, fader3, fader4;
int fadersBaseY = 550;
int fadersBaseX = 150;

void setup()
{
  size(768,1024);
  imageMode(CENTER);
  images = loadImages("Animation_data/movie", ".jpg", 183);
  recordPlayer = loadImages("black-record_", ".png", 36);
  TV = loadImage("TV.png");
  maxim = new Maxim(this);
  player1 = maxim.loadFile("beat1.wav");
  player1.setLooping(true);
  player2 = maxim.loadFile("beat2.wav");
  player2.setLooping(true);
  background(10);
  fader1 = new Fader(fadersBaseX,fadersBaseY, "Cross Fader");
  fader2 = new Fader(fadersBaseX,fadersBaseY + 50, "Track1 Speed");
  fader3 = new Fader(fadersBaseX,fadersBaseY + 100, "Track2 Speed");
  fader4 = new Fader(fadersBaseX,fadersBaseY + 150, "Video speed");
}

void draw()
{
  background(10); 
  imageMode(CENTER);
  image(images[(int)currentFrame], width/2, images[0].height/2+margin, images[0].width, images[0].height);
  image(TV, width/2, TV.height/2+margin, TV.width, TV.height);
  deck1x = (width/2)-recordPlayer[0].width/2-(margin*10);
  deck1y = TV.height+recordPlayer[0].height/2+margin;
  image(recordPlayer[(int) rotateDeck1], deck1x, deck1y, recordPlayer[0].width, recordPlayer[0].height);
  deck2x = (width/2)+recordPlayer[0].width/2+(margin*10);
  deck2y = deck1y;
  image(recordPlayer[(int) rotateDeck2], deck2x, deck2y, recordPlayer[0].width, recordPlayer[0].height);
  
  if (deck1Playing || deck2Playing) {
    
    player1.speed(speedAdjust1);
    player2.speed(speedAdjust2);
    // player2.speed((player2.getLengthMs()/player1.getLengthMs())*speedAdjust);
    currentFrame= currentFrame+speedAdjust3 / 2;
  }

  if (currentFrame < 0)
    currentFrame = images.length - 1;
  if (currentFrame >= images.length) {

    currentFrame = 0;
  }

  if (deck1Playing) {

    rotateDeck1 += 1*speedAdjust1;

    if (rotateDeck1 >= recordPlayer.length) {

      rotateDeck1 = 0;
    }
  }

  if (deck2Playing) {

    rotateDeck2 += 1*speedAdjust2;

    if (rotateDeck2 >= recordPlayer.length) {

      rotateDeck2 = 0;
    }
  }
  fader1.draw();
  fader2.draw();
  fader3.draw();
  fader4.draw();
}


void mouseClicked()
{

  //if (mouseX > (width/2)-recordPlayer[0].width-(margin*10) && mouseX < recordPlayer[0].width+((width/2)-recordPlayer[0].width-(margin*10)) && mouseY>TV.height+margin && mouseY <TV.height+margin + recordPlayer[0].height) {
  if(dist(mouseX, mouseY, deck1x, deck1y) < recordPlayer[0].width/2){
    
    deck1Playing = !deck1Playing;
  }

  if (deck1Playing) {
    player1.play();
  } 
  else {

    player1.stop();
  }

  if(dist(mouseX, mouseY, deck2x, deck2y) < recordPlayer[0].width/2){
  
    deck2Playing = !deck2Playing;
  }

  if (deck2Playing) {
    player2.play();
  } 
  else {

    player2.stop();
  }
}

void mousePressed() {
  fader1.mousePressed();
  fader2.mousePressed();
  fader3.mousePressed();
  fader4.mousePressed();
}

void mouseReleased() {
  fader1.mouseReleased();
  fader2.mouseReleased();
  fader3.mouseReleased();
  fader4.mouseReleased();
}

void mouseDragged() {
  fader1.mouseDragged();
  fader2.mouseDragged();
  fader3.mouseDragged();
  fader4.mouseDragged();
  float volume1 = map(fader1.getValue(), 0.0f, 1.0f, 2.0f, 0.0f);
  if (volume1 > 1)
    volume1 = 1;
  float volume2 = map(fader1.getValue(), 0.0f, 1.0f, 0.0f, 2.0f);
  if (volume2 > 1)
    volume2 = 1;
  player1.volume(volume1);
  player2.volume(volume2);
  speedAdjust1 = map(fader2.getValue(), 0.0f, 1.0f, 0.0f, 2.0f);
  speedAdjust2 = map(fader3.getValue(), 0.0f, 1.0f, 0.0f, 2.0f);
  speedAdjust3 = map(fader4.getValue(), 0.0f, 1.0f, -2.0f, 2.0f);
}

