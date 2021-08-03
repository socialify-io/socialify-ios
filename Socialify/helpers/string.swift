//
//  string.swift
//  string
//
//  Created by Tomasz on 03/08/2021.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, comment: "")
  }
}
