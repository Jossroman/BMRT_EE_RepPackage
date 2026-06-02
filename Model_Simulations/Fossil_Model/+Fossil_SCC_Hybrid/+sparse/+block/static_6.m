function [y, T] = static_6(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(3)=params(29)*(1+y(2))^(1-params(30));
end
