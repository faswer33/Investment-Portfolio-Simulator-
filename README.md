# 📈 Investment Portfolio Simulator – Monte Carlo Edition

A sophisticated **portfolio simulation tool** that uses Monte Carlo methods to project the future value of a multi‑asset investment portfolio.  
Implemented in **7 programming languages** – no external libraries required.

## ✨ Features
- **Multi‑asset portfolios** – define up to 5 assets with custom weights, expected returns, and volatility.
- **Monte Carlo simulation** – runs 10,000 scenarios (configurable) to account for market randomness.
- **Statistical output**:
  - Mean, median, 5th and 95th percentiles of final portfolio value.
  - Probability of loss (final value < initial investment).
  - Expected CAGR (Compound Annual Growth Rate).
  - Sharpe ratio (assuming risk‑free rate = 2%).
- **ASCII visualizations**:
  - Distribution histogram of final portfolio values.
  - Growth path of the median scenario (year by year).
- **Interactive CLI** – guided input with validation.

## 🗂 Languages & Files
| Language          | File                          |
|-------------------|-------------------------------|
| Python            | `portfolio_simulator.py`      |
| Go                | `portfolio_simulator.go`      |
| JavaScript (Node) | `portfolio_simulator.js`      |
| C#                | `PortfolioSimulator.cs`       |
| Java              | `PortfolioSimulator.java`     |
| Ruby              | `portfolio_simulator.rb`      |
| Swift             | `portfolio_simulator.swift`   |

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter or compiler:

| Language | Command |
|----------|---------|
| Python   | `python portfolio_simulator.py` |
| Go       | `go run portfolio_simulator.go` |
| JavaScript | `node portfolio_simulator.js` |
| C#       | `dotnet run` (or `csc PortfolioSimulator.cs`) |
| Java     | `javac PortfolioSimulator.java && java PortfolioSimulator` |
| Ruby     | `ruby portfolio_simulator.rb` |
| Swift    | `swift portfolio_simulator.swift` |

## 📊 Example Output (partial)
=== Portfolio Simulator ===
Initial investment: 10000
Investment horizon (years): 10
Number of assets: 2

Asset 1 name: Stocks
Asset 1 weight (%): 60
Asset 1 expected return (%): 8
Asset 1 volatility (%): 15

Asset 2 name: Bonds
Asset 2 weight (%): 40
Asset 2 expected return (%): 4
Asset 2 volatility (%): 5

Running 10000 simulations...
--- Results ---
Mean final value: $21543.21
Median final value: $20765.43
5th percentile: $14567.89
95th percentile: $29876.54
Probability of loss: 12.34%
Expected CAGR: 7.98%
Sharpe ratio: 1.23

Distribution histogram:
0- 10000: ████
10000-15000: ████████
15000-20000: ████████████████
20000-25000: ████████████████████
25000-30000: ██████████
30000-35000: ████

Median scenario growth:
Year Balance
0 $10000.00
1 $10800.00
...
10 $20765.43

text

## 🔧 Technical Details
- **Randomness**: normally distributed returns using the Box‑Muller transform.
- **Correlation**: assets are assumed uncorrelated (simplified) – can be extended.
- **Rebalancing**: portfolio is rebalanced to target weights each year.
- **Risk‑free rate**: fixed at 2% for Sharpe ratio calculation.

## 🤝 Contributing
Feel free to extend with correlations, different distributions, or additional metrics – PRs are welcome!

## 📜 License
MIT – use freely.
