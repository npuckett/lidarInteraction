class KeyPoint
{
  int xPos;
  int yPos;
  int sNumber;
  Point2D center;
  
  ArrayList<BasicBlob> dataList = new ArrayList<BasicBlob>();
  
  KeyPoint(float _xp, float _yp, float sf, int _sn)
  {
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
