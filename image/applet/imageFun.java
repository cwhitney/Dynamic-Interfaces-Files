import processing.core.*; 
import processing.xml.*; 

import hypermedia.video.*; 
import java.awt.*; 
import org.openkinect.*; 
import org.openkinect.processing.*; 
import controlP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class imageFun extends PApplet {








// Kinect Library object
Kinect kinect;

// Size of kinect image
int w = 640;
int h = 480;

float threshold = 800;
float[] depthLookUp = new float[2048];
boolean hasKinect = false;
ControlP5 gui;
PImage display;
OpenCV opencv;

int lastX = -1;
int lastY = -1;
PImage taco;
float inc = 0;
float rot = 0;
float lastDist = -1;


public void setup() {
  size(1280,520);
  
// Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
  
  try{
    kinect = new Kinect(this);
    kinect.start();
    kinect.enableDepth(true);
    kinect.enableRGB(true);
    kinect.enableIR(false);
    kinect.processDepthImage(true);
    
    display = createImage(w, h, PConstants.RGB);
  }catch(Exception e){

  }
  
  // init guis
  gui = new ControlP5(this);
  gui.addSlider("threshold", 0, 2047, 127, 10 ,40, 200, 15);
  
  // cv
  opencv = new OpenCV(this);
  opencv.allocate(640, 480);
  
  // taco
  taco = loadImage("Double_Decker_Taco.png");
  
};



public void draw(){
  fill(255);
  background(0);
  
 // Get the raw depth as array of integers
    int[] depth = kinect.getRawDepth();
  
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) {
      return;
    }
    
    int kw = 640;
    int kh = 480;
    
    display.loadPixels();

    for(int x = 0; x < kw; x++) {
      for(int y = 0; y < kh; y++) {
        
        // mirroring image
        int offset = kw-x-1+y*kw;
        
        // Raw depth
        int rawDepth = depth[offset];

        int pix = x + y * display.width;
        if (rawDepth < threshold) {
        
          // A red color instead
          display.pixels[pix] = color(255,0,0);
        } 
        else {
          display.pixels[pix] = color(0,0,0);
        }
      }
      
    }
    display.updatePixels();
   // image(display, 0, 0);
   
   
   // open cv
   opencv.copy(display);
 //  opencv.threshold(80);
   
   image(opencv.image(), 0, 0);
   
   // blobs(minArea, maxArea, maxBlobs, findHoles);
   Blob[] blobs = opencv.blobs( 100, w*h/3, 2, false );
   
   fill(255);
   // now draw
   for(Blob b:blobs){
     Point c = b.centroid;
     ellipse(c.x, c.y, 5, 5);
   }
   
   pushMatrix();
     if(blobs.length == 2){
       rot = atan2( (blobs[0].centroid.y - blobs[1].centroid.y), (blobs[0].centroid.x - blobs[1].centroid.x) );
       println(rot);
     }
     
     translate(width/4 * 3, height/2);
     rotate(rot);
     image(taco, -taco.height/2, -taco.width/2);
     
   popMatrix();
   
   gui.draw();
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html`
public float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0f / ((double)(depthValue) * -0.0030711016f + 3.3309495161f));
  }
  return 0.0f;
};
  
public void stop() {
  kinect.quit();
  super.stop();
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#c0c0c0", "imageFun" });
  }
}
