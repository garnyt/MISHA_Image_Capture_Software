function capture_images(app)
    app.TextArea.Value{1} = 'Select folder...';
    % create folder for data - check if there is already data
    new_dir = [app.capture_info.filepath, '\' , app.capture_info.fname, '\'];
    if exist(new_dir,'dir')
        answer = questdlg('Folder already exists. Overwrite data?','Overwrite data?','Yes','No','No');
        switch answer
            case 'Yes'
                rmdir(new_dir,'s');
            case 'No'
                return
            
        end
    end
        
    mkdir(new_dir);

    
    %create LED's and exposure times
    waves = app.waves;
    exposure_time_to_set = app.exposure_time_to_set;
    
   
    % open serial port to arduino LED interface
    ser = serialport('COM3',9600);

    if strcmp(app.capture_info.fname, 'raw') 
        exposure_time_to_set = exposure_time_to_set * app.exposure_gain;
        % capture dark image
        pause(2)
        % capture image
        dark = capture_image(app,exposure_time_to_set(10));
    end
    
    app.TextArea.Value = '';
    app.TextArea.Value{1} = 'Imaging...';
    filt = fspecial('average', 5);
   
    for i = 1:size(waves,2)
        if app.cancel_capture
            app.cancel_capture = false;
            app.TextArea.Value = 'Cancelling... this will take a few seconds';
            % switch off all LED's
            write(ser,"0,0\n","string")
            pause(3)
            set(app.capture_flat,'enable','on');
            set(app.capture_raw,'enable','on');
            set(app.test_leds,'enable','on');
            set(app.set_exposure,'enable','on');
            set(app.focus,'enable','on');
            set(app.cancel,'enable','off');
            
            app.TextArea.Value = 'Operation Cancelled';
            return
        end
        pause(3)
        send_on = [waves(i) + ",100"];
        % switch on LED
        write(ser,send_on,"string");
        pause(2)
        % capture image
        img = capture_image(app,exposure_time_to_set(i));
        disp('image captured')
        if strcmp(app.capture_info.fname, 'raw')    
            img = img-dark;
        end
        
        if strcmp(app.capture_info.fname, 'flat')    
            img = imfilter(img,filt);
        end
        if app.cancel_capture
            app.cancel_capture = false;
            app.TextArea.Value = 'Cancelling... this will take a few seconds';
            % switch off all LED's
            write(ser,"0,0\n","string")
            pause(3)
            set(app.capture_flat,'enable','on');
            set(app.capture_raw,'enable','on');
            set(app.test_leds,'enable','on');
            set(app.set_exposure,'enable','on');
            set(app.focus,'enable','on');
            set(app.cancel,'enable','off');
            
            app.TextArea.Value = 'Operation Cancelled';
            return
        end
        temp = double(img);
        temp = temp/2^12;
        title(app.UIAxes, []);
        xlabel(app.UIAxes, []);
        ylabel(app.UIAxes, []);
        app.UIAxes.XAxis.TickLabels = {};
        app.UIAxes.YAxis.TickLabels = {};
        % Display image and stretch to fill axes
        I = imshow(temp, 'Parent', app.UIAxes, ...
            'XData', [1 app.UIAxes.Position(3)], ...
            'YData', [1 app.UIAxes.Position(4)]);

        % display histogram
        title(app.zoom, 'Histogram', 'FontSize', 13);
        app.zoom.XColor = [0,0,0];  
        temp(1,1) = 1;
        temp(1,2) = 0;
        h = histogram(temp(:),'Parent',app.zoom);
        drawnow;
        
        % display zoomed image
        row_size = 500;
        col_size = 500;
        zoom_start_row = uint16(size(temp,1)/2)-row_size;
        zoom_start_col = uint16(size(temp,2)/2)-col_size;

        img_zoom = temp(zoom_start_row: zoom_start_row + row_size*2, zoom_start_col: zoom_start_col+col_size*2);

        title(app.zoom_2, []);
        xlabel(app.zoom_2, []);
        ylabel(app.zoom_2, []);
        app.zoom_2.XAxis.TickLabels = {};
        app.zoom_2.YAxis.TickLabels = {};
        % Display image and stretch to fill axes
        I = imshow(img_zoom, 'Parent', app.zoom_2, ...
            'XData', [1 app.zoom_2.Position(3)], ...
            'YData', [1 app.zoom_2.Position(4)]);
        % Set limits of axes
        app.zoom_2.XLim = [0 I.XData(2)];
        app.zoom_2.YLim = [0 I.YData(2)];
        drawnow;
        if app.cancel_capture
            app.cancel_capture = false;
            app.TextArea.Value = 'Cancelling... this will take a few seconds';
            % switch off all LED's
            write(ser,"0,0\n","string")
            pause(3)
            set(app.capture_flat,'enable','on');
            set(app.capture_raw,'enable','on');
            set(app.test_leds,'enable','on');
            set(app.set_exposure,'enable','on');
            set(app.focus,'enable','on');
            set(app.cancel,'enable','off');
            
            app.TextArea.Value = 'Operation Cancelled';
            return
        end
        
        app.TextArea.Value{1+i} = [num2str(waves(i)), 'nm captured'];
        scroll(app.TextArea, 'bottom')
            
        filename = [new_dir, '\', app.capture_info.object_name, '_', app.capture_info.fname, '_', num2str(waves(i)), '_nm.tif'];
        imwrite(img,filename);

        pause(2)
        % switch off all LED's
        write(ser,"0,0\n","string")
        
        
    end
    
    
    clear ser
    app.TextArea.Value = 'Completed';
    beep
    
end