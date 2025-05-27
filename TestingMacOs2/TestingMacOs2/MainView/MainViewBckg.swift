//
//  MainViewBckg.swift
//  TestingMacOs2
//
//  Created by Joao Filipe Reis Justo da Silva on 26/05/25.
//

import SwiftUI

struct MainViewBckg: View {
    var body: some View {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        VStack {
            Text("MainView")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("Pince o card para aumentar ou diminuir")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    MainViewBckg()
}
