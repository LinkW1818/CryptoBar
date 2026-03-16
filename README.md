# CryptoBar

Lightweight macOS menu bar app for real-time cryptocurrency price monitoring.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![License](https://img.shields.io/badge/License-MIT-green)

## Features

- Real-time crypto prices in menu bar (e.g. `BTC $84,230 | ETH $3,210`)
- 24h price change percentage in dropdown menu
- Configurable symbols, currency, and refresh interval
- Monospaced digit font for clean display
- Pure menu bar app — no Dock icon

## Screenshot

```
┌──────────────────────────────────────────────────────┐
│ Menu Bar:  BTC $84,230 | ETH $3,210                  │
├──────────────────────────────────────────────────────┤
│  BTC  $84,230   +2.35%                               │
│  ETH  $3,210    -0.87%                                │
│ ──────────────────────                                │
│  Refresh: 30s                                         │
│ ──────────────────────                                │
│  Refresh Now              ⌘R                          │
│  Reload Config (~/.crypto.json)                       │
│ ──────────────────────                                │
│  Quit CryptoBar           ⌘Q                          │
└──────────────────────────────────────────────────────┘
```

## Installation

### Build from source

Requires **macOS 13+** and **Swift 5.9+** (Xcode 15+).

```bash
git clone https://github.com/LinkW1818/CryptoBar.git
cd CryptoBar
chmod +x build.sh
./build.sh
```

### Run

```bash
open CryptoBar.app
```

### Install to Applications (optional)

```bash
cp -r CryptoBar.app /Applications/
```

## Configuration

CryptoBar reads `~/.crypto.json` on startup. A default config is created automatically if it doesn't exist.

```json
{
  "symbols": ["BTC", "ETH"],
  "currency": "USD",
  "refresh_interval": 30
}
```

| Field | Description | Default |
|-------|-------------|---------|
| `symbols` | Crypto symbols to track | `["BTC", "ETH"]` |
| `currency` | Quote currency (`USD` maps to USDT on Binance) | `"USD"` |
| `refresh_interval` | Auto-refresh interval in seconds | `30` |

### Adding more coins

Edit `~/.crypto.json` and add symbols:

```json
{
  "symbols": ["BTC", "ETH", "SOL", "BNB", "DOGE"],
  "currency": "USD",
  "refresh_interval": 30
}
```

Then click **Reload Config** from the menu, or restart the app.

## Data Source

Prices are fetched from the [Binance Public API](https://binance-docs.github.io/apidocs/spot/en/#24hr-ticker-price-change-statistics) (`/api/v3/ticker/24hr`). No API key required.

## Project Structure

```
CryptoBar/
├── Package.swift           # Swift Package Manager config
├── build.sh                # Build & package script
├── CryptoBar/
│   ├── main.swift          # App entry point
│   ├── Config.swift        # Config loader (~/.crypto.json)
│   ├── PriceService.swift  # Binance API client
│   └── AppDelegate.swift   # Menu bar UI logic
└── README.md
```

## License

[MIT](LICENSE)
