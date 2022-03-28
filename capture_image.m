function img = capture_image(app,exposure)

    % connecting to camera
    vid=videoinput('pixelinkimaq', 1, 'MONO16_5472x3648');

    % get camera properties
    src = getselectedsource(vid);

    % modifying camera properties
    set(src,'ExposureMode','manual');
    set(src,'Exposure',exposure)

    % get image
    img=getsnapshot(vid);
        
end