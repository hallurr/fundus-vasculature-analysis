function multipleFundus()
    % multipleFundus - Analyzes fundus image to compute vessel diameter
    %
    % This function takes no input parameters and allows user to enter inputs
    % through dialog prompts. The script then analyzes a fundus image and
    % computes the vessel diameter around the optic disc for various radii.
    %
    % Usage:
    %   1. Run the multipleFundus() function.
    %   2. Provide the required inputs in the dialog prompt that appears.
    %   3. The script will perform the analysis and display the results as plots.
    %
    % Required Libraries:
    %   - MATLAB Image Processing Toolbox
    %   - RF Toolbox
    %   - hline and vline
    %   - Financial Toolbox
    %   - Statistics and Machine Learning Toolbox



    % User prompt
    prompt = {'Enter filename:','Enter skew from between 1 and 0:','Enter maximum 2x radius multiplier:','Enter num_of_radiuses of radii:','Do you want to view all photos? [Y/N]'};
    dlg_title = 'Input for fundus analysis';
    num_lines = 1; % 1 line per input
    defaultans = {'2020-06-03_10-10-16-94.tif','0.15','1.3','30','N'};
    
    % Get user input
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
    % Set default values for variables
    filename = answer{1};
    skew = str2double(answer{2}); % Skew from between 1 and 0
    max_radius_multiplier = str2double(answer{3});
    num_of_radiuses = str2double(answer{4});

    % View all photos?
    if answer{5} ~= 'Y'
        answer{5} = 'N';
    end
    
    % Distances from center of the optic disk in terms of second radius
    dist_between_radiuses = linspace(1,max_radius_multiplier,num_of_radiuses);
    img = imread(filename); % Read image
    grayImg = rgb2gray(img); % Convert to grayscale

    % Draw figure
    h0 = figure('units','normalized','outerposition',[0 0 1 1]);
    set(0,'CurrentFigure',h0); % Set current figure
    figure(h0) % Draw figure
    imshow(img); % Show image

    % Draw circle by selecting first the centre then the periphery of the optic disc
    tmpTitle = title('Select the center of the optic disk...','color','r','fontsize',16);
%     point = drawpoint; % Create point
    point = drawpoint;
    optic_disc_center = point.Position;
%     optic_disc_center = wait(point); % Wait for user to select point
%     setColor(point, 'r') % Set color of point to red

    set(tmpTitle,'string', 'Now select edge of optic disk...','color','r','fontsize',16);
    %     point = impoint; % Create point
    point = drawpoint;
    optic_disc_edge = point.Position;
%     optic_disc_edge = wait(point); % Wait for user to select point
%     setColor(point,'r') % Set color of point to red
    
    % Calculate radius of optic disc
    optic_disc_radius = sqrt((optic_disc_center(1)-optic_disc_edge(1))^2+(optic_disc_center(2)-optic_disc_edge(2))^2);
    delete(tmpTitle) % Delete title

    hold on
    viscircles(optic_disc_center,optic_disc_radius); % Draw circle
    viscircles(optic_disc_center,optic_disc_radius*2); % Draw circle
    hold off

    % Get the fundus diameter for each radius and store in cell array rightorder
    rightorder = cell(1,num_of_radiuses);
    for i = 1:num_of_radiuses
        rightorder{i} = fundusDiameter(filename, dist_between_radiuses(i), optic_disc_radius, optic_disc_center, img, answer{5});
    end
    
    % Drawing and setting the figure
    h1 = figure('units','normalized','outerposition',[0 0 1 1]);
    set(0,'CurrentFigure',h1);
    figure(h1)

    % Initializing cells for start and end points
    pp_start = cell(1, num_of_radiuses);
    pp_start_points = cell(1, num_of_radiuses);
    pp_end = cell(1, num_of_radiuses);
    pp_end_points = cell(1, num_of_radiuses);
    
    % Initializing cells for the vessel diameter and the radius
    for i = 1:num_of_radiuses
        orderedorder = rightorder{1,i};
        %initialize the column vector for the intensity values
        Intensity = zeros(size(rightorder{i},1),1);
        for j=1:size(Intensity)
            %Squeeze the values of the ordered xy coordinates for the
            %intensity of each pixel
            Intensity(j) = squeeze(grayImg(orderedorder(j,2),orderedorder(j,1),:));
        end
        
        % Filter cutoff value
        filter_cutoff = ((max(Intensity)-min(Intensity))/2)+min(Intensity);
        
        % Distance filter
        for j=1:size(rightorder{i},1)
            if j < size(rightorder{i},1)
                if Intensity(j) <= filter_cutoff && Intensity(j+1) > filter_cutoff
                    pp_start{i} = [pp_start{i}, j+1];
                end
                if  Intensity(j) >= filter_cutoff && Intensity(j+1) < filter_cutoff
                    pp_end{i} = [pp_end{i}, j];
                end
           end
        end

        % Initialize the column vector for the intensity values
        pp_start_points{i} = ones(length(pp_start{i}),1); 
        pp_end_points{i} = ones(length(pp_end{i}),1); 
        pp_start_points{i} = pp_start_points{i}*175; 
        pp_end_points{i} = pp_end_points{i}*175; 
        maxx = size(orderedorder,1); 

        % Plot the intensity values
        subplot(num_of_radiuses,1,i) 
        hold on
        plot(1:size(orderedorder,1),Intensity)
        plot(pp_start{i},  pp_start_points{i} ,'gv')
        plot(pp_end{i},pp_end_points{i} ,'rv')
        xlim([0, maxx])
        hline(filter_cutoff,'r-')
        vline(size(orderedorder,1)/4)
        vline(size(orderedorder,1)/4*2)
        vline(size(orderedorder,1)/4*3)
        vline(size(orderedorder,1))
    end
    hold off

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%         Connecting Clusters       %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % A cell that combines start-end values
        
        
        % For all the end points
        figure(h0)
        hold on
        start_set = {}; % Initialize start set
        end_set = {}; % Initialize end set
        mindistbetweenpoints = 4; % Minimum distance between points
        for i = 1:num_of_radiuses-1 % For all the radiuses
            working_set1 = rightorder{i}; % Get the working set
            working_set2 = rightorder{i+1}; % Get the working set
            for j1=1:length(pp_end{i}) % For all the end points
                x1 = working_set1(pp_end{i}(j1),1); % Get the x coordinate
                y1 = working_set1(pp_end{i}(j1),2); % Get the y coordinate
                for j2=1:length(pp_end{i+1}) % For all the end points
                    x2 = working_set2(pp_end{i+1}(j2),1); % Get the x coordinate
                    y2 = working_set2(pp_end{i+1}(j2),2); % Get the y coordinate
                    if sqrt((x2-x1)^2+(y2-y1)^2)< mindistbetweenpoints && sqrt((x2-x1)^2+(y2-y1)^2)> 0 % If the distance is less than the minimum distance
                        plot([x1,x2],[y1,y2],'r') % Plot the line
                        end_set{i,j1} = [x2  , y2]; % Store the end point
                    end
                end
            end
        end
        
        for i = 1:num_of_radiuses-1
            working_set1 = rightorder{i};
            working_set2 = rightorder{i+1};
            for j1=1:length(pp_start{i})
                x1 = working_set1(pp_start{i}(j1),1);
                y1 = working_set1(pp_start{i}(j1),2);
                for j2=1:length(pp_start{i+1})
                    x2 = working_set2(pp_start{i+1}(j2),1);
                    y2 = working_set2(pp_start{i+1}(j2),2);
                    if sqrt((x2-x1)^2+(y2-y1)^2)< mindistbetweenpoints  && sqrt((x2-x1)^2+(y2-y1)^2)> 0
                        plot([x1,x2],[y1,y2],'b')
                        start_set{i,j1} = [x2  , y2];
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%         Diameter checker         %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        smalldisttrue = ones(size(start_set,1),size(start_set,2))*inf; % Initialize the small distance matrix
        
        if size(start_set{1,1})~=0 
            firststart = start_set{1,1}(1);
        elseif size(start_set{2,1})~=0
            firststart = start_set{2,1}(1);
        elseif size(start_set{3,1})~=0
            firststart = start_set{3,1}(1);    
        end
            
        if size(end_set{1,1})~=0
            firstend = end_set{1,1}(1);
        elseif size(end_set{2,1})~=0
            firstend = end_set{2,1}(1);
        elseif size(end_set{3,1})~=0
            firstend = end_set{3,1}(1);  
        end
        
        % If the start is before the end 
        if firststart < firstend
            for numvessel = 1:size(start_set,2) % For all the vessels
               for i = 1:size(start_set,1)
                   if size(start_set{i,numvessel})~=0
                       for y = 1:size(end_set,1)
                           if size(end_set{y,numvessel})~=0 
                               currentdist = sqrt((start_set{i,numvessel}(1)- end_set{y,numvessel}(1))^2 + ...
                                   (start_set{i,numvessel}(2)- end_set{y,numvessel}(2))^2);
                               if currentdist < smalldisttrue(i,numvessel) % If the distance is smaller than the current distance
                                   x1 = start_set{i,numvessel}(1); y1 = start_set{i,numvessel}(2);
                                   x2 = end_set{y,numvessel}(1); y2 = end_set{y,numvessel}(2);
                                   smalldisttrue(i,numvessel)=currentdist;
                               end
                           end
                       end
                       plot([x1,x2],[y1,y2],'w') % Plot a line between the starting indexes and the ending indexes
                   end
               end
            end
        end
       
        hold off

    
       smalldisttrue(smalldisttrue==Inf)=NaN; % Remove all the infinite distances
       smalldisttrue(smalldisttrue <= 3)=NaN; % Remove all the distances that are smaller than 3
       thismeandiameter = zeros(1,size(smalldisttrue,2)); % Create an empty vector for the mean diameter
       SEM = zeros(1,size(smalldisttrue,2)); % Create an empty vector for the standard error
       N = zeros(1,size(smalldisttrue,2)); % Create an empty vector for the number of samples
       thisstddiameter = zeros(1,size(smalldisttrue,2)); % Create an empty vector for the standard deviation
       vesseltyped = {}; % Create an empty cell for vessel types

    % Alter based on skew variable
    for i=1:size(smalldisttrue,2)
        temporaryvector = smalldisttrue(:,i)'; % Get the current vector
        vectorinuse = temporaryvector(temporaryvector<(nanmean(temporaryvector)*(1+skew)) & temporaryvector>(nanmean(temporaryvector)*(1-skew))); % Remove all the values that are not within the skew
        thismeandiameter(i) = nanmean(vectorinuse); % Calculate the mean
        thisstddiameter(i) = nanstd(vectorinuse); % Calculate the standard deviation
        thisnanmediandiameter(i) = nanmedian(vectorinuse); % Calculate the median
        N(i) = length(vectorinuse(isnan(vectorinuse)==0)); % Calculate the number of samples
        SEM(i) = thisstddiameter(i)/sqrt(N(i)); % Calculate the standard error
        vesseltyped{i} = 'Unknown'; % initialize this specific vessel type as unknown
    end
       
        
       vesseltyped = vesseltyped'; % Transpose the vessel type
	h4 = figure('units','normalized','outerposition',[0.1 0.1 0.9 0.9]);
    hold on
    % Create a Datacell for easy copy pasting
    Data = [num2cell(thismeandiameter'),num2cell(thisnanmediandiameter'),num2cell(SEM'), ...
        num2cell(thisstddiameter'), num2cell(N'), vesseltyped ,num2cell(smalldisttrue')];
    t = uitable('Parent', h4, 'Position', [50 50 1200 800], 'Data', Data);
    t.ColumnName = {'Mean', 'Median', 'SEM', 'std', 'N', 'INSERT TYPE','VALUES...'};
    t.ColumnEditable = [false false false false false true];
    t.ColumnFormat = {[] [] [] [] [] {'Vein', 'Probable Vein', 'Artery', 'Probable Artery', 'Unknown', 'NOT A VESSEL'}};
    t.BackgroundColor = [.4 .4 .4; .4 .4 .8]; 
    t.ForegroundColor = [1 1 1]; 
    t.ColumnWidth = {'auto', 'auto', 'auto', 'auto', 'auto',120,'auto','auto'}; 
	hold off
        
       
    x = 1:size(smalldisttrue,2); % Create a vector for the x axis
    h3 = figure;
    hold on
    errorbar(x(N>5),thismeandiameter(N>5),SEM(N>5),'o') % Plot the mean diameter with the standard error
    axis([0 length(N(N>5))+1 0 ceil(max(thismeandiameter)+1)]) % Set the axis
    hold off
       
end

