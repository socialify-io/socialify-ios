//
//  setColor.swift
//  setColor
//
//  Created by Tomasz on 03/08/2021.
//

import Foundation
import SwiftUI

let cellBackground: Color = Color(UIColor.systemGray5).opacity(0.5)
let borderColor: Color = Color(UIColor.systemGray).opacity(0)

public func setColor(input: String, clicked: Bool) -> Color {
    if(clicked == true) {
        if(input == "") { return Color.red.opacity(0.4) }
        else { return borderColor }
    } else {
        return borderColor
    }
}
