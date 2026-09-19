//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

// MARK: - Delegate Protocol

protocol CoinManagerDelegate: AnyObject {
    /// Called on a background thread — dispatch to main before touching UI.
    func didUpdatePrice(_ coinManager: CoinManager, price: Double, currency: String)
    func didFailWithError(error: Error)
}

// MARK: - JSON Response Shape

private struct CoinData: Decodable {
    let rate: Double
}

// MARK: - CoinManager
// Changed from struct → class to support the weak delegate reference.

class CoinManager {

    // MARK: - API Configuration
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey  = "YOUR_API_KEY_HERE"

    let currencyArray = [
        "AUD", "BRL", "CAD", "CNY", "EUR", "GBP", "HKD", "IDR",
        "ILS", "INR", "JPY", "MXN", "NOK", "NZD", "PLN", "RON",
        "RUB", "SEK", "SGD", "USD", "ZAR"
    ]

    // MARK: - Delegate
    weak var delegate: CoinManagerDelegate?

    // MARK: - Public API

    /// Fetches the current BTC → `currency` exchange rate via CoinAPI.
    ///
    /// When `apiKey` is still the placeholder value, a simulated price
    /// is returned so the UI can be exercised without a real key.
    func getCoinPrice(for currency: String) {
        guard apiKey != "YOUR_API_KEY_HERE" else {
            // Demo / development mode — return a plausible simulated value
            let simulated = 43_287.50
            delegate?.didUpdatePrice(self, price: simulated, currency: currency)
            return
        }

        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("ByteCoin ⚠️ Invalid URL: \(urlString)")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.didFailWithError(error: error)
                return
            }
            guard let safeData = data else { return }

            do {
                let decoded = try JSONDecoder().decode(CoinData.self, from: safeData)
                self.delegate?.didUpdatePrice(self, price: decoded.rate, currency: currency)
            } catch {
                self.delegate?.didFailWithError(error: error)
            }
        }.resume()
    }
}
