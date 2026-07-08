// PortfolioSimulator.cs
using System;
using System.Collections.Generic;
using System.Linq;

class Asset
{
    public string Name { get; set; }
    public double Mean { get; set; }
    public double Std { get; set; }
}

class PortfolioSimulator
{
    static Random rand = new Random();

    static double NormalRandom(double mean, double std)
    {
        double u1 = rand.NextDouble();
        double u2 = rand.NextDouble();
        double z = Math.Sqrt(-2.0 * Math.Log(u1)) * Math.Cos(2 * Math.PI * u2);
        return mean + std * z;
    }

    static double SimulateYear(List<Asset> assets, List<double> weights)
    {
        double[] returns = new double[assets.Count];
        for (int i = 0; i < assets.Count; i++)
        {
            returns[i] = NormalRandom(assets[i].Mean, assets[i].Std) / 100.0;
        }
        double portRet = 0;
        for (int i = 0; i < weights.Count; i++)
        {
            portRet += weights[i] * returns[i];
        }
        return portRet;
    }

    static List<double> RunSimulations(double initial, int years, List<Asset> assets, List<double> weights, int numSims)
    {
        List<double> results = new List<double>();
        for (int s = 0; s < numSims; s++)
        {
            double balance = initial;
            for (int y = 0; y < years; y++)
            {
                double ret = SimulateYear(assets, weights);
                balance *= (1 + ret);
            }
            results.Add(balance);
        }
        return results;
    }

    static void Main()
    {
        Console.WriteLine("=== Portfolio Simulator ===");
        Console.Write("Initial investment: ");
        double initial = double.Parse(Console.ReadLine());
        Console.Write("Investment horizon (years): ");
        int years = int.Parse(Console.ReadLine());
        Console.Write("Number of assets (2-5): ");
        int nAssets = int.Parse(Console.ReadLine());
        if (nAssets < 2 || nAssets > 5)
        {
            Console.WriteLine("Please choose 2-5 assets.");
            return;
        }

        List<Asset> assets = new List<Asset>();
        List<double> weights = new List<double>();
        double totalWeight = 0;
        for (int i = 0; i < nAssets; i++)
        {
            Console.WriteLine($"\nAsset {i+1}:");
            Console.Write("  Name: ");
            string name = Console.ReadLine();
            Console.Write("  Weight (%): ");
            double w = double.Parse(Console.ReadLine());
            weights.Add(w / 100.0);
            totalWeight += weights[i];
            Console.Write("  Expected return (%): ");
            double mean = double.Parse(Console.ReadLine());
            Console.Write("  Volatility (%): ");
            double std = double.Parse(Console.ReadLine());
            assets.Add(new Asset { Name = name, Mean = mean, Std = std });
        }
        if (Math.Abs(totalWeight - 1.0) > 0.001)
        {
            Console.WriteLine("Weights must sum to 100%.");
            return;
        }

        int numSims = 10000;
        Console.WriteLine($"\nRunning {numSims} simulations...");
        List<double> results = RunSimulations(initial, years, assets, weights, numSims);

        // Statistics
        results.Sort();
        double mean = results.Average();
        double median = results[results.Count / 2];
        double p5 = results[(int)(0.05 * results.Count)];
        double p95 = results[(int)(0.95 * results.Count)];
        int lossCount = results.Count(r => r < initial);
        double lossProb = (double)lossCount / results.Count * 100;
        double cagr = Math.Pow(median / initial, 1.0 / years) - 1;
        double riskFree = 0.02;
        double[] logReturns = results.Select(r => Math.Log(r / initial) / years).ToArray();
        double avgLog = logReturns.Average();
        double stdLog = Math.Sqrt(logReturns.Select(r => Math.Pow(r - avgLog, 2)).Average());
        double sharpe = (avgLog - riskFree) / stdLog;

        Console.WriteLine("\n--- Results ---");
        Console.WriteLine($"Mean final value:   ${mean:F2}");
        Console.WriteLine($"Median final value: ${median:F2}");
        Console.WriteLine($"5th percentile:     ${p5:F2}");
        Console.WriteLine($"95th percentile:    ${p95:F2}");
        Console.WriteLine($"Probability of loss: {lossProb:F2}%");
        Console.WriteLine($"Expected CAGR:      {cagr*100:F2}%");
        Console.WriteLine($"Sharpe ratio:       {sharpe:F3}");

        // Histogram
        double minVal = results[0];
        double maxVal = results[results.Count - 1];
        int bins = 20;
        double binWidth = (maxVal - minVal) / bins;
        int[] hist = new int[bins];
        foreach (var r in results)
        {
            int idx = (int)((r - minVal) / binWidth);
            if (idx >= bins) idx = bins - 1;
            hist[idx]++;
        }
        int maxCount = hist.Max();
        Console.WriteLine("\nDistribution histogram:");
        for (int i = 0; i < hist.Length; i++)
        {
            int barLen = (int)((double)hist[i] / maxCount * 40);
            string bar = new string('█', barLen);
            double lower = minVal + i * binWidth;
            double upper = lower + binWidth;
            Console.WriteLine($"{lower,8:F0}-{upper,8:F0}: {bar} ({hist[i]})");
        }
    }
}
