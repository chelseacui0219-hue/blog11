# ============================================================
# Blog Post 11: Bayesian SVAR with MCMC
# Monetary Policy Shock and Macroeconomic Dynamics
# ============================================================

# library
pkgs <- c("bsvars", "tidyfinance", "dplyr", "ggplot2")
for (p in pkgs) if (!requireNamespace(p, quietly = TRUE)) install.packages(p)

library(bsvars)
library(tidyfinance)
library(dplyr)
library(ggplot2)

set.seed(2024)
dir.create("output", showWarnings = FALSE)

# ---------- 1. dta ----------
fred <- download_data_fred_md("FRED-MD", transform = TRUE)

# variable
Y_mat <- fred |>
  dplyr::select(date, INDPRO, CPIAUCSL, FEDFUNDS, GS10) |>
  dplyr::filter(date >= as.Date("1980-01-01"), date <= as.Date("2019-12-01")) |>
  dplyr::select(-date) |>
  as.matrix()

cat("样本量:", nrow(Y_mat), "个月\n")

# ---------- 2. Bayesian SVAR ----------
spec <- specify_bsvar$new(Y_mat, p = 6L)

# ---------- 3. MCMC estimation (Gibbs Sampler) ----------
burn <- estimate(spec, S = 1000, show_progress = FALSE)

post <- estimate(burn, S = 2000, show_progress = FALSE)

# ---------- 4. impulse response ----------
irf <- compute_impulse_responses(post, horizon = 24)

# ---------- 5. graph ----------
if (is.list(irf)) {
  irf_names <- names(irf)

  point_est <- irf[[grep("irf|point|median", irf_names)[1]]]
  lower_bound <- irf[[grep("lower|lower68|quantile16", irf_names)[1]]]
  upper_bound <- irf[[grep("upper|upper68|quantile84", irf_names)[1]]]
} else {
  point_est <- unclass(irf)
  lower_bound <- point_est
  upper_bound <- point_est
}

horizon <- 0:24

df_indpro <- data.frame(
  horizon = horizon,
  median = point_est[1, 3, ],
  lower = lower_bound[1, 3, ],
  upper = upper_bound[1, 3, ]
)
df_cpi <- data.frame(
  horizon = horizon,
  median = point_est[2, 3, ],
  lower = lower_bound[2, 3, ],
  upper = upper_bound[2, 3, ]
)

p_indpro <- ggplot(df_indpro, aes(x = horizon)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "steelblue", alpha = 0.3) +
  geom_line(aes(y = median), color = "steelblue", size = 1.2) +
  labs(x = "Months after shock", y = "Response of INDPRO",
       title = "Industrial Production to Monetary Policy Shock") +
  theme_minimal()

ggsave("output/irf_indpro.png", p_indpro, width = 8, height = 5, dpi = 300)

# CPI
p_cpi <- ggplot(df_cpi, aes(x = horizon)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "firebrick", alpha = 0.3) +
  geom_line(aes(y = median), color = "firebrick", size = 1.2) +
  labs(x = "Months after shock", y = "Response of CPI",
       title = "CPI Inflation to Monetary Policy Shock") +
  theme_minimal()

ggsave("output/irf_cpi.png", p_cpi, width = 8, height = 5, dpi = 300)
