function [y, T] = static_1(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(13)=0;
  y(33)=0;
  y(43)=params(29);
  y(31)=1/params(3);
  y(32)=1/params(4);
  y(35)=1;
end
