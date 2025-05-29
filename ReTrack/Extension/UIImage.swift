//
//  UIImage.swift
//  ReTrack
//
//  Created by 박난 on 5/29/25.
//
import SwiftUI

extension UIImage {
    func resized(to maxLength: CGFloat) -> UIImage? {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxLength else { return self }
        let scale = maxLength / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.7)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }
}
