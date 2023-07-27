//
//  ContentView.swift
//  OPeach
//
//  Created by Casper Aurelius on 1/7/2023.
// TEST
//

import SwiftUI
import UIKit
import UserNotifications
import Combine

struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        TextField("Search...", text: $text)
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 10)
            .onTapGesture {
                self.hideKeyboard()
            }
    }
}
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct OpportunityDetailView: View {
    @Binding var opportunity: Opportunity
    
    var body: some View {
        VStack {
            Text(opportunity.name)
                .font(.title)
                .padding()
            
            HStack {
                Text(opportunity.stage.rawValue)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(opportunity.stage.color)
                    .cornerRadius(5)
                Spacer()
                Text("$\(opportunity.value, specifier: "%.2f")")
                    .font(.title2)
                    .padding(.trailing)
            }
            Spacer()
        }
        .padding()
    }
}



struct Opportunity: Identifiable {
    var id = UUID()
    var name: String
    var stage: OpportunityStage
    var value: Double
}

enum OpportunityStage: String, CaseIterable {
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
            // New dummy data
            Opportunity(name: "Cyberdyne Systems", stage: .proposal, value: 200000),
            Opportunity(name: "Wayne Enterprises", stage: .qualification, value: 150000),
            Opportunity(name: "Tyrell Corporation", stage: .prospecting, value: 90000),
            Opportunity(name: "Oscorp Industries", stage: .negotiation, value: 80000),
            Opportunity(name: "SkyNet", stage: .closedWon, value: 300000),
        ]
    }
struct OpportunityFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: OpportunityViewModel
    var opportunityID: UUID
    
    @State private var name: String = ""
    @State private var stage: OpportunityStage = .prospecting
    @State private var value: Double = 0.0
    
    var opportunityIndex: Int {
        viewModel.opportunities.firstIndex { $0.id == opportunityID } ?? 0
    }


    var body: some View {
        Form {
            Section(header: Text("Opportunity Name")) {
                TextField("Name", text: $name)
            }
            Section(header: Text("Stage")) {
                Picker("Select Stage", selection: $stage) {
                    ForEach(OpportunityStage.allCases, id: \.self) { stage in
                        Text(stage.rawValue.capitalized).tag(stage)
                    }
                }
            }
            Section(header: Text("Value")) {
                TextField("Value", value: $value, formatter: NumberFormatter())
            }
            Section {
                Button("Save") {
                    viewModel.opportunities[opportunityIndex].name = name
                    viewModel.opportunities[opportunityIndex].stage = stage
                    viewModel.opportunities[opportunityIndex].value = value
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Delete Opportunity") {
                    viewModel.opportunities.remove(at: opportunityIndex)
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
            }
        }
        .onAppear(perform: loadData)
        .navigationBarTitle(Text(name))
    }
    
    func loadData() {
        name = viewModel.opportunities[opportunityIndex].name
        stage = viewModel.opportunities[opportunityIndex].stage
        value = viewModel.opportunities[opportunityIndex].value
    }
    func handleOpportunity() {
        if let opportunityIndex = viewModel.opportunities.firstIndex { $0.id == opportunityID } {
            // opportunityIndex is not nil and can be used here
            let opportunity = viewModel.opportunities[opportunityIndex]
            // Do something with opportunity
        } else {
            // Handle case where opportunityIndex is nil, meaning no opportunity with that ID was found
            print("No opportunity found with ID: \(opportunityID)")
        }
    }

}


struct TaskListView: View {
    @ObservedObject var viewModel = OpportunityViewModel()
      @State private var showingOpportunityForm = false
      
      var body: some View {
          NavigationView {
              List(viewModel.opportunities) { opportunity in
                  NavigationLink(destination: OpportunityDetailView(opportunity: $viewModel.opportunities[viewModel.opportunities.firstIndex(where: {$0.id == opportunity.id})!])) {
                      OpportunityRow(opportunity: opportunity)
                  }
              }
              .navigationTitle("Opportunities")
              .navigationBarItems(trailing: Button(action: {
                  showingOpportunityForm = true
              }) {
                  Image(systemName: "plus")
              })
              .sheet(isPresented: $showingOpportunityForm) {
                  OpportunityFormView(viewModel: viewModel, opportunityID: UUID())
              }
          }
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


    
struct Group: Identifiable {
    var id = UUID()
    var name: String
    var members: [Contact]
    var category: String
}
class GroupViewModel: ObservableObject {
    @Published var groups: [Group] = []

    func addGroup(_ group: Group, completion: @escaping (Bool) -> Void) {
        // Validation for required fields
        if group.name.isEmpty || group.members.isEmpty {
            completion(false)
            return
        }
        // Add Group
        groups.append(group)
        completion(true)
    }

    func deleteGroup(at offsets: IndexSet) {
        groups.remove(atOffsets: offsets)
    }

    func updateGroup(_ group: Group) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
        }
    }
}

struct GroupView: View {
    @ObservedObject var viewModel = GroupViewModel()
    @State private var showingAddGroupSheet = false
    @State private var newGroupName = ""
    @State private var newGroupMembers = [Contact]()
    @State private var newGroupCategory = ""
    @State private var errorMessage = ""

    var sortedGroups: [Group] {
            viewModel.groups.sorted { $0.name < $1.name }
        }
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedGroups) { group in
                                    NavigationLink(destination: GroupDetailView(group: $viewModel.groups[viewModel.groups.firstIndex(where: { $0.id == group.id })!])) {
                                        Text(group.name)

                    }
                }
                .onDelete(perform: viewModel.deleteGroup)
            }
            .navigationBarTitle("Groups")
            .navigationBarItems(trailing: Button(action: { showingAddGroupSheet = true }) { Image(systemName: "plus") })
            .sheet(isPresented: $showingAddGroupSheet) {
                VStack {
                    Text("Add Group")
                        .font(.headline)
                        .padding()
                    Divider()
                    TextField("Name", text: $newGroupName)
                        .padding()
                    TextField("Category", text: $newGroupCategory)
                        .padding()
                    // UI for adding/removing contacts to the newGroupMembers goes here
                    ContactPicker(selectedContacts: $newGroupMembers)
                    Button("Add Group") {
                        let newGroup = Group(name: newGroupName, members: newGroupMembers, category: newGroupCategory)
                        viewModel.addGroup(newGroup) { success in
                            if success {
                                showingAddGroupSheet = false
                                errorMessage = ""
                                newGroupName = ""
                                newGroupMembers = []
                                newGroupCategory = ""
                            } else {
                                errorMessage = "Could not add group. Please make sure all fields are filled."
                            }
                        }
                    }
                    .padding()
                                        .disabled(newGroupName.isEmpty || newGroupMembers.isEmpty || newGroupCategory.isEmpty)
                                        if newGroupName.isEmpty || newGroupMembers.isEmpty || newGroupCategory.isEmpty {
                                            Text("Please fill in all fields and select at least one member.")
                                                .foregroundColor(.red)
                                                .padding()
                    }
                }
            }
        }
    }
}



struct GroupDetailView: View {
    @Binding var group: Group

    var body: some View {
        Form {
            Section {
                Text("Group Name: \(group.name)")
                Text("Category: \(group.category)")
                
                ForEach(group.members) { member in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Member Name: \(member.name)")
                            Text("Member Phone: \(member.phoneNumber)")
                            Text("Member Email: \(member.email)")
                            Text("Member Category: \(member.category)")
                        }
                        Spacer()
                        Button(action: { removeContact(member) }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .navigationTitle("Group Details")
    }

    private func removeContact(_ contact: Contact) {
        if let index = group.members.firstIndex(where: { $0.id == contact.id }) {
            group.members.remove(at: index)
        }
    }
}

struct ContactPicker: View {
    @ObservedObject var contactViewModel = ContactViewModel()
    @Binding var selectedContacts: [Contact]

    var body: some View {
        List {
            ForEach(contactViewModel.contacts) { contact in
                ContactRow(contact: contact, selectedContacts: $selectedContacts)
            }
        }
    }
}

struct ContactRow: View {
    var contact: Contact
    @Binding var selectedContacts: [Contact]

    var body: some View {
        HStack {
            Text(contact.name)
            Spacer()
            if isSelected() {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelected() {
                // remove contact if it is already selected
                if let index = selectedContacts.firstIndex(where: { $0.id == contact.id }) {
                    selectedContacts.remove(at: index)
                }
            } else {
                // add contact if it is not already selected
                selectedContacts.append(contact)
            }
        }
    }

    private func isSelected() -> Bool {
        selectedContacts.contains(where: { $0.id == contact.id })
    }
}



struct Reminder: Identifiable {
    var id = UUID()
    var title: String
    var date: Date
}

class RemindersViewModel: ObservableObject {
    @Published var reminders = [Reminder]()
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
    }
}

struct ReminderDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RemindersViewModel
    let reminderID: UUID
    
    @State private var title: String = ""
    @State private var date: Date = Date()
    
    var reminderIndex: Int {
        viewModel.reminders.firstIndex { $0.id == reminderID }!
    }
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $title)
            }
            
            Section(header: Text("Date")) {
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
            }
            
            Section {
                Button("Save") {
                    viewModel.reminders[reminderIndex].title = title
                    viewModel.reminders[reminderIndex].date = date
                    presentationMode.wrappedValue.dismiss()
                }
                
                Button("Delete Reminder") {
                    viewModel.reminders.remove(at: reminderIndex)
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
            }
        }
        .onAppear(perform: loadData)
        .navigationBarTitle(Text(title))
    }
    
    func loadData() {
        title = viewModel.reminders[reminderIndex].title
        date = viewModel.reminders[reminderIndex].date
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
                    NavigationLink(destination: ReminderDetailView(viewModel: viewModel, reminderID: reminder.id)) {
                        Text(reminder.title)
                    }
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


struct Contact: Identifiable {
    var id = UUID()
    var name: String
    var phoneNumber: String
    var email: String
    var category: String
    var opportunity: Opportunity?
}
enum Category: String, CaseIterable {
    case personal
    case professional
    case custom
}

class ContactViewModel: ObservableObject {
    @Published var contacts: [Contact] = [
           Contact(name: "John Doe", phoneNumber: "1234567890", email: "john.doe@example.com", category: "Personal"),
           Contact(name: "Jane Smith", phoneNumber: "2345678901", email: "jane.smith@example.com", category: "Professional"),
           Contact(name: "Alice Johnson", phoneNumber: "3456789012", email: "alice.johnson@example.com", category: "Personal"),
           Contact(name: "Bob Williams", phoneNumber: "4567890123", email: "bob.williams@example.com", category: "Professional"),
           Contact(name: "Charlie Brown", phoneNumber: "5678901234", email: "charlie.brown@example.com", category: "Personal")
       ]
    func addContact(_ contact: Contact, completion: @escaping (Bool) -> Void) {
        // Validation for required fields
        if contact.name.isEmpty || contact.email.isEmpty || contact.phoneNumber.isEmpty {
            completion(false)
            return
        }
        // Add Contact
               contacts.append(contact)
               completion(true)
           }
        
    func deleteContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }
    
    func updateContact(_ contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
        }
    }
}

struct ContactsView: View {
    @ObservedObject var viewModel = ContactViewModel()
    @ObservedObject var opportunityViewModel = OpportunityViewModel() // new instance
    @State private var showingAddContactSheet = false
    @State private var newContactName = ""
    @State private var newContactPhone = ""
    @State private var newContactEmail = ""
    @State private var newContactCategory = ""
    
    var body: some View {
        NavigationView {
            List {
//                SearchBar(text: $newContactName)
                ForEach(viewModel.contacts) { contact in
                    NavigationLink(destination: ContactDetailView(contact: $viewModel.contacts[viewModel.contacts.firstIndex(where: { $0.id == contact.id })!], opportunityViewModel: opportunityViewModel)) {
                           Text(contact.name)
                       }
                }
                .onDelete(perform: viewModel.deleteContact)
            }
            .navigationBarTitle("Contacts")
            .navigationBarItems(trailing: Button(action: {
                showingAddContactSheet = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddContactSheet) {
                VStack {
                    Text("Add Contact")
                        .font(.headline)
                        .padding()
                    Divider()
                    TextField("Name", text: $newContactName)
                        .padding()
                    TextField("Phone", text: $newContactPhone)
                        .padding()
                    TextField("Email", text: $newContactEmail)
                        .padding()
                    Button("Add Contact") {
                        let newContact = Contact(name: newContactName, phoneNumber: newContactPhone, email: newContactEmail, category: newContactCategory)
                        viewModel.addContact(newContact) { success in
                            if success {
                                showingAddContactSheet = false
                            } else {
                                // Show some error message to the user
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}


struct ContactDetailView: View {
    @Binding var contact: Contact
    @ObservedObject var opportunityViewModel: OpportunityViewModel
    
    var body: some View {
        Form {
                    Section {
                        Text("Name: \(contact.name)")
                        Text("Phone: \(contact.phoneNumber)")
                        Text("Email: \(contact.email)")
                        Text("Category: \(contact.category)")
                        
                        if let opportunity = contact.opportunity {
                            NavigationLink(destination: OpportunityDetailView(opportunity: .constant(opportunity))) {
                                Text("Opportunity: \(opportunity.name)")
                            }
                        } else {
                            Button("Convert to Opportunity") {
                                let newOpportunity = Opportunity(name: contact.name, stage: .prospecting, value: 10000)
                                opportunityViewModel.opportunities.append(newOpportunity)
                                contact.opportunity = newOpportunity
                            }
                        }
                    }
                }
                .navigationTitle("Contact Details")
            }
        }





struct ContentView: View {
        @ObservedObject var viewModel = ContactViewModel()
        
        var body: some View {
            TabView {
                NavigationView {
                    TaskListView()
                }
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Opportunities")
                }
                ContactsView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Contacts")
                    }
                GroupView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Group")
                    }
                RemindersView()
                    .tabItem {
                        Image(systemName: "clock")
                        Text("Reminders")
                    }
                
            }
        }
    }
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(viewModel: ContactViewModel())
//    }
//}
