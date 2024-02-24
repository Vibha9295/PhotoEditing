//
//  APIResponseModel.swift
//  DemoRoomvu
//
//  Created by Sparrow on 2024-02-23.
//

import Foundation
struct APIResponseModel: Decodable {
    let status: String
    let message: String?
    let data: APIResponseData?
}

struct APIResponseData: Decodable {
    let enhanced_user_image: String
}
