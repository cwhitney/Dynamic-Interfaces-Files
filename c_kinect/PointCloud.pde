
class PointCloud {
  
  int points[];
  float rotY;
  float trans;
  
  PVector oPos = new PVector(0,0);
  PVector pos = new PVector(0,0);
  
  float cutoff;
  
  PointCloud(){
    rotY = 0;
  }
  
}
