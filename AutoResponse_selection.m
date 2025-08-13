function [AutoResponse_elect] = AutoResponse_selection(Peak)
AutoResponseOpt = ["Yes" "No"];
Peak = string(Peak);
msgResponse = append('Whould you like to correct the location of ', Peak);
AutoResponseChoice = menu(msgResponse, AutoResponseOpt);
AutoResponse_elect = AutoResponseOpt(AutoResponseChoice);
