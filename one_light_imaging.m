ser = serialport('COM3',9600);
                    
pause(2)
send_on = ["940,100"];
%switch LED on
write(ser,send_on(1),"string");

% connecting to camera
vid=videoinput('pixelinkimaq', 1, 'MONO16_5472x3648');

% get camera properties
src = getselectedsource(vid);

% modifying camera properties
exposure = 1;
set(src,'ExposureMode','manual');
set(src,'Exposure',exposure)

% get image
frame=getsnapshot(vid);

img = (double(frame)-min(double(frame(:))))/(double(max(frame(:)))-min(double(frame(:))));
                     
imshow(img)


write(ser,"0,0\n","string");
clear ser