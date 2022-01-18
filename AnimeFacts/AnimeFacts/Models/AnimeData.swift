//
//  AnimeData.swift
//  AnimeFacts
//
//  Created by Малиль Дугулюбгов on 15.01.2022.
//

struct AnimeData: Decodable {
    let success: Bool?
    let data: [AnimeExample]?
}

struct AnimeExample: Decodable {
    let anime_id: Int?
    let anime_name: String?
    let anime_img: String?
}
