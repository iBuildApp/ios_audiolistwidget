//
//  DataModel.swift
//  AudioListModule
//
//  Created by Anton Boyarkin on 25/06/2019.
//

import Foundation
import IBACore

struct DataModel: Decodable {
    var colorScheme: ColorSchemeModel?
    
    var moduleId: String?
    
    var allowsharing: String
    var allowcomments: String
    
    var cover: String
    var tracks: [AudioItemModel]?
    
    enum CodingKeys: String, CodingKey {
        case colorScheme = "colorskin"
        case moduleId = "module_id"
        case allowsharing = "allowsharing"
        case allowcomments = "allowcomments"
        case cover = "#cover_image"
        case tracks = "track"
    }
}

extension DataModel {
    var canShare: Bool { return allowsharing == "on" }
    var canComment: Bool { return allowcomments == "on" }
    
    var coverImageUrl: URL? {
        guard !cover.isEmpty else { return nil }
        
        return URL(string: cover)
    }
}
