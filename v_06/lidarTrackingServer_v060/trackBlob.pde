class TrackBlob
{
Point2D center;
Path2D allPoints;
Rectangle2D boundingBox;

float radius =0;
int totalPoints;

float joinRadius;
float distFromSource;
int maxPoints;

ArrayList<Point2D> locationHistory;
ArrayList<LidarPoint> blobPoints; //= new ArrayList<LidarPoint>();

String name;
int blobNumber;

float distanceTrackCalibration = 30;
/////
long birthDay;
float velocity;
double lastUpdate;
float distanceTraveled;
float life;
boolean drawLabel = true;
int labelSize = 10;

Nomen nameGenerator = new Nomen();

// new variables for velocity
  
  float velocityMagnitude;
  PVector velocityVec; // new variable to store the velocity vector
    boolean drawVelocity = true;





TrackBlob()
{
blobPoints = new ArrayList<LidarPoint>();
allPoints = new Path2D.Double();

locationHistory = new ArrayList<Point2D>();
locationHistory.add(new Point2D.Double());
totalPoints =0;
name = nameGenerator.animal().get();
birthDay = millis();

velocityVec = new PVector(0,0);
    velocityMagnitude = 0;





}

public void predict() {
    kalmanFilter.predict();
}

public void correct(Point2D measurement) {
    SimpleMatrix z = new SimpleMatrix(2, 1);
    z.set(0, 0, measurement.getX());
    z.set(1, 0, measurement.getY());
    kalmanFilter.correct(z);
    Point2D newCenter = new Point2D.Double(kalmanFilter.getState().get(0), kalmanFilter.getState().get(1));
    setLocation(newCenter);
}

public void setLocation(Point2D location) {
    center = location;
}

void addPoint(LidarPoint blPt) {
    blobPoints.add(blPt);
    allPoints.append(new Ellipse2D.Double(blPt.world.getX(),blPt.world.getY(),1,1),true);
    totalPoints++;

    boundingBox = allPoints.getBounds2D();
    center = new Point2D.Double(boundingBox.getCenterX(),boundingBox.getCenterY());
    locationHistory.add(0, center);  // add new position to the beginning of the list
 
    if (locationHistory.size() > 2) {
      locationHistory.remove(locationHistory.size() - 1);  // remove the oldest position

    }
   
}


void display(float drawScale, boolean drawPoints, boolean drawBox, boolean drawHistory, color fColor)
{


life = (millis()-birthDay)/1000.0;


if(locationHistory.size()>1)
{
    
    

    if (locationHistory.size() > 1 && drawVelocity) {
    Point2D currentPoint = locationHistory.get(0);
    Point2D previousPoint = locationHistory.get(1);
    drawVelocityArrow(currentPoint, previousPoint, 2, 200, drawScale, fColor);

    distanceTraveled = calcDistance(locationHistory)/1000;  
    velocity = distanceTraveled/life;
  }



}



lastUpdate=millis();


rectMode(CORNER);
stroke(fColor);
strokeWeight(1);
fill(0,255,0,100);
rect((float)boundingBox.getX()*drawScale,(float)boundingBox.getY()*drawScale,(float)boundingBox.getWidth()*drawScale,(float)boundingBox.getHeight()*drawScale);
//noStroke();
noFill();
ellipse((float)center.getX()*drawScale,(float)center.getY()*drawScale,10,10);

if(drawLabel)
{
fill(fColor);
    textSize(22);
    textAlign(CENTER,CENTER);
    text("X: "+(round((float)center.getX())+" | Y: "+round((float)center.getY())),(float)center.getX()*drawScale,((float)center.getY()*drawScale)-20);
    textSize(40);
    text(blobNumber+" / "+name,(float)center.getX()*drawScale,((float)center.getY()*drawScale)+0);
    textSize(30);
    text("active time: "+roundTo(life,1)+" / Metres: "+roundTo(distanceTraveled,2),(float)center.getX()*drawScale,((float)center.getY()*drawScale)+35);
    //text(distanceTraveled+" "+life+" "+velocity,(float)center.getX()*drawScale,((float)center.getY()*drawScale)+60);
}
if(drawHistory)
{
    stroke(fColor);
    strokeWeight(1);
    for(int hist = locationHistory.size()-1;hist>0;hist--)
    {
        line((float)locationHistory.get(hist).getX()*drawScale,(float)locationHistory.get(hist).getY()*drawScale,(float)locationHistory.get(hist-1).getX()*drawScale,(float)locationHistory.get(hist-1).getY()*drawScale);
        
    }

}




}


void update(TrackBlob closestPrev)
{
name = closestPrev.name;
locationHistory.addAll(closestPrev.locationHistory);
birthDay = closestPrev.birthDay;
blobNumber = closestPrev.blobNumber;
}

float calcDistance(ArrayList<Point2D> allPoints)
{
    float totalDis = 0;
    for(int i=0;i<allPoints.size()-1;i++)
    {
    float checkDis = (float)allPoints.get(i).distance(allPoints.get(i+1));    
    if(checkDis<distanceTrackCalibration){checkDis=0;}
    totalDis+=checkDis;
    }

return totalDis;
}


void assignID()
{
 int newNumber = blobID++;
 blobNumber = newNumber;


}


void drawVelocityArrow(Point2D currentPoint, Point2D previousPoint, float distanceThreshold, float arrowSize, float drawScale, int arrowColor) {
  float distance = (float) currentPoint.distance(previousPoint);
  
    PVector direction = new PVector((float) (currentPoint.getX() - previousPoint.getX()), (float) (currentPoint.getY() - previousPoint.getY()));
    float arrowAngle = degrees(direction.heading());

    //println(arrowAngle);

}


}


