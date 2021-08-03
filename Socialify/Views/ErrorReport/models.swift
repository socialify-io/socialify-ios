//
//  models.swift
//  models
//
//  Created by Tomasz on 04/08/2021.
//

import Foundation

struct ErrorAlert: Identifiable {
    var id: String { name }
    let name: String
    let description: String
}

enum ActiveAlert {
    case success, failure
}
