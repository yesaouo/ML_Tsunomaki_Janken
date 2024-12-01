import SwiftUI

enum Sign: String, CaseIterable, Identifiable {
    case rock = "👊"
    case paper = "✋"
    case scissors = "✌️"

    var id: String { rawValue }

    /// 從標籤名稱回傳符號或預設值
    static func emoji(fromLabel label: String) -> String {
        fromLabel(label)?.rawValue ?? "🤔"
    }

    /// 從標籤名稱回傳枚舉實例
    static func fromLabel(_ label: String) -> Sign? {
        switch label {
        case "Rock":
            return .rock
        case "Scissors":
            return .scissors
        case "Paper":
            return .paper
        default:
            return nil
        }
    }

    /// 判斷與另一個 Sign 的勝負
    func beats(_ other: Sign) -> Bool? {
        if self == other {
            return nil
        }
        switch (self, other) {
        case (.rock, .scissors), (.paper, .rock), (.scissors, .paper):
            return true
        default:
            return false
        }
    }
}

@Observable class RPSGameState {
    var playerMove: Sign? = .rock
    var computerMove: Sign? = .rock
    var wins: Bool? = nil
    var showResult = false
    var showButton = true
    var showOptions = true
    var backgroundColor = Color.gray.opacity(0.2)

    let moves = Sign.allCases

    // 切換拳選項
    func changeMove(direction: Int) {
        guard let currentMove = playerMove,
              let currentIndex = moves.firstIndex(of: currentMove) else { return }
        let newIndex = (currentIndex + direction + moves.count) % moves.count
        playerMove = moves[newIndex]
    }

    // 確定勝負
    func determineWinner() {
        computerMove = moves.randomElement()
        guard let playerMove = playerMove, let computerMove = computerMove else { return }
        wins = playerMove.beats(computerMove)
        switch wins {
        case true:
            backgroundColor = Color.green
        case false:
            backgroundColor = Color.red
        default:
            backgroundColor = Color.yellow
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
