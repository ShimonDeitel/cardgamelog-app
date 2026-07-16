import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Session?

    var body: some View {
        NavigationStack {
            ZStack {
                CardgamelogTheme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Cardgame Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if store.canAddMore || purchases.isPro {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            EntryFormView(itemToEdit: nil) { newItem in
                store.add(newItem)
            }
        }
        .sheet(item: $editingItem) { item in
            EntryFormView(itemToEdit: item) { updated in
                store.update(updated)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(CardgamelogTheme.accentBright)
            Text("No sessions yet")
                .font(CardgamelogTheme.headlineFont)
                .foregroundStyle(.white)
            Text("Tap + to log your first one.")
                .font(CardgamelogTheme.captionFont)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var list: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    editingItem = item
                } label: {
                    row(for: item)
                }
                .accessibilityIdentifier("row_\(item.id.uuidString)")
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(for item: Session) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.game).font(CardgamelogTheme.headlineFont).foregroundStyle(CardgamelogTheme.ink)
            Text(item.players).font(CardgamelogTheme.bodyFont).foregroundStyle(CardgamelogTheme.secondaryInk)
            Text(item.winner).font(CardgamelogTheme.captionFont).foregroundStyle(CardgamelogTheme.secondaryInk)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= item.rating ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundStyle(CardgamelogTheme.accent)
                }
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(CardgamelogTheme.cardBackground)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: Store
    let itemToEdit: Session?
    let onSave: (Session) -> Void

    @State private var game: String
    @State private var players: String
    @State private var winner: String
    @State private var rating: Int
    @FocusState private var focusedField: Bool

    init(itemToEdit: Session?, onSave: @escaping (Session) -> Void) {
        self.itemToEdit = itemToEdit
        self.onSave = onSave
        _game = State(initialValue: itemToEdit?.game ?? "")
        _players = State(initialValue: itemToEdit?.players ?? "")
        _winner = State(initialValue: itemToEdit?.winner ?? "")
        _rating = State(initialValue: itemToEdit?.rating ?? 3)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Game") {
                    TextField("Game", text: $game)
                        .focused($focusedField)
                        .accessibilityIdentifier("field_game")
                }
                Section("Players") {
                    TextField("Players", text: $players)
                        .accessibilityIdentifier("field_players")
                }
                Section("Winner") {
                    TextField("Winner", text: $winner, axis: .vertical)
                        .accessibilityIdentifier("field_winner")
                }
                Section("Rating") {
                    Picker("Rating", selection: $rating) {
                        ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = false
            }
            .navigationTitle(itemToEdit == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let base = itemToEdit ?? Session(game: game, players: players, winner: winner)
                        var updated = base
                        updated.game = game
                        updated.players = players
                        updated.winner = winner
                        updated.rating = rating
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(game.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
