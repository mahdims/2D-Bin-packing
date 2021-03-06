
sets i,t;

parameters due,M,N,q,h,w,BinH,BinW,Cap,P_cost,B_cost,S,Early,Late;

$GDXIN G:\My Drive\Side Projects\Cutting stock (APA)\Code\Model\Input\Data_5_3_7_Tloose.gdx
$load i,t
$load due,M,N,q,h,w,BinH,BinW,Cap,P_cost,B_cost,S ,Early,Late
$GDXIN

*$gdxin %gdxincname%
*$load i,t , due,M,N,q,h,w,BinH,BinW,Cap,P_cost,B_cost,S ,Early,Late
*$gdxin

Alias (i,j,k,l,ll);
sets al(j,i), del(l,j,i) , Aset(l,k,j,i);
al(j,i)$(ord(j) <= ord(i))= yes;
del(l,j,i)$(ord(l) < ord(i) and ord(j) < ord(i) and ord(j)>=ord(l) )=yes;
Aset(l,k,j,i)$(ord(j) <= ord(i) and ord(l)<= ord(k)) = yes;

variables BQ(l),P(l),objV;

Binary variables
alpha(j,i)
beta(k,j)
gamma(l,k)
a(l,k,j,i)
b(i,l,t)
x(i,t)     \Assign bins to day for printing\
r(l) \revolting bin or not\
bs(l) \If two sided item is in bin l\
;
integer variables
o(j,i)
delta(l,j,i)
y(i)
z(i,t)
tp(i)
tn(i)
;

y.lo(i) = 1 ;
y.up(i) = M(i)  ;
equations
obj
c1(i)
c2(j,i)
c2_1(j,i)
c2_2(j,i)
c2_3(j)
c3(i)
c4(j)
c5(k,j)
c6(k,j)
c7(k)
c8(k)
*c9(l,j,i)
*c10(l,j,i)
*c11(l,j,i)
*c12(l)
c9_2(l)
c13(l)
c14(l)
c15(l,k,j,i)
c16(i,l)
c16_2(l)
c16_3(l)
c16_4(l)
c16_5(l,ll,i)
c17(i,l,t)
c18(t)
c19(i)
c20(i)
c21(i)
c22(i)
;

obj..objV =e= sum(l,P_cost*P(l)) + sum (l, ( gamma(l,l) + (1-r(l))*bs(l) )*B_cost);
c1(i)..sum(j$(al(j,i)),o(j,i)) =e= y(i);
c2(al(j,i))..o(j,i) =l= M(i)*alpha(j,i)   ;
c2_1(al(j,i))..alpha(j,i) =l=o(j,i)   ;

c2_2(al(j,i))$(w(i) ne w(j))..alpha(j,i)=e= 0;
c2_3(j)..sum(i$(al(j,i)), o(j,i)*h(i) )=l= BinH;

C3(j)$(ord(j)<=N-1)..sum(i$(al(j,i) and ord(i) ne ord(j)),alpha(j,i)) =l= (N-ord(j))*alpha(j,j) ;

c4(j)..sum(k, beta(k,j)) =e= alpha(j,j);

c5(k,j)$(ord(j)<ord(k) and ord(k)>=1 ).. sum(i$al(j,i), h(i)*o(j,i) ) =l= sum(i$al(k,i), h(i)*o(k,i)) +(BinH+1)*(1-beta(k,j)) ;
c6(k,j)$(ord(j)>=ord(k) and ord(k)<N-1 ).. sum(i$al(j,i), h(i)*o(j,i) ) =l= sum(i$al(k,i), h(i)*o(k,i)) +(BinH)*(1-beta(k,j)) ;

c7(k).. sum(j,w[j]*beta(k,j)) =l= BinW * beta(k,k) - BinW*0.5* sum (l$al(l,k), gamma(l,k)*r(l)) ;

c8(k).. sum(l$al(l,k), gamma(l,k)) =e= beta(k,k);

*c9(del(l,j,i)).. delta(l,j,i) =l= o(j,i);
*c10(del(l,j,i)).. delta(l,j,i) =l= M(i)*gamma(l,j);
*c11(del(l,j,i)).. o(j,i)-M(i)*(1-gamma(l,j)) =l= delta(l,j,i)   ;

*c12(l)$(ord(l) < N-1)..sum( i$(ord(i)>=ord(l)) , h(i)*gamma(l,l)*o(i,i) ) +
*         sum((i,j)$(ord(i)>=ord(l)+1 and del(l,j,i)) , h(i)*delta(l,j,i) ) =l= BinH*gamma(l,l);

c9_2(l)$(ord(l)<=N-1) ..  sum(k$(ord(k)>=ord(l)), sum(i$al(k,i),  h(i)*o(k,i)) * gamma(l,k)  ) =l= BinH*gamma(l,l);

c13(l)$(ord(l) < N-1)..sum( k$(ord(k)>=ord(l)+1), gamma(l,k)) =l= (N-ord(l))*gamma(l,l);

c14(l).. sum(t, x(l,t)) =e= gamma(l,l);
c15(Aset(l,k,j,i)).. a(l,k,j,i) =e= alpha(j,i)*beta(k,j)*gamma(l,k);

c16(i,l).. sum((k,j)$Aset(l,k,j,i), a(l,k,j,i)*q(i)) =l= y(i)*BQ(l);
c16_2(l).. P(l) =e= BQ(l)-0.5*BQ(l)*r(l);
c16_3(l).. r(l) =l=   sum((k,j,i)$Aset(l,k,j,i), a(l,k,j,i)*S(i)) ;
c16_4(l).. sum((k,j,i)$Aset(l,k,j,i), a(l,k,j,i)*S(i)) =l= bs(l)*card(i) ;
c16_5(l,ll,i)$(ord(l) ne ord(ll)).. sum((k,j)$Aset(l,k,j,i), a(l,k,j,i)) =l= 1-sum((k,j)$Aset(ll,k,j,i), a(ll,k,j,i) );

c17(i,l,t).. b(i,l,t) =e= sum((k,j)$(Aset(l,k,j,i)) , a(l,k,j,i)) * x(l,t);

c18(t).. sum(l , x(l,t)*P(l)) =l= Cap;

c19(i).. sum( (t,l) , (ord(t)-1)*b(i,l,t) ) - due(i) =l= tp(i)  ;
c20(i).. due(i) - sum( (t,l) , (ord(t)-1)*b(i,l,t) ) =l= tn(i) ;
c21(i).. tp(i) =l= Late ;
c22(i).. tn(i) =l= Early ;

model spliting /all/;

option resLim=7200;
option optCR=0.0001
option Threads=50
option solver=Baron

solve spliting minimizing objV using MINLP;
scalar   runtime;
runtime = spliting.etSolve     ;
scalar lowerbound,lowerbound2 ;
lowerbound  = spliting.objEst ;
lowerbound2 = spliting.rObj ;
scalar objval;objval=spliting.objVal;

*Execute_Unload ' G:\My Drive\Side Projects\Cutting stock (APA)\Code\Model\Output\Spliting_model_optimal_5_1_1',alpha,beta,gamma,o,y,BQ,r,P,runtime,lowerbound,lowerbound2,objval;
*execute "gdx2sqlite -i  G:\My Drive\Side Projects\Cutting stock (APA)\Code\Model\Output\Spliting_model_optimal_5_1_1.gdx -o   G:\My Drive\Side Projects\Cutting stock (APA)\Code\Model\Output\Spliting_model_optimal_5_1_1.db" ;

display due,Late,Early;
