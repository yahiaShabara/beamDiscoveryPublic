% function that returns a y(Y) or n(N) from user
function userInput = getYesNo()
while (1)
    userInput = input("\n==> Enter y(Y) for Yes, and n(N) for No: ", 's');
    if ( strcmpi(userInput, 'y') || strcmpi(userInput, 'n'))
        break;
    else
        fprintf("Invalid input ...");
    end
end
end