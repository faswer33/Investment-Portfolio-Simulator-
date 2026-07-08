// portfolio_simulator.js
const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

function normalRandom(mean, std) {
    let u1 = Math.random();
    let u2 = Math.random();
    let z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
    return mean + std * z;
}

function simulateYear(assets, weights) {
    let returns = assets.map(a => normalRandom(a.mean, a.std) / 100.0);
    let portRet = 0;
    for (let i = 0; i < weights.length; i++) {
        portRet += weights[i] * returns[i];
    }
    return portRet;
}

function runSimulations(initial, years, assets, weights, numSims) {
    let results = [];
    for (let s = 0; s < numSims; s++) {
        let balance = initial;
        for (let y = 0; y < years; y++) {
            let ret = simulateYear(assets, weights);
            balance *= (1 + ret);
        }
        results.push(balance);
    }
    return results;
}

async function main() {
    console.log("=== Portfolio Simulator ===");
    let initial = parseFloat(await ask("Initial investment: "));
    let years = parseInt(await ask("Investment horizon (years): "));
    let nAssets = parseInt(await ask("Number of assets (2-5): "));
    if (nAssets < 2 || nAssets > 5) {
        console.log("Please choose 2-5 assets.");
        rl.close();
        return;
    }
    let assets = [];
    let weights = [];
    let totalWeight = 0;
    for (let i = 0; i < nAssets; i++) {
        console.log(`\nAsset ${i+1}:`);
        let name = await ask("  Name: ");
        let w = parseFloat(await ask("  Weight (%): "));
        let mean = parseFloat(await ask("  Expected return (%): "));
        let std = parseFloat(await ask("  Volatility (%): "));
        assets.push({ name, mean, std });
        weights.push(w / 100.0);
        totalWeight += weights[i];
    }
    if (Math.abs(totalWeight - 1.0) > 0.001) {
        console.log("Weights must sum to 100%.");
        rl.close();
        return;
    }

    const numSims = 10000;
    console.log(`\nRunning ${numSims} simulations...`);
    let results = runSimulations(initial, years, assets, weights, numSims);

    // Statistics
    let sorted = results.slice().sort((a,b) => a-b);
    let mean = results.reduce((a,b) => a+b, 0) / results.length;
    let median = sorted[Math.floor(sorted.length/2)];
    let p5 = sorted[Math.floor(0.05 * sorted.length)];
    let p95 = sorted[Math.floor(0.95 * sorted.length)];
    let lossProb = results.filter(r => r < initial).length / results.length * 100;
    let cagr = Math.pow(median/initial, 1/years) - 1;
    let riskFree = 0.02;
    let logReturns = results.map(r => Math.log(r/initial) / years);
    let avgLog = logReturns.reduce((a,b) => a+b, 0) / logReturns.length;
    let stdLog = Math.sqrt(logReturns.map(r => Math.pow(r-avgLog, 2)).reduce((a,b) => a+b, 0) / (logReturns.length - 1));
    let sharpe = (avgLog - riskFree) / stdLog;

    console.log("\n--- Results ---");
    console.log(`Mean final value:   $${mean.toFixed(2)}`);
    console.log(`Median final value: $${median.toFixed(2)}`);
    console.log(`5th percentile:     $${p5.toFixed(2)}`);
    console.log(`95th percentile:    $${p95.toFixed(2)}`);
    console.log(`Probability of loss: ${lossProb.toFixed(2)}%`);
    console.log(`Expected CAGR:      ${(cagr*100).toFixed(2)}%`);
    console.log(`Sharpe ratio:       ${sharpe.toFixed(3)}`);

    // Histogram
    let minVal = sorted[0];
    let maxVal = sorted[sorted.length-1];
    let bins = 20;
    let binWidth = (maxVal - minVal) / bins;
    let hist = new Array(bins).fill(0);
    for (let r of results) {
        let idx = Math.min(Math.floor((r - minVal) / binWidth), bins-1);
        hist[idx]++;
    }
    let maxCount = Math.max(...hist);
    console.log("\nDistribution histogram:");
    for (let i = 0; i < hist.length; i++) {
        let barLen = Math.round((hist[i] / maxCount) * 40);
        let bar = '█'.repeat(barLen);
        let lower = minVal + i * binWidth;
        let upper = lower + binWidth;
        console.log(`${lower.toFixed(0)}-${upper.toFixed(0)}: ${bar} (${hist[i]})`);
    }
    rl.close();
}

main().catch(console.error);
