//
//  RemoteImage.swift
//  Zustand
//
//  Created by Vasileios  Gkreen on 19/05/25.
//

import SwiftUI
import Bodega

/// A type representing the API response of an image from the API we're interacting with.
struct RemoteImage: Codable, Equatable, Identifiable {
    let url: URL
    let dataRepresentation: Data

    // We're using a `CacheKey` from Bodega (one of Boutique's dependencies)
    // because it's file-system safe, unlike `url.absoluteString`.
    //
    // In most cases using a plain string will be perfectly sufficient but URLs can be up to 4096 characters
    // and files on disk can only be 256 characters, so I recommend using a `CacheKey` when possible.
    // But it's worth emphasizing, using a String should be perfectly acceptable with pretty much any non-URL data type.
    var id: String {
        return CacheKey(url: self.url).value
    }
}
