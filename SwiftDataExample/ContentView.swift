//
//  ContentView.swift
//  SwiftDataExample
//
//  Created by Hijazi on 05/05/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment (\.modelContext) var context
    
    @State private var isShowingItemSheet = false
    
//    @Query (filter: #Predicate<Expense> { $0.value > 1000 }, sort: \Expense.date)
//    var expenses: [Expense]
    
    @Query (sort: \Expense.date, order: .reverse) var expenses: [Expense]
    
    @State private var expenseToEdit: Expense?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { expense in
                    ExpenseCell(expense: expense)
                        .onTapGesture {
                            expenseToEdit = expense
                        }
                }
                .onDelete { indexSet in
                 
                    for index in indexSet {
                        context.delete(expenses[index])
                    }
                    
                }
            }
            .navigationTitle ("Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingItemSheet) {
                AddExpenseSheet()
            }
            .sheet(item: $expenseToEdit) { expense in
                EditExpenseSheet(expense: expense)
            }
            .toolbar {
                
                Button ("Add Expense", systemImage: "plus") {
                    isShowingItemSheet = true
                }
                
            }
            .overlay {
                
                if expenses.isEmpty {
                
                    ContentUnavailableView(label: {
                        Label("No Expenses", systemImage: "dollarsign.arrow.circlepath")
                    }, description: {
                        Text("Start adding expenses to see your list.")
                    }, actions: {
                        Button ("Add Expense") { isShowingItemSheet = true }
                    })
                    .offset(y: -60)
                    
                }
                
            }
            
        }
        
    }
    
}


struct ExpenseCell: View {
    
    let expense: Expense
    
    var body: some View {
        HStack {
            
            Text(expense.name)
            
            Spacer()
            
            Text(String(format: "%.2f", expense.value ?? 0.0))
            
        }
    }
    
}


struct AddExpenseSheet: View {
    
    var expense: Expense?
    
    @Environment (\.modelContext) var context
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""

    @State private var date:Date = .now
    
    @State private var value: Double? = nil
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                TextField( "Expense Name", text: $name)
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                TextField("Value", value: $value, format: .currency (code: ""))
                    .keyboardType(.decimalPad)
                    .navigationTitle("New Expense")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        
                        ToolbarItemGroup(placement: .topBarLeading) {
                            Button ("Cancel") { dismiss () }
                        }
                        ToolbarItemGroup(placement:.topBarTrailing){
                            Button ("Save") {
                                
                                if (value == nil) {
                                    return
                                }
                                
                                let expense = Expense(name: name, date: date, value: value!)
                                
                                context.insert(expense)
                                
//                                try! context.save()
                                
                                dismiss ()
                                
                            }
                        }
                        
                    }
                
            }
        }
    }
                
}
        
struct EditExpenseSheet: View {
    
    @Bindable var expense: Expense
    
    @Environment (\.modelContext) var context
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""

    @State private var date:Date = .now
    
    @State private var value: Double? = nil
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                TextField( "Expense Name", text: $expense.name)
                
                DatePicker("Date", selection: $expense.date, displayedComponents: .date)
                
                TextField("Value", value: $expense.value, format: .currency (code: ""))
                    .keyboardType(.decimalPad)
                    .navigationTitle("New Expense")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        
                        ToolbarItemGroup(placement:.topBarTrailing){
                            Button ("Done") {
                                dismiss ()
                            }
                        }
                        
                    }
                
            }
        }
    }
                
}
  

#Preview {
    ContentView()
}
