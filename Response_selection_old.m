% This function was retired may 9, 2025
function [Response_elect] = Response_selection(peak)
ResponseOpt = ["Yes" "No"];
peak = string(peak);
if peak == 'Overall'
    msgResponse = append('Is there an identifiable response?');
else
    msgResponse = append('Is there an identifiable ', peak, ' location?');
end
ResponseChoice = menu(msgResponse, ResponseOpt);
Response_elect = ResponseOpt(ResponseChoice);
