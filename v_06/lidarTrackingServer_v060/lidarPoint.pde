class LidarPoint implements Comparable<LidarPoint>
{
  Point2D local;
  Point2D world;

  float angle;
  float dist;
  float originX;
  float originY;
  
  boolean bgPoint;
  
    LidarPoint(float in_angle, float in_dist, float worldPosX, float worldPosY)
    {
      
      
        ///come back to this seems like an error check 
        //maxDist = (lidarDistance>maxDist) ? lidarDistance : maxDist;
        float localX = 0 + in_dist * sin(radians(in_angle));
        float localY = 0 - in_dist * cos(radians(in_angle)); 
        local = new Point2D.Float(localX,localY);

      
      //angle = (in_angle > 0) ? in_angle : (360+in_angle);
      angle = in_angle;
      dist = in_dist;
      originX = worldPosX;
      originY = worldPosY;
      float wx = localX+worldPosX;
      float wy = localY+worldPosY;

      world = new Point2D.Float(wx,wy);

      //println(localX+"\t"+localY+"\t"+wx+"\t"+wy);
    }


////to use this:  Collections.sort(ldPoints);
  @Override
    int compareTo(LidarPoint other) 
    {
      return Float.compare(this.angle,other.angle);
    } 

  void display(float drawScale, color dotColor, boolean drawAsNumbers)
  {
    fill(dotColor);
    noStroke();
      //ellipse(ctrX+map(xPos, 0.0f , scaleFactor, 0.0f, width/2.0f),ctrY+map(yPos, 0.0f , scaleFactor, 0.0f, width/2.0f),width/200,width/200);
     if(drawAsNumbers)
     {
       textAlign(CENTER,CENTER);
       textSize(10);
       text(""+angle,(float)world.getX()*drawScale,(float)world.getY()*drawScale);


     }
     else
     {
      ellipse((float)world.getX()*drawScale,(float)world.getY()*drawScale,width/500,width/500);
      
      if(showRays)
      {
      stroke(dotColor);
      strokeWeight(0.3);
      line(originX*drawScale,originY*drawScale,(float)world.getX()*drawScale,(float)world.getY()*drawScale);
      }
     }
  }  


  void adjust(float adjDist, float clipRad)
  {
    dist = (dist<clipRad) ? dist : clipRad;

    dist += adjDist;
    float localX = 0 + dist * sin(radians(angle));
    float localY = 0 - dist * cos(radians(angle)); 
    local.setLocation(localX,localY);
    
    world.setLocation((originX+localX),(originY+localY));

  }
  
  
}
