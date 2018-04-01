function LEDs=clampLEDValues(LEDs)
R = LEDs(1);
G = LEDs(2);
B = LEDs(3);
if(R < 0)
    R = 0;
end
if(R > 1)
    R = 1;
end
if(G < 0)
    G = 0;
end
if(G > 1)
    G = 1;
end
if(B < 0)
    B = 0;
end
if(B > 1)
    B = 1;
end

LEDs = [R,G,B];
