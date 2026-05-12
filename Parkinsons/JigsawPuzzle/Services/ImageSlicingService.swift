// MARK: - ImageSlicingService.swift
// Utility for cutting a full UIImage into an ordered grid of equal sub-images.
// Retained for future use with photo-based puzzles; the current emoji-based
// mode generates tiles directly in PuzzleGeneratorService.

import UIKit

enum ImageSlicingService {

    // MARK: - Public API

    /// Slices `image` into `rows × columns` equal tiles.
    ///
    /// - Parameters:
    ///   - image:   The full-resolution source image.
    ///   - rows:    Number of horizontal cuts.
    ///   - columns: Number of vertical cuts.
    /// - Returns:   An array of `UIImage` in row-major order (left-to-right,
    ///              top-to-bottom). Count equals `rows * columns`.
    /// Slices `image` into `rows × columns` equal tiles with optional bleed for jigsaw tabs.
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
                // Expand the crop rect by bleed factor on all sides
                let cropRect = CGRect(
                    x: (CGFloat(col) - bleed) * tileWidth,
                    y: (CGFloat(row) - bleed) * tileHeight,
                    width: (1.0 + 2.0 * bleed) * tileWidth,
                    height: (1.0 + 2.0 * bleed) * tileHeight
                )

                // Clamp to image bounds or just let CGImage handle it (it returns nil if completely outside)
                // Actually, we want to allow empty areas if bleed goes off-image (edges)
                if let tile = cgImage.cropping(to: cropRect) {
                    slices.append(UIImage(cgImage: tile, scale: normalised.scale, orientation: .up))
                } else {
                    // Fallback to non-bleed if cropping fails (shouldn't happen with valid coords)
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

// MARK: - UIImage orientation helper

private extension UIImage {
    /// Returns a copy that is always `.up` orientation,
    /// by redrawing into a fresh context. Required before CGImage cropping.
    func normalised() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
