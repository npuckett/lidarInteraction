ArrayList<TrackBlob> sortToBlobs(ArrayList<LidarPoint> rawPts, float jTolerance, Polygon testArea)
{
ArrayList<LidarPoint> bgFilteredPts = new ArrayList<LidarPoint>();

for(LidarPoint testPt : rawPts)
  {
    if(testArea.contains(testPt.world))
    {
      bgFilteredPts.add(testPt);
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







 
void printPoints(ArrayList<LidarPoint> printList)
{
  println();
  for (LidarPoint pt : printList) 
                     {           
                       print(pt.angle+"\t");     
                      }
                      print("**********");
                     //print(bufferList.size());
                     print("**********");
  
  
}


class KeyPoint
{
  float pixelX;
  float pixelY;
  int xPos;
  int yPos;
  int sNumber;
  Point2D center;
  KeyPoint(float _xp, float _yp, float sf, int _sn)
  {
    pixelX = _xp;
    pixelY = _yp;
    xPos=round(_xp/sf);
    yPos=round(_yp/sf);

    center = new Point2D.Float(_xp/sf,_yp/sf);
    sNumber = _sn;
  }

  void display(float drawScale)
  {
    noStroke();  
    fill(255,165,0);
    ellipse((float)center.getX()*drawScale,(float)center.getY()*drawScale,20,20);
    textAlign(CENTER,CENTER);
    textSize(20);
    text(("x "+xPos+"  |  y "+yPos),(float)center.getX()*drawScale,((float)center.getY()*drawScale)+25);
    text(""+sNumber,(float)center.getX()*drawScale,((float)center.getY()*drawScale)-30);

  }



}

void removePoint(ArrayList<KeyPoint> kPoint)
{
  if(kPoint.size()>0)
  {
    kPoint.remove(kPoint.size()-1);
    sensorCount = kPoint.size();
  }


}
