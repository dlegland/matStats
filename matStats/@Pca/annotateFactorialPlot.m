function annotateFactorialPlot(obj, ax, cp1, cp2)
% Create labels and title of a factorial plot.
%
%   output = annotateFactorialPlot(input)
%
%   Example
%   annotateFactorialPlot
%
%   See also
%     scorePlot, loadingPlot
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2012-10-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.
% create legends

vl1 = obj.EigenValues.Data(cp1, 2);
vl2 = obj.EigenValues.Data(cp2, 2);

xlabel(ax, sprintf('Principal component %d (%5.2f %%)', cp1, vl1));
ylabel(ax, sprintf('Principal component %d (%5.2f %%)', cp2, vl2));

title(ax, obj.TableName, 'interpreter', 'none');
