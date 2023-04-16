class DataSender
{




DataSender()
{

}


void send(boolean sendOSC, boolean sendWebSocket, ArrayList<TrackBlob> allBlobs, ArrayList<KeyPoint> allKeyPoints, ArrayList<SensorZone> allSensorZones, TrackPoly theTrackPoly)
{
    //send basic data about the scene
   OscMessage sceneData = new OscMessage("/scene");
        sceneData.add(width);
        sceneData.add(height);
        sceneData.add(displayscaleFactor);

    if(sendOSC)
    {        
      lidarFeed1.send(sceneData,broadcastList);
    }
    //create the JSON object for the scene data to send to the web socket
    JSONObject sceneDataJSON = new JSONObject();
      sceneDataJSON.setInt("width",width);
      sceneDataJSON.setInt("height",height);
      sceneDataJSON.setFloat("scaleFactor",displayscaleFactor);

    if(sendWebSocket)
    {    
      try {
        webData.sendMessage(sceneDataJSON.toString());
      } catch (Exception e) {
        
        println("error sending scene data");
      }
    }


if(allBlobs.size() > 0)
    {
    //create the JSON object and array for the web socket data
    JSONObject basicBlobData = new JSONObject();
    JSONArray blobNumbers = new JSONArray();
    //add the total number of blobs to the json object
    basicBlobData.setInt("totalBlobs",allBlobs.size());


    //osc message for blob data
            OscMessage blobData = new OscMessage("/blobs");
            blobData.add(allBlobs.size());  //0 total number of blobs
            int blobCount = 0;
            //create an integer array of all the blob numbers
            int[] blobNumberList = new int[allBlobs.size()];
            for(int i = 0; i < allBlobs.size(); i++)
              {
              //add the blob number to the array  
              blobNumberList[i] = allBlobs.get(i).blobNumber;
              //add the blob number to the json array
              blobNumbers.setInt(i,allBlobs.get(i).blobNumber);
              }
            //add the array to the osc message
            blobData.add(blobNumberList); //1 array of all the blob numbers
            //add the json array to the json object
            basicBlobData.setJSONArray("blobNumbers",blobNumbers);

            for(TrackBlob tb : allBlobs)
              {
              
              //send the blob data
              blobData.add(tb.name);//2 blob name
              blobData.add(tb.blobNumber);//3 blob number
              blobData.add((float)tb.center.getX());//4 blob x position world coordinates
              blobData.add((float)tb.center.getY());//5 blob y position world coordinates
              blobData.add((float)tb.boundingBox.getWidth());//6 blob width in world coordinates
              blobData.add((float)tb.boundingBox.getHeight());//7 blob height in world coordinates
              blobData.add(tb.life);//8 blob lifespan
              blobData.add(tb.distanceTraveled*1000);//9 blob distance traveled in meters

              float pixelX = (float)tb.center.getX()*displayscaleFactor;
              float pixelY = (float)tb.center.getY()*displayscaleFactor;
            
              blobData.add(pixelX);//10 blob x position pixel coordinates
              blobData.add(pixelY);//11 blob y position pixel coordinates
              blobData.add(pixelX/(float)width);//12 blob x position normalized pixel coordinates
              blobData.add(pixelY/(float)height);//13 blob y position normalized pixel coordinates

                //add all the blob data to the basic blob data json object
                basicBlobData.setString("blob"+blobCount+"Name",tb.name);
                basicBlobData.setInt("blob"+blobCount+"Number",tb.blobNumber);
                basicBlobData.setFloat("blob"+blobCount+"worldX",(float)tb.center.getX());
                basicBlobData.setFloat("blob"+blobCount+"worldY",(float)tb.center.getY());
                basicBlobData.setFloat("blob"+blobCount+"worldWidth",(float)tb.boundingBox.getWidth());
                basicBlobData.setFloat("blob"+blobCount+"worldHeight",(float)tb.boundingBox.getHeight());
                basicBlobData.setFloat("blob"+blobCount+"life",tb.life);
                basicBlobData.setFloat("blob"+blobCount+"distanceTraveled",tb.distanceTraveled*1000);
                basicBlobData.setFloat("blob"+blobCount+"pixelX",pixelX);
                basicBlobData.setFloat("blob"+blobCount+"pixelY",pixelY);
                basicBlobData.setFloat("blob"+blobCount+"normalizedPixelX",pixelX/(float)width);
                basicBlobData.setFloat("blob"+blobCount+"normalizedPixelY",pixelY/(float)height);
              
              }
              
                if(sendOSC)
                {
                    lidarFeed1.send(blobData,broadcastList);
                }
              
                if(sendWebSocket)
                {
                  try {
                    webData.sendMessage(basicBlobData.toString());
                    //println(basicBlobData.toString());
                  } catch (Exception e) {
                    // TODO Auto-generated catch block
                    //e.printStackTrace();
                    println("error sending blob data");
                  }
                  //webData.sendMessage(basicBlobData.toString());
                }
    }

    if(allKeyPoints.size() > 0)
    {
//send keypoint data
OscMessage dsData = new OscMessage("/distanceSensors");
    
     dsData.add(allKeyPoints.size()); //0
     dsData.add(allBlobs.size()); //1
     lidarFeed1.send(dsData,broadcastList);
//send keypoint data to web socket
JSONObject dsDataGeneralJSON = new JSONObject();
    dsDataGeneralJSON.setInt("totalKeyPoints",allKeyPoints.size());
    dsDataGeneralJSON.setInt("totalBlobs",allBlobs.size());
    if(sendWebSocket)
    {
      try {
        webData.sendMessage(dsDataGeneralJSON.toString());
      } catch (Exception e) {
        // TODO Auto-generated catch block
        //e.printStackTrace();
        println("error sending keypoint data");
      }
    }

//send keypoint data to web socket
JSONObject dsDataJSON = new JSONObject();

      for(KeyPoint point : allKeyPoints)
     {
      OscMessage ksData = new OscMessage("/distanceSensors/"+point.sNumber);

        dsDataJSON.setInt("keyPoint"+point.sNumber+"Number",point.sNumber);
      
       ksData.add((float)point.xPos); //0
       ksData.add((float)point.yPos); //1
       
        dsDataJSON.setFloat("keyPoint"+point.sNumber+"worldX",(float)point.xPos);
        dsDataJSON.setFloat("keyPoint"+point.sNumber+"worldY",(float)point.yPos);

     
          for(TrackBlob blob : allBlobs)
          {
            
            float aT = atan2((float)point.center.getY()-(float)blob.center.getY(),(float)point.center.getX()-(float)blob.center.getX());
            float angleTo = degrees(aT);
            float sDist = (float)blob.center.distance(point.center);
            float xp = (((float)blob.center.getX()*displayscaleFactor)+((float)point.center.getX()*displayscaleFactor))/2.0f;
            float yp = (((float)blob.center.getY()*displayscaleFactor)+((float)point.center.getY()*displayscaleFactor))/2.0f;
              

              
              ksData.add(sDist); //2
              ksData.add(angleTo); //3
              ksData.add(blob.name); //4
              ksData.add(blob.blobNumber);//5

                dsDataJSON.setFloat("keyPoint"+point.sNumber+"distanceToBlob"+blob.blobNumber,sDist);
                dsDataJSON.setFloat("keyPoint"+point.sNumber+"angleToBlob"+blob.blobNumber,angleTo);
          }
        if(sendOSC)
        {  
          lidarFeed1.send(ksData,broadcastList);
        }       
     }  
   //send keypoint data to web socket
    if(sendWebSocket)
    {
      try {
        webData.sendMessage(dsDataJSON.toString());
      } catch (Exception e) {
        // TODO Auto-generated catch block
        //e.printStackTrace();
        println("error sending keypoint data");
      }
    }
    }
    if(allSensorZones.size() > 0)
    {
      //send sensor zone data
      OscMessage szData = new OscMessage("/sensorZones");
      szData.add(allSensorZones.size()); //0
      lidarFeed1.send(szData,broadcastList);
      
      JSONObject szDataJSON = new JSONObject();
      szDataJSON.setInt("totalSensorZones",allSensorZones.size());
      if(sendWebSocket)
      {
        try {
          webData.sendMessage(szDataJSON.toString());
        } catch (Exception e) {
          // TODO Auto-generated catch block
          //e.printStackTrace();
          println("error sending sensor zone data");
        }
      }
    
    szDataJSON = new JSONObject();
    JSONArray szbNums = new JSONArray();
    for(SensorZone sz : allSensorZones)
    {
        szData = new OscMessage("/sensorZones/"+sz.sNumber);
        szData.add(sz.currentMembers.size()); //0

        //create array of inside blob numbers
        int[] inBlobNumbers = new int[sz.currentMembers.size()];
        for(int i = 0; i < sz.currentMembers.size(); i++)
        {
          inBlobNumbers[i] = sz.currentMembers.get(i);
          szbNums.setInt(i,inBlobNumbers[i]);
        }
        szData.add(inBlobNumbers); //1
        szDataJSON.setInt("sensorZone"+sz.sNumber+"Number",sz.currentMembers.size());
        szDataJSON.setJSONArray("sensorZone"+sz.sNumber+"blobNumbers",szbNums);

        if(sendOSC)
        {  
          lidarFeed1.send(szData,broadcastList);
        }



    }
    if(sendWebSocket)
    {
      try {
        webData.sendMessage(szDataJSON.toString());
      } catch (Exception e) {
        // TODO Auto-generated catch block
        //e.printStackTrace();
        println("error sending sensor zone data");
      }
    }
    
    
    
    
    
    }

}
}