//
//  TodoView.swift
//  MEMO APP
//
//  Created by Lum Naw on 2022/12/22.
//

import SwiftUI

struct TodoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(entity: TodoItem.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \TodoItem.order, ascending: true), NSSortDescriptor(keyPath: \TodoItem.timestamp, ascending: true)],
                  animation: .default)
    
    
    var todos: FetchedResults<TodoItem>
    @State private var sheetShowing = false
    @State private var alertShowing = false
    @State var editMode = false
    
    @AppStorage ("isDarkMode") private var isDark = false
    @State var todoText = ""
    
    var body: some View {
        
        NavigationView {
            VStack{
                List {
                    ForEach(todos) {todo in
                        if((todo.todoText?.isEmpty) == false) {
                            HStack {
                                
                                if(todo.checked) {
                                    Image(systemName:"checkmark.circle.fill")
                                        .foregroundColor(Color(.systemPurple))
                                        .buttonStyle(.borderless)
                                        .font(.system(size: 20))
                                    Text(todo.todoText!)
                                        .foregroundColor(Color("TextColor"))
                                    
                                }
                                else {
                                    Image(systemName:"circle")
                                        .foregroundColor(Color(.systemPurple))
                                        .buttonStyle(.borderless)
                                        .font(.system(size: 20))
                                    Text(todo.todoText!)
                                        .foregroundColor(Color("TextColor"))
                                }
                                
                                Button(action: {
                                    todo.checked.toggle()
                                }){
                                }
                            } //hstack
                        }
                    } //for each
                    .onDelete(perform: deleteList)
                    .onMove(perform: move)
                } //list
                
                Divider()
                
                HStack{
                    TextField("Add new to do...", text: $todoText)
                    
                    Button(action: {
                        addTodo()
                    })
                    {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 35))
                    }
                }
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                
                Divider()
                
            }//vstack
            .navigationTitle("ToDo")
            .toolbar {
                Menu {
                    
                    Button(action: deleteChecked) {
                        
                        Text("Clear Checked")
                            .foregroundColor(Color.black)
                        Image(systemName:"checkmark.circle.fill")
                    }
                    Button(action: {
                        alertShowing = true
                    }) {
                        Text("Clear All")
                        Image(systemName:"trash")
                    }
                    
                    Button(action: {
                        isDark.toggle()}, label: {isDark ? Label("Dark Mode", systemImage: "lightbulb.fill") : Label("Dark Mode", systemImage: "lightbulb")})
                    
                } label: {
                    Label("Setting", systemImage: "gearshape")
                }
                .alert(isPresented: $alertShowing) {
                    Alert(title: Text("Clear all?"),
                          primaryButton: .default(Text("Yes")) {
                        deleteAll()
                    },
                          secondaryButton: .cancel())
                } .accentColor(Color("AccentColor"))
                
            }
        }//navigation view
    } //body
    
    private func addTodo() {
        
        let newTodo = TodoItem(context: viewContext)
        newTodo.todoText = todoText
        newTodo.timestamp = Date()
        do {
            try viewContext.save()
        } catch {
            fatalError("Unresolved Error")
        }
        self.todoText = ""
    }
    
    private func deleteChecked() {
        for todo in todos {
            if(todo.checked) {
                viewContext.delete(todo)
            }
        }
        
        do {
            try viewContext.save()
            
        } catch {
            fatalError("Unresolved Error")
        }
    }
    
    private func deleteAll() {
        for todo in todos {
            viewContext.delete(todo)
        }
        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to save")
        }
    }
    
    private func deleteList(offsets: IndexSet) {
        withAnimation {
            offsets.map { todos[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func move( from source: IndexSet, to destination: Int) {
        var revisedItems: [TodoItem] = todos.map { $0 }
        revisedItems.move(fromOffsets: source, toOffset: destination )
        
        for i in 0..<revisedItems.count { revisedItems[i].order = Int16(i) }
        
        
        do {
            try viewContext.save()
        } catch {
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
} //Struct

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

    
        
