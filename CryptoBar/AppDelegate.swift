import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var config: CryptoConfig!
    private var latestPrices: [PriceData] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        config = CryptoConfig.load()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Loading..."
        statusItem.button?.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)

        buildMenu()
        fetchAndUpdate()
        startTimer()
    }

    private func buildMenu() {
        let menu = NSMenu()

        // Prices section (will be updated dynamically)
        menu.addItem(NSMenuItem.separator())

        let refreshItem = NSMenuItem(title: "Refresh Now", action: #selector(refreshNow), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        let reloadConfigItem = NSMenuItem(title: "Reload Config", action: #selector(reloadConfig), keyEquivalent: "")
        reloadConfigItem.target = self
        menu.addItem(reloadConfigItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        // Price detail items
        for price in latestPrices {
            let priceStr = formatPrice(price.price)
            var title = "\(price.symbol)  \(priceStr)"
            if let change = price.change24h {
                let sign = change >= 0 ? "+" : ""
                title += "  \(sign)\(String(format: "%.2f", change))%"
            }
            let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }

        if latestPrices.isEmpty {
            let item = NSMenuItem(title: "No data", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())

        let intervalItem = NSMenuItem(title: "Refresh: \(config.refreshInterval)s", action: nil, keyEquivalent: "")
        intervalItem.isEnabled = false
        menu.addItem(intervalItem)

        menu.addItem(NSMenuItem.separator())

        let refreshItem = NSMenuItem(title: "Refresh Now", action: #selector(refreshNow), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        let reloadConfigItem = NSMenuItem(title: "Reload Config (~/.crypto.json)", action: #selector(reloadConfig), keyEquivalent: "")
        reloadConfigItem.target = self
        menu.addItem(reloadConfigItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit CryptoBar", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(config.refreshInterval), repeats: true) { [weak self] _ in
            self?.fetchAndUpdate()
        }
    }

    private func fetchAndUpdate() {
        Task {
            let prices = await PriceService.shared.fetchPrices(
                symbols: config.symbols,
                currency: config.currency
            )
            await MainActor.run {
                self.latestPrices = prices
                self.updateStatusBar(prices: prices)
                self.rebuildMenu()
            }
        }
    }

    private func updateStatusBar(prices: [PriceData]) {
        guard !prices.isEmpty else {
            statusItem.button?.title = "⚠ No Data"
            return
        }

        let parts = prices.map { price -> String in
            let formatted = formatPrice(price.price)
            return "\(price.symbol) \(formatted)"
        }

        statusItem.button?.title = parts.joined(separator: " | ")
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = price >= 1 ? 0 : 4
        formatter.minimumFractionDigits = price >= 1 ? 0 : 2
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }

    @objc private func refreshNow() {
        fetchAndUpdate()
    }

    @objc private func reloadConfig() {
        config = CryptoConfig.load()
        startTimer()
        fetchAndUpdate()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
