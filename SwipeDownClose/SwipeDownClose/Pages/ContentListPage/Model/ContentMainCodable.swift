//
//  ContentMainCodable.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import Foundation
struct ContentListCodable : Decodable {
    let base : [ContentListData]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        base = try values.decode([ContentListData].self)
    }
}

struct ContentListData : Codable {
    let id : Int?
    let image_url : String?
    let nickname : String?
    let profile_image_url : String?
    let description : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case image_url = "image_url"
        case nickname = "nickname"
        case profile_image_url = "profile_image_url"
        case description = "description"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        nickname = try values.decodeIfPresent(String.self, forKey: .nickname)
        profile_image_url = try values.decodeIfPresent(String.self, forKey: .profile_image_url)
        description = try values.decodeIfPresent(String.self, forKey: .description)
    }
}

