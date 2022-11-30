# lidarInteraction
This set of open tools uses data from RPLidar sensors as a means of interaction with environments by tracking the real-time position of people and data from Mixed Reality Sensors

## OSC output format
Track Blobs
address - "/blobs"

0 - total number of blobs currently tracked

(assuming your loop start at x=0 to read data (x*8)+?)
1 - nth blob name   
2 - nth blob ID number
3 - nth blob center X coordinate (centimeters)
4 - nth blob center X coordinate (centimeters)
5 - nth blob bounding box Width (centimeters)
6 - nth blob bounding box Height (centimeters)
7 - nth blob lifespan (seconds)
8 - nth blob distanc travelled (centimeters)

9 - nth blob name
10 - nth blob number
11 - nth blob center X coordinate (centimeters)
12 - nth blob center X coordinate (centimeters)
13 - nth blob bounding box Width (centimeters)
14 - nth blob bounding box Height (centimeters)
15 - nth blob lifespan (seconds)
16 - nth blob distanc travelled (centimeters)
...and so on for all blobs

Distance Sensors
address - "/distanceSensors"

0 - total distance sensors
1 - total number of blobs currently tracked

address - "/distanceSensors/nth distance sensor ID number"

0 - nth distance sensor X coordinate (centimeters)
1 - nth distance sensor Y coordinate (centimeters)

2 - distance to nth blob (centimeters)
3 - angle to nth blob (degrees)
4 - nth blob name
5 - nth blob ID number

## control keys
s - saves all current values, zones, keypoints

t - toggles the creation state for a tracking zone. Press it to enter the mode, click the points, then press t again to save it. A tracking zone is the area where the lidar points can be merged into blobs

m - toggles the mask creation state. A mask is an area inside the tracking zone where the points are ignored. This is useful if there are fixed objects in the way

M - deletes the last mask

z - toggles the creation of a sensor zone. This functions like a collider in a game engine. It must be inside the tracking zone. It calculates whether the bounding boxes of any tracked blobs are inside and counts how many.

Z - deletes the last sensor zone

k - toggles the creation of a sensor point. Once created it measures the distance and angle to each of the blobs being tracked.

w - creates a track window. This is useful for sending points to a screen of a particular size. Define the resolution of the output in windowpoints.json

W - deletes the last track window created

x - deletes all zones and points


