// PortfolioSimulator.java
import java.util.*;

class Asset {
    String name;
    double mean;
    double std;
}

public class PortfolioSimulator {
    private static Random rand = new Random();

    private static double normalRandom(double mean, double std) {
        double u1 = rand.nextDouble();
        double u2 = rand.nextDouble();
        double z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
        return mean + std * z;
    }

    private static double simulateYear(List<Asset> assets, List<Double> weights) {
        double[] returns = new double[assets.size()];
        for (int i = 0; i < assets.size(); i++) {
            returns[i] = normalRandom(assets.get(i).mean, assets.get(i).std) / 100.0;
        }
        double portRet = 0;
        for (int i = 0; i < weights.size(); i++) {
            portRet += weights.get(i) * returns[i];
        }
        return portRet;
    }

    private static List<Double> runSimulations(double initial, int years, List<Asset> assets, List<Double> weights, int numSims) {
        List<Double> results = new ArrayList<>();
        for (int s = 0; s < numSims; s++) {
            double balance = initial;
            for (int y = 0; y < years; y++) {
                double ret = simulateYear(assets, weights);
                balance *= (1 + ret);
            }
            results.add(balance);
        }
        return results;
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.println("=== Portfolio Simulator ===");
        System.out.print("Initial investment: ");
        double initial = scanner.nextDouble();
        System.out.print("Investment horizon (years): ");
        int years = scanner.nextInt();
        System.out.print("Number of assets (2-5): ");
        int nAssets = scanner.nextInt();
        if (nAssets < 2 || nAssets > 5) {
            System.out.println("Please choose 2-5 assets.");
            return;
        }

        List<Asset> assets = new ArrayList<>();
        List<Double> weights = new ArrayList<>();
        double totalWeight = 0;
        for (int i = 0; i < nAssets; i++) {
            System.out.println("\nAsset " + (i+1) + ":");
            System.out.print("  Name: ");
            String name = scanner.next();
            System.out.print("  Weight (%): ");
            double w = scanner.nextDouble();
            weights.add(w / 100.0);
            totalWeight += weights.get(i);
            System.out.print("  Expected return (%): ");
            double mean = scanner.nextDouble();
            System.out.print("  Volatility (%): ");
            double std = scanner.nextDouble();
            Asset a = new Asset();
            a.name = name;
            a.mean = mean;
            a.std = std;
            assets.add(a);
        }
        if (Math.abs(totalWeight - 1.0) > 0.001) {
            System.out.println("Weights must sum to 100%.");
            return;
        }

        int numSims = 10000;
        System.out.println("\nRunning " + numSims + " simulations...");
        List<Double> results = runSimulations(initial, years, assets, weights, numSims);

        // Statistics
        Collections.sort(results);
        double mean = results.stream().mapToDouble(Double::doubleValue).average().orElse(0);
        double median = results.get(results.size() / 2);
        double p5 = results.get((int)(0.05 * results.size()));
        double p95 = results.get((int)(0.95 * results.size()));
        long lossCount = results.stream().filter(r -> r < initial).count();
        double lossProb = (double)lossCount / results.size() * 100;
        double cagr = Math.pow(median / initial, 1.0 / years) - 1;
        double riskFree = 0.02;
        double[] logReturns = results.stream().mapToDouble(r -> Math.log(r / initial) / years).toArray();
        double avgLog = Arrays.stream(logReturns).average().orElse(0);
        double stdLog = Math.sqrt(Arrays.stream(logReturns).map(r -> Math.pow(r - avgLog, 2)).average().orElse(0));
        double sharpe = (avgLog - riskFree) / stdLog;

        System.out.println("\n--- Results ---");
        System.out.printf("Mean final value:   $%.2f\n", mean);
        System.out.printf("Median final value: $%.2f\n", median);
        System.out.printf("5th percentile:     $%.2f\n", p5);
        System.out.printf("95th percentile:    $%.2f\n", p95);
        System.out.printf("Probability of loss: %.2f%%\n", lossProb);
        System.out.printf("Expected CAGR:      %.2f%%\n", cagr*100);
        System.out.printf("Sharpe ratio:       %.3f\n", sharpe);

        // Histogram
        double minVal = results.get(0);
        double maxVal = results.get(results.size()-1);
        int bins = 20;
        double binWidth = (maxVal - minVal) / bins;
        int[] hist = new int[bins];
        for (double r : results) {
            int idx = (int)((r - minVal) / binWidth);
            if (idx >= bins) idx = bins - 1;
            hist[idx]++;
        }
        int maxCount = Arrays.stream(hist).max().orElse(1);
        System.out.println("\nDistribution histogram:");
        for (int i = 0; i < hist.length; i++) {
            int barLen = (int)((double)hist[i] / maxCount * 40);
            String bar = "█".repeat(Math.max(0, barLen));
            double lower = minVal + i * binWidth;
            double upper = lower + binWidth;
            System.out.printf("%8.0f-%8.0f: %s (%d)\n", lower, upper, bar, hist[i]);
        }
        scanner.close();
    }
}
