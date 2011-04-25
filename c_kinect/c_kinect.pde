/*
* Charlie Whitney
 * c.whitney@bigspaceship.com
 * 1.28.2011
 */


import librarytests.*;
import org.openkinect.*;
import org.openkinect.processing.*;
import controlP5.*;

// Kinect Library object
Kinect kinect;

float a = 0;
float tiltDeg = 0;

// Size of kinect image
int w = 640;
int h = 480;

float depthValue = 800;
float rotValue = 0;
float zoomValue = -50;

float editZoom = 0;
float editRot = 0;
float editITrans = 0;
float editIRot = 0;
Slider editRotSlider;
Slider editTransSlider;

int timer = 999;

String mode = "CAPTURE";
int lastCloud = 0;

boolean hasKinect = false;

CaptureMode capMode;
EditMode editMode;
ControlP5 capGui;
ControlP5 editGui;
ListBox listbox;

// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];

void setup() {
  size(1200,600,P3D);
  
  try{
    kinect = new Kinect(this);
    kinect.start();
    
    kinect.enableDepth(true);
    kinect.processDepthImage(false);
    
    hasKinect = true;
  }catch(Exception e){
    mode = "NO_KINECT";
    hasKinect = false;
  }
  // init guis
  capGui = new ControlP5(this);
  capGui.addSlider("depthValue", 0, 2047, 127, 10 ,40, 200, 15);
  capGui.addSlider("rotValue", 0, PI*2, 0, 10 ,60, 200, 15);
  capGui.addSlider("zoomValue", -1000, 1000, 0, 10 ,80, 200, 15);
  capGui.addButton("takeSnap",0,10,100,80,19);
  
  editGui = new ControlP5(this);
  editGui.addButton("saveFile", 0, 150, 10, 80, 19);
  editGui.addSlider("editRot", 0, PI*2, 0, 10 ,40, 200, 15);
  editGui.addSlider("editZoom", -1000, 1000, 0, 10 ,60, 200, 15);
  // for individuals
  editRotSlider = editGui.addSlider("editIRot", 0, PI*2, 0, 300 ,40, 200, 15);
  editTransSlider = editGui.addSlider("editITrans", -1000, 1000, 0, 300 ,60, 200, 15);
  
  
  // init modes
  if(hasKinect){
    capMode = new CaptureMode(this, kinect);
  }
  
  editMode = new EditMode();
};

void draw() {
  
  if(mode == "CAPTURE"){
    capMode.rot = rotValue;
    capMode.depthCutoff = depthValue;
    capMode.zoom = zoomValue;
    capMode.render();
    
    capGui.draw();
  }else if(mode == "EDIT"){
    
    PointCloud cur = editMode.getCurCloud();
    
    // clouds were switched since last update
    if(lastCloud != editMode.curCloud){
      editRotSlider.setValue( cur.rotY );
      editTransSlider.setValue( cur.trans );
      lastCloud = editMode.curCloud;
    }
    
    cur.rotY = editIRot;
    cur.trans = editITrans;
    
    editMode.zoom = editZoom;
    editMode.rot = editRot;
    editMode.render();
    editGui.draw();
  }else if(mode == "NO_KINECT"){
    String loadPath = selectInput("Open a saved kinect data file");
    if (loadPath != null) {
      String pointList[] = loadStrings(loadPath);
      
      print(pointList);
      
      for(String p:pointList){
        println(p);
      }
      
      mode = "boogers";
    }
  }
  
  textMode(SCREEN);
  if(hasKinect)
    text("Kinect FR: " + (int)kinect.getDepthFPS() + "\nProcessing FR: " + (int)frameRate,10,16);
  
  // hack time
  if(timer == 200 && mode == "CAPTURE"){
    println("--------------------SNAP--------------------");
    editMode.addCloud( capMode.getCloud() );
    timer = 999;
  }else if(timer < 200){
    timer++;
  }
};

void keyPressed() {
  if(keyCode == UP && hasKinect){
    kinect.tilt(tiltDeg += 1);
  }else if(keyCode == DOWN && hasKinect){
    kinect.tilt(tiltDeg -= 1);
  }else if(keyCode == 32){              // space bar
     editMode.addCloud( capMode.getCloud() );
  }else if(key == 'm'){
    print("change mode\n");
    if(mode == "CAPTURE"){
      mode = "EDIT";
      
      editMode.curCloud = 0;
      lastCloud = 0;
      listbox = editGui.addListBox("Clouds",10,90,120,120);
      for(int i=0; i<editMode.numClouds; i++) {
        listbox.addItem("Cloud "+(i+1),i);
      }
    }
    else mode = "CAPTURE";
  }
  
  else if(keyCode == 157 && mode == "EDIT"){
    cursor(MOVE);
  }
};

void keyReleased(){
  if(keyCode == 157){
    cursor(ARROW);
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    int val = round(theEvent.group().value());
    editMode.curCloud = val;
  }
};

void takeSnap(int value){
  println("TAKE SNAP PRESS: "+value);
  timer = 0;
};

void saveFile(int val){
  editMode.saveFile();
}

void stop() {
  if(hasKinect){
    kinect.quit();
    kinect.tilt(0);
  }
  
  super.stop();
};

