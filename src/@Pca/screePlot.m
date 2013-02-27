function varargout = screePlot(this, varargin)
%SCREEPLOT  Display the scree plot of the PCA result
%
%   screePlot(PCA)
%
%   Example
%   screePlot
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-02-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.


% extract data
name    = this.tableName;
coord   = this.scores.data;
values  = this.eigenValues.data;

% distribution of the first 10 eigen values
h = figure('Name', 'PCA - Eigen Values', 'NumberTitle', 'off');
if ~isempty(varargin)
    set(gca, varargin{:});
end

% number of components to display
nx = min(10, size(coord, 2));

% scree plot
bar(1:nx, values(1:nx, 2));
hold on;
plot(1:nx, values(1:nx, 3), 'color', 'r', 'linewidth', 2);

% setup graph
xlim([0 nx+1]);

% annotations
xlabel('Number of components');
ylabel('Inertia (%)');
title([name ' - eigen values'], 'interpreter', 'none');

if nargout > 0
    varargout = {h};
end
