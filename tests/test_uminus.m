function tests = test_uminus
% Test suite for the file uminus.
%
%   Test suite for the file uminus
%
%   Example
%   test_uminus
%
%   See also
%     uminus

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-07-21,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

tab = Table(magic(4));
res = -tab;

assertTrue(testCase, isa(res, 'Table'));


