function [value, varList] = parseInputOption(varList, name, varargin)
% Cherry-pick a parameter from an argument list based on its name.
%
%   Usage:
%   [VALUE, VARARGIN] = parseInputOption(VARARGIN, NAME)
%   [VALUE, VARARGIN] = parseInputOption(VARARGIN, NAME, DEFAULTVALUE)
%
%   Example
%     [showLegend, varargin] = parseInputOption(varargin, 'ShowLegend', false);
%
%   See also
%     inputParser
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2013-03-10,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% first defines default value (empty, or user-defined)
value = [];
if ~isempty(varargin)
    value = varargin{1};
end

% check if option is given
ind = find(strcmpi(varList(1:2:end), name));

% extract value, and remove processed options
if ~isempty(ind)
    value = varList{2*ind};
    varList(2*ind-1:2*ind) = [];
end
