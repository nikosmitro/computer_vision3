function result = LeastEucDist(x, c)

[ndata, ~] = size(x);
[ncentres, ~] = size(c);
result = (ones(ncentres, 1) * sum((x.^2)', 1))' + ones(ndata, 1) * sum((c.^2)',1) - 2.*(x*(c'));

if any(any(result < 0))
  result(result < 0) = 0;
end

end