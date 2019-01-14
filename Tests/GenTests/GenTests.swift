import XCTest
import Gen

final class GenTests: XCTestCase {
  
  func testExample() {
    measure {
      var rng = LCRNG(seed: 0)
      let i = image.run(using: &rng)

    }
  }

  func testImperative() {
    measure {
      var rng = LCRNG(seed: 0)
      let i = Imperative.image(&rng)

    }
  }

  @available(iOS 10.0, *)
  func testFun() {
    let size = CGSize(width: 1024, height: 1024)
    let rect = CGRect(origin: .zero, size: size)
    let inner = rect.insetBy(dx: 300, dy: 200)

    let points = 200
    let lines = 160

    let dx = inner.width / CGFloat(points)
    let dy = inner.height / CGFloat(lines)

    func normal(_ x: CGFloat, mu: CGFloat, sigma: CGFloat) -> CGFloat {
      return (1 / (sigma * sqrt(2 * .pi))) * exp(-0.5 * pow((x - mu) / sigma, 2))
    }

    let mx = inner.width / 2

    let mu = CGFloat(mx + 50)
    let sigma = CGFloat(30 + 50)

    let path = { (y: CGFloat) in
      Gen<CGPath> { rng in
        let path = CGMutablePath()
//        let norm = Gen<CGFloat>.float(in: -1...1).run(using: &rng)
        path.addLines(
          between: stride(from: inner.minX, to: inner.maxX, by: dx).map { x in
            CGPoint(x: x, y: y + 10000*normal(x, mu: mu, sigma: sigma))
          }
        )
        return path
      }
    }

    let paths = Gen<[CGPath]> { rng in
      stride(from: inner.minY, to: inner.maxY, by: dy)
        .reduce(into: [CGPath]()) { paths, y in
          paths.append(path(y).run(using: &rng))
      }
    }

    let image = Gen<UIImage> { rng in
      UIGraphicsImageRenderer(size: size).image { ctx in
        let ctx = ctx.cgContext
        UIColor.black.setFill()
        ctx.fill(rect)

        UIColor.white.setStroke()
        print(paths.run(using: &rng).count)
        paths.run(using: &rng).forEach { path in
          ctx.addPath(path)
          ctx.drawPath(using: .fillStroke)
        }
      }
    }

    var rng = LCRNG(seed: 0)
    let i = image.run(using: &rng)

   }

  static var allTests = [
    ("testExample", testExample),
    ]
}

let canvas = CGRect(x: 0, y: 0, width: 625, height: 594)

public let xMin: CGFloat = 140
let xMax = canvas.width - xMin
let yMin: CGFloat = 100
let yMax = canvas.height - yMin

let nPoints = 100
let nLines = 80

let dx = (xMax - xMin) / CGFloat(nPoints)
let dy = (yMax - yMin) / CGFloat(nLines)

func normal(mu: CGFloat, sigma: CGFloat) -> Gen<CGFloat> {
  return Gen.float(in: -1...1).array(of: .always(6))
    .map { (xs: [CGFloat]) -> CGFloat in
      return mu + sigma * (xs.reduce(into: 0, +=) / 6)
  }
}

func normalPdf(_ x: CGFloat, mu: CGFloat, sigma: CGFloat) -> CGFloat {
  print("normalPdf(\(x), \(mu), \(sigma))")
  return (1 / (sigma * sqrt(2 * .pi))) * exp(-0.5 * pow((x - mu) / sigma, 2))
}

public let mx = (xMin + xMax) / 2

public let mu = normal(mu: mx, sigma: 50)
public let sigma = normal(mu: 30, sigma: 30)

public let modes = zip(.float(in: mx - 50...mx + 50), normal(mu: 24, sigma: 30))
  .array(of: .int(in: 1...4))

func path(from min: CGFloat, to max: CGFloat, by step: CGFloat) -> (CGFloat) -> Gen<CGPath> {
  return { y -> Gen<CGPath> in
    zip(mu, sigma, modes).flatMap { mu, sigma, modes -> Gen<CGPath> in
      Gen<CGPath> { rng in
        var w = y
        return stride(from: min, to: max, by: step)
          .map { x -> CGPoint in
            let noise = modes.reduce(into: 0) { noise, ms in
              noise += normalPdf(x, mu: ms.0, sigma: ms.1)
            }
            let yy = zip(
//              Gen<CGFloat>.always(1),
//              Gen<CGFloat>.always(1),
//              Gen<CGFloat>.always(1)
              Gen<CGFloat>.float(in: 0...1),
              Gen<CGFloat>.float(in: 0...1),
              Gen<CGFloat>.float(in: -0.5...0.5)
              )
              .map { 0.3 * w + 0.7 * (y - 600 * noise + noise * $0 * 200 * $1) + $2 }
              .run(using: &rng)
            defer { w = yy }
            return CGPoint(x: x, y: yy)
          }
          .reduce(into: CGMutablePath()) { path, point in
            point.x == xMin
              ? path.move(to: point)
              : path.addLine(to: point)
        }
      }
    }
  }
}

let paths = stride(from: yMin, to: yMax, by: dy)
  .map(path(from: xMin, to: xMax, by: dx))
  .sequence()

let image = paths.map { paths -> UIImage in
  if #available(iOS 10.0, *) {
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
  } else {
    fatalError()
  }
}

enum Imperative {
  static func normal<T: RandomNumberGenerator>(mu: CGFloat, sigma: CGFloat, _ rng: inout T) -> CGFloat {
    var r: CGFloat = 0
    for _ in 1...6 {
      r += CGFloat.random(in: -1...1, using: &rng)
    }
    return mu + sigma * (r / 6)
  }

  static func normalPdf(_ x: CGFloat, mu: CGFloat, sigma: CGFloat) -> CGFloat {
    let sigma2 = pow(sigma, 2)
    let numerator = exp(-pow(x - mu, 2) / (2 * sigma2))
    let denominator = sqrt(2 * .pi * sigma2)
    return numerator / denominator

//    return exp(-pow(x - mu, 2) / 2 * pow(sigma, 2))

//    return (1 / mu * sqrt(2 * .pi)) * exp(-0.5 * pow((x - mu) / sigma, 2))
  }

  static let mx = (xMin + xMax) / 2

  static func path<T: RandomNumberGenerator>(from min: CGFloat, to max: CGFloat, by step: CGFloat, y: CGFloat, _ rng: inout T) -> CGPath {
    let mu = normal(mu: mx, sigma: 50, &rng)
    let sigma = normal(mu: 30, sigma: 30, &rng)

    var modes: [(CGFloat, CGFloat)] = []
    for _ in 1...Int.random(in: 1...4, using: &rng) {
      modes.append((CGFloat.random(in: mx - 50...mx + 50, using: &rng), normal(mu: 24, sigma: 30, &rng)))
    }

    var w = y
    return stride(from: min, to: max, by: step)
      .map { x -> CGPoint in
        let noise = modes.reduce(into: 0) { noise, ms in
          noise += normalPdf(x, mu: ms.0, sigma: ms.1)
        }
        let yy = 0.3 * w + 0.7 * (y - 600 * noise + noise * CGFloat.random(in: 0...1, using: &rng) * 200 * CGFloat.random(in: 0...1, using: &rng)) + CGFloat.random(in: -0.5...0.5, using: &rng)
        defer { w = yy }
        return CGPoint(x: x, y: yy)
      }
      .reduce(into: CGMutablePath()) { path, point in
        point.x == xMin
          ? path.move(to: point)
          : path.addLine(to: point)
    }
  }

  static func paths<T: RandomNumberGenerator>(_ rng: inout T) -> [CGPath] {
    return stride(from: yMin, to: yMax, by: dy)
      .map { y in path(from: xMin, to: xMax, by: dx, y: y, &rng) }
  }

  static func image<T: RandomNumberGenerator>(_ rng: inout T) -> UIImage {
    if #available(iOS 10.0, *) {
      return UIGraphicsImageRenderer(bounds: canvas).image { ctx in
        let ctx = ctx.cgContext

        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fill(canvas)

        ctx.setLineWidth(1.2)
        ctx.setStrokeColor(UIColor.white.cgColor)

        paths(&rng).forEach {
          ctx.addPath($0)
          ctx.drawPath(using: .fillStroke)
        }
      }
    } else {
      fatalError()
    }
  }
}
