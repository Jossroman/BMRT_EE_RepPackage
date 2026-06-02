function [lambda,lambda_h] = get_ss_lambda_hybrid(C_T, H, gamma, sigma, m, Beta,g_a)

    % Define the equation to solve
    func = @(ss)[
        ss(1)  - (C_T-gamma*H)^(-sigma) + ss(1)*ss(2)*(1-m);
        ss(1)*ss(2)  - Beta*gamma*(C_T-gamma*H)^(-sigma)/((1+g_a)-Beta*m);

    ];

    % Initial guess
    x0 = [1,1];

    % Options for fsolve
    options = optimset('display', 'off', 'algorithm', 'Levenberg-Marquardt', ...
        'MaxFunEvals', 10000, 'MaxIter', 10000, 'TolFun', 1e-16, 'TolX', 1e-8); 

    % Solve the equation
    rez = fsolve(func, x0, options);

    % Output the solution
    lambda = rez(1);
    lambda_h = rez(2);


end


