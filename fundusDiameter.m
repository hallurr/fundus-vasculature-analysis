% User prompt
% Open file browser for filename
close all
[filename, filepath] = uigetfile({'*.jpg;*.jpeg;*.tif;*.tiff;*.png;*.bmp;*.gif;*.raw;*.cr2;*.nef;*.orf;*.sr2;*.psd;*.ico;*.heic;*.indd;*.ai;*.eps'},'Select an image file');
filename = fullfile(filepath, filename); % Update filename

prompt = {'Enter threshold multiplier:','Enter maximum 2x radius multiplier:','Enter num_of_radiuses of radii:'};
dlg_title = 'Input for fundus analysis';
num_lines = 1; % 1 line per input
defaultans = {'1.15','1.3','30'};

% Get user input
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

% Set default values for variables
thresh = str2double(answer{1}); % threshold multiplier
max_radius_multiplier = str2double(answer{2});
num_of_radiuses = str2double(answer{3});

% Distances from center of the optic disk in terms of second radius
dist_between_radiuses = linspace(1,max_radius_multiplier,num_of_radiuses);
img = imread(filename); % Read image
% img = imsharpen(img);
grayImg = rgb2gray(img); % Convert to grayscale

% Draw figure
h0 = figure('units','normalized','outerposition',[0 0 1 1]);
set(0,'CurrentFigure',h0); % Set current figure
figure(h0) % Draw figure
imshow(img); % Show image

% Draw circle by selecting first the centre then the periphery of the optic disc
tmpTitle = title('Select the center of the optic disk...','color','r','fontsize',16);
point = drawpoint;
optic_disc_center = point.Position;

set(tmpTitle,'string', 'Now select edge of optic disk...','color','r','fontsize',16);
%     point = impoint; % Create point
point = drawpoint;
optic_disc_edge = point.Position;

% Calculate radius of optic disc
optic_disc_radius = sqrt((optic_disc_center(1)-optic_disc_edge(1))^2+(optic_disc_center(2)-optic_disc_edge(2))^2);
delete(tmpTitle) % Delete title

hold on
viscircles(optic_disc_center,optic_disc_radius); % Draw circle
viscircles(optic_disc_center,optic_disc_radius*2); % Draw circle
hold off
close(h0)
   
%% Get the fundus diameter for each radius and store in cell array rightorder
rightorder = cell(1,num_of_radiuses);
r_special = optic_disc_radius*2*dist_between_radiuses;
for i = 1:length(r_special)
    Distance = r_special(i);
    grayImg = rgb2gray(img);
    pointsincircle = [];
    for y = 1:size(img,2)
        for x = 1:size(img,1)
            if sqrt((optic_disc_center(1)-x)^2+(optic_disc_center(2)-y)^2) < Distance+0.5 && sqrt((optic_disc_center(1)-x)^2+(optic_disc_center(2)-y)^2) > Distance-0.5
                pointsincircle = [pointsincircle; x,y];
            end
        end
    end
    xvalues = pointsincircle(:,1);
    yvalues = pointsincircle(:,2);

    % Upper right
    positionsin1 = intersect(find(xvalues >= optic_disc_center(1)), find(yvalues <= optic_disc_center(2)));
    pos1values = [xvalues(positionsin1),yvalues(positionsin1)];
    pos1values = sortrows(pos1values, [1,2]);

    % Lower right
    positionsin2 = intersect(find(xvalues >= optic_disc_center(1)), find(yvalues > optic_disc_center(2)));
    pos2values = [xvalues(positionsin2),yvalues(positionsin2)];
    pos2values = sortrows(pos2values, [2,-1]);

    % Lower left
    positionsin3 = intersect(find(xvalues < optic_disc_center(1)), find(yvalues > optic_disc_center(2)));
    pos3values = [xvalues(positionsin3),yvalues(positionsin3)];
    pos3values = sortrows(pos3values, [-1,-2]);

    % Upper left
    positionsin4 = intersect(find(xvalues < optic_disc_center(1)), find(yvalues <= optic_disc_center(2)));
    pos4values = [xvalues(positionsin4),yvalues(positionsin4)];
    pos4values = sortrows(pos4values, [-2,1]);

    rightorder{i} = [pos1values;pos2values;pos3values;pos4values];
end

%% Assess vessle diameter

peaks = cell(length(rightorder),1);
intensities =  cell(length(rightorder),1);
for i = 1:length(rightorder)
    orderedorder = rightorder{1,i};
    % Get y and x coordinates from orderedorder.
    yCoordinates = orderedorder(:, 2);
    xCoordinates = orderedorder(:, 1);
    % Use matrix indexing to get intensities.
    Intensity = grayImg(sub2ind(size(grayImg), yCoordinates, xCoordinates));
   
    % Filter the signal to reduce noize
    Fs = 1; % Sampling frequency
    cutoffFreq = 0.1; % Cutoff frequency - Adjust according to your needs
    % Design a low-pass filter
    d = designfilt('lowpassfir', 'FilterOrder', 20, 'CutoffFrequency', cutoffFreq, 'SampleRate', Fs);
    % Apply the filter to the intensity data
    IntensityFiltered = filtfilt(d, double(Intensity));
    IntensityFiltered = IntensityFiltered-min(IntensityFiltered);
    % set the threshold as 25% over mean overall intensity
    threshold = mean(Intensity)*thresh;

    % Find all peaks over threshold
    [peakValues, peakIndices,widths,proms] = findpeaks(IntensityFiltered, 'MinPeakHeight', threshold);
    temppeaks = nan(length(widths),4);
    
    for n = 1:length(peakIndices)
        temppeaks(n,:) = [xCoordinates(peakIndices(n)),yCoordinates(peakIndices(n)), widths(n),peakIndices(n)];
    end
    peaks{i} = temppeaks;
    intensities{i} = IntensityFiltered;
end

%% Clean all
% Throw away peaks that are not mean(peaks) long
lengths = cellfun(@(x) size(x, 1), peaks);  % getting the length (columns) of each array
modeLength = mode(lengths);  % calculate mean length
equalLengthArrays = peaks(lengths == modeLength);
r_special2 = r_special(lengths == modeLength);
equalLengthintensities = intensities(lengths == modeLength);
widths = nan(size(equalLengthArrays{1},1),length(equalLengthArrays));

% Define normalization function
normalize = @(x) (x - min(x)) ./ max(x);

% Apply normalization to each cell
normalizedCellArray = cellfun(normalize, intensities, 'UniformOutput', false);

% Show the results
figure('units','normalized','outerposition',[0 0 1 0.75]);
subplot(3,1,1:2)
imshow(img)
hold on
c = colormap(hsv(modeLength));
for i = 1:length(equalLengthArrays)
    widths(:,i) = equalLengthArrays{i}(:,3);
    for n = 1:modeLength
        plot(equalLengthArrays{i}(n,1),equalLengthArrays{i}(n,2),'o','Color',c(n,:))
    end
end

for i = 1:modeLength
    % plot mean and std error of widths row wise
    subplot(3,3,7)
    errorbar(i, mean(widths(i,:)), std(widths(i,:)),'o','Color',c(i,:))
    hold on
    xlim([0,modeLength+1])
    ylim([0, max(max(widths))])

    subplot(3,3,8)
    plot(r_special2,widths(i,:),'x-', 'Color',c(i,:))
    hold on

    subplot(3,3,9)
    hold on
    plot(linspace(0,360,length(normalizedCellArray{i, 1})),normalizedCellArray{i, 1}+r_special2(i),'k')
end
subplot(3,3,7)
title('Mean Thicnkess')
xlabel('Vessel #')
ylabel('Thickness [pixels]')
subplot(3,3,8)
title('Thicnkess change')
xlabel('Distance from centre [pixels]')
ylabel('Thickness [pixels]')
subplot(3,3,9)
xlim([0,360])
title('Intensity plots')
xlabel('Degrees')
ylabel('Distance from centre [pixels]')

%% Extract
% Assuming 'myArray' is your 2D array
f = figure('units','normalized','outerposition',[0 0.75 1 0.25]);
means_std_sem = nan(size(widths,1),3);
for i=1:size(widths,1)
    means_std_sem(i,:) = [mean(widths(i,:)),std(widths(i,:)),...
        std( widths(i,:) ) / sqrt( length( widths(i,:) ))];
end
Data = [means_std_sem,widths];
t = uitable(f, 'Data', Data, 'Units', 'normalized', 'Position', [0.01 0.01 0.98 0.98]);

% Specify column names
t.ColumnName = ['Mu';'SD';'SE';cellstr(num2str((1:size(widths, 2))'))];

% Specify row names
t.RowName = cellstr(strcat('Vessel',{' '},num2str((1:size(widths, 1))')));

% Set column width
t.ColumnWidth = num2cell(repmat(100, 1, size(widths, 2)));

% Set font size
t.FontSize = 8;

% Set font weight
t.FontWeight = 'bold';
