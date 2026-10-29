function sol = bk_solve(T,nStates)
% Solve E_t z(t+1)=T*z(t), z=[predetermined states; jump variables].
% Real Schur stable subspace, not finite-horizon truncation or guess-and-verify.
% Innovations are supplied to predetermined states by the calling model.
n = size(T,1);
assert(size(T,2)==n && nStates>0 && nStates<n);
tol = 1e-8;
roots = eig(T);
sol.roots = roots;
sol.nStable = sum(abs(roots)<1-tol);
sol.nUnstable = sum(abs(roots)>1+tol);
sol.nStates = nStates;
sol.nJumps = n-nStates;
sol.unitRoot = any(abs(abs(roots)-1)<=tol);
sol.determinate = false;
sol.rankStateBlock = NaN;
sol.maxResidual = NaN;
if sol.unitRoot || sol.nStable~=nStates
    return
end
[U,S] = schur(T,'real');
[U,S] = ordschur(U,S,'udi'); %#ok<ASGLU>
Us = U(:,1:nStates);
Uss = Us(1:nStates,:);
sol.rankStateBlock = rank(Uss,1e-10);
if sol.rankStateBlock~=nStates || rcond(Uss)<1e-12
    return
end
sol.F = real(Us(nStates+1:end,:)/Uss);
W = [eye(nStates);sol.F];
sol.P = real(T(1:nStates,:)*W);
sol.maxResidual = max(abs(T*W-W*sol.P),[],'all');
sol.determinate = sol.maxResidual<1e-8;
end
