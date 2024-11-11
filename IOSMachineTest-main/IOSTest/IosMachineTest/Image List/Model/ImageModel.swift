//
//  Model.swift
//  IosMachineTest
//
//  Created by Shahrukh on 09/11/24.
//

import Foundation

// MARK: - Welcome
struct ImageModel: Codable {
    let status: String
    let images: [Image]
}

// MARK: - Image
struct Image: Codable {
    let xtImage: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case xtImage = "xt_image"
        case id
    }
}



struct saveImageResoponse : Codable{
    let status : String
    let message : String
}
