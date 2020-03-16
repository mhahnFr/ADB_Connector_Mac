//
//  SettingsView.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 24.01.20.
//  Copyright © 2020 Manuel Hahn. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        VStack {
            Text("Standardport:")
            TextField("Standardport:", value: Settings.shared.$standardLANPort, formatter: NumberFormatter())
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
