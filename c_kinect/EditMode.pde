
class EditMode{
  
  PointCloud allClouds[];
  int numClouds = 0;
  int curCloud = 0;
  
  float zoom = 0;
  float rot = 0;
  
  boolean mouseDown = false;
  float msx;
  float msy;
  
  EditMode(){
    allClouds  = new PointCloud[10];
  };
  
  void addCloud( PointCloud cloud ){
    allClouds[numClouds] = cloud;
    numClouds++;
    
    print("Saved cloud number "+numClouds+"\n");
  };
  
  PointCloud getCurCloud(){
    return allClouds[curCloud];
  };
  
  
  void checkForDrag(){
    
    PointCloud c = allClouds[curCloud];
    
    // start new press
    if(mousePressed && !mouseDown && keyPressed){
      mouseDown = true;
      msx = mouseX;
      msy = mouseY;
    }
    // update the model
    else if(mousePressed && mouseDown && keyPressed){
      c.pos.x = c.oPos.x + (mouseX - msx);
      c.pos.y = c.oPos.y + (mouseY - msy);
    }
    // click over, stop updating
    else if(!mousePressed && mouseDown){
      mouseDown = false;
      
      c.oPos.x = c.pos.x;
      c.oPos.y = c.pos.y;
    }
  }
  
  void render(){
    
    checkForDrag();
    
    background(0);
    fill(255);
    int skip = 4;
  
    color col = color(255);
    
    pushMatrix();
    
    translate(width/2, height/2, zoom);
    rotateY( rot );
    
    for(int i=0; i<numClouds; i++){
      
      if(i == curCloud) col = color(0, 255, 0);
      else col = color(255);
      
      PointCloud c = allClouds[i];
      
      // Translate and rotate
      pushMatrix();      
        translate( c.pos.x, c.pos.y, 0);
        
      //  translate(c.pos.x, c.pos.y, 0);
        rotateY( c.rotY );
      
        for(int x=0; x<w; x+=skip) {
          for(int y=0; y<h; y+=skip) {
            int offset = x+y*w;
      
            // Convert kinect data to world xyz coordinate
            int rawDepth = c.points[offset];
            
            if(rawDepth > c.cutoff) continue;
            
            PVector v = depthToWorld(x,y,rawDepth);
      
            stroke(col);
            
            pushMatrix();
              // Scale up by 200
              float factor = 200;
              translate(v.x*factor, v.y*factor, factor-v.z*factor);
              
              
              // Draw a point
              point(0,0);
              
            popMatrix();
          }
        }
      popMatrix();
    }// end for
    
    popMatrix();
    
  };
  
  void saveFile(){
    println("Saving...");
    
    String saveString = "";
    String outfile[] = new String[1];    
    
    int skip = 4;
    
    for(int i=0; i<numClouds; i++){

      PointCloud c = allClouds[i];
      saveString += "# CLOUD_"+i+"\n";
      
      // Translate and rotate
      pushMatrix();
        translate(width/2 + c.pos.x, height/2 + c.pos.y, zoom);
        
        rotateY( c.rotY + rot);
      
        for(int x=0; x<w; x+=skip) {
          for(int y=0; y<h; y+=skip) {
            int offset = x+y*w;
      
            // Convert kinect data to world xyz coordinate
            int rawDepth = c.points[offset];
            
            if(rawDepth > c.cutoff) continue;
            
            PVector v = depthToWorld(x,y,rawDepth);
      
            pushMatrix();
              // Scale up by 200
              float factor = 200;
              translate(v.x*factor, v.y*factor, factor-v.z*factor);
              
              
              saveString += modelX(0,0,0) + "," +modelY(0,0,0) + "," + modelZ(0,0,0)+"\n";
              
            popMatrix();
          }
        }
        
        
        
      popMatrix();
    }
    
    // --------
    
    
    
    
    
    outfile[0] = saveString;
    saveStrings("out/face_"+hour()+"_"+minute()+"_"+second()+".asc", outfile);
    
    println("Save complete");
    
  };
  
  // These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
  float rawDepthToMeters(int depthValue) {
    if (depthValue < 2047) {
      return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
    }
    return 0.0f;
  };
  
  PVector depthToWorld(int x, int y, int depthValue) {
  
    final double fx_d = 1.0 / 5.9421434211923247e+02;
    final double fy_d = 1.0 / 5.9104053696870778e+02;
    final double cx_d = 3.3930780975300314e+02;
    final double cy_d = 2.4273913761751615e+02;
  
    PVector result = new PVector();
    double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
    result.x = (float)((x - cx_d) * depth * fx_d);
    result.y = (float)((y - cy_d) * depth * fy_d);
    result.z = (float)(depth);
    return result;
  };
}
