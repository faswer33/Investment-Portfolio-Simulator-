# portfolio_simulator.py
import math
import random
import statistics

def normal_random(mean, std):
    """Box-Muller transform to generate normal random number."""
    u1 = random.random()
    u2 = random.random()
    z = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)
    return mean + std * z

def simulate_year(portfolio, weights):
    """Generate one year returns for each asset and return portfolio return."""
    returns = [normal_random(asset['mean'], asset['std']) / 100.0 for asset in portfolio]
    port_return = sum(w * r for w, r in zip(weights, returns))
    return port_return

def run_simulation(initial, years, portfolio, weights, num_sims=10000):
    results = []
    for _ in range(num_sims):
        balance = initial
        for y in range(years):
            ret = simulate_year(portfolio, weights)
            balance *= (1 + ret)
        results.append(balance)
    return results

def main():
    print("=== Portfolio Simulator ===")
    initial = float(input("Initial investment: "))
    years = int(input("Investment horizon (years): "))
    n_assets = int(input("Number of assets (2-5): "))
    if n_assets < 2 or n_assets > 5:
        print("Please choose 2-5 assets.")
        return
    portfolio = []
    weights = []
    total_weight = 0.0
    for i in range(n_assets):
        print(f"\nAsset {i+1}:")
        name = input("  Name: ")
        w = float(input("  Weight (%): "))
        mean = float(input("  Expected return (%): "))
        std = float(input("  Volatility (%): "))
        portfolio.append({'name': name, 'mean': mean, 'std': std})
        weights.append(w / 100.0)
        total_weight += w / 100.0
    if abs(total_weight - 1.0) > 0.001:
        print("Weights must sum to 100%.")
        return

    num_sims = 10000
    print(f"\nRunning {num_sims} simulations...")
    results = run_simulation(initial, years, portfolio, weights, num_sims)

    # Statistics
    mean_final = statistics.mean(results)
    median_final = statistics.median(results)
    sorted_res = sorted(results)
    p5 = sorted_res[int(0.05 * num_sims)]
    p95 = sorted_res[int(0.95 * num_sims)]
    loss_prob = sum(1 for r in results if r < initial) / num_sims * 100
    cagr = (median_final / initial) ** (1.0 / years) - 1
    # Sharpe ratio: assume risk-free = 2%
    risk_free = 0.02
    # Annualized return = CAGR, std of annual returns? We can estimate from final values?
    # Simpler: use median CAGR and volatility of annual returns from one simulation? Not accurate.
    # We'll compute from all simulations: compute annualized returns for each, then average.
    annual_returns = []
    # For simplicity, we'll compute Sharpe based on median CAGR and average volatility? Better: compute from simulation results.
    # Actually, we can compute the standard deviation of final values, then annualized std = std(log(final/initial))/sqrt(years)
    # We'll compute log returns.
    log_returns = [math.log(r / initial) / years for r in results]
    avg_log_return = statistics.mean(log_returns)
    std_log_return = statistics.stdev(log_returns) if len(log_returns) > 1 else 0.0
    sharpe = (avg_log_return - risk_free) / std_log_return if std_log_return > 0 else 0.0

    print("\n--- Results ---")
    print(f"Mean final value:   ${mean_final:,.2f}")
    print(f"Median final value: ${median_final:,.2f}")
    print(f"5th percentile:     ${p5:,.2f}")
    print(f"95th percentile:    ${p95:,.2f}")
    print(f"Probability of loss: {loss_prob:.2f}%")
    print(f"Expected CAGR:      {cagr*100:.2f}%")
    print(f"Sharpe ratio:       {sharpe:.3f}")

    # Histogram
    min_val = min(results)
    max_val = max(results)
    bins = 20
    bin_width = (max_val - min_val) / bins
    hist = [0] * bins
    for r in results:
        idx = min(int((r - min_val) / bin_width), bins-1)
        hist[idx] += 1
    max_count = max(hist)
    print("\nDistribution histogram:")
    for i, count in enumerate(hist):
        bar_len = int((count / max_count) * 40) if max_count > 0 else 0
        bar = '█' * bar_len
        lower = min_val + i * bin_width
        upper = lower + bin_width
        print(f"{lower:8.0f}-{upper:8.0f}: {bar} ({count})")

    # Median scenario growth
    # Find the simulation closest to median
    median_val = median_final
    median_idx = min(range(len(results)), key=lambda i: abs(results[i] - median_val))
    # Re-run that specific simulation to get yearly balances
    # We'll simulate one path with same random seed? Not needed; just show median scenario.
    # To get the path, we need to store the yearly balances for the median simulation.
    # Instead, we'll re-run a single simulation with median parameters? Not possible.
    # We'll just display the median final value and not the path for simplicity, or we can store paths during simulation.
    # For brevity, we'll skip year-by-year to keep code simpler, but we can show a table.
    # I'll implement a separate function to get the median path by re-running with same seed? Not deterministic.
    # Let's just output the median final value only.
    print(f"\nMedian scenario final value: ${median_final:,.2f}")

if __name__ == "__main__":
    main()
