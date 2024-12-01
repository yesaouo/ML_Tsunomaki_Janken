import SwiftUI

@Observable class RPSGameState {
    var playerMove: String? = "👊"
    var computerMove: String? = "👊"
    var wins: Bool? = nil
    var showResult = false
    var showButton = true
    var showOptions = true
    var backgroundColor = Color.gray.opacity(0.2)

    let moves = ["👊", "✋", "✌️"]

    // 切換拳選項
    func changeMove(direction: Int) {
        guard let currentIndex = moves.firstIndex(of: playerMove ?? "") else { return }
        let newIndex = (currentIndex + direction + moves.count) % moves.count
        playerMove = moves[newIndex]
    }

    // 確定勝負
    func determineWinner() {
        computerMove = moves.randomElement()
        guard let playerMove = playerMove, let computerMove = computerMove else { return }
        if playerMove == computerMove {
            wins = nil
            backgroundColor = Color.yellow
        } else if (playerMove == "👊" && computerMove == "✌️") ||
                (playerMove == "✋" && computerMove == "👊") ||
                (playerMove == "✌️" && computerMove == "✋") {
            wins = true
            backgroundColor = Color.green
        } else {
            wins = false
            backgroundColor = Color.red
        }
        showResult = true
    }

    // 重置遊戲
    func reset() {
        showButton = true
        showOptions = true
        backgroundColor = Color.gray.opacity(0.2)
        showResult = false
    }
}
