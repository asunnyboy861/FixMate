import Foundation
import UIKit
import PhotosUI

struct PhotoService {
    static func compress(image: UIImage, quality: CGFloat = 0.6) -> Data? {
        image.jpegData(compressionQuality: quality)
    }

    static func decompress(data: Data) -> UIImage? {
        UIImage(data: data)
    }
}
