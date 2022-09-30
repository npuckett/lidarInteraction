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



  void packagePoints(float ldrAngle, int ldrDistance, int pointNumber, float farClip, int lidarNumber, float ox, float oy, float rAdjust)
    {
      if(buffersReady)
      { 
      PointSet pointBuffer = activePoints.pts.get(currentWrite);
      pointBuffer.originX = ox;
      pointBuffer.originY = oy;
      pointBuffer.angleAdjust = rAdjust;
    
      pointBuffer.lidarNumber = lidarNumber;  
          if(ldrDistance<=farClip)
          {
             
              LidarPoint bufferPoint = new LidarPoint(ldrAngle+pointBuffer.angleAdjust,ldrDistance,pointBuffer.originX,pointBuffer.originY);

              
                if((pointNumber>prevPoint)||(pointBuffer.ldPoints.size()==0))
                {
                  //add the point to the current active slot
                  pointBuffer.addPoint(bufferPoint);
                }
                else
                {
                  //set the birthday for that pointset  
                  fillCount++;
                  if(fillCount>4){available=true;}
                  pointBuffer.birthday=fillCount;
                  //println(fillCount+"\t"+pointBuffer.ldPoints.size()+"\t"+currentWrite+"\t"+activePoints.pts.size());

                  //find the new target, clear it, add the point
                  currentWrite=find(0);
                  //
                  //println("** "+currentWrite);
                  activePoints.pts.get(currentWrite).ldPoints.clear();
                  activePoints.pts.get(currentWrite).addPoint(bufferPoint);
                }

                    
              prevPoint=pointNumber;

          }
      }

      else
      {
        print("..");
      }
    }

 PointSet getDrawPoints()
 {
   PointSet testPoints = new PointSet(0,0, color(0,0,0), 0);
   for(int i=3;i>=0;i--)
    {
      try 
      {
        testPoints = activePoints.pts.get(find(i));
        break;
      } catch (ConcurrentModificationException e) 
      {
       println("nope"); 
      }
    }
  return testPoints;
 }
  
  void testing()
  {
println("********************"+find(2));
  }

void superSample(int samples)
{
ssCount++;
ArrayList<LidarPoint> tempPoints = new ArrayList<LidarPoint>();
if(ssCount<=samples)
{
PointSet freshPoints = getDrawPoints();  
tempPoints = (ArrayList)freshPoints.ldPoints.clone();
ssPoints.ldPoints.addAll(tempPoints);
  if(ssCount==samples)
  {
    background(255);   

    //sort the list
    Collections.sort(ssPoints.ldPoints);
    //draw the list
    
        if(ssPoints.ldPoints.size()>0)
        {
          if(record)
          {
            //folderTarget=("frames/set_"+year()+"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second());
            beginRecord(PDF, ("frames/set_"+year()+"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second()+"res_"+samples+"_frame_####.pdf")); 
          } 

          if(connectDots)
          {
          ssPoints.connect(displayscaleFactor,color(0,0,0,50),3);
          }

          if(showRawPoints)
            {
              for(LidarPoint pt : ssPoints.ldPoints)
              {
              pt.display(displayscaleFactor,freshPoints.dotColor,false);
              }  
            }
            
          
            endRecord();
            record = false;
            
        }
        ssPoints.ldPoints.clear();
    //reset ssCount
    ssCount = 0;
  }

}


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
            ArrayList<TrackBlob> freshBlobs = sortToBlobs(freshPoints.ldPoints,trackPointJoinDis,tZone.trackArea,iZones);
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
              blobData.add(tb.distanceTraveled);//8

              float pixelX = (float)tb.center.getX()*displayscaleFactor;
              float pixelY = (float)tb.center.getY()*displayscaleFactor;

              float wpX1 = tZone.pList.get(0).worldX*displayscaleFactor;
              float wpY1 = tZone.pList.get(0).worldY*displayscaleFactor;
              float wpX2 = tZone.pList.get(2).worldX*displayscaleFactor;
              float wpY2 = tZone.pList.get(2).worldY*displayscaleFactor;
              
              float relX = map((pixelX-wpX1),0,(wpX2-wpX1),0,outSizeX);
              float relY = map((pixelY-wpY1),0,(wpY2-wpY1),0,outSizeY);
              //blobData.add(relX);
              //blobData.add(relY);
              
              //println(relX+"   "+relY);
              }
              lidarFeed1.send(blobData,broadcastList);
              


              prevBlobs.clear();
              prevBlobs.addAll(currentBlobs);  

          }
        }
      }

    ArrayList<TrackBlob> sortToBlobs(ArrayList<LidarPoint> rawPts, float jTolerance, Polygon testArea, ArrayList<TrackPoly> igZones)
    {
    ArrayList<LidarPoint> bgFilteredPts = new ArrayList<LidarPoint>();

    for(LidarPoint testPt : rawPts)
      {
        boolean ignorePoint = false;
        if(testArea.contains(testPt.world))   //&& (!ignoreZones.contains(testPt.world)))
        {
          for(int i =0;i<igZones.size();i++)
          {
            if(igZones.get(i).trackArea.contains(testPt.world))
            {
              ignorePoint=true;
            }
          }

          if(!ignorePoint)
          {
          bgFilteredPts.add(testPt);
          }
        }

      }

      ArrayList<TrackBlob> blobList = new ArrayList<TrackBlob>();
      boolean currentlyAdding = false;
      boolean prevState = false;
      for (int i = 0; i<(bgFilteredPts.size()-1); i++)
      {
        double testDist = bgFilteredPts.get(i).world.distance(bgFilteredPts.get(i+1).world);
        
        if((float)testDist<=jTolerance)
          {
          if(currentlyAdding==false)   /////this is where to add the max points filter
          {
            blobList.add(new TrackBlob());
            blobList.get(blobList.size()-1).addPoint(bgFilteredPts.get(i));
            currentlyAdding=true;
          }
          blobList.get(blobList.size()-1).addPoint(bgFilteredPts.get(i+1));    
        }
        else
        {
          currentlyAdding=false;
        }

      }


    if(blobList.size()>1)
    {
    int lastBlob = blobList.size()-1;
    int lastPoint = blobList.get(lastBlob).blobPoints.size()-1;  

    double edgeDistance = blobList.get(lastBlob).blobPoints.get(lastPoint).world.distance(blobList.get(0).blobPoints.get(0).world);

      if((float)edgeDistance<=jTolerance)
      {
        for(LidarPoint ep : blobList.get(0).blobPoints)
        {
          blobList.get(lastBlob).addPoint(ep);
        }
        blobList.remove(0);

      }
    }

    for(int i=0;i<blobList.size();i++)
    {
      if(blobList.get(i).totalPoints<=2)
      {
        blobList.remove(i);
      }
    }



return blobList;


}
 
void connect(ArrayList<KeyPoint> kp)
{
     OscMessage dsData = new OscMessage("/distanceSensors");
     dsData.add(displayscaleFactor); //0
     dsData.add(kp.size()); //1
     dsData.add(currentBlobs.size()); //2
     
     for(KeyPoint point : kp)
     {
       dsData.add(point.sNumber); //3
       dsData.add((float)point.xPos); //4
       dsData.add((float)point.yPos); //5
       
     
          for(TrackBlob blob : currentBlobs)
          {
            
            float aT = atan2((float)point.center.getY()-(float)blob.center.getY(),(float)point.center.getX()-(float)blob.center.getX());
            float angleTo = degrees(aT);
            //angle = atan2(y2 - y1, x2 - x1) * 180 / PI;
            
               strokeWeight(2);
               stroke(255,165,0);
               line((float)blob.center.getX()*displayscaleFactor,(float)blob.center.getY()*displayscaleFactor,(float)point.center.getX()*displayscaleFactor,(float)point.center.getY()*displayscaleFactor);
              fill(streamColor);
              float sDist = (float)blob.center.distance(point.center);
              float xp = (((float)blob.center.getX()*displayscaleFactor)+((float)point.center.getX()*displayscaleFactor))/2.0f;
              float yp = (((float)blob.center.getY()*displayscaleFactor)+((float)point.center.getY()*displayscaleFactor))/2.0f;
              text(""+sDist+" @ "+angleTo,xp,yp);

              dsData.add(blob.name); //6
              dsData.add(blob.blobNumber);//7
              dsData.add(sDist); //8
              dsData.add(angleTo); //9
          }
     }
     lidarFeed1.send(dsData,broadcastList);


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
