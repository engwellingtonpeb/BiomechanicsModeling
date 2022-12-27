function xdot = suspension(t,x,u)

% Parâmetros do modelo
ks = 900;
kus = 2500; 
ms = 2.45;
mus = 1;
bs = 7.5; 
bus = 5;


A = [ 0 1 0 -1 ;
    -ks/ms -bs/ms 0 bs/ms;
    0 0 0 1;
    ks/mus bs/mus -kus/mus -(bs+bus)/mus];

B = [0  0 ; 0 1/ms ; -1  0 ; bus/mus -1/mus ];

C = [ 1 0 0 0 ;
    -ks/ms -bs/ms 0 bs/ms ];

D=[0 0;
   0 1/ms ];


xdot=A*x+B*u

end

