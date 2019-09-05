% testParLocal
a = in;
parfor i = 1:12
    x(i) = sum(randn(1,1e8));
end