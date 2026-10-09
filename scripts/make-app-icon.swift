#!/usr/bin/env swift
// Draws the app icon: a white raised hand on the brand color, 1024×1024, with no transparency.
// Run from the repo root: swift scripts/make-app-icon.swift

import AppKit

let side = 1024
/// `Theme.Colors.brand`, light value (#0A6B67).
let brand = CGColor(srgbRed: 0x0A / 255.0, green: 0x6B / 255.0, blue: 0x67 / 255.0, alpha: 1)
let glyphName = "hand.raised.fill"
/// Height of the glyph as a share of the icon's side.
let glyphScale = 0.56
let output = "App/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"

guard
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
    let context = CGContext(
        data: nil, width: side, height: side, bitsPerComponent: 8, bytesPerRow: 0,
        space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )
else {
    fatalError("Could not create a drawing context.")
}

context.setFillColor(brand)
context.fill(CGRect(x: 0, y: 0, width: side, height: side))

let configuration = NSImage.SymbolConfiguration(pointSize: CGFloat(side), weight: .medium)
    .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
guard
    let symbol = NSImage(systemSymbolName: glyphName, accessibilityDescription: nil)?
    .withSymbolConfiguration(configuration)
else {
    fatalError("The symbol \(glyphName) is not available on this Mac.")
}

let height = CGFloat(side) * glyphScale
let width = height * symbol.size.width / symbol.size.height
let glyphRect = CGRect(
    x: (CGFloat(side) - width) / 2, y: (CGFloat(side) - height) / 2, width: width, height: height
)
NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
symbol.draw(in: glyphRect)
NSGraphicsContext.current = nil

guard
    let image = context.makeImage(),
    let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])
else {
    fatalError("Could not encode the icon.")
}

do {
    try png.write(to: URL(fileURLWithPath: output))
    print("Wrote \(output)")
} catch {
    fatalError("Could not write \(output): \(error)")
}
