/**
  * This sketch demonstrates how to an <code>AudioRecorder</code> to record audio to disk. 
  * To use this sketch you need to have something plugged into the line-in on your computer, 
  * or else be working on a laptop with an active built-in microphone. 
  * <p>
  * Press 'r' to toggle recording on and off and the press 's' to save to disk. 
  * The recorded file will be placed in the sketch folder of the sketch.
  * <p>
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
  */

import ddf.minim.*;
import java.io.File;

// The number of TRACKS available
static int TRACKS = 8;

static final int TRACK_STATE_EMPTY      = 11;
static final int TRACK_STATE_RECORDING  = 12;
static final int TRACK_STATE_RECORDED   = 13;
static final int TRACK_STATE_PLAYING    = 14;

static final int FRAME_RATE = 60;

static final int BEATS = 16;
static final int BEAT_SIZE = 30;

Minim minim;
AudioInput in;
AudioRecorder recorder;
AudioSample[] samples;

int tracksStates[];
Toggle recButtons[];
Toggle playButtons[];
boolean recording;
int recordingTrack;
boolean [][] beat;

int playhead;
int currentbeat = 0;

void setup()
{
  size(800, 600);
  frameRate(FRAME_RATE);
  
  minim = new Minim(this);
  in = minim.getLineIn();

  // Init recorders and audio samples
  // recorders = new AudioRecorder[TRACKS]; 
  samples = new AudioSample[TRACKS];
  // textFont(createFont("Arial", 12));
  
  // Init recording and playing flags
  tracksStates = new int[TRACKS];
  recording = false;
  recordingTrack = -1;
  
  // Init beat
  beat = new boolean[TRACKS][BEATS];
  
  // Init interface element
  recButtons = new Toggle[TRACKS];
  playButtons = new Toggle[TRACKS];
  for (int i = 0; i < TRACKS; i++) {
    // recorders[i] = minim.createRecorder(in, "Track"+i+".wav");
    tracksStates[i] = TRACK_STATE_EMPTY;
    recButtons[i] = new Toggle("REC", 20, 20 + 40 * i, 50, 30);
    playButtons[i] = new Toggle("PLAY", 80, 20 + 40 * i, 50, 30);
  }
  
  playhead = 0;
  currentbeat = 0;
}

void draw()
{
  background(0); 
  stroke(255);
  for (int i = 0; i < TRACKS; i++) {
    recButtons[i].display();
    playButtons[i].display();
    
    if (playhead == 0 && tracksStates[i] == TRACK_STATE_PLAYING && beat[i][currentbeat]) {
      // samples[i].stop();
      println("Playing track "+ i);
      samples[i].trigger();
    }
  }
  
  if (playhead == 0) {
    currentbeat++;
    currentbeat %= BEATS;
  }
  playhead++;
  playhead %= 10;
  
  // draw a moving square showing where the sequence is 

  // draw beat
  stroke(0);
  for (int t = 0; t < TRACKS; t++) {
    int y = 20 + (10 + BEAT_SIZE) * t;
    for (int b = 0; b < BEATS; b++) {
      int x = 140 + (10 + BEAT_SIZE) * b;      
      if (beat[t][b])
        fill(0,255,0);
      else
        fill(255, 0, 0);
      rect(x, y, BEAT_SIZE, BEAT_SIZE);
    }
  }
  fill(0, 0, 200, 120);
  rect(140 + (10 + BEAT_SIZE) * currentbeat, 10, BEAT_SIZE, (BEAT_SIZE + 10) * TRACKS + 10);
}

void mousePressed() {
  for (int i = 0; i < TRACKS; i++) {
    recButtons[i].mousePressed();
    if (!recording) {
      playButtons[i].mousePressed();
    }
  }
}

void mouseReleased() {
  for (int i = 0; i < TRACKS; i++) {
    // Handle recording
    boolean isClicked = recButtons[i].mouseReleased();
    if (!recording && isClicked) {
      // Start recording
      println("Start recording " + i);
      String filename = "Track"+i+".wav";
      File f = new File(filename);
      if (f.exists())
        f.delete();
      recording = true;
      recorder = minim.createRecorder(in, filename);
      recordingTrack = i;
      recorder.beginRecord();
      tracksStates[i] = TRACK_STATE_RECORDING;   
    } else if (recording && isClicked && (i == recordingTrack)) {
      println("Stop recording " + i);
      recording = false;
      recordingTrack = -1;
      recorder.endRecord();
      recorder.save();
      tracksStates[i] = TRACK_STATE_RECORDED;
      samples[i] = minim.loadSample("Track"+i+".wav"); 
    } else if (recordingTrack != i) {
      recButtons[i].set(false);
    }
    
    // Handle playing
    isClicked = playButtons[i].mouseReleased();
    if (!recording && isClicked)
      switch (tracksStates[i]) {
        case TRACK_STATE_EMPTY:
        case TRACK_STATE_RECORDING:
          // Can't play if we haven't any track or recording
          println("Can't start playing track " + i);
          playButtons[i].set(false);
          break;
        case TRACK_STATE_RECORDED:
          println("Start playing track " + i);
          tracksStates[i] = TRACK_STATE_PLAYING;
          break;
        case TRACK_STATE_PLAYING:
          println("Stop playing track " + i);
          playButtons[i].set(false);
          tracksStates[i] = TRACK_STATE_RECORDED;
          samples[i].stop();
          break;
        default:
          println("THIS IS A BUG");
          playButtons[i].set(false);
          tracksStates[i] = TRACK_STATE_EMPTY;
          break;             
      }
  }
  for (int t = 0; t < TRACKS; t++) {
    int y = 20 + (10 + BEAT_SIZE) * t;
    for (int b = 0; b < BEATS; b++) {
      int x = 140 + (10 + BEAT_SIZE) * b;
      int dx = mouseX - x;
      int dy = mouseY - y;
      if (dx >= 0 && dy >= 0 && dx < BEAT_SIZE && dy < BEAT_SIZE) {
        beat[t][b] = !beat[t][b];
      }      
    }
  }  
}

/*
void keyReleased()
{
  if ( key == 'r' ) 
  {
    // to indicate that you want to start or stop capturing audio data, you must call
    // beginRecord() and endRecord() on the AudioRecorder object. You can start and stop
    // as many times as you like, the audio data will be appended to the end of the buffer 
    // (in the case of buffered recording) or to the end of the file (in the case of streamed recording). 
    if ( recorder.isRecording() ) 
    {
      recorder.endRecord();
    }
    else 
    {
      recorder.beginRecord();
    }
  }
  if ( key == 's' )
  {
    // we've filled the file out buffer, 
    // now write it to the file we specified in createRecorder
    // in the case of buffered recording, if the buffer is large, 
    // this will appear to freeze the sketch for sometime
    // in the case of streamed recording, 
    // it will not freeze as the data is already in the file and all that is being done
    // is closing the file.
    // the method returns the recorded audio as an AudioRecording, 
    // see the example  AudioRecorder >> RecordAndPlayback for more about that
    recorder.save();
    println("Done saving.");
  }
}
*/
