
import UIKit

enum ImageSlicingService {

    static func sliceImage(_ image: UIImage, rows: Int, columns: Int, bleed: CGFloat = 0.25) -> [UIImage] {
        let normalised = image.normalised()
        guard let cgImage = normalised.cgImage else { return [] }

        let totalWidth  = CGFloat(cgImage.width)
        let totalHeight = CGFloat(cgImage.height)

        let tileWidth  = totalWidth  / CGFloat(columns)
        let tileHeight = totalHeight / CGFloat(rows)

        var slices: [UIImage] = []
        slices.reserveCapacity(rows * columns)

        for row in 0..<rows {
            for col in 0..<columns {
                let cropRect = CGRect(
                    x: (CGFloat(col) - bleed) * tileWidth,
                    y: (CGFloat(row) - bleed) * tileHeight,
                    width: (1.0 + 2.0 * bleed) * tileWidth,
                    height: (1.0 + 2.0 * bleed) * tileHeight
                )

                if let tile = cgImage.cropping(to: cropRect) {
                    slices.append(UIImage(cgImage: tile, scale: normalised.scale, orientation: .up))
                } else {
                    let simpleRect = CGRect(x: CGFloat(col) * tileWidth, y: CGFloat(row) * tileHeight, width: tileWidth, height: tileHeight)
                    if let simpleTile = cgImage.cropping(to: simpleRect) {
                        slices.append(UIImage(cgImage: simpleTile, scale: normalised.scale, orientation: .up))
                    }
                }
            }
        }
        return slices
    }
}


private extension UIImage {
    func normalised() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
