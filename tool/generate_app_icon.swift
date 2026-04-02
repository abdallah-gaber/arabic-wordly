import AppKit

let arguments = CommandLine.arguments
guard arguments.count > 1 else {
  fputs("Usage: swift generate_app_icon.swift <output-path>\n", stderr)
  exit(1)
}

let outputPath = arguments[1]
let size = CGSize(width: 1024, height: 1024)
let rect = CGRect(origin: .zero, size: size)

let image = NSImage(size: size)
image.lockFocus()

guard let context = NSGraphicsContext.current?.cgContext else {
  fputs("Unable to get graphics context.\n", stderr)
  exit(1)
}

let backgroundPath = NSBezierPath(
  roundedRect: rect.insetBy(dx: 48, dy: 48),
  xRadius: 230,
  yRadius: 230
)

context.saveGState()
backgroundPath.addClip()
let colors = [
  NSColor(calibratedRed: 0.05, green: 0.44, blue: 0.40, alpha: 1.0).cgColor,
  NSColor(calibratedRed: 0.12, green: 0.57, blue: 0.52, alpha: 1.0).cgColor,
]
let locations: [CGFloat] = [0.0, 1.0]
let colorSpace = CGColorSpaceCreateDeviceRGB()
let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!
context.drawLinearGradient(
  gradient,
  start: CGPoint(x: 120, y: 120),
  end: CGPoint(x: 904, y: 904),
  options: []
)
context.restoreGState()

let haloRect = CGRect(x: 120, y: 150, width: 784, height: 724)
let haloPath = NSBezierPath(roundedRect: haloRect, xRadius: 160, yRadius: 160)
NSColor(calibratedWhite: 1, alpha: 0.08).setFill()
haloPath.fill()

let tileCount: CGFloat = 5
let tileGap: CGFloat = 28
let tileSize: CGFloat = 128
let totalWidth = (tileSize * tileCount) + (tileGap * (tileCount - 1))
let startX = (size.width - totalWidth) / 2
let tileY: CGFloat = 420

for index in 0..<Int(tileCount) {
  let x = startX + (CGFloat(index) * (tileSize + tileGap))
  let tileRect = CGRect(x: x, y: tileY, width: tileSize, height: tileSize)
  let isAccent = index == 2
  let tilePath = NSBezierPath(
    roundedRect: tileRect,
    xRadius: isAccent ? 34 : 24,
    yRadius: isAccent ? 34 : 24
  )

  if isAccent {
    NSColor(calibratedRed: 0.89, green: 0.66, blue: 0.23, alpha: 1.0).setFill()
  } else {
    NSColor(calibratedRed: 0.98, green: 0.96, blue: 0.92, alpha: 1.0).setFill()
  }
  tilePath.fill()

  let borderColor = isAccent
    ? NSColor(calibratedRed: 0.55, green: 0.36, blue: 0.08, alpha: 0.35)
    : NSColor(calibratedRed: 0.15, green: 0.28, blue: 0.26, alpha: 0.12)
  borderColor.setStroke()
  tilePath.lineWidth = 2
  tilePath.stroke()
}

let finalTileRect = CGRect(
  x: startX + (4 * (tileSize + tileGap)),
  y: tileY,
  width: tileSize,
  height: tileSize
)
let accentMark = NSBezierPath(roundedRect: CGRect(
  x: finalTileRect.minX + 16,
  y: finalTileRect.maxY - 24,
  width: 26,
  height: 8
), xRadius: 4, yRadius: 4)
NSColor(calibratedRed: 0.89, green: 0.66, blue: 0.23, alpha: 1.0).setFill()
accentMark.fill()

let paragraphStyle = NSMutableParagraphStyle()
paragraphStyle.alignment = .center

let attributes: [NSAttributedString.Key: Any] = [
  .font: NSFont(name: "SF Arabic Rounded", size: 86) ?? NSFont.systemFont(ofSize: 86, weight: .bold),
  .foregroundColor: NSColor(calibratedRed: 0.13, green: 0.18, blue: 0.19, alpha: 1.0),
  .paragraphStyle: paragraphStyle,
]

let letter = NSString(string: "و")
let textRect = CGRect(
  x: finalTileRect.minX,
  y: finalTileRect.minY + 14,
  width: finalTileRect.width,
  height: finalTileRect.height
)
letter.draw(in: textRect, withAttributes: attributes)

let shadowAttributes: [NSAttributedString.Key: Any] = [
  .font: NSFont(name: "SF Arabic Rounded", size: 70) ?? NSFont.systemFont(ofSize: 70, weight: .semibold),
  .foregroundColor: NSColor(calibratedWhite: 1, alpha: 0.9),
  .paragraphStyle: paragraphStyle,
]
let title = NSString(string: "وردلي")
title.draw(
  in: CGRect(x: 240, y: 250, width: 544, height: 100),
  withAttributes: shadowAttributes
)

image.unlockFocus()

guard
  let tiffData = image.tiffRepresentation,
  let bitmap = NSBitmapImageRep(data: tiffData),
  let pngData = bitmap.representation(using: .png, properties: [:])
else {
  fputs("Unable to encode PNG.\n", stderr)
  exit(1)
}

let outputURL = URL(fileURLWithPath: outputPath)
try FileManager.default.createDirectory(
  at: outputURL.deletingLastPathComponent(),
  withIntermediateDirectories: true
)
try pngData.write(to: outputURL)
