//
//  MemoView.swift
//  MEMO APP
//
//  Created by Lum Naw on 2022/12/22.
//

import SwiftUI

struct MemoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MemoItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MemoItem>
    

    @AppStorage ("isDarkMode") private var isDark = false
    
    @State private var sheetShowing = false
    @State private var alertShowing = false
    @State var text = ""
    
    var body: some View {
        NavigationView {
                VStack(spacing: 1) {
                    Divider()
                    List {
                        ForEach(items) { item in
                                if((item.text?.isEmpty) == false) {
                                    Section {
                                        VStack(alignment: .center){
                                            
                                            NavigationLink {
                                                TextEditView(edit: item)

                                            } label: {
                                                Text(item.text!).lineLimit(1)
                                            }
                                            .padding()
                                            
                                        }
                                        .foregroundColor(Color("TextColor"))
                                        
                                    }  header: {
                                        HStack{
                                            Text(item.timestamp!, formatter: dateFormatter)

                                            Text(item.timestamp!, formatter: timeFormatter)

                                        }
                                        .font(.system(size: 13))
                                        .foregroundColor(Color("SecondaryText"))

                                    }
                                
                                }
                        } //for each
                        .onDelete(perform: deleteItems)
                    }//list
                    .listStyle(.insetGrouped)
                     
                }//vstack
                    
                .navigationBarTitle("MEMO")
                .toolbar {
                    NavigationLink {
                       AddMemoView()

                    } label: {
                        Image(systemName: "plus")
                    }

                    
                    Menu {
                        Button(action: {
                            alertShowing = true
                        }) {
                            Text("Clear All")
                            Image(systemName: "trash")
                        }
                        
                       
                        Button(action: {
                            isDark.toggle()}, label: {isDark ? Label("Dark Mode", systemImage: "lightbulb.fill") : Label("Dark Mode", systemImage: "lightbulb")})
                        
                    } label: {
                        Label("Setting", systemImage: "gearshape")
                    }
                    .alert(isPresented: $alertShowing) {
                        Alert(title: Text("Clear All?"),
                            primaryButton: .default(Text("Yes")) {
                            deleteAll()
                            },
                            secondaryButton: .cancel())
                    } .accentColor(Color("AccentColor"))

                   
                } //toolbar
                .foregroundColor(Color("AccentColor"))
            }
        
        
        }// body view
        
        private func deleteAll() {
            //confirmation alert
            
            for item in items {
                viewContext.delete(item)
            }

            do {
                try viewContext.save()
            } catch {
                fatalError("Failed to save")
            }
            
        }
        
        private func deleteItems(offsets: IndexSet) {
            withAnimation {
                
                offsets.map { items[$0] }.forEach(viewContext.delete)
                
                do {
                    try viewContext.save()
                } catch {
                    
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    
    }//Memo View
    
    

struct AddMemoView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MemoItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MemoItem>
   
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.dismiss) var dismiss
    @State var text = ""
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 3){
            
            Button("Save") {
                addItem()
                dismiss()
            }
            .foregroundColor(Color("AccentColor"))
            .padding(10)
         
            ZStack{
                Rectangle().fill(Color(UIColor.systemBackground)).cornerRadius(10).shadow(color: .gray, radius: 3, x: 1, y: 1)
                VStack {
                    HStack {
                        Text(dateFormatter.string(from: Date()))
                        Text(timeFormatter.string(from: Date()))
                    } .foregroundColor(Color("SecondaryText"))
                        .padding()
                     
                    TextEditor(text: $text)
                        .padding(10)
                        .foregroundColor(Color("TextColor"))
                        
                }
            }
        }// vstack
        .frame(height: 400)
       
        
    } //body
        
    
    private func addItem() {
        withAnimation {
            let newItem = MemoItem(context: viewContext)
            newItem.timestamp = Date()
            newItem.text = text
            
            do {
                try viewContext.save()
            } catch {
                
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            text = " "
        }
    }
} //Add Memo View

    
 
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
//        formatter.dateStyle = .medium
    formatter.dateFormat = "E, MMM dd yyyy"
    return formatter
}()

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()
   


struct TextEditView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MemoItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MemoItem>
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    
    @Environment(\.dismiss) var dismiss
    @State var text = ""
    
    init(edit: MemoItem? = nil){
        self.edit = edit
        _text = State(initialValue: edit!.text!)
    }
    var edit : MemoItem?
    
    @State var isVisible = false
    
    var body: some View {
        NavigationView {
            VStack{

                ZStack {
                    Text(edit!.text!)
                        .font(.system(size: 20))
                        .frame(maxWidth: 300, alignment: .leading)
                        .opacity(isVisible ? 0 : 100)
                    
                    if #available(iOS 16.0, *) {
                        TextField(edit!.text!, text: $text, axis: .vertical)
                            .font(.system(size: 20))
                            .frame(maxWidth: 300, alignment: .leading)
                        
                            .opacity(isVisible ? 100 : 0)
                    } else {
                        // Fallback on earlier versions
                        TextEditor(text: $text)
                            .font(.system(size: 20))
                            .frame(maxWidth: 300, alignment: .leading)
                            .opacity(isVisible ? 100 : 0)
                        
                    }
                }
                
                Spacer()
            }
        }
        .accentColor(Color("TabColor"))
        
        
        
        .toolbar {
            VStack{
                Text(edit!.timestamp!, formatter: dateFormatter)
                    .font(.headline)
                Text(edit!.timestamp!, formatter: timeFormatter)
                    .font(.subheadline)
            
            }
            .foregroundColor(Color("SecondaryText"))
            
            
            Button{
                do {
                    if let edit = edit {
                        edit.text = text
                        try viewContext.save()
                    }
                } catch {
                    
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                presentationMode.wrappedValue.dismiss()
                
            } label: {
                Text("Save")
                    
            }
            .opacity(isVisible ? 100 : 0)
            .disabled(!isVisible)
            
            Button{
                isVisible.toggle()
            } label: {
                Text("Edit")
            }
        }
        
    } //body
} //Text edit View



struct MemoView_Previews: PreviewProvider {
    static var previews: some View {
        MemoView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
    
    



