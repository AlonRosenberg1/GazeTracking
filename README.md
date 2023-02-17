# GazeTracking
A project in gaze tracking
The purpose of this project is to track the user's gaze with a simple webcam and pop usefull information regarding the work beeing currently watched.
this project includs only the tracking part.
As it is a prototype, it does not work in real time.

# Algorithm

### Calibration
The first stage is a calibration stage, where a set of points is shown on the screen and the user is directed to look at them.
The head position and eyes orientation are extracted for each point.

### Usage
At real time, the program captures the user's image, extracts their head position and eyes orientation and calculate a distance (or similarity measure) to each calibration points' head position and eyes orientation.
It choses the best 4 calibration points and than it do a weighted averaging with respect of the similarity measure (that is - a similar point is weighted more) to figure out the actual point the user is gazing at.

## example
![example](https://raw.githubusercontent.com/AlonRosenberg1/GazeTracking/main/example.png)
