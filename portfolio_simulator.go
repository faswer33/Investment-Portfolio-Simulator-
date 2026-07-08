// portfolio_simulator.go
package main

import (
	"bufio"
	"fmt"
	"math"
	"math/rand"
	"os"
	"sort"
	"strconv"
	"strings"
	"time"
)

type Asset struct {
	Name string
	Mean float64 // expected return (%)
	Std  float64 // volatility (%)
}

func normalRandom(mean, std float64) float64 {
	u1 := rand.Float64()
	u2 := rand.Float64()
	z := math.Sqrt(-2.0*math.Log(u1)) * math.Cos(2*math.Pi*u2)
	return mean + std*z
}

func simulateYear(assets []Asset, weights []float64) float64 {
	returns := make([]float64, len(assets))
	for i, a := range assets {
		returns[i] = normalRandom(a.Mean, a.Std) / 100.0
	}
	portRet := 0.0
	for i, w := range weights {
		portRet += w * returns[i]
	}
	return portRet
}

func runSimulations(initial float64, years int, assets []Asset, weights []float64, numSims int) []float64 {
	results := make([]float64, numSims)
	for s := 0; s < numSims; s++ {
		balance := initial
		for y := 0; y < years; y++ {
			ret := simulateYear(assets, weights)
			balance *= (1 + ret)
		}
		results[s] = balance
	}
	return results
}

func main() {
	rand.Seed(time.Now().UnixNano())
	reader := bufio.NewReader(os.Stdin)

	fmt.Println("=== Portfolio Simulator ===")
	fmt.Print("Initial investment: ")
	input, _ := reader.ReadString('\n')
	initial, _ := strconv.ParseFloat(strings.TrimSpace(input), 64)

	fmt.Print("Investment horizon (years): ")
	input, _ = reader.ReadString('\n')
	years, _ := strconv.Atoi(strings.TrimSpace(input))

	fmt.Print("Number of assets (2-5): ")
	input, _ = reader.ReadString('\n')
	nAssets, _ := strconv.Atoi(strings.TrimSpace(input))
	if nAssets < 2 || nAssets > 5 {
		fmt.Println("Please choose 2-5 assets.")
		return
	}

	assets := make([]Asset, nAssets)
	weights := make([]float64, nAssets)
	totalWeight := 0.0
	for i := 0; i < nAssets; i++ {
		fmt.Printf("\nAsset %d:\n", i+1)
		fmt.Print("  Name: ")
		name, _ := reader.ReadString('\n')
		assets[i].Name = strings.TrimSpace(name)

		fmt.Print("  Weight (%): ")
		input, _ = reader.ReadString('\n')
		w, _ := strconv.ParseFloat(strings.TrimSpace(input), 64)
		weights[i] = w / 100.0
		totalWeight += weights[i]

		fmt.Print("  Expected return (%): ")
		input, _ = reader.ReadString('\n')
		assets[i].Mean, _ = strconv.ParseFloat(strings.TrimSpace(input), 64)

		fmt.Print("  Volatility (%): ")
		input, _ = reader.ReadString('\n')
		assets[i].Std, _ = strconv.ParseFloat(strings.TrimSpace(input), 64)
	}
	if math.Abs(totalWeight-1.0) > 0.001 {
		fmt.Println("Weights must sum to 100%.")
		return
	}

	numSims := 10000
	fmt.Printf("\nRunning %d simulations...\n", numSims)
	results := runSimulations(initial, years, assets, weights, numSims)

	// Statistics
	sort.Float64s(results)
	mean := 0.0
	for _, v := range results {
		mean += v
	}
	mean /= float64(numSims)
	median := results[numSims/2]
	p5 := results[int(0.05*float64(numSims))]
	p95 := results[int(0.95*float64(numSims))]
	lossCount := 0
	for _, v := range results {
		if v < initial {
			lossCount++
		}
	}
	lossProb := float64(lossCount) / float64(numSims) * 100.0
	cagr := math.Pow(median/initial, 1.0/float64(years)) - 1.0
	// Sharpe ratio
	riskFree := 0.02
	logReturns := make([]float64, numSims)
	for i, v := range results {
		logReturns[i] = math.Log(v/initial) / float64(years)
	}
	avgLog := 0.0
	for _, v := range logReturns {
		avgLog += v
	}
	avgLog /= float64(numSims)
	stdLog := 0.0
	for _, v := range logReturns {
		diff := v - avgLog
		stdLog += diff * diff
	}
	stdLog = math.Sqrt(stdLog / float64(numSims-1))
	sharpe := (avgLog - riskFree) / stdLog

	fmt.Println("\n--- Results ---")
	fmt.Printf("Mean final value:   $%.2f\n", mean)
	fmt.Printf("Median final value: $%.2f\n", median)
	fmt.Printf("5th percentile:     $%.2f\n", p5)
	fmt.Printf("95th percentile:    $%.2f\n", p95)
	fmt.Printf("Probability of loss: %.2f%%\n", lossProb)
	fmt.Printf("Expected CAGR:      %.2f%%\n", cagr*100)
	fmt.Printf("Sharpe ratio:       %.3f\n", sharpe)

	// Histogram
	minVal := results[0]
	maxVal := results[numSims-1]
	bins := 20
	binWidth := (maxVal - minVal) / float64(bins)
	hist := make([]int, bins)
	for _, v := range results {
		idx := int((v - minVal) / binWidth)
		if idx >= bins {
			idx = bins - 1
		}
		hist[idx]++
	}
	maxCount := 0
	for _, c := range hist {
		if c > maxCount {
			maxCount = c
		}
	}
	fmt.Println("\nDistribution histogram:")
	for i, count := range hist {
		barLen := int((float64(count) / float64(maxCount)) * 40)
		bar := strings.Repeat("█", barLen)
		lower := minVal + float64(i)*binWidth
		upper := lower + binWidth
		fmt.Printf("%8.0f-%8.0f: %s (%d)\n", lower, upper, bar, count)
	}
}
