class CaptureMode {

  PApplet stage;
  Kinect kinect;
  Slider mySlider;
  
  float depthCutoff = 127;
  float rot = 0;
  float zoom = -50;
 
 
  // ------------------------------------------------
  // CONSTRUCT
  CaptureMode(PApplet ref, Kinect k){
    
    stage = ref;
    kinect = k;

    // Lookup table for all possible depth values (0 - 2047)
    for (int i = 0; i < depthLookUp.length; i++) {
      depthLookUp[i] = rawDepthToMeters(i);
    }
    
  };
  
   
  PointCloud getCloud(){ 
    PointCloud p = new PointCloud();
    p.points = kinect.getRawDepth();
    p.rotY = rot;
    p.cutoff = depthCutoff;
    
    return p;
  };
    
  void render(){

    background(0);
    fill(255);
  
    // Get the raw depth as array of integers
    int[] depth = kinect.getRawDepth();
  
    // We're just going to calculate and draw every 4th pixel (equivalent of 160x120)
    int skip = 4;
  
    // Translate and rotate
    pushMatrix();
      translate(width/2,height/2, zoom);
      rotateY(rot);
    
      for(int x=0; x<w; x+=skip) {
        for(int y=0; y<h; y+=skip) {
          int offset = x+y*w;
    
          // Convert kinect data to world xyz coordinate
          int rawDepth = depth[offset];
          
          if(rawDepth > depthCutoff) continue;
          
          PVector v = depthToWorld(x,y,rawDepth);
    
          stroke(255);
          pushMatrix();
          // Scale up by 200
          float factor = 200;
          translate(v.x*factor,v.y*factor,factor-v.z*factor);
          // Draw a point
          point(0,0);
          popMatrix();
        }
      }
    popMatrix();
  };
    
    // These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html`
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
