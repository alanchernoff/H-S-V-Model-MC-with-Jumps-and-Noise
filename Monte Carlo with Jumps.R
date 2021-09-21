#Model Parametrs

m = 0.05 
phi = 5  
v = 0.04 
eta = 0.5 
rho = -0.5 
del = (1/252)/1560 
sdel = sqrt(del)
srho = sqrt(1-rho^2)

#Simulation set up 

n = 10000 #number of simulations

blanks=matrix(0,nrow=n,ncol=1559)
y = cbind(matrix(m,nrow=n,ncol=1),blanks)
S2 = cbind(matrix(v,nrow=n,ncol=1),blanks)
S2_jumps = matrix(0,nrow=n,ncol=1560)
W1 = matrix(rnorm(n*15600),nrow=n,ncol=1560)
n1 = matrix(rnorm(n*15600),nrow=n,ncol=1560)
W2 = (n1*srho +rho*W1)

#To test for the correlation of -0.5 between brownian motions W1 and W2
#use cor(W1[i,],W2[i,]) for any i < number of simulations

#Jump generation

jmin = 0 ;
jmax = 1/252 ;
jp = jmin + runif(10000)*(jmax - jmin);
jt = round(1560*jp*252);
ser = 1:1560 ;
jump=matrix(0,nrow=1560,ncol=n)
for (i in 1:1560){
  jump[i,] = ser[i];
}

for (j in 1:10000){
  for (i in 1:1560){
    if (jump[i,j] == jt[j]){
      jump[i,j] = 1;
    }else{
      jump[i,j] = 0;
    }
  }
}

j_price = t(matrix(rnorm(n*15600,0,0.02),nrow=1560,ncol=n)*jump)

j_vol = t(matrix(exp(rnorm(n*15600,-5,1)),nrow=1560,ncol=n)*jump)

#Heston Volatility Equation pre-jumps (calculated separately for ease of IV calculation)

for (i in 1:1559){
  S2[,i+1] <- S2[,i] +phi*(v - S2[,i])*del + eta*sqrt(S2[,i])*W2[,i]*sdel
}

#Heston Volatility Equation including jumps

for (i in 0:1559){
  S2_jumps[,i] <- S2[,i] + j_vol[,i]
}

#Heston Volatility Price Equation

for (i in 1:1559){
  y[,i+1] <- y[,i] + (m - (S2[,i])/2 )*del + sqrt(S2[,i])*W1[,i]*sdel + j_price[,i]
}

#Generate data for simulated 20, 10, and 5 minute intervals

y_78 = y[,seq(1,ncol(y), 20)]
y_156 = y[,seq(1,ncol(y), 10)]
y_312 = y[,seq(1,ncol(y), 5)]

#Volatility Calculation

RV = (rowSums(S2))*del
