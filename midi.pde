// 1 & 0 fucking cube matrix midi controlla 

//import peasy.*;

// Hype Library 
import hype.*;
import hype.extended.behavior.*;
import hype.extended.colorist.*;
import hype.extended.layout.*;
import hype.interfaces.*;
import hype.extended.behavior.HOrbiter3D;

// FFT Library AudioInput, Audionalysis,
import ddf.minim.Minim;
import ddf.minim.AudioInput;
import ddf.minim.analysis.*;

// Controller MIDI 
import java.util.HashMap;
import java.util.Map;
import controlP5.*;
import javax.sound.midi.MidiDevice;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.MidiSystem;
import javax.sound.midi.MidiUnavailableException;
import javax.sound.midi.Receiver;
import javax.sound.midi.Transmitter;

//PeasyCam      cam;

//Hype
HDrawablePool pool;
HOrbiter3D    orb;
HTimer       timerPool;

// FFT
Minim         minim; //Minim Library 
AudioInput  myAudio; 
//AudioPlayer   myAudio;
FFT           myAudioFFT;

// Midi Controller
ControlP5           cp5;
MidiSimple          midi;
int                 theIndex;
Map<String, String> midimapper = new HashMap<String, String>();


// FFT 
boolean       showVisualizer   = false;

int           myAudioRange     = 11;
int           myAudioMax       = 22;

float         myAudioAmp       = 40.0;
float         myAudioIndex     = 0.2;
float         myAudioIndexAmp  = myAudioIndex;
float         myAudioIndexStep = 0.35;
float[]       myAudioData      = new float[myAudioRange];


// How many HDrawables in Hype/ How many objects
int           rR = 700; // moved 
float         r  = 0.0;

// Object Colors
final HColorPool colors = new HColorPool (#FFFFFF);//(#52A9FF, #52A9FF);


PFont type;
void setup() {
  // size(640,600, P3D);
  // #920F0E,#A71914,#FFFFFF,#FFFFFF,#BB2D1B,#D0432D,#A33520,#0DFF14
  fullScreen(P3D);

  H.init(this).background(#FFFFFF).use3D(true).autoClear(false);
  smooth();

  //FFT
   minim   = new Minim(this);                                                //Minim Library
   myAudio = minim.getLineIn(Minim.MONO);                                    //myAudio AudioInput

  // myAudio = minim.loadFile("m.mp3");
  // myAudio.loop();

   myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());        //if you construct an FFT with a timeSize of 1024 and and a sampleRate of 44100 Hz, 
   myAudioFFT.linAverages(myAudioRange);                                    //then the spectrum will contain values for frequencies below 22010 Hz
                                                                            // which is the Nyquist frequency (half the sample rate).
                                                                            //  If you ask for the value of band number 5, this will correspond to a frequency band centered on 5/1024 * 44100 = 0.0048828125 * 44100 = 215 Hz.
                                                                            // The width of that frequency band is equal to 2/1024, 
                                                                            //  expressed as a fraction of the total bandwidth of the spectrum.
                                                                            //The total bandwith of the spectrum is equal to the Nyquist frequency,
                                                                            //which in this case is 22050, so the bandwidth is equal to about 50 Hz.
                                                                            

  type = createFont("Helvetica-48.vlw", 50);
  
  pool = new HDrawablePool(rR);   // how many objects
  pool.autoAddToStage()          
    // .add(new HShape("1.svg").enableStyle(false).anchorAt(H.CENTER) )
    // .add(new HShape("0.svg").enableStyle(false).anchorAt(H.CENTER) )
    // .add(new HText( "1", 50, type ) ) // you can add as many as you want
    // .add(new HText( "0", 50, type ) )
    // .add(new HText( "Castano", 50, type ) )
    .add(new HText( "J Balvin", 50, type ) )

    .onCreate(new HCallback() {
      public void run(Object obj) {
        
        // current object
        int i = pool.currentIndex();                        
        int ranIndex = (int)random(myAudioRange);





        //This is where the anchor, fill, stroke, noStroke and, where we give a random index to the object so we can blah blah blah
        HText d = (HText) obj;
        d
          .noStroke()
          .strokeCap(ROUND).strokeJoin(ROUND)
          .fill(colors.getColor(),225)
          .anchorAt(H.CENTER)
          .loc(  (int)random(-width/2,width/2) , (int)random(height+400), (int)random(-width/2,width/2+300) )
          .extras( new HBundle().num("i", ranIndex) )
          
      
      
      
      
      // Where we give the alpha channel and expand the random objects left and right
           .obj("xo", new HOscillator()
              .target(d)
              .property(H.X)
              .relativeVal(d.x())
              .range(-(int)random(5,10), (int)random(5,10))
              .speed( random(.005,.2) )
              .freq(0)
              .currentStep(i)
            )

            .obj("ao", new HOscillator()
              .target(d)
              .property(H.ALPHA)
              .range(0,255)
              .speed(random(.3,.9) )
              .freq(1)
              .currentStep(i)
            )

            
          ;
          
            new HRotate().target(d).speed( random(0.01,1.1) )   // MOVE
            ;
        }
      }
    )
    .onRequest(
      new HCallback() {
        public void run(Object obj) {
          HDrawable d = (HDrawable) obj;
          d.scale(1).alpha(0).loc((int)random(-width/2,-width/2),(int)random(0,height+200));

          HOscillator xo = (HOscillator) d.obj("xo"); xo.register();
          HOscillator ao = (HOscillator) d.obj("ao"); ao.register();
          //HOscillator wo = (HOscillator) d.obj("wo"); wo.register();
          //HOscillator ro = (HOscillator) d.obj("ro"); ro.register();
        }
      }
    )

    .onRelease(
      new HCallback() {
        public void run(Object obj) {
          HDrawable d = (HDrawable) obj;

          HOscillator xo = (HOscillator) d.obj("xo"); xo.unregister();
          HOscillator ao = (HOscillator) d.obj("ao"); ao.unregister();
         // HOscillator wo = (HOscillator) d.obj("wo"); wo.unregister();
          //HOscillator ro = (HOscillator) d.obj("ro"); ro.unregister();
        }
      }
    )
  ;



  // This is our timer so every 40 milliseconds we will get a new object
  new HTimer(40)
    .callback(
      new HCallback() {
        public void run(Object obj) {
          pool.request();
        }
      }
    )
  ;

   translate(-50000, 0, 0);




  // ------------------------------- IMPORTANT -------------------------------
  
  
  //         THIS IS OUR MIDI CONTROLLER 
  
  //         where the magic happens
  
  cp5 = new ControlP5( this );

  cp5.begin(cp5.addTab("a"));
  
  cp5.addSlider("a-3").setPosition(-120, 200).setSize(200, 20)
      .setRange(0,25);//.setValue(200);

  
  cp5.end();
  
  /*
  cp5.begin(cp5.addTab("b"));
  cp5.addSlider("b-1").setPosition(20, 120).setSize(200, 20);
  cp5.addSlider("b-2").setPosition(20, 160).setSize(200, 20);
  cp5.addSlider("b-3").setPosition(20, 200).setSize(200, 20);
  */
  
  cp5.end();
  
  
  
  
  
  // Most important line this is where we specify the midi controller's name 
  // In my case it's called MIDI MIX 
  // The name of my controller
  
  final String device = "MIDI Mix";
  
  
  
  
  //midimapper.clear();
 
 
  // -----------------------------------------------
  // After in here is where we assign our controller that we are moving
  
  pushMatrix();
  for (int i =0; i < 127; i ++){
  midimapper.put( ref( device, i ), "a-3" );
  }
  popMatrix();
  
  
  // --------------------------------------------------
  
  
  
 
  /*
  midimapper.put( ref( device, 32 ), "a-4" );
  midimapper.put( ref( device, 48 ), "a-5" );
  midimapper.put( ref( device, 64 ), "a-6" );
  
  */

  /*
  midimapper.put( ref( device, 16 ), "b-1" );
  midimapper.put( ref( device, 17 ), "b-2" );
  midimapper.put( ref( device, 18 ), "b-3" );
  
  */



  boolean DEBUG = true;
  
  // This is the controller view colors etc...
  

  if (DEBUG) {
    new MidiSimple( device );
  } 
   midi = new MidiSimple( device , new Receiver() {

      @Override public void send( MidiMessage msg, long timeStamp ) {

        byte[] b = msg.getMessage();

        if ( b[ 0 ] != -48 ) {

          Object index = ( midimapper.get( ref( device , b[ 2 ] ) ) );

          if ( index != null ) {

            Controller c = cp5.getController(index.toString());
            if (c instanceof Slider ) {  
              float min = c.getMin();
              float max = c.getMax();
              c.setValue(map(b[ 2 ], 0, 127, min, max) );

            }  else if ( c instanceof Button ) {
              if ( b[ 2 ] > 0 ) {
                c.setValue( c.getValue( ) );
                c.setColorBackground( #000000 );
              } else {
                c.setColorBackground( #000000 );
              }
            
            } else if ( c instanceof Bang ) {
              if ( b[ 2 ] > 0 ) {
                c.setValue( c.getValue( ) );
                c.setColorForeground( #000000 );
              } else {
                c.setColorForeground( #000000 );
              }
            
            } else if ( c instanceof Toggle ) {
              if ( b[ 2 ] > 0 ) {
                ( ( Toggle ) c ).toggle( );
              }
            }
          }
        }
      }

      @Override public void close( ) {
      }
    }
    );
}

String ref(String theDevice, int theIndex) {
  return theDevice+"-"+theIndex;
}


// the End of the controller 




void draw() {
  
 // background(#000000);
  translate(width/2+0, height/2-650 ,-width/4);
  
  // our FFT forward for sound processing 
  myAudioFFT.forward(myAudio.mix);
  myAudioDataUpdate();


  // our blurrrrr effect 
  pushMatrix();
  translate(-1908, -200, -548);
  fill(0,57); rect(-width/2, -height,width*5, height*5); // MOVEE  200 , 14, 0
  popMatrix();

  pushMatrix();
 // rotateY(r);

  // float s1 = cp5.getController("a-1").getValue();
  // float s2 = cp5.getController("a-2").getValue();
 
  // the controller assigning the value to the speed of the effect
  float s3 = cp5.getController("a-3").getValue();

  for(HDrawable d : pool) {
    d.loc( d.x(), d.y() - random(0.07,s3) );

    if (d.y() < -40) {
      pool.release(d);
  r += 0.000;
    }
  }

  H.drawStage();   // Objects being drawn 
  popMatrix();



  // Where we give the alpha channel of the sound 
   for (HDrawable d : pool) {
     HBundle tempExtra = d.extras();
     int i = (int)tempExtra.num("i");
     int fftFillColor = (int)map(myAudioData[i], 0, myAudioMax, 0, 255);
     d.fill(colors.getColor(),fftFillColor);
   }
  if (showVisualizer) myAudioDataWidget();
}





// Audio Analizer 
void myAudioDataUpdate() {
  for (int i = 0; i < myAudioRange; ++i) {
    float tempIndexAvg = (myAudioFFT.getAvg(i) * myAudioAmp) * myAudioIndexAmp;
    float tempIndexCon = constrain(tempIndexAvg, 0, myAudioMax);
    myAudioData[i]     = tempIndexCon;
    myAudioIndexAmp+=myAudioIndexStep;
  }
  myAudioIndexAmp = myAudioIndex;
}


// Audio analizer spectrum where its view is turned off 
void myAudioDataWidget() {
  noLights();
  hint(DISABLE_DEPTH_TEST);
  noStroke(); fill(0,200); rect(0, height-112, width, 102);
  for (int i = 0; i < myAudioRange; ++i) {
    fill(#CCCCCC); rect(10 + (i*5), (height-myAudioData[i])-11, 4, myAudioData[i]);
  }
  hint(ENABLE_DEPTH_TEST);
}

void stop() {
  myAudio.close();
  minim.stop();  
  super.stop();
}

//void keyPressed(){
// saveFrame("##-av.jpg"); 
//}