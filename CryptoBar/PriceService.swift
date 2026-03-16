import Foundation

struct BinanceTicker: Codable {
    let symbol: String
    let price: String
}

struct PriceData {
    let symbol: String
    let price: Double
    let change24h: Double?
}

class PriceService {
    static let shared = PriceService()
    private let session = URLSession.shared

    // Map common names to Binance trading pairs
    private func tradingPair(for symbol: String, currency: String) -> String {
        let quote = currency == "USD" ? "USDT" : currency
        return "\(symbol.uppercased())\(quote)"
    }

    func fetchPrices(symbols: [String], currency: String) async -> [PriceData] {
        let pairs = symbols.map { tradingPair(for: $0, currency: currency) }
        let joined = pairs.map { "\"\($0)\"" }.joined(separator: ",")
        let urlString = "https://api.binance.com/api/v3/ticker/24hr?symbols=[\(joined)]"

        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, _) = try await session.data(from: url)
            let tickers = try JSONDecoder().decode([Ticker24hr].self, from: data)
            let tickerMap = Dictionary(uniqueKeysWithValues: tickers.map { ($0.symbol, $0) })

            return symbols.compactMap { symbol in
                let pair = tradingPair(for: symbol, currency: currency)
                guard let ticker = tickerMap[pair] else { return nil }
                return PriceData(
                    symbol: symbol.uppercased(),
                    price: Double(ticker.lastPrice) ?? 0,
                    change24h: Double(ticker.priceChangePercent)
                )
            }
        } catch {
            print("Price fetch error: \(error)")
            return []
        }
    }
}

struct Ticker24hr: Codable {
    let symbol: String
    let lastPrice: String
    let priceChangePercent: String
}
