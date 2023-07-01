//
//  ContentView.swift
//  OPeach
//
//  Created by Casper Aurelius on 1/7/2023.
//

import SwiftUI
import UIKit

struct Opportunity: Identifiable {
    var id = UUID()
    var name: String
    var stage: OpportunityStage
    var value: Double
}

enum OpportunityStage: String {
    case prospecting
    case qualification
    case proposal
    case negotiation
    case closedWon
    
    var color: Color {
        switch self {
        case .prospecting:
            return .blue
        case .qualification:
            return .purple
        case .proposal:
            return .green
        case .negotiation:
            return .orange
        case .closedWon:
            return .red
        }
    }
}

class OpportunityViewModel: ObservableObject {
    @Published var opportunities = [
        Opportunity(name: "Acme Inc.", stage: .proposal, value: 100000),
        Opportunity(name: "Globex Corp.", stage: .qualification, value: 50000),
        Opportunity(name: "Initech LLC", stage: .prospecting, value: 25000),
        Opportunity(name: "Umbrella Corp.", stage: .negotiation, value: 75000),
        Opportunity(name: "Stark Industries", stage: .closedWon, value: 150000),
    ]
}

struct TaskListView: View {
    @ObservedObject var viewModel = OpportunityViewModel()
    
    var body: some View {
        List(viewModel.opportunities) { opportunity in
            OpportunityRow(opportunity: opportunity)
        }
        .navigationTitle("Opportunities")
        .navigationBarItems(trailing: Button(action: {
            // add new opportunity action
        }) {
            Image(systemName: "plus")
        })
    }
}

struct OpportunityRow: View {
    var opportunity: Opportunity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(opportunity.name)
                    .font(.headline)
                
                HStack {
                    Text(opportunity.stage.rawValue)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(opportunity.stage.color)
                        .cornerRadius(5)
                    
                    Spacer()
                    
                    Text("$\(opportunity.value, specifier: "%.2f")")
                }
            }
        }
    }
}


    
struct Message: Identifiable {
        let id = UUID()
        let sender: String
        let message: String
    }

    struct InboxView: View {
        let messages = [        Message(sender: "John", message: "Hey, how are you?"),        Message(sender: "Mary", message: "Want to grab lunch today?"),        Message(sender: "Tom", message: "Can you send me the report by EOD?")    ]
        
        var body: some View {
            NavigationView {
                List(messages) { message in
                    NavigationLink(destination: Text(message.message)) {
                        HStack {
                            Text(message.sender)
                                .font(.headline)
                            Spacer()
                            Text(message.message)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .navigationBarTitle(Text("Inbox"))
            }
        }
    }
    
struct Reminder: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
}

class RemindersViewModel: ObservableObject {
    @Published var reminders = [Reminder]()
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
    }
}

struct RemindersView: View {
    @ObservedObject var viewModel = RemindersViewModel()
    @State private var showingAddReminderSheet = false
    @State private var newReminderTitle = ""
    @State private var newReminderDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.reminders) { reminder in
                    Text(reminder.title)
                }
            }
            .navigationBarTitle("Reminders")
            .navigationBarItems(trailing: Button(action: {
                showingAddReminderSheet = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddReminderSheet) {
                VStack {
                    Text("Add Reminder")
                        .font(.headline)
                        .padding()
                    Divider()
                    TextField("Title", text: $newReminderTitle)
                        .padding()
                    DatePicker("Date", selection: $newReminderDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .padding()
                    Button("Add Reminder") {
                        let newReminder = Reminder(title: newReminderTitle, date: newReminderDate)
                        viewModel.addReminder(newReminder)
                        showingAddReminderSheet = false
                    }
                    .padding()
                }
            }
        }
    }
}

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        VStack {
            Toggle(isOn: $notificationsEnabled) {
                Text("Notifications")
            }
            
            Toggle(isOn: $darkModeEnabled) {
                Text("Dark mode")
            }
            
            Button(action: {
                // perform logout action
            }) {
                Text("Log out")
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Settings")
    }
}


struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                TaskListView()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Opportunities")
            }
            InboxView()
                .tabItem {
                    Image(systemName: "tray")
                    Text("Inbox")
                }
            RemindersView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Reminders")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
