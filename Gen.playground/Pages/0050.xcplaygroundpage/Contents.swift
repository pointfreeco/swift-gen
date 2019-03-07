import Gen
import PlaygroundSupport
import UIKit


let canvas = CGRect(x: 0, y: 0, width: 600, height: 600)
let mainArea = canvas.insetBy(dx: 130, dy: 100)
let numLines = 80
let numPointsPerLine = 80
let dx = mainArea.width / CGFloat(numPointsPerLine)
let dy = mainArea.height / CGFloat(numLines)

func collect<A>(_ gens: [Gen<A>]) -> Gen<[A]> {
  return Gen<[A]> { rng in
    gens.map { gen in gen.run(using: &rng) }
  }
}
func f(_ x: CGFloat) -> CGFloat {
  if x <= 0 { return 0 }
  return exp(-1 / x)
}
func g(_ x: CGFloat) -> CGFloat {
  return f(x) / (f(x) + f(1 - x))
}
func bump(_ x: CGFloat) -> CGFloat {
  return g(x * x)
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

func noiseyBump(
  amplitude: CGFloat,
  center: CGFloat,
  plateauSize: CGFloat,
  curveSize: CGFloat
  ) -> (CGFloat) -> Gen<CGFloat> {

  let noise = Gen<CGFloat>.float(in: 1...3)
  let curve = bump(amplitude: amplitude, center: center, plateauSize: plateauSize, curveSize: curveSize)

  return { x in
    return Gen { rng in
      let y = curve(x)
      return noise.run(using: &rng) * (y / amplitude + 0.5) + curve(x)
    }
  }
}

func path(from min: CGFloat, to max: CGFloat, baseline: CGFloat) -> Gen<CGPath> {
  return Gen<CGPath> { rng in

    let curve = zip(
      with: noiseyBump(amplitude:center:plateauSize:curveSize:),
      Gen<CGFloat>.float(in: 1...20).map { -$0 },
      Gen<CGFloat>.float(in: -60...60).map { $0 + canvas.width / 2 },
      Gen<CGFloat>.float(in: 0...60),
      Gen<CGFloat>.float(in: 10...60)
      )
      .run(using: &rng)

    let path = CGMutablePath()
    path.move(to: CGPoint(x: min, y: baseline))
    stride(from: min, to: max, by: dx).forEach { x in
      let y = curve(x).run(using: &rng)
      path.addLine(to: CGPoint(x: x, y: baseline + y))
    }
    path.addLine(to: CGPoint.init(x: max, y: baseline))
    return path
  }
}

let paths = collect(
  stride(from: mainArea.minY, to: mainArea.maxY, by: dy)
    .map { path(from: mainArea.minX, to: mainArea.maxX, baseline: $0) }
)

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

