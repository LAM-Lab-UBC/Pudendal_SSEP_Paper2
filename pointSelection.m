function [x, y] = pointSelection()
% Enable data cursor mode
datacursormode on

% Wait for user to select a point
pause

% Get the data cursor information
dcm_obj = datacursormode();
dcm_obj.Enable = 'on';
dcm_obj.DisplayStyle = 'window';
info = getCursorInfo(dcm_obj);

% Extract the coordinates
x = info.Position(1);
y = info.Position(2);

% Save the coordinates or use them as needed
disp(['Selected coordinates: x = ' num2str(x) ', y = ' num2str(y)])
datacursormode off
end
