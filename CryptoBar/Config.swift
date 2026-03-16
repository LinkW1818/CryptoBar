import Foundation

struct CryptoConfig: Codable {
    var symbols: [String]
    var currency: String
    var refreshInterval: Int

    enum CodingKeys: String, CodingKey {
        case symbols
        case currency
        case refreshInterval = "refresh_interval"
    }

    static let defaultConfig = CryptoConfig(
        symbols: ["BTC", "ETH"],
        currency: "USD",
        refreshInterval: 30
    )

    static func load() -> CryptoConfig {
        let path = NSString("~/.crypto.json").expandingTildeInPath
        let url = URL(fileURLWithPath: path)

        guard let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(CryptoConfig.self, from: data) else {
            // Write default config if not exists
            if !FileManager.default.fileExists(atPath: path) {
                writeDefault(to: url)
            }
            return defaultConfig
        }
        return config
    }

    private static func writeDefault(to url: URL) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(defaultConfig) {
            try? data.write(to: url)
        }
    }
}
