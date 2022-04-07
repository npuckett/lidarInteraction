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
int population;

int ssCount = 0;


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
    activePoints.pts.add(new PointSet(fillCount));
  }

}
 void readNewData(OscMessage inData)
 {
   
   if(inData.addrPattern().equals(blobDataFilter))
   {
     int dataPoints = 5;
     population = inData.get(0).intValue();
     xp = inData.get(7).floatValue();
     yp = inData.get(8).floatValue();
     
     
     currentWrite=find(0);
     PointSet newBlobs = activePoints.pts.get(find(0));
     newBlobs.blobs.clear();
      
       for(int i = 1;i<=population*dataPoints;i+=dataPoints)
       {
        fillCount++; 
        newBlobs.blobs.add(new TrackBlob(inData.get(i).stringValue(), inData.get(i+2).floatValue(), inData.get(i+3).floatValue(), inData.get(i+4).floatValue(), inData.get(i+5).floatValue()));
        newBlobs.birthday=fillCount;        
       }
       
   }
   else if(inData.addrPattern().equals(distanceFilter))
   {
     /*
     displayScaleFactor = inData.get(0).floatValue();
     xp = inData.get(4).floatValue();
     yp = inData.get(5).floatValue();
     distanceTo = inData.get(9).floatValue();
     angleTo = inData.get(10).floatValue();
     totalSensors = inData.get(1).intValue();
     */
   }

   
 }



 PointSet getNewest()
 {
   PointSet testPoints = new PointSet(0);
   for(int i=bufferSlots-1;i>=0;i--)
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
  




  void show()
  {
      
    PointSet freshBlobs = getNewest();

            for(TrackBlob tb : freshBlobs.blobs)
              {
              tb.display(displayScaleFactor,true,true,color(255));

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
