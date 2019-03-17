import Gen
import UIKit

let canvas = CGRect(x: 0, y: 0, width: 600, height: 600)
let mainArea = canvas.insetBy(dx: 130, dy: 100)
let numLines = 80
let numPointsPerLine = 80
let dx = mainArea.width / CGFloat(numPointsPerLine)
let dy = mainArea.height / CGFloat(numLines)

func f(_ x: CGFloat) -> CGFloat {
  if x <= 0 { return 0 }
  return exp(-1 / x)
}

func g(_ x: CGFloat) -> CGFloat {
  return f(x) / (f(x) + f(1 - x))
}

func bump(
  amplitude: CGFloat,
  center: CGFloat,
  plateauSize: CGFloat,
  curveSize: CGFloat
  ) -> (CGFloat) -> CGFloat {
  return { x in
    let plateauSize = plateauSize / 2
    let curveSize = curveSize / 2
    let size = plateauSize + curveSize
    let x = x - center
    return amplitude * (1 - g((x * x - plateauSize * plateauSize) / (size * size - plateauSize * plateauSize)))
  }
}

func noisyBump(
  amplitude: CGFloat,
  center: CGFloat,
  plateauSize: CGFloat,
  curveSize: CGFloat
  ) -> (CGFloat) -> Gen<CGFloat> {

  let curve = bump(amplitude: amplitude, center: center, plateauSize: plateauSize, curveSize: curveSize)

  return { x in
    let y = curve(x)
    return Gen<CGFloat>.float(in: 0...3).map { $0 * (y / amplitude + 0.5) + y }
  }
}

let curve = Gen
  .zip(
    Gen<CGFloat>.float(in: -30...(-1)),
    Gen<CGFloat>.float(in: -60...60)
      .map { $0 + canvas.width / 2 },
    Gen<CGFloat>.float(in: 0...60),
    Gen<CGFloat>.float(in: 10...60)
  )
  .map(noisyBump(amplitude:center:plateauSize:curveSize:))

func path(from min: CGFloat, to max: CGFloat, baseline: CGFloat) -> Gen<CGPath> {
  return Gen<CGPath> { rng in
    let bumps = curve.array(of: .int(in: 1...4))
      .run(using: &rng)

    let path = CGMutablePath()
    path.move(to: CGPoint(x: min, y: baseline))
    stride(from: min, to: max, by: dx).forEach { x in
      let ys = bumps.map { $0(x).run(using: &rng) }
      let average = ys.reduce(0, +) / CGFloat(ys.count)
      path.addLine(to: CGPoint(x: x, y: baseline + average))
    }
    path.addLine(to: CGPoint.init(x: max, y: baseline))
    return path
  }
}

let paths = stride(from: mainArea.minY, to: mainArea.maxY, by: dy)
  .map { path(from: mainArea.minX, to: mainArea.maxX, baseline: $0) }
  .sequence()

let colors = [
  UIColor(red: 0.47, green: 0.95, blue: 0.69, alpha: 1),
  UIColor(red: 1, green: 0.94, blue: 0.5, alpha: 1),
  UIColor(red: 0.3, green: 0.80, blue: 1, alpha: 1),
  UIColor(red: 0.59, green: 0.30, blue: 1, alpha: 1)
]

let image = paths.map { paths in
  UIGraphicsImageRenderer(bounds: canvas).image { ctx in
    let ctx = ctx.cgContext

    ctx.setFillColor(UIColor.black.cgColor)
    ctx.fill(canvas)

    ctx.setLineWidth(1.2)
    ctx.setStrokeColor(UIColor.white.cgColor)

    paths.enumerated().forEach { idx, path in
      ctx.setStrokeColor(
        colors[colors.count * idx / paths.count].cgColor
      )
      ctx.addPath(path)
      ctx.drawPath(using: .fillStroke)
    }
  }
}

let imageView = image.map(UIImageView.init)

import PlaygroundSupport
PlaygroundPage.current.liveView = imageView.run()
