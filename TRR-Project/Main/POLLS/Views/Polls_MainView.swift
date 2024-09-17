import SwiftUI
import FirebaseFirestore

struct Polls_MainView: View {
    @State private var polls: [Poll] = []
    @State private var selectedTag: String = "RHOBH"
    private var tags = ["RHOBH", "Rankings", "Real Housewives", "All Tags"]

    var body: some View {
        NavigationStack {
            VStack {
                Text("Polls")
                    .font(Font.custom("Poppins", size: 33).weight(.black))
                    .foregroundColor(.black)
                    .padding()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            Button(action: {
                                selectedTag = tag
                            }) {
                                Text(tag)
                                    .font(Font.custom("Poppins", size: 15))
                                    .foregroundColor(selectedTag == tag ? .white : .black)
                                    .padding()
                                    .background(selectedTag == tag ? Color.black : Color.clear)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                ScrollView {
                    ForEach(filteredPolls(), id: \.id) { poll in
                        NavigationLink(destination: PollCoverView(poll: poll)) {
                            PollCardView(poll: poll)
                        }
                        .buttonStyle(PlainButtonStyle()) // Ensure NavigationLink looks like a regular button
                    }
                }
            }
            .onAppear {
                fetchPolls()
            }
        }
        .navigationBarBackButtonHidden(true) // Ensure back button is hidden
    }

    func filteredPolls() -> [Poll] {
        if selectedTag == "All Tags" {
            return polls
        } else {
            return polls.filter { $0.pollTags.contains(selectedTag) }
        }
    }

    func fetchPolls() {
        let db = Firestore.firestore()
        db.collection("polls").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching polls: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            self.polls = documents.compactMap { document in
                do {
                    let pollData = document.data()
                    print("Fetched poll data: \(pollData)") // Log raw poll data
                    let poll = try document.data(as: Poll.self)
                    return poll
                } catch {
                    print("Error decoding poll: \(error)")
                    return nil
                }
            }
            print("Fetched Polls: \(self.polls)")
        }
    }
}

struct Polls_MainView_Previews: PreviewProvider {
    static var previews: some View {
        Polls_MainView()
    }
}
