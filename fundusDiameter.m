function rightorder = fundusDiameter(filename, dist_between_radiuses, optic_disc_radius, optic_disc_center, img, show_fig)
    r_special = optic_disc_radius*2*dist_between_radiuses;
    grayImg = rgb2gray(img);
    eyeMask = imbinarize(grayImg, graythresh(grayImg));
    eyeMask = imfill(eyeMask, 'holes');
    eyeMask = bwareaopen(eyeMask, 100);

    if show_fig == 'Y'
        figure()
        imshow(grayImg);
        hold on
        circle(optic_disc_center(1),optic_disc_center(2),optic_disc_radius);
        circle(optic_disc_center(1),optic_disc_center(2),optic_disc_radius*2);
        circle(optic_disc_center(1),optic_disc_center(2),optic_disc_radius*2*dist_between_radiuses);

        pointsincircle = [];
        for y = 1:size(img,2)
            for x = 1:size(img,1)
                if sqrt((optic_disc_center(1)-x)^2+(optic_disc_center(2)-y)^2) < r_special+0.5 && sqrt((optic_disc_center(1)-x)^2+(optic_disc_center(2)-y)^2) > r_special-0.5
                    pointsincircle = [pointsincircle; x,y];
                    plot(x,y,'ro')
                end
            end
        end
        hline(optic_disc_center(2));
        vline(optic_disc_center(1));

        xvalues = pointsincircle(:,1);
        yvalues = pointsincircle(:,2);
    else
        pointsincircle = [];
        for y = 1:size(img,2)
            for x = 1:size(img,1)
                if sqrt((optic_disc_center(1)-x)^2+(optic_disc_center(2)-y)^2) < r_special+0.5 && sqrt((optic_disc_center(1)-x)^2+(optic_disc_center(2)-y)^2) > r_special-0.5
                    pointsincircle = [pointsincircle; x,y];
                end
            end
        end
        xvalues = pointsincircle(:,1);
        yvalues = pointsincircle(:,2);
    end

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

    rightorder = [pos1values;pos2values;pos3values;pos4values];

    if show_fig == 'Y'
        figure('units','normalized','outerposition',[0 0 1 1])

        Intensity = [];
        for i=1:size(rightorder,1)
            Intensity = [Intensity, squeeze(grayImg(rightorder(i,2),rightorder(i,1),:))];
        end

        %%%%%%%%%%%%%%%%%
        subplot(2,2,1:2)
        imshow(img);

        hold on
        circle(optic_disc_center(1),optic_disc_center(2),optic_disc_radius);
        circle(optic_disc_center(1),optic_disc_center(2),optic_disc_radius*2);
        circle(optic_disc_center(1),optic_disc_center(2),optic_disc_radius*2*dist_between_radiuses);

        hline(optic_disc_center(2));
        vline(optic_disc_center(1));
        hold off

        subplot(2,2,3)
        imshow(grayImg);

        subplot(2,2,4)
        plot(1:size(rightorder,1),Intensity)
        hold on
        vline(size(rightorder,1)/4)
        vline(size(rightorder,1)/4*2)
        vline(size(rightorder,1)/4*3)
        vline(size(rightorder,1))
        hold off
    end
end