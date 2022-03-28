% Pixelink camera stuffies

dev = imaqhwinfo('pixelinkimaq')
dev.DeviceInfo(1)

% connecting to default camera
%vid=videoinput('pixelinkimaq')
vid = videoinput('pixelinkimaq', 1, 'MONO16_5472x3648')
vid.FramesPerTrigger = 1;

% display camera properties
src = getselectedsource(vid)

inspect(src)
inspect(vid)

% modifying camera properties
get(src,'Exposure')
set(src,'Exposure',0.005)

% get image
frame=getsnapshot(vid);

imshow(double(frame)/double(max(frame(:))))

imaqhelp

% view live video
preview(vid)
stoppreview(vid);

for i = 1:10
    
    frame=getsnapshot(vid);

    imshow(double(frame)/double(max(frame(:)))) 
    drawnow;
    pause(0.5)
    
    
    
end    

%% arduino interface

ser = serialport('COM3',9600);

%all LED's
wavelengths = ['365 nm', '385 nm', '395 nm', '420 nm', ...
               '450 nm', '470 nm', '490 nm', '520 nm', ...
               '560 nm', '590 nm', '615 nm', '630 nm', ...
               '660 nm', '730 nm', '850 nm', '940 nm']
           
waves = [365,385,395,420, ...
           450,470,490,520, ...
           560,590,615,630, ...
           660,730,850,940]
           
exposure_time_to_set = [0.0045,0.0025,0.002,0.0028 ...
                                 ,0.001,0.001,0.001,0.0024 ...
                                 ,0.002,0.018,0.004,0.0035 ...
                                 ,0.0025,0.011,0.01,0.05]*3

wave = waves(1)

exposure_time_to_set = exposure_time_to_set * 1000000

exposure_time_to_set = exposure_time_to_set * 1


send_on = [wave + ",100"]

%aan
write(ser,send_on,"string")
%af
write(ser,"0,0\n","string")







    


