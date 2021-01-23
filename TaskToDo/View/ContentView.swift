//
//  ContentView.swift
//  TaskToDo
//
//  Created by Levent Bostanci on 19/01/2021.
//

import SwiftUI

struct ContentView: View {
    // MARK: - PROPERTIES
    
    @Environment(\.managedObjectContext) var managedobjectContext
    
    @FetchRequest(entity: TaskToDo.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \TaskToDo.name, ascending: true)]) var todos: FetchedResults<TaskToDo>
    
    @State private var showingSettingsView: Bool = false
    @State private var showingAddToDoView: Bool = false
    @State private var animatingButton: Bool = false
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(self.todos, id: \.self) { todo in
                        HStack {
                            Text(todo.name ?? "Unknown")
                            
                            Spacer()
                            
                            Text(todo.priority ?? "Unknown")
                        }
                        .padding(.vertical, 10)
                    }
                    .onDelete(perform: deleteToDo)
                }
                .navigationBarTitle("Todo", displayMode: .inline)
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(action: {
                    self.showingSettingsView.toggle()
                }) {
                    Image(systemName: "paintbrush")
                        .imageScale(.large)
                    }
                .sheet(isPresented: $showingSettingsView) {
                    SettingsView()
                }
            )
                if todos.count == 0 {
                    EmptyListView()
                }
            }
            .sheet(isPresented: $showingAddToDoView) {
                AddTodoView().environment(\.managedObjectContext, self.managedobjectContext)
            }
            .overlay(
                ZStack {
                    Group {
                       Circle()
                        .fill(Color.blue)
                        .opacity(self.animatingButton ? 0.2 : 0)
                        .scaleEffect(self.animatingButton ? 1 : 0)
                        .frame(width: 68, height: 68, alignment: .center)
                        Circle()
                         .fill(Color.blue)
                         .opacity(self.animatingButton ? 0.15 : 0)
                         .scaleEffect(self.animatingButton ? 1 : 0)
                         .frame(width: 88, height: 88, alignment: .center)
                    }
//                    .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true))
                    
                    Button(action: {
                        self.showingAddToDoView.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .background(Circle().fill(Color("ColorBase")))
                            .frame(width: 48, height: 48, alignment: .center)
                    }
                    .onAppear(perform: {
                        self.animatingButton.toggle()
                    })
                }
                .padding(.bottom, 15)
                .padding(.trailing, 15)
                , alignment: .bottomTrailing
            )
        }
    }
    private func deleteToDo(at offsets: IndexSet) {
        for index in offsets {
            let todo = todos[index]
            managedobjectContext.delete(todo)
            
            do {
                try managedobjectContext.save()
            } catch {
                print(error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView()
            .environment(\.managedObjectContext, context)
            .previewDevice("iPhone 12 Pro")
    }
}
