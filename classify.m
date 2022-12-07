% takes input RGB value and determines *reasonably* 
% accurately what general color the dot is

function color = classify(r,g,b)

    if(g > 0.75 && r > 0.75)
        color = "Yellow";
    elseif (r > g && r > b)
        color = "Red";
    elseif (b > r && b > g)
        color = "Blue";
    elseif (g > r && g > b)
        color = "Green";
    end
end