function varargout = screePlot(obj, varargin)
% Display the scree plot of the PCA result.
%
%   screePlot(PCA)
%   Display the scree plot of the PCA object in a new figure.
%
%   H = screePlot(PCA)
%   Returns a handle to the created figure.
%
%   Example
%   screePlot
%     iris = Table.read('fisherIris.txt');
%     resPca = Pca(iris, 'display', 'off');
%     screePlot(resPca, 'FontSize', 14);
%
%   See also
%     Pca, scorePlot
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2013-02-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.


% extract data
name    = obj.TableName;
coord   = obj.Scores.Data;
values  = obj.EigenValues.Data;

% distribution of the first 10 eigen values
h = figure('Name', 'PCA - Eigen Values', 'NumberTitle', 'off');
if ~isempty(varargin)
    set(gca, varargin{:});
end

% number of components to display
nx = min(10, size(coord, 2));

% scree plot
bar(1:nx, values(1:nx, 2));
% hold on;
% plot(1:nx, values(1:nx, 3), 'color', 'r', 'linewidth', 2);

% setup graph
xlim([0 nx+1]);

% annotations
xlabel('Number of components');
ylabel('Inertia (%)');
title([name ' - eigen values'], 'interpreter', 'none');

% eventually returns handle to graphic handle
if nargout > 0
    varargout = {h};
end
