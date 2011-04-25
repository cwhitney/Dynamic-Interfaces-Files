import hypermedia.video.*;
import java.awt.*;

import org.openkinect.*;
import org.openkinect.processing.*;
import controlP5.*;

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

PImage taco;
float inc = 0;
float rot = 0;
float lastDist = -1;
float startDist = -1;

float dx = 0;
float dy = 0;

void setup() {
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



void draw(){
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
   
   float curDist = 1;
   
   pushMatrix();
     if(blobs.length == 2){
       
       Point p1;
       Point p2;
       
       // kinect will order the points by y position, but we want them ordered by x position
       if(blobs[0].centroid.x < blobs[1].centroid.x){
         p1 = blobs[0].centroid;
         p2 = blobs[1].centroid;
       }else{
         p1 = blobs[1].centroid;
         p2 = blobs[0].centroid;
       }
       
       // rotation is in radians, so adding PI is the same as adding 180 degrees
       rot = atan2( p1.y - p2.y, p1.x - p2.x ) + PI;
       
       if(startDist == -1){
         startDist = sqrt( (p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y) ); // a^2 + b^2 = c^2
       }
       
       curDist = sqrt( (p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y) );
     }else{
       startDist = -1;
       curDist = -1;
       rot = 0;
       
       if(blobs.length > 0){
         dx = blobs[0].centroid.x - 640/2;
         dy = blobs[0].centroid.y - height/2;
       }
     }
     
     
     translate(width/4 * 3, height/2);
     translate(dx, dy);
     scale( curDist / startDist );
     rotate(rot);
     image(taco, -taco.height/2, -taco.width/2);
     
   popMatrix();
   
   gui.draw();
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html`
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
};
  
void stop() {
  kinect.quit();
  super.stop();
}
