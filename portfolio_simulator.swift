// portfolio_simulator.swift
import Foundation

struct Asset {
    var name: String
    var mean: Double
    var std: Double
}

func normalRandom(mean: Double, std: Double) -> Double {
    let u1 = Double.random(in: 0...1)
    let u2 = Double.random(in: 0...1)
    let z = sqrt(-2.0 * log(u1)) * cos(2 * .pi * u2)
    return mean + std * z
}

func simulateYear(assets: [Asset], weights: [Double]) -> Double {
    var returns = [Double]()
    for a in assets {
        returns.append(normalRandom(mean: a.mean, std: a.std) / 100.0)
    }
    var portRet = 0.0
    for i in 0..<weights.count {
        portRet += weights[i] * returns[i]
    }
    return portRet
}

func runSimulations(initial: Double, years: Int, assets: [Asset], weights: [Double], numSims: Int) -> [Double] {
    var results = [Double]()
    for _ in 0..<numSims {
        var balance = initial
        for _ in 0..<years {
            let ret = simulateYear(assets: assets, weights: weights)
            balance *= (1 + ret)
        }
        results.append(balance)
    }
    return results
}

func main() {
    print("=== Portfolio Simulator ===")
    print("Initial investment: ", terminator: "")
    guard let initial = Double(readLine() ?? "") else { return }
    print("Investment horizon (years): ", terminator: "")
    guard let years = Int(readLine() ?? "") else { return }
    print("Number of assets (2-5): ", terminator: "")
    guard let nAssets = Int(readLine() ?? ""), nAssets >= 2, nAssets <= 5 else {
        print("Please choose 2-5 assets.")
        return
    }

    var assets = [Asset]()
    var weights = [Double]()
    var totalWeight = 0.0
    for i in 0..<nAssets {
        print("\nAsset \(i+1):")
        print("  Name: ", terminator: "")
        let name = readLine() ?? ""
        print("  Weight (%): ", terminator: "")
        let w = Double(readLine() ?? "")! / 100.0
        weights.append(w)
        totalWeight += w
        print("  Expected return (%): ", terminator: "")
        let mean = Double(readLine() ?? "")!
        print("  Volatility (%): ", terminator: "")
        let std = Double(readLine() ?? "")!
        assets.append(Asset(name: name, mean: mean, std: std))
    }
    if abs(totalWeight - 1.0) > 0.001 {
        print("Weights must sum to 100%.")
        return
    }

    let numSims = 10000
    print("\nRunning \(numSims) simulations...")
    let results = runSimulations(initial: initial, years: years, assets: assets, weights: weights, numSims: numSims)

    // Statistics
    let sorted = results.sorted()
    let mean = results.reduce(0, +) / Double(results.count)
    let median = sorted[sorted.count / 2]
    let p5 = sorted[Int(0.05 * Double(sorted.count))]
    let p95 = sorted[Int(0.95 * Double(sorted.count))]
    let lossCount = results.filter { $0 < initial }.count
    let lossProb = Double(lossCount) / Double(results.count) * 100
    let cagr = pow(median / initial, 1.0 / Double(years)) - 1
    let riskFree = 0.02
    let logReturns = results.map { log($0 / initial) / Double(years) }
    let avgLog = logReturns.reduce(0, +) / Double(logReturns.count)
    let stdLog = sqrt(logReturns.map { pow($0 - avgLog, 2) }.reduce(0, +) / Double(logReturns.count - 1))
    let sharpe = (avgLog - riskFree) / stdLog

    print("\n--- Results ---")
    print(String(format: "Mean final value:   $%.2f", mean))
    print(String(format: "Median final value: $%.2f", median))
    print(String(format: "5th percentile:     $%.2f", p5))
    print(String(format: "95th percentile:    $%.2f", p95))
    print(String(format: "Probability of loss: %.2f%%", lossProb))
    print(String(format: "Expected CAGR:      %.2f%%", cagr * 100))
    print(String(format: "Sharpe ratio:       %.3f", sharpe))

    // Histogram
    let minVal = sorted.first!
    let maxVal = sorted.last!
    let bins = 20
    let binWidth = (maxVal - minVal) / Double(bins)
    var hist = [Int](repeating: 0, count: bins)
    for r in results {
        var idx = Int((r - minVal) / binWidth)
        if idx >= bins { idx = bins - 1 }
        hist[idx] += 1
    }
    let maxCount = hist.max()!
    print("\nDistribution histogram:")
    for i in 0..<hist.count {
        let barLen = Int((Double(hist[i]) / Double(maxCount)) * 40)
        let bar = String(repeating: "█", count: barLen)
        let lower = minVal + Double(i) * binWidth
        let upper = lower + binWidth
        print(String(format: "%8.0f-%8.0f: %@ (%d)", lower, upper, bar, hist[i]))
    }
}

main()
