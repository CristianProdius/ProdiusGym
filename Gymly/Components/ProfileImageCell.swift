//
//  ProfileImageCell.swift
//  ShadowLift
//
//  Created by Sebastián Kučera on 07.03.2025.
//


import SwiftUI
import UIKit

struct ProfileImageCell: View {
    @Environment(\.colorScheme) private var scheme
    var profileImage: UIImage?
    var frameSize: CGFloat

    // Adaptive shadow that looks good in both light and dark mode
    private var shadowColor: Color {
        scheme == .dark
            ? Color.black.opacity(0.6)
            : Color.black.opacity(0.15)
    }

    private var shadowRadius: CGFloat {
        scheme == .dark ? 15 : 8
    }

    var body: some View {
        if let image = profileImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: frameSize, height: frameSize)
                .clipShape(Circle())
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: scheme == .dark ? 5 : 2)
        } else {
            Image("defaultProfileImage")
                .resizable()
                .frame(width: frameSize, height: frameSize)
                .clipShape(Circle())
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: scheme == .dark ? 5 : 2)
        }
    }
}
