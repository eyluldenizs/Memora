//
//  SettingRowView.swift
//  Memora
//
//  Created by Eylül Soylu on 22.01.2026.
//

import SwiftUI

struct SettingRowView: View {
    let imageName: String
    let title: String
    let tintColor:Color
    var body: some View {
        HStack(spacing:9 ){
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    SettingRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
}
