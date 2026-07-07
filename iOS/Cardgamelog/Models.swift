import Foundation

struct Session: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var game: String
    var players: String
    var winner: String
    var rating: Int

    init(id: UUID = UUID(), date: Date = Date(), game: String, players: String, winner: String, rating: Int = 3) {
        self.id = id
        self.date = date
        self.game = game
        self.players = players
        self.winner = winner
        self.rating = rating
    }
}
