function [Response_elect] = Response_selection(peak)
ResponseOpt = ["Yes" "No"];
peak = string(peak);
msgResponse = append('Is there a ', peak, ' response');
ResponseChoice = menu(msgResponse, ResponseOpt);
Response_elect = ResponseOpt(ResponseChoice);
