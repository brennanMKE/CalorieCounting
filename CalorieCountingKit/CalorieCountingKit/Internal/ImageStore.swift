import Foundation
import CoreGraphics
import CoreServices
import ImageIO
import os.log

// Docs:
// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/ImageIOGuide/imageio_basics/ikpg_basics.html#//apple_ref/doc/uid/TP40005462-CH216-TPXREF101

class ImageStore {
    enum Failure: Error {
        case failedToStoreImage
        case failedToLoadImage
    }

    let fileStore: FileStore

    init(fileStore: FileStore = .default) {
        self.fileStore = fileStore
    }

    func store(image: CGImage, url: URL) throws {
        if let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeJPEG, 1, nil) {
            CGImageDestinationAddImage(destination, image, nil)
            CGImageDestinationFinalize(destination)
        } else {
            throw Failure.failedToStoreImage
        }
    }

    func loadImage(url: URL) throws -> CGImage {
        guard
            let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            throw Failure.failedToLoadImage
        }
        return image
    }

}
