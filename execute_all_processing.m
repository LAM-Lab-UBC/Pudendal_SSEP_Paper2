%% Load data
% Select the workspace that has all previously processed data
% [filename, inpath] = uigetfile({'*.mat', 'Impact file (*.mat)'}, ...
%     'Select .mat workspace with all previously processed data', 'MultiSelect', 'off');
% addpath(inpath);
% inDat = load(filename);
% temp_name = string(fieldnames(inDat));
% inDat = inDat.(temp_name);
% allParticipant = inDat;

% Select folder containing raw data for all participants
EEG_folder = uigetdir('Select Folder with Single Trial EEG Data');

% Select which reviewer it is
ReviewerOpt = ["Reviewer 1" "Reviewer 2" "Reviewer 3" "Reviewer 4"];
msgReviewer = append("Which reviewer are you"); %% add the specific trial
ReviewerChoice = menu(msgReviewer,ReviewerOpt); %Prompt user selection
Reviewer_elect = ReviewerOpt(ReviewerChoice); %Assign selection


% Select which review session it is
SessionOpt = ["1" "2"];
msgSession = 'What reviewing session is this';
SessionChoice = menu(msgSession, SessionOpt);
Session_elect = SessionOpt(SessionChoice);



%% Time Domain Only
for i = 1:length(allParticipant)
    for k = 1:length(allParticipant(i).data)
        CzAvg = allParticipant(i).data(k).CzAvg;
        times = allParticipant(i).data(k).times;
        
        %Plot the response
        plot(times, CzAvg,'-r', 'LineWidth', 1.5)
        set(gca, 'Ydir','reverse')
        hold on
        xlim([-10 100])
        hold off
        
        % check if there is an overall response
        peak = "Overall";
        [Response_elect] = Response_selection(peak);
        allParticipant(i).data(k).Overall_Response = Response_elect;
        
        if strcmp(Response_elect, "No")
            [Confidence_val] = confidence_slider(peak);
            allParticipant(i).data(k).Overall_Confidence = Confidence_val;
            allParticipant(i).data(k).Onset.Response = Response_elect;
            allParticipant(i).data(k).Onset.Confidence = Confidence_val;
            allParticipant(i).data(k).P1.Response = Response_elect;
            allParticipant(i).data(k).P1.Confidence = Confidence_val;
            allParticipant(i).data(k).N1.Response = Response_elect;
            allParticipant(i).data(k).N1.Confidence = Confidence_val;
            allParticipant(i).data(k).P2.Response = Response_elect;
            allParticipant(i).data(k).P2.Confidence = Confidence_val;
            allParticipant(i).data(k).N2.Response = Response_elect;
            allParticipant(i).data(k).N2.Confidence = Confidence_val;

        elseif strcmp(Response_elect, "Yes")
            % Onset
            peak = "Onset";
            [Response_elect] = Response_selection(peak);
            [Confidence_val] = confidence_slider(peak);
            allParticipant(i).data(k).Onset.Response = Response_elect;
            allParticipant(i).data(k).Onset.Confidence = Confidence_val;
            if strcmp(Response_elect, "Yes")
                [Peak_amp, Peak_time] = calcConditionManu(CzAvg, times, peak);
                allParticipant(i).data(k).Onset.amp = Peak_amp;
                allParticipant(i).data(k).Onset.time = Peak_time;
            end

            %P1
            peak = "P1";
            [Response_elect] = Response_selection(peak);
            [Confidence_val] = confidence_slider(peak);
            allParticipant(i).data(k).P1.Response = Response_elect;
            allParticipant(i).data(k).P1.Confidence = Confidence_val;
            if strcmp(Response_elect, "Yes")
                [Peak_amp, Peak_time] = calcConditionManu(CzAvg, times, peak);
                allParticipant(i).data(k).P1.amp = Peak_amp;
                allParticipant(i).data(k).P1.time = Peak_time;
            end

            %N1
            peak = "N1";
            [Response_elect] = Response_selection(peak);
            [Confidence_val] = confidence_slider(peak);
            allParticipant(i).data(k).N1.Response = Response_elect;
            allParticipant(i).data(k).N1.Confidence = Confidence_val;
            if strcmp(Response_elect, "Yes")
                [Peak_amp, Peak_time] = calcConditionManu(CzAvg, times, peak);
                allParticipant(i).data(k).N1.amp = Peak_amp;
                allParticipant(i).data(k).N1.time = Peak_time;
            end

            %P2
            peak = "P2";
            [Response_elect] = Response_selection(peak);
            [Confidence_val] = confidence_slider(peak);
            allParticipant(i).data(k).P2.Response = Response_elect;
            allParticipant(i).data(k).P2.Confidence = Confidence_val;
            if strcmp(Response_elect, "Yes")
                [Peak_amp, Peak_time] = calcConditionManu(CzAvg, times, peak);
                allParticipant(i).data(k).P2.amp = Peak_amp;
                allParticipant(i).data(k).P2.time = Peak_time;
            end

            %N2
            peak = "N2";
            [Response_elect] = Response_selection(peak);
            [Confidence_val] = confidence_slider(peak);
            allParticipant(i).data(k).N2.Response = Response_elect;
            allParticipant(i).data(k).N2.Confidence = Confidence_val;
            if strcmp(Response_elect, "Yes")
                [Peak_amp, Peak_time] = calcConditionManu(CzAvg, times, peak);
                allParticipant(i).data(k).N2.amp = Peak_amp;
                allParticipant(i).data(k).N2.time = Peak_time;
            end
        end
        close all

    end
end

%% Time Frequency and Global Field Potential

