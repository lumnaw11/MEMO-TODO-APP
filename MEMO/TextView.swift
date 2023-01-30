//
//  TextView.swift
//  MEMO APP
//
//  Created by cmStudent on 2023/01/16.
//

import SwiftUI



struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
