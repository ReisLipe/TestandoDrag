//
//  Card.swift
//  TestingMacOs2
//
//  Created by Joao Filipe Reis Justo da Silva on 26/05/25.
//

import Foundation
import SwiftUI

struct Card: Identifiable {
    let id: UUID
    var title: String
    var position: CGSize = .zero
    var size: CGSize = .zero
    var scale: CGFloat = 1.0
}
