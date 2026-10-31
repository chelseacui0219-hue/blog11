# Blog Post 11: Bayesian SVAR with MCMC

## Overview
This project estimates a Bayesian Structural Vector Autoregression (SVAR) to investigate the macroeconomic effects of a contractionary monetary policy shock. The analysis uses monthly U.S. data from 1980 to 2019, identifies the structural shock via Cholesky recursive restrictions, and employs a Gibbs sampler for Markov Chain Monte Carlo (MCMC) estimation. The final output traces the dynamic responses of industrial production and inflation over a 24-month horizon.

## Data Source
The data comes from **FRED-MD** (Federal Reserve Economic Data - Monthly Database), maintained by the Federal Reserve Bank of St. Louis. 

- **Access method**: The data is automatically downloaded via the `download_data_fred_md()` function from the `tidyfinance` R package.
- **Variables included**:
  - `INDPRO`: Industrial Production Index (log-differenced)
  - `CPIAUCSL`: Consumer Price Index (log-differenced)
  - `FEDFUNDS`: Effective Federal Funds Rate (level)
  - `GS10`: 10-Year Treasury Constant Maturity Rate (level)
- **Sample period**: January 1980 to December 2019 (480 monthly observations). The post-2020 period is excluded to avoid distortions from the zero lower bound and the COVID-19 pandemic.

## Methodology
1. **Model**: Bayesian VAR with 6 lags (\(p = 6\)). 
2. **Identification**: Cholesky recursive restrictions (Sims, 1980). The variable ordering is `[INDPRO, CPIAUCSL, FEDFUNDS, GS10]`, meaning the third shock is identified as the exogenous monetary policy shock.
3. **Prior**: A Minnesota prior is applied to the VAR coefficients to prevent overfitting, and an inverse-Wishart prior is used for the covariance matrix.
4. **MCMC**: Estimation is performed using a Gibbs sampler. To ensure computational efficiency, we use the homoskedastic version (`specify_bsvar`) rather than the stochastic volatility version. The sampler runs 1,000 burn-in iterations and retains 2,000 posterior draws.
5. **Output**: Impulse Response Functions (IRFs) are computed over a 24-month horizon, with 68% Bayesian credible intervals.

## Reproducibility
To reproduce the analysis:
1. Install the required packages:
   ```R
   install.packages(c("bsvars", "tidyfinance", "dplyr", "ggplot2"))