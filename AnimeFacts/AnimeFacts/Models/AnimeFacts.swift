//
//  AnimeFacts.swift
//  AnimeFacts
//
//  Created by Малиль Дугулюбгов on 15.01.2022.
//

struct AnimeFacts: Decodable {
    let success: Bool?
    let total_facts: Int?
    let anime_img: String?
    let data: [Fact]?
}

struct Fact: Decodable {
    let fact_id: Int?
    let fact: String?
}
