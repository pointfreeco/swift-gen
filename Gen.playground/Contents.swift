import Gen
import PlaygroundSupport
import UIKit

let canvas = CGRect(x: 0, y: 0, width: 600, height: 600)
let mainArea = canvas.insetBy(dx: 130, dy: 100)
let numLines = 80
let numPointsPerLine = 80
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
  plateauWidth: CGFloat,
  curveWidth: CGFloat
  ) -> (CGFloat) -> CGFloat {

  return { x in
    let a = plateauWidth / 2
    let b = (plateauWidth + curveWidth) / 2
    return -amplitude * baseBumpCurve(x - center, a, b)
  }
}

@inlinable func noiseyBumpCurve(
  amplitude: CGFloat,
  center: CGFloat,
  plateauWidth: CGFloat,
  curveWidth: CGFloat
  ) -> (CGFloat) -> Gen<CGFloat> {

  let curve = bumpCurve(amplitude: amplitude, center: center, plateauWidth: plateauWidth, curveWidth: curveWidth)

  return { x in
      let t = 1 - min(1, max(0, abs(x - center) / center))
      return Gen<CGFloat>.float(in: 1...3).map { -$0 * t + curve(x) }
  }
}



func bump(amplitude: CGFloat, center: CGFloat, plateauSize: CGFloat, curveSize: CGFloat) -> (CGFloat) -> CGFloat {
  return { x in
    let plateauSize = plateauSize / 2
    let curveSize = curveSize / 2
    let size = plateauSize + curveSize
    let x = x - center
    return amplitude * (1 - g((x * x - plateauSize * plateauSize) / (size * size - plateauSize * plateauSize)))
  }
}




func path(from min: CGFloat, to max: CGFloat, baseline: CGFloat) -> Gen<CGPath> {
//  return Gen<CGPath> { rng in
//    let path = CGMutablePath()
//    path.move(to: CGPoint(x: min, y: baseline))
//    stride(from: min, to: max, by: dx).forEach { x in
//      return path.addLine(
//        to: CGPoint(
//          x: x,
//          y: baseline
//        )
//      )
//    }
//    path.addLine(to: CGPoint.init(x: max, y: baseline))
//    return path
//  }

  return Gen<CGPath> { rng in
    let curve = zip(
      with: bumpCurve(amplitude:center:plateauWidth:curveWidth:),
      Gen<CGFloat>.float(in: 1...12),
      Gen<CGFloat>.float(in: (0.3)...(0.7)).map { $0 * (mainArea.maxX - mainArea.minX) },
      Gen<CGFloat>.float(in: 0...60),
      Gen<CGFloat>.float(in: 10...60)
    )

    let __curve = zip(
      with: bump(amplitude:center:plateauSize:curveSize:),
      Gen<CGFloat>.float(in: 1...20).map { -$0 },
      Gen<CGFloat>.float(in: -60...60).map { $0 + canvas.width / 2 },
      Gen<CGFloat>.float(in: 0...60),
      Gen<CGFloat>.float(in: 10...60)
    )
    .run(using: &rng)

    let curves = curve.array(of: Gen<Int>.int(in: 1...1))
      .run(using: &rng)

    let path = CGMutablePath()
    path.move(to: CGPoint.init(x: min, y: baseline))
    stride(from: min, to: max, by: dx).forEach { x in
      let y = __curve(x) //bump(x, amplitude: -10, center: canvas.width / 2, plateauSize: 50, curveSize: 50)
      path.addLine(to: CGPoint(x: x, y: baseline + y))
//      let ys = curves.map { $0(x - mainArea.minX) }//.run(using: &rng) }
//      let avg = CGFloat(ys.reduce(into: 0, +=)) / CGFloat(ys.count)
//      let factor = CGFloat(ys.map { 1 - $0 / 20 }.reduce(into: 1, *=))
//      path.addLine(
//        to: CGPoint(
//          x: x,
//          y: baseline + avg * factor
//        )
//      )
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


func graph(_ f: (CGFloat) -> CGFloat) -> UIImage {
  let bounds = CGRect(x: 0, y: 0, width: 300, height: 300)
  return UIGraphicsImageRenderer(bounds: bounds).image { ctx in
    let ctx = ctx.cgContext

    ctx.setFillColor(UIColor.black.cgColor)
    ctx.setStrokeColor(UIColor.white.cgColor)
    ctx.fill(bounds)

    ctx.move(to: CGPoint.init(x: 0, y: 150))
    ctx.addLine(to: CGPoint.init(x: 300, y: 150))
    ctx.strokePath()

    ctx.move(to: CGPoint.init(x: 150, y: 0))
    ctx.addLine(to: CGPoint.init(x: 150, y: 300))
    ctx.strokePath()

    ctx.setStrokeColor(UIColor.red.cgColor)
    ctx.move(to: CGPoint.init(x: 0, y: (1 - f(-1)) * 150))
    stride(from: 0, to: 2, by: 0.001).forEach { x in
      ctx.addLine(to: CGPoint.init(x: x * 150, y: (1 - f(x - 1)) * 150))
    }
    ctx.strokePath()
  }
}


//PlaygroundPage.current.liveView = UIImageView(image: graph { bump($0, amplitude: 0.5, center: 0, plateauSize: 0, curveSize: 1.5) })

