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

// The number of TRACKS available
static int TRACKS = 4;

static final int TRACK_STATE_EMPTY      = 11;
static final int TRACK_STATE_RECORDING  = 12;
static final int TRACK_STATE_RECORDED   = 13;
static final int TRACK_STATE_PLAYING    = 14;

static final int FRAME_RATE = 60;

Minim minim;
AudioInput in;
AudioRecorder[] recorders;
AudioSample[] samples;

int tracksStates[];
Toggle recButtons[];
Toggle playButtons[];
boolean recording;
int recordingTrack;
int frame;

void setup()
{
  size(800, 600);
  frameRate(FRAME_RATE);
  
  minim = new Minim(this);
  in = minim.getLineIn();

  // Init recorders and audio samples
  recorders = new AudioRecorder[TRACKS]; 
  samples = new AudioSample[TRACKS];
  // textFont(createFont("Arial", 12));
  
  // Init recording and playing flags
  tracksStates = new int[TRACKS];
  recording = false;
  recordingTrack = -1;
  
  // Init interface element
  recButtons = new Toggle[TRACKS];
  playButtons = new Toggle[TRACKS];
  for (int i = 0; i < TRACKS; i++) {
    recorders[i] = minim.createRecorder(in, "Track"+i+".wav");
    tracksStates[i] = TRACK_STATE_EMPTY;
    recButtons[i] = new Toggle("REC", 20, 220 + 40 * i, 80, 30);
    playButtons[i] = new Toggle("PLAY", 120, 220 + 40 * i, 80, 30);
  }
  
  int frame = 0;
}

void draw()
{
  background(0); 
  stroke(255);
  for (int i = 0; i < TRACKS; i++) {
    recButtons[i].display();
    playButtons[i].display();
    
    if (tracksStates[i] == TRACK_STATE_PLAYING && frame == 0) {
      println("Triggering sample "+ i);
      samples[i].stop();
      samples[i].trigger();
    }
  }
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
    line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
  }
  
  frame++;
  frame %= FRAME_RATE;
  /*
  if ( recorder.isRecording() )
  {
    text("Currently recording...", 5, 15);
  }
  else
  {
    text("Not recording.", 5, 15);
  }
  */
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
      recording = true;
      recordingTrack = i;
      recorders[i].beginRecord();
      tracksStates[i] = TRACK_STATE_RECORDING;   
    } else if (recording && isClicked && (i == recordingTrack)) {
      println("Stop recording " + i);
      recording = false;
      recordingTrack = -1;
      recorders[i].endRecord();
      recorders[i].save();
      tracksStates[i] = TRACK_STATE_RECORDED;
      samples[i] = minim.loadSample("Track"+i+".wav"); 
    } else if (recordingTrack != i) {
      recButtons[i].set(false);
    }
    
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
