import Gen
import PlaygroundSupport
import UIKit

let canvas = CGRect(x: 0, y: 0, width: 600, height: 600)
let mainArea = canvas.insetBy(dx: 130, dy: 100)
let numLines = 80
let numPointsPerLine = 100
let dx = mainArea.width / CGFloat(numPointsPerLine)
let dy = mainArea.height / CGFloat(numLines)

@inlinable func f(_ x: CGFloat) -> CGFloat {
  return x <= 0 ? 0 : exp(-1 / x)
}
@inlinable func g(_ x: CGFloat) -> CGFloat {
  let a = f(x)
  return a / (a + f(1 - x))
}
@inlinable func h(_ x: CGFloat, _ a: CGFloat, _ b: CGFloat) -> CGFloat {
  return g((x - a * a) / (b * b - a * a))
}
@inlinable func k(_ x: CGFloat, _ a: CGFloat, _ b: CGFloat) -> CGFloat {
  return h(x * x, a, b)
}
@inlinable func baseBumpCurve(_ x: CGFloat, _ a: CGFloat, _ b: CGFloat) -> CGFloat {
  return 1 - k(x, a, b)
}

@inlinable func bumpCurve(
  amplitude: CGFloat,
  center: CGFloat,
  innerWidth: CGFloat,
  bumpWidth: CGFloat
  ) -> (CGFloat) -> CGFloat {

  return { x in
    let a = innerWidth / 2
    let b = (innerWidth + bumpWidth) / 2
    return -amplitude * baseBumpCurve(x - center, a, b)
  }
}

@inlinable func noiseyBumpCurve(
  amplitude: CGFloat,
  center: CGFloat,
  innerWidth: CGFloat,
  bumpWidth: CGFloat
  ) -> (CGFloat) -> Gen<CGFloat> {

  let curve = bumpCurve(amplitude: amplitude, center: center, innerWidth: innerWidth, bumpWidth: bumpWidth)

  return { x in
    let y = curve(x)
    return Gen<CGFloat>.float(in: 0...3).map { $0 * (y / amplitude + 0.5) + y }
  }
}

func path(from min: CGFloat, to max: CGFloat, baseline: CGFloat) -> Gen<CGPath> {
  return Gen<CGPath> { rng in
    let curve = zip(
      with: noiseyBumpCurve(amplitude:center:innerWidth:bumpWidth:),
      Gen<CGFloat>.float(in: 1...12),
      Gen<CGFloat>.float(in: (0.3)...(0.7)).map { $0 * (mainArea.maxX - mainArea.minX) },
      Gen<CGFloat>.float(in: 0...60),
      Gen<CGFloat>.float(in: 10...60)
    )

    let curves = curve.array(of: .int(in: 1...4))
      .run(using: &rng)

    let path = CGMutablePath()
    path.move(to: CGPoint.init(x: min, y: baseline))
    stride(from: min, to: max, by: dx).forEach { x in
      let ys = curves.map { $0(x - mainArea.minX).run(using: &rng) }
      let avg = ys.reduce(into: 0, +=) / CGFloat(ys.count)
      let factor = ys.map { 1 - $0 / 20 }.reduce(into: 1, *=)
      return path.addLine(
        to: CGPoint(
          x: x,
          y: baseline + avg * factor
        )
      )
    }
    path.addLine(to: CGPoint.init(x: max, y: baseline))
    return path
  }
}

let paths = stride(from: mainArea.minY, to: mainArea.maxY, by: dy)
  .map { path(from: mainArea.minX, to: mainArea.maxX, baseline: $0) }
  .sequence()

func promote<A>(_ gens: [Gen<A>]) -> Gen<[A]> {
  return Gen<[A]> { rng in
    gens.map { gen in gen.run(using: &rng) }
  }
}

let tmp = stride(from: mainArea.minY, to: mainArea.maxY, by: dy)
  .map { path(from: mainArea.minX, to: mainArea.maxX, baseline: $0) }

let image = paths.map { paths in
  return UIGraphicsImageRenderer(bounds: canvas).image { ctx in
    let ctx = ctx.cgContext

    ctx.setFillColor(UIColor.black.cgColor)
    ctx.fill(canvas)

    ctx.setLineWidth(1.2)
    ctx.setStrokeColor(UIColor.white.cgColor)

    paths.forEach {
      ctx.addPath($0)
      ctx.drawPath(using: .fillStroke)
    }
  }
}

var lcrgn = LCRNG.init(seed: 1)
PlaygroundPage.current.liveView = UIImageView(image: image.run(using: &lcrgn))
1

