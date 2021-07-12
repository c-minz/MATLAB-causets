%% initialize causet object from permutation:
obj = EmbeddedCauset(2, 'Permutation', [1 5 4 3 2 6]);
obj.relate();  % find causal relations
obj.plot('Labels', true);  % make a plot with labels
C = transpose(obj.Caumat);  % causal matrix
L = transpose(obj.Linkmat);  % link matrix

%% preferred past structure:
Lambda = false(obj.Card);  % initialize
Lambda(6, 1) = true;  % event 6 has event 1 as preferred past
fprintf('pref. past struct.:\n');  % print in command window
disp(Lambda);

%% compute Klein-Gordon and Green operators from Lambda:
P = eye(obj.Card) - L + Lambda;
E_ret = inv(P) / 2;
fprintf('ret. Green operator:\n');  % print in command window
disp(E_ret);

%% field solution:
a = 1;
b = 2;
phi_initial = [a; b; b; b; b; 0];
phi_final = E_ret * phi_initial;
