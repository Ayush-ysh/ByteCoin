//
//  ViewController.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - IBOutlets (Original — preserved)
    @IBOutlet weak var bitcoinLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!

    // MARK: - IBOutlets (New — for programmatic Neo-Tactile styling)
    @IBOutlet weak var coinCardView: UIView!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var currencyPillView: UIView!

    // MARK: - Data
    var coinManager = CoinManager()

    // MARK: - Private state
    private var backgroundGradient: CAGradientLayer?
    private var cardTopGlowLayer: CAGradientLayer?
    private var hasAnimatedEntrance = false

    // MARK: - Lifecycle ─────────────────────────────────────────────────────

    override func viewDidLoad() {
        super.viewDidLoad()

        coinManager.delegate   = self
        currencyPicker.dataSource = self
        currencyPicker.delegate   = self

        // Apply the Neo-Tactile visual system
        applyBackgroundGradient()
        applyGlassCardStyling()
        applyPickerContainerStyling()
        applyCurrencyPillStyling()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAnimatedEntrance else { return }
        hasAnimatedEntrance = true

        // Select USD as the default currency
        let defaultIndex = coinManager.currencyArray.firstIndex(of: "USD") ?? 0
        currencyPicker.selectRow(defaultIndex, inComponent: 0, animated: false)
        currencyLabel.text = coinManager.currencyArray[defaultIndex]
        coinManager.getCoinPrice(for: coinManager.currencyArray[defaultIndex])

        // Run entrance animations after first layout is complete
        animateCardEntrance()
        startHeaderIconFloat()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Keep gradient filling the full screen on all device sizes
        backgroundGradient?.frame = view.bounds

        // Sync the card top-glow layer width with the card's real frame
        if let card = coinCardView {
            cardTopGlowLayer?.frame = CGRect(x: 0, y: 0,
                                             width: card.bounds.width,
                                             height: 2)
        }
    }

    // MARK: - Background ────────────────────────────────────────────────────

    private func applyBackgroundGradient() {
        // Remove any previously inserted gradient
        view.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        // Subtle diagonal gradient from dark navy (top-left) to slightly
        // lighter indigo (bottom-right) — gives depth without being garish.
        gradient.colors = [
            UIColor(red: 0.043, green: 0.051, blue: 0.102, alpha: 1).cgColor,   // #0B0D1A
            UIColor(red: 0.051, green: 0.059, blue: 0.122, alpha: 1).cgColor,   // #0D0F1F
            UIColor(red: 0.059, green: 0.071, blue: 0.149, alpha: 1).cgColor    // #0F1226
        ]
        gradient.locations  = [0.0, 0.45, 1.0]
        gradient.startPoint = CGPoint(x: 0.30, y: 0.0)
        gradient.endPoint   = CGPoint(x: 0.70, y: 1.0)
        view.layer.insertSublayer(gradient, at: 0)
        self.backgroundGradient = gradient
    }

    // MARK: - Glass Card ────────────────────────────────────────────────────

    private func applyGlassCardStyling() {
        guard let card = coinCardView else { return }

        // Shape
        card.layer.cornerRadius  = 28
        card.layer.masksToBounds = false   // allow external shadow

        // 1-pt white border at low opacity → neo-tactile "edge highlight"
        card.layer.borderWidth = 1.0
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.09).cgColor

        // Ambient cyan/blue glow — appears as soft ambient light around card
        card.layer.shadowColor   = UIColor(red: 0.0, green: 0.60, blue: 1.0, alpha: 1).cgColor
        card.layer.shadowOffset  = CGSize(width: 0, height: 8)
        card.layer.shadowRadius  = 48
        card.layer.shadowOpacity = 0.20

        // Thin cyan gradient "inner highlight" on the top edge only
        // Creates the impression of light hitting a physical glass surface.
        let glow = CAGradientLayer()
        glow.frame         = CGRect(x: 0, y: 0, width: card.bounds.width, height: 2)
        glow.cornerRadius  = 28
        glow.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        glow.colors = [
            UIColor(red: 0.0, green: 0.76, blue: 1.0, alpha: 0.55).cgColor,
            UIColor(red: 0.0, green: 0.76, blue: 1.0, alpha: 0.00).cgColor
        ]
        glow.startPoint = CGPoint(x: 0.5, y: 0)
        glow.endPoint   = CGPoint(x: 0.5, y: 1)
        card.layer.addSublayer(glow)
        self.cardTopGlowLayer = glow
    }

    // MARK: - Picker Container ──────────────────────────────────────────────

    private func applyPickerContainerStyling() {
        guard let container = pickerContainerView,
              let picker    = currencyPicker else { return }

        // Dark glass base
        container.backgroundColor = UIColor(red: 0.051, green: 0.067, blue: 0.137, alpha: 1)

        // System blur for depth
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.frame = container.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.isUserInteractionEnabled = false
        container.insertSubview(blur, at: 0)

        // 1-pt cyan separator line at the very top
        let sep = UIView()
        sep.backgroundColor = UIColor(red: 0.0, green: 0.76, blue: 1.0, alpha: 0.22)
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.isUserInteractionEnabled = false
        container.addSubview(sep)
        NSLayoutConstraint.activate([
            sep.topAnchor.constraint(equalTo: container.topAnchor),
            sep.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            sep.heightAnchor.constraint(equalToConstant: 1)
        ])

        // Picker base appearance
        picker.backgroundColor = .clear
        picker.setValue(UIColor.white.withAlphaComponent(0.88), forKey: "textColor")

        // Replace the default grey hairline selection indicator with
        // custom cyan lines added after layout settles.
        DispatchQueue.main.async { [weak self] in
            self?.addCustomPickerSelectionLines(to: picker)
        }
    }

    /// Adds two thin cyan lines above and below the selected row,
    /// replacing the default UIPickerView selection indicator.
    private func addCustomPickerSelectionLines(to picker: UIPickerView) {
        // Hide the default selection indicator subviews (1-pt height on retina)
        picker.subviews.forEach { sub in
            if sub.bounds.height < 2 {
                sub.backgroundColor = .clear
            }
        }

        let rowH:   CGFloat = 48
        let hPad:   CGFloat = 28
        let midY            = picker.bounds.height / 2
        let lineColor       = UIColor(red: 0.0, green: 0.76, blue: 1.0, alpha: 0.45)

        for (offsetY) in [midY - rowH / 2, midY + rowH / 2] {
            let line = UIView()
            line.backgroundColor        = lineColor
            line.frame                  = CGRect(x: hPad, y: offsetY,
                                                 width: picker.bounds.width - hPad * 2,
                                                 height: 1)
            line.isUserInteractionEnabled = false
            picker.addSubview(line)
        }
    }

    // MARK: - Currency Pill ─────────────────────────────────────────────────

    private func applyCurrencyPillStyling() {
        guard let pill = currencyPillView else { return }

        pill.layer.cornerRadius  = 22
        pill.layer.masksToBounds = false   // allow shadow
        pill.layer.borderWidth   = 1.0
        pill.layer.borderColor   = UIColor.white.withAlphaComponent(0.15).cgColor

        // Subtle depth shadow
        pill.layer.shadowColor   = UIColor.black.cgColor
        pill.layer.shadowOffset  = CGSize(width: 0, height: 3)
        pill.layer.shadowRadius  = 10
        pill.layer.shadowOpacity = 0.28
    }

    // MARK: - Animations ────────────────────────────────────────────────────

    /// Card slides up slightly and fades in on first appearance.
    private func animateCardEntrance() {
        guard let card = coinCardView else { return }
        card.alpha     = 0
        card.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            .translatedBy(x: 0, y: 14)

        UIView.animate(
            withDuration: 0.55,
            delay: 0.06,
            usingSpringWithDamping: 0.80,
            initialSpringVelocity: 0.0,
            options: .curveEaseOut,
            animations: {
                card.alpha     = 1
                card.transform = .identity
            }
        )
    }

    /// The small header Bitcoin icon gently floats up and down — a very
    /// subtle 4-pt sinusoidal motion every 3 s.
    private func startHeaderIconFloat() {
        // The BTC icon has tag=10 (set in storyboard)
        guard let icon = view.viewWithTag(10) else { return }
        let anim             = CABasicAnimation(keyPath: "transform.translation.y")
        anim.duration        = 3.0
        anim.fromValue       = 0
        anim.toValue         = -4
        anim.autoreverses    = true
        anim.repeatCount     = .infinity
        anim.timingFunction  = CAMediaTimingFunction(name: .easeInEaseOut)
        icon.layer.add(anim, forKey: "floatY")
    }

    /// Fade-out → text update → fade-in + 8pt upward slide.
    /// Called on the main thread every time a new price arrives.
    private func animatePriceReveal() {
        let slide = bitcoinLabel.transform.translatedBy(x: 0, y: 10)

        UIView.animate(withDuration: 0.12, animations: {
            self.bitcoinLabel.alpha     = 0
            self.bitcoinLabel.transform = slide
        }, completion: { _ in
            UIView.animate(withDuration: 0.22, delay: 0,
                           options: .curveEaseOut) {
                self.bitcoinLabel.alpha     = 1
                self.bitcoinLabel.transform = .identity
            }
        })
    }

    /// Brief alpha pulse on the currency label when a new row is selected.
    private func animateCurrencyLabelPulse() {
        UIView.animate(withDuration: 0.12) {
            self.currencyLabel.alpha = 0.4
        } completion: { _ in
            UIView.animate(withDuration: 0.18) {
                self.currencyLabel.alpha = 1.0
            }
        }
    }
}

// MARK: - CoinManagerDelegate ───────────────────────────────────────────────

extension ViewController: CoinManagerDelegate {

    func didUpdatePrice(_ coinManager: CoinManager, price: Double, currency: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // Format with thousands separator for readability
            let formatter          = NumberFormatter()
            formatter.numberStyle  = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            let formatted = formatter.string(from: NSNumber(value: price)) ?? String(format: "%.2f", price)

            self.bitcoinLabel.text  = formatted
            self.currencyLabel.text = currency
            self.animatePriceReveal()
        }
    }

    func didFailWithError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.bitcoinLabel.text = "—"
        }
    }
}

// MARK: - UIPickerView DataSource & Delegate ────────────────────────────────

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        coinManager.currencyArray.count
    }

    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let label            = (view as? UILabel) ?? UILabel()
        label.text           = coinManager.currencyArray[row]
        label.textAlignment  = .center
        label.font           = .systemFont(ofSize: 18, weight: .medium)
        label.textColor      = UIColor.white.withAlphaComponent(0.88)
        return label
    }

    func pickerView(_ pickerView: UIPickerView,
                    rowHeightForComponent component: Int) -> CGFloat { 48 }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        let selected        = coinManager.currencyArray[row]
        currencyLabel.text  = selected
        animateCurrencyLabelPulse()
        coinManager.getCoinPrice(for: selected)
    }
}
