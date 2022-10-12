% takes input RGB value and determines *reasonbly* 
% accurately what general color the dot is

function color = classify(r,g,b)

    if(g > 0.75 && r > 0.75)
        color = "yellow";
    elseif (r > g && r > b)
        color = "red";
    elseif (b > r && b > g)
        color = "blue";
    elseif (g > r && g > b)
        color = "green";
    end
end