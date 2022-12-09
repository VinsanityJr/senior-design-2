% takes input RGB value and determines *reasonably* 
% accurately what general color the dot is

function color = classify(r,g,b)


    if(b > 0.75 && r < 0.6)
        color = "Blue";
    elseif(g*0.8 > r)
        color = "Green";
    elseif(0.75*r > g && r > b)
        color = "Red";
    else
        color = "Yellow";

    end
end