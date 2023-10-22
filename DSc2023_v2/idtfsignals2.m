
A=0.25;
f=5;

if phi>deg2rad(10)

    uecrl=A*square(2*pi*f*t);
    ufcu=0;

elseif phi<deg2rad(-10)

    uecrl=0;
    ufcu=A*square(2*pi*f*t);

else
    uecrl=A*square(2*pi*f*t);
    ufcu=A*square(2*pi*f*t);
end

if psi>deg2rad(30)

    usup=A*square(2*pi*f*t);
    upq=0;

elseif psi<deg2rad(10)

    usup=0;
    upq=A*square(2*pi*f*t);

else
    usup=A*square(2*pi*f*t);
    upq=A*square(2*pi*f*t);
end