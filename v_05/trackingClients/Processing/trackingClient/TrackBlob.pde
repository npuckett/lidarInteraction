class TrackBlob
{
//Point2D center;
//Rectangle2D boundingBox;



String name;
float centerX;
float centerY;
float bbWidth;
float bbHeight;

TrackBlob(String _name, float _cx, float _cy, float _bbw, float _bbh)
{
  name = _name;
  centerX = _cx;
  centerY = _cy;
  bbWidth = _bbw;
  bbHeight = _bbh;

}



void display(float drawScale, boolean drawBox, boolean drawText, color fColor)
{
fill(fColor);  
ellipse(centerX*drawScale,centerY*drawScale,10,10);

  if(drawBox)
  {
  rectMode(CENTER);
  stroke(fColor);
  strokeWeight(1);
  noFill();
  rect(centerX*drawScale,centerY*drawScale,bbWidth*drawScale,bbHeight*drawScale);
  }

  if(drawText)
  {
    fill(fColor);
    textSize(22);
    textAlign(CENTER,CENTER);
    text("X: "+(round(centerX)+" | Y: "+round(centerY)),centerX*drawScale,(centerY*drawScale)-20);
    textSize(18);
    text(name+"",centerX*drawScale,(centerY*drawScale)+35);
    //text(distanceTraveled+" "+life+" "+velocity,(float)center.getX()*drawScale,((float)center.getY()*drawScale)+60);
  }





}
}
