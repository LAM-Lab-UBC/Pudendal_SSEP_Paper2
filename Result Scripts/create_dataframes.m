function [T_wide, T_long, T_overall_wide, T_overall_long, T_master_long] = processSEP(allParticipant, saveCSV)
%PROCESSSEP  Generate event and overall response tables and a combined master long table.
%   [T_wide, T_long, T_overall_wide, T_overall_long, T_master_long] = processSEP(allParticipant, saveCSV)
%   Outputs:
%     T_wide             — event-level wide table
%     T_long             — event-level long table
%     T_overall_wide     — overall-response wide table
%     T_overall_long     — overall-response long table
%     T_master_long      — master long table (event rows only)
%                          with separate event and response decision times and order
%   If saveCSV is true, writes T_master_long to 'master_long.csv'.

    if nargin < 2, saveCSV = false; end
    fn        = fieldnames(allParticipant);
    revFields = fn(startsWith(fn,'Reviewer_'));
    nTrials   = numel(allParticipant);
    events    = {'Onset','P1','N1','P2','N2'};

    % Counts
    maxRowsE  = numel(revFields)*nTrials*numel(events);
    maxRowsO  = numel(revFields)*nTrials;

    % Preallocate storage
    wideData     = cell(maxRowsE, 18);
    longData     = cell(2*maxRowsE, 10);
    overallWide  = cell(maxRowsO, 9);
    overallLong  = cell(2*maxRowsO, 6);
    masterData   = cell(2*maxRowsE, 12);  % only event rows
    w = 0; l = 0; ow = 0; ol = 0; m = 0;

    for iR = 1:numel(revFields)
        rev = revFields{iR};
        if ~all(isfield(allParticipant(1).(rev),{'Day_1','Day_2'})), continue; end
        % map days to ERP vs Full
        switch rev
            case {'Reviewer_1','Reviewer_2'}; erpDay='Day_1'; fullDay='Day_2';
            case {'Reviewer_3','Reviewer_4'}; erpDay='Day_2'; fullDay='Day_1';
            otherwise; erpDay='Day_1'; fullDay='Day_2';
        end
        for t = 1:nTrials
            % overall info
            ERP_info = allParticipant(t).(rev).(erpDay);
            Full_info= allParticipant(t).(rev).(fullDay);
            ERP_ov   = getFieldOrDefault(ERP_info,'Overall_Response','');
            Full_ov  = getFieldOrDefault(Full_info,'Overall_Response','');
            ERP_rt   = getFieldOrDefault(ERP_info,'response_time',NaN);
            Full_rt  = getFieldOrDefault(Full_info,'response_time',NaN);
            ERP_ord  = getFieldOrDefault(ERP_info,'order',NaN);
            Full_ord = getFieldOrDefault(Full_info,'order',NaN);

            % overall-wide row
            ow = ow + 1;
            overallWide(ow,:) = {rev,t,ERP_ov,ERP_rt,ERP_ord,Full_ov,Full_rt,Full_ord,Full_rt-ERP_rt};
            % overall-long rows
            ol = ol + 1;
            overallLong(ol,:) = {rev,t,'ERP',ERP_ov,ERP_rt,ERP_ord};
            ol = ol + 1;
            overallLong(ol,:) = {rev,t,'Full',Full_ov,Full_rt,Full_ord};

            % event-level rows
            for e = 1:numel(events)
                ev = events{e};
                % extract ERP event
                ERPf = getFieldOrDefault(ERP_info,ev,struct());
                [ERPr, ERPlat, ERPcf, ERPdt] = unpackEvent(ERPf);
                % if no overall response, null-out event metrics
                if strcmpi(ERP_ov,'No')
                    ERPlat = NaN;
                    ERPcf  = NaN;
                    ERPdt  = NaN;
                end
                % extract Full event
                Fullf = getFieldOrDefault(Full_info,ev,struct());
                [Fr, Flat, Fcf, Fdt] = unpackEvent(Fullf);
                if strcmpi(Full_ov,'No')
                    Flat = NaN;
                    Fcf  = NaN;
                    Fdt  = NaN;
                end
                % compute scales and diffs
                ERPsc = ERPcf * choiceSign(ERPr);
                Fsc   = Fcf  * choiceSign(Fr);
                latD  = abs(Flat - ERPlat);
                confD = Fcf - ERPcf;
                tdD   = Fdt - ERPdt;

                % event-wide
                w = w + 1;
                wideData(w,:) = {rev,t,ERP_ov,Full_ov,ev,ERPr,ERPlat,ERPcf,ERPdt,Fr,Flat,Fcf,Fdt,latD,confD,tdD,ERPsc,Fsc};
                % event-long
                l = l + 1;
                longData(l,:) = {rev,t,'ERP',ERP_ov,ev,ERPr,ERPlat,ERPcf,ERPdt,ERPsc};
                l = l + 1;
                longData(l,:) = {rev,t,'Full',Full_ov,ev,Fr,Flat,Fcf,Fdt,Fsc};

                % master long (events only)
                m = m + 1;
                masterData(m,:) = {rev,t,'ERP',ERP_ov,ev,ERPr,ERPlat,ERPcf,ERPdt,ERPsc,ERP_rt,ERP_ord};
                m = m + 1;
                masterData(m,:) = {rev,t,'Full',Full_ov,ev,Fr,Flat,Fcf,Fdt,Fsc,Full_rt,Full_ord};
            end
        end
    end

    % trim unused rows
    wideData(w+1:end,:)     = [];
    longData(l+1:end,:)     = [];
    overallWide(ow+1:end,:) = [];
    overallLong(ol+1:end,:) = [];
    masterData(m+1:end,:)   = [];

    % convert to tables
    T_wide         = cell2table(wideData, 'VariableNames',{ ...
        'Reviewer','TraceID','ERP_Overall','Full_Overall','Event', ...
        'ERP_Response','ERP_Latency','ERP_Confidence','ERP_DecisionTime', ...
        'Full_Response','Full_Latency','Full_Confidence','Full_DecisionTime', ...
        'LatencyDiff','ConfidenceDiff','DecisionTimeDiff', ...
        'ERP_200_Confidence','Full_200_Confidence'});
    T_long         = cell2table(longData, 'VariableNames',{ ...
        'Reviewer','TraceID','Day','Overall_Response','Event', ...
        'Response','Latency','Confidence','Event_decision_time','Scale200'});
    T_overall_wide = cell2table(overallWide, 'VariableNames',{ ...
        'Reviewer','TraceID','ERP_Overall','Response_decision_time','ERP_Order', ...
        'Full_Overall','Full_Response_decision_time','Full_Order','DecisionTimeDiff'});
    T_overall_long = cell2table(overallLong, 'VariableNames',{ ...
        'Reviewer','TraceID','Day','Overall_Response','Response_decision_time','Order'});
    T_master_long  = cell2table(masterData, 'VariableNames',{ ...
        'Reviewer','TraceID','Day','Overall_Response','Event', ...
        'Response','Latency','Confidence','Event_decision_time','Scale200', ...
        'Response_decision_time','Order'});

    if saveCSV
        writetable(T_master_long,'master_long.csv');
    end
end

% --- helper to safely get a field or default ---
function val = getFieldOrDefault(s, fld, def)
    if isstruct(s) && isfield(s, fld), val = s.(fld);
    else val = def;
    end
end

% --- unpack a single-event struct ---
function [resp, lat, conf, dt] = unpackEvent(evS)
    resp = getFieldOrDefault(evS,'Response','');
    lat  = getFieldOrDefault(evS,'time',NaN);
    conf = round(getFieldOrDefault(evS,'Confidence',NaN),2);
    dt   = getFieldOrDefault(evS,'peak_response_time',NaN);
end

% --- convert Yes/No to +1/-1 ---
function s = choiceSign(x)
    if strcmpi(x,'Yes'), s = 1;
    elseif strcmpi(x,'No'), s = -1;
    else s = 0;
    end
end

%%

[T_wide, T_long, T_overall_wide, T_overall_long, T_master_long] = processSEP(allParticipant, false)