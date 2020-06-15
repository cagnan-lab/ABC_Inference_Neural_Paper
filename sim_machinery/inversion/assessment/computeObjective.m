function [ACC R2] = computeObjective(R,r2)
R2 = R.SimAn.scoreweight(1)*(r2);
ACC = (R.SimAn.scoreweight(1)*(r2)) - (R.SimAn.scoreweight(2)*R.Mfit.DKL);