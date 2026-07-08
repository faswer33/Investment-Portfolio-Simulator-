# portfolio_simulator.rb
def normal_random(mean, std)
  u1 = rand
  u2 = rand
  z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2 * Math::PI * u2)
  mean + std * z
end

def simulate_year(assets, weights)
  returns = assets.map { |a| normal_random(a[:mean], a[:std]) / 100.0 }
  port_ret = weights.each_with_index.sum { |w, i| w * returns[i] }
  port_ret
end

def run_simulations(initial, years, assets, weights, num_sims)
  results = []
  num_sims.times do
    balance = initial
    years.times do
      ret = simulate_year(assets, weights)
      balance *= (1 + ret)
    end
    results << balance
  end
  results
end

def main
  puts "=== Portfolio Simulator ==="
  print "Initial investment: "
  initial = gets.to_f
  print "Investment horizon (years): "
  years = gets.to_i
  print "Number of assets (2-5): "
  n_assets = gets.to_i
  if n_assets < 2 || n_assets > 5
    puts "Please choose 2-5 assets."
    return
  end

  assets = []
  weights = []
  total_weight = 0.0
  n_assets.times do |i|
    puts "\nAsset #{i+1}:"
    print "  Name: "
    name = gets.chomp
    print "  Weight (%): "
    w = gets.to_f / 100.0
    weights << w
    total_weight += w
    print "  Expected return (%): "
    mean = gets.to_f
    print "  Volatility (%): "
    std = gets.to_f
    assets << { name: name, mean: mean, std: std }
  end
  if (total_weight - 1.0).abs > 0.001
    puts "Weights must sum to 100%."
    return
  end

  num_sims = 10000
  puts "\nRunning #{num_sims} simulations..."
  results = run_simulations(initial, years, assets, weights, num_sims)

  # Statistics
  sorted = results.sort
  mean = results.sum / results.size
  median = sorted[sorted.size / 2]
  p5 = sorted[(0.05 * sorted.size).to_i]
  p95 = sorted[(0.95 * sorted.size).to_i]
  loss_prob = results.count { |r| r < initial }.to_f / results.size * 100
  cagr = (median / initial) ** (1.0 / years) - 1
  risk_free = 0.02
  log_returns = results.map { |r| Math.log(r / initial) / years }
  avg_log = log_returns.sum / log_returns.size
  std_log = Math.sqrt(log_returns.map { |r| (r - avg_log) ** 2 }.sum / (log_returns.size - 1))
  sharpe = (avg_log - risk_free) / std_log

  puts "\n--- Results ---"
  puts "Mean final value:   $#{'%.2f' % mean}"
  puts "Median final value: $#{'%.2f' % median}"
  puts "5th percentile:     $#{'%.2f' % p5}"
  puts "95th percentile:    $#{'%.2f' % p95}"
  puts "Probability of loss: #{'%.2f' % loss_prob}%"
  puts "Expected CAGR:      #{'%.2f' % (cagr * 100)}%"
  puts "Sharpe ratio:       #{'%.3f' % sharpe}"

  # Histogram
  min_val = sorted.first
  max_val = sorted.last
  bins = 20
  bin_width = (max_val - min_val) / bins
  hist = Array.new(bins, 0)
  results.each do |r|
    idx = ((r - min_val) / bin_width).to_i
    idx = bins - 1 if idx >= bins
    hist[idx] += 1
  end
  max_count = hist.max
  puts "\nDistribution histogram:"
  hist.each_with_index do |count, i|
    bar_len = ((count.to_f / max_count) * 40).to_i
    bar = '█' * bar_len
    lower = min_val + i * bin_width
    upper = lower + bin_width
    puts "#{'%.0f' % lower}-#{'%.0f' % upper}: #{bar} (#{count})"
  end
end

main if __FILE__ == $0
