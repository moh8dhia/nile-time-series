# Nile Time Series Analysis

This project focuses on the analysis of the **Nile river annual flow dataset**, available in R.
Before modeling, we analyze the variance of the time series.

If the variance appears to increase over time, a logarithmic transformation is applied in order to stabilize it and simplify the modeling process by converting a multiplicative structure into an additive one.

We compare both the original and transformed series to determine the most appropriate approach.

## Objective

The goal is to study the behavior of the time series, understand its structure, and build predictive models.

More specifically, we aim to:
- Analyze the trend and variability of the data
- Study autocorrelations (ACF, PACF)
- Check stationarity
- Build predictive models

## Methods

Several time series methods are used, inspired by the course project:

- ARIMA / SARIMA models
- Exponential smoothing
- Linear regression with trend and seasonality

## Dataset

The dataset used is the **Nile dataset**, which represents the annual flow of the Nile river.

It is directly available in R:

```r
Nile