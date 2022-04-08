



void oscEvent(OscMessage inputData) 
{

 if(inputData.addrPattern().equals("/lidar1"))
 {
   lidarPoints1.packagePoints(inputData.get(0).floatValue(),inputData.get(1).intValue(),inputData.get(2).intValue(),clipPlane,1,l1x+panX,l1y+panY,l1Rot);
 }
else if(inputData.addrPattern().equals(connectPattern))
{
   connectClient(inputData.netAddress().address());
}


}


 private void connectClient(String theIPaddress) {
     if (!broadcastList.contains(theIPaddress, broadcastPort)) {
       broadcastList.add(new NetAddress(theIPaddress, broadcastPort));
       println("### adding "+theIPaddress+" to the list.");
     } else {
       println("### "+theIPaddress+" is already connected.");
     }
     println("### currently there are "+broadcastList.list().size()+" remote locations connected.");
 }


/*
private void disconnect(String theIPaddress) {
if (broadcastList.contains(theIPaddress, myBroadcastPort)) {
		broadcastList.remove(theIPaddress, myBroadcastPort);
       println("### removing "+theIPaddress+" from the list.");
     } else {
       println("### "+theIPaddress+" is not connected.");
     }
       println("### currently there are "+broadcastList.list().size());
 }

*/




  
