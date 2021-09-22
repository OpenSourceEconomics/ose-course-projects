#include <Rcpp.h>
#include <math.h>
#include <vector>
#include <cassert>
#include <numeric>
#include <algorithm>
#include <functional>
using namespace Rcpp;

double interpolate(double x_left, double x_right, double y_left, double y_right, double x){
  if(x == x_left) return(y_left);
  double m = (y_right - y_left) / (x_right - x_left);
  double y = y_left + m * (x - x_left);
  return(y);
}

double x_lneigh(NumericVector args, double x) {
  int len = args.size();
  int i = 0;
  
  while(i < len){
    if(x >= args[i]){
      if(x == args[i]) return(i);
      i++;
    }
    else{
      break;
    }
  } 
  return(i-1);
}

// [[Rcpp::export]]
NumericVector grid_approx_obs(NumericVector args, NumericVector vals, NumericVector grid) {
  
  int n_points = grid.size();
  NumericVector output(n_points);
  int x_l = 0;
  
  for(int i = 0; i < n_points; i++){
    x_l = x_lneigh(args, grid[i]);
    output(i) = interpolate(args[x_l], args[x_l + 1], vals[x_l], vals[x_l + 1], grid[i]);
  }
  
  return(output);
}

double truncNormKernel(double t) {
  if(t <= 0) return(0);
  else{
    return(2. / sqrt(2. * M_PI) * exp(- pow(t,2.)/2.));
  }
}

double quant(NumericVector v, double alpha){
  
  int k = floor((double) v.size() * alpha);
  auto m = v.begin() + k;
  NumericVector tmp = clone(v);
  
  std::nth_element(tmp.begin(), m, tmp.end());
  
  return(tmp[k]);
}

double func_norm(NumericVector grid, NumericVector vals1, NumericVector vals2){
    
  int num_points = grid.size();
  NumericVector deltas(num_points - 1);
  NumericVector tmp1(num_points - 1);
  NumericVector tmp2(num_points - 1);
    
  for(int i = 0; i < num_points - 1; i++){
      deltas[i] = grid[i+1] - grid[i];
      tmp1[i] = vals1[i+1];
      tmp2[i] = vals2[i+1];
  }  
    
  return(sqrt(sum(deltas * pow(tmp1 - tmp2, 2))));
}

// [[Rcpp::export]]
NumericVector hM_depth(NumericMatrix valueMatrix, NumericVector grid) {
  
  int n = valueMatrix.nrow();
  NumericMatrix norms(n,n);
  NumericMatrix Kernel_norms(n,n);
  NumericVector tmp(n*n);
  int z = n;
  
  // Main diagonal is zero
  for(int i = 1; i < n; i++){
    for(int j = 0; j < i; j++){
      norms(i,j) = func_norm(grid, valueMatrix(i, _ ), valueMatrix(j, _ ));
      norms(j,i) = norms(i,j);
      
      tmp[z] = norms(i,j);
      tmp[z+1] = norms(i,j);
      z += 2;
    }
  }

  double h = quant(tmp, 0.15);
  // Rcout << h;
  
  for(int i = 0; i < n; i++){
    for(int j = 0; j < i; j++){
      Kernel_norms(i,j) = truncNormKernel(norms(i,j) / h);
      Kernel_norms(j,i) = Kernel_norms(i,j);
    }
  }
  
  NumericVector fdepths = rowSums(Kernel_norms);
  return(fdepths);
}
