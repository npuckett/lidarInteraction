class LidarData {
  String oscAddress;
  color pointColor;
  float ox;
  float oy;
  float rAdjust;

  LidarData(String oscAddress, color pointColor, float ox, float oy, float rAdjust) {
    this.oscAddress = oscAddress;
    this.pointColor = pointColor;
    this.ox = ox;
    this.oy = oy;
    this.rAdjust = rAdjust;
  }
}
class PointStream
{
int totalFeeds;
int bufferSlots;
PointSet pointBuffer;
ArrayList<TrackBlob> prevBlobs = new ArrayList<TrackBlob>();
ArrayList<TrackBlob> currentBlobs = new ArrayList<TrackBlob>();
DrawBuffer activePoints;
int fillCount;
color streamColor;
String oscTag;
int startPoint;
int prevPoint;
int currentWrite =0;

int ssCount = 0;
PointSet ssPoints = new PointSet(0,0, color(0,0,0), 0);

private static final int FILL_COUNT_THRESHOLD = 4;

boolean available = false;
PointStream(int bufferSize, String prefix, color dCol)
{
//pointBuffer = new PointSet(0,0,dCol,fillCount);
oscTag=prefix;
activePoints = new DrawBuffer(bufferSize);
bufferSlots = bufferSize;
fillCount=0;
  for(int i =0;i<bufferSize;i++)
  {
    fillCount++;
    activePoints.pts.add(new PointSet(0.0f, 0.0f, streamColor, fillCount));
  }

}
void packagePoints(float ldrAngle, int ldrDistance, int pointNumber, float farClip, int lidarNumber, float ox, float oy, float rAdjust) {
    // Check if buffers are ready
    if (buffersReady) {
        PointSet pointBuffer = activePoints.pts.get(currentWrite);
        pointBuffer.originX = ox;
        pointBuffer.originY = oy;
        pointBuffer.angleAdjust = rAdjust;

        pointBuffer.lidarNumber = lidarNumber;
        // Check if the point is within the far clip distance
        if (ldrDistance <= farClip) {
            LidarPoint bufferPoint = new LidarPoint(ldrAngle + pointBuffer.angleAdjust, ldrDistance, pointBuffer.originX, pointBuffer.originY);

            // Check if the point number is greater than the previous point number or if the buffer is empty
            if ((pointNumber > prevPoint) || (pointBuffer.ldPoints.size() == 0)) {
                // Add the point to the current active slot
                pointBuffer.addPoint(bufferPoint);
            } else {
                // Update the current write index, clear it, and add the point
                updateCurrentWriteIndex(pointBuffer);
                activePoints.pts.get(currentWrite).addPoint(bufferPoint);
            }

            prevPoint = pointNumber;
        }
    }
}


private void updateCurrentWriteIndex(PointSet pointBuffer) {
    // Update fill count and set 'available' if the threshold is exceeded
    fillCount++;
    if (fillCount > FILL_COUNT_THRESHOLD) {
        available = true;
    }
    // Set the birthday for the current point set
    pointBuffer.birthday = fillCount;

    // Update the current write index and clear the corresponding PointSet
    currentWrite = find(0);
    activePoints.pts.get(currentWrite).ldPoints.clear();
}







PointSet getDrawPoints() {
    PointSet newestPointSet = null;
    Iterator<PointSet> iterator = activePoints.pts.iterator();

    while (iterator.hasNext()) {
        PointSet pointSet = iterator.next();

        if (newestPointSet == null || pointSet.birthday > newestPointSet.birthday) {
            newestPointSet = pointSet;
        }
    }

    return newestPointSet != null ? newestPointSet : new PointSet(0, 0, color(0, 0, 0), 0);
}






  void show()
  {
    
    
    
    PointSet freshPoints = getDrawPoints();
        if(freshPoints.ldPoints.size()>0)
        {
          if(connectDots)
          {
          freshPoints.connect(displayscaleFactor,color(0,0,0,50),3);
          }

          if(showRawPoints)
            {
              for(LidarPoint pt : freshPoints.ldPoints)
              {
              pt.display(displayscaleFactor,freshPoints.dotColor,false);
              }  
            }

          if(showBlobs)
          {
            ArrayList<TrackBlob> freshBlobs = sortToBlobs(freshPoints.ldPoints,trackPointJoinDis,tZone.trackArea,iZones,maxBlobPoints);
            currentBlobs.clear();
            currentBlobs = checkPersistance(freshBlobs,prevBlobs,persistTolerance);

            OscMessage blobData = new OscMessage("/blobs");
            blobData.add(currentBlobs.size());  //0
            for(TrackBlob tb : currentBlobs)
              {
              tb.display(displayscaleFactor,true,true,true,streamColor);
              //send the blob data
              blobData.add(tb.name);//1
              blobData.add(tb.blobNumber);//2
              blobData.add((float)tb.center.getX());//3
              blobData.add((float)tb.center.getY());//4
              blobData.add((float)tb.boundingBox.getWidth());//5
              blobData.add((float)tb.boundingBox.getHeight());//6
              blobData.add(tb.life);//7
              blobData.add(tb.distanceTraveled*1000);//8

              float pixelX = (float)tb.center.getX()*displayscaleFactor;
              float pixelY = (float)tb.center.getY()*displayscaleFactor;

              float wpX1 = tZone.pList.get(0).worldX*displayscaleFactor;
              float wpY1 = tZone.pList.get(0).worldY*displayscaleFactor;
              float wpX2 = tZone.pList.get(2).worldX*displayscaleFactor;
              float wpY2 = tZone.pList.get(2).worldY*displayscaleFactor;
              
              float relX = map((pixelX-wpX1),0,(wpX2-wpX1),0,outSizeX);
              float relY = map((pixelY-wpY1),0,(wpY2-wpY1),0,outSizeY);
              
              }
              lidarFeed1.send(blobData,broadcastList);
              


              prevBlobs.clear();
              prevBlobs.addAll(currentBlobs);  

          }
        }
      }

    ArrayList<TrackBlob> sortToBlobs(ArrayList<LidarPoint> rawPts, float jTolerance, Polygon testArea, ArrayList<TrackPoly> igZones, int maxPointsPerBlob) {
    ArrayList<LidarPoint> bgFilteredPts = new ArrayList<LidarPoint>();

    // Iterate through raw LIDAR points
    for (LidarPoint testPt : rawPts) {
        boolean ignorePoint = false;

        // Check if the point is within the tracking area
        if (testArea.contains(testPt.world)) {
            // Check if the point is within any of the ignore zones
            for (TrackPoly igZone : igZones) {
                if (igZone.trackArea.contains(testPt.world)) {
                    ignorePoint = true;
                    break;
                }
            }

            // If the point should be ignored, skip the rest of the current iteration
            if (ignorePoint) {
                continue;
            }

            // Add the point to the filtered points list if it passes the checks
            bgFilteredPts.add(testPt);
        }
    }

    ArrayList<TrackBlob> blobList = new ArrayList<TrackBlob>();
    boolean currentlyAdding = false;

    // Iterate through the filtered points
    for (int i = 0; i < (bgFilteredPts.size() - 1); i++) {
        // Calculate the distance between the current point and the next point
        double testDist = bgFilteredPts.get(i).world.distance(bgFilteredPts.get(i + 1).world);

        // Check if the distance is less than or equal to the tolerance
        if ((float) testDist <= jTolerance) {
            // Add a new blob if not currently adding or if the current blob is full
            if (!currentlyAdding || blobList.get(blobList.size() - 1).totalPoints >= maxPointsPerBlob) {
                blobList.add(new TrackBlob());
                blobList.get(blobList.size() - 1).addPoint(bgFilteredPts.get(i));
                currentlyAdding = true;
            }
            // Add the next point to the current blob
            blobList.get(blobList.size() - 1).addPoint(bgFilteredPts.get(i + 1));
        } else {
            // Set currentlyAdding to false if the distance is greater than the tolerance
            currentlyAdding = false;
        }
    }


// Check if there is more than one blob in the list
if (blobList.size() > 1) {
    // Get the index of the last blob in the list
    int lastBlob = blobList.size() - 1;
    // Get the index of the last point in the last blob
    int lastPoint = blobList.get(lastBlob).blobPoints.size() - 1;

    // Calculate the distance between the last point of the last blob and the first point of the first blob
    double edgeDistance = blobList.get(lastBlob).blobPoints.get(lastPoint).world.distance(blobList.get(0).blobPoints.get(0).world);

    // Check if the distance is less than or equal to the tolerance
    if ((float) edgeDistance <= jTolerance) {
        // If the distance is within tolerance, merge the first blob into the last blob
        for (LidarPoint ep : blobList.get(0).blobPoints) {
            blobList.get(lastBlob).addPoint(ep);
        }
        // Remove the first blob from the list after merging
        blobList.remove(0);
    }
}


    //remove blobs with too few points
    for(int i=0;i<blobList.size();i++)
    {
      if(blobList.get(i).totalPoints<=minBlobPoints)
      {
        blobList.remove(i);
      }
    }



return blobList;


}
 
void connect(ArrayList<KeyPoint> kp)
{
     OscMessage dsData = new OscMessage("/distanceSensors");
    
     dsData.add(kp.size()); //0
     dsData.add(currentBlobs.size()); //1
     lidarFeed1.send(dsData,broadcastList);
     
     for(KeyPoint point : kp)
     {
      OscMessage ksData = new OscMessage("/distanceSensors/"+point.sNumber);
      
       ksData.add((float)point.xPos); //0
       ksData.add((float)point.yPos); //1
       
     
          for(TrackBlob blob : currentBlobs)
          {
            
            float aT = atan2((float)point.center.getY()-(float)blob.center.getY(),(float)point.center.getX()-(float)blob.center.getX());
            float angleTo = degrees(aT);
            
            
               strokeWeight(2);
               stroke(255,165,0);
               line((float)blob.center.getX()*displayscaleFactor,(float)blob.center.getY()*displayscaleFactor,(float)point.center.getX()*displayscaleFactor,(float)point.center.getY()*displayscaleFactor);
              fill(streamColor);
              float sDist = (float)blob.center.distance(point.center);
              float xp = (((float)blob.center.getX()*displayscaleFactor)+((float)point.center.getX()*displayscaleFactor))/2.0f;
              float yp = (((float)blob.center.getY()*displayscaleFactor)+((float)point.center.getY()*displayscaleFactor))/2.0f;
              text(""+sDist+" @ "+angleTo,xp,yp);

              
              ksData.add(sDist); //2
              ksData.add(angleTo); //3
              ksData.add(blob.name); //4
              ksData.add(blob.blobNumber);//5
          }
        lidarFeed1.send(ksData,broadcastList);  
     }

}
    int find(int ageRank)
    {
      int returnIndex =0; 
      IntList bdays = new IntList();
      for(int i=0;i<activePoints.pts.size();i++)
      {
        int birthday = (int)activePoints.pts.get(i).birthday;
        bdays.append(birthday);
      }
      bdays.sort();
      int found = bdays.get(ageRank);
      for(int i=0;i<activePoints.pts.size();i++)
      {
        if((int)activePoints.pts.get(i).birthday==found)
        {
          returnIndex=i;
          break;         
        }
        
      }
      return returnIndex;


    }



}

class DrawBuffer
{
int bufferSize;
ArrayList<PointSet> pts = new ArrayList<PointSet>();
DrawBuffer(int bSize)
{
  bufferSize = bSize;


}


}



ArrayList<TrackBlob> checkPersistance(ArrayList<TrackBlob> newBlobs, ArrayList<TrackBlob> oldBlobs, float minDistance)
{
//https://github.com/jorditost/BlobPersistence/blob/master/WhichFace/WhichFace.pde

  //measure distance from new blobs to all previous ones
  for(int nb=0;nb<newBlobs.size();nb++)
  {
  //make a list
  MeasureManager closestBlob = new MeasureManager();

    for(int ob = 0;ob<oldBlobs.size();ob++)
    {
      double measure = newBlobs.get(nb).center.distance(oldBlobs.get(ob).center);
      if((float)measure<closestBlob.distance)
      {
        closestBlob.index = ob;
        closestBlob.distance = (float)measure;
      }
    }
    //println(closestBlob.distance);
    ///see if the closest old blob is close enough to count
    if(closestBlob.distance<=minDistance)
    {
      newBlobs.get(nb).update(oldBlobs.get(closestBlob.index)); 
    }
    else
    {
      //give it a number
      
      newBlobs.get(nb).assignID();

     
    }


  }

return newBlobs;
}
class MeasureManager
{
int index;
float distance;
  MeasureManager()
  {
    distance=99999;
  }
}

public float roundTo(float thenumber, int decimalPlaces)
{
 
  String rString = nf(thenumber,0,decimalPlaces);
 float rFloat = 0;
  
 


  try{
    rFloat = Float.parseFloat(rString);
    }catch(NumberFormatException exp)
    {

    }

     return rFloat;
}
