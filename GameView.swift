import SwiftUI
import AVFoundation

struct GameView: View {
    @Binding var isMLGame: Bool
    @Binding var showingGame: Bool
    @State private var currentTab = 0
    let images = ["Tsunomaki-Watame_pr-img_02-399x640", "Tsunomaki-Watame_pr-img_03-399x640", "Tsunomaki-Watame_pr-img_04-399x640", "Tsunomaki-Watame_pr-img_05-399x640", "Tsunomaki-Watame_pr-img_07-399x640"]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TabView(selection: $currentTab) {
                    ForEach(images.indices, id: \.self) { index in
                        Image(images[index])
                            .resizable()
                            .scaledToFit()
                            .padding(25)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                VStack {
                    Spacer()
                    RPSGameView(isMLGame: $isMLGame)
                        .padding()
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                }
            }
        }
        .overlay(alignment: .top) {
            HStack(alignment: .top) {
                Spacer()
                    .frame(width: 75) // 隱藏寬度占用，讓 HistoryWidget 置中
                
                Spacer()
                
                HistoryWidget()
                    .padding(.vertical)
                
                Spacer()
                
                Button {
                    showingGame = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 75)
                        .shadow(color: .gray, radius: 3)
                }
            }
        }
        .background(GameBackgroundView())
    }
}

struct RPSGameView: View {
    @Binding var isMLGame: Bool
    @State private var game: RPSGameState = RPSGameState()
    @State private var audioPlayer: AVAudioPlayer?
    @AppStorage("totalWins") private var totalWins: Int = 0
    @AppStorage("totalDraws") private var totalDraws: Int = 0
    @AppStorage("totalLosses") private var totalLosses: Int = 0
    @StateObject private var appModel = AppModel()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(game.backgroundColor)
                .animation(.easeInOut(duration: 0.5), value: game.backgroundColor)
            
            if game.showResult {
                GameResultView()
            } else if isMLGame {
                if !game.showButton {
                    MoveDisplay(move: game.playerMove?.rawValue ?? "🤔", borderColor: .blue)
                } else {
                    // Camera preview with hand pose overlay
                    CameraView(showNodes: true)
                        .environmentObject(appModel)
                        .overlay {
                            Text(Sign.emoji(fromLabel: appModel.predictionLabel))
                                .font(.system(size: 50))
                        }
                        .overlay(alignment: .bottom) {
                            VStack {
                                if isCountingDown {
                                    Text("\(countdownSeconds)")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white)
                                } else {
                                    if mlGameStep == 0 {
                                        Text("👊 揮拳以開始 👊")
                                    } else if secondRockDetected {
                                        Text("✅ 第二次揮拳 ✅")
                                    } else if firstRockDetected {
                                        Text("✅ 第一次揮拳 ✅")
                                    }
                                }
                            }
                            .padding()
                        }
                        .onChange(of: appModel.predictionLabel) { oldValue, newValue in 
                            handleMLPrediction(newValue: newValue)
                        }
                }
            } else {
                HStack {
                    if game.showOptions {
                        Button(action: { game.changeMove(direction: -1) }) {
                            Text("◀️")
                                .font(.system(size: 40))
                        }
                        .disabled(!game.showButton)
                    }

                    MoveDisplay(move: game.playerMove?.rawValue ?? "🤔", borderColor: .blue)
                        .onTapGesture {
                            if game.showButton {
                                startGame()
                            }
                        }
                    
                    if game.showOptions {
                        Button(action: { game.changeMove(direction: 1) }) {
                            Text("▶️")
                                .font(.system(size: 40))
                        }
                        .disabled(!game.showButton)
                    }
                }
            }
        }
        .environment(game)
    }
    
    // 開始遊戲
    func startGame() {
        game.showButton = false
        game.showOptions = false

        // 播放音效
        playSound(name: "Tsunomaki_Janken")

        // 背景變色動畫
        game.backgroundColor = Color(hue: Double.random(in: 0...1), saturation: 1, brightness: 1)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if game.showResult {
                timer.invalidate() // 停止動畫
            } else {
                game.backgroundColor = Color(hue: Double.random(in: 0...1), saturation: 1, brightness: 1)
            }
        }

        // 模擬遊戲結果
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            game.determineWinner()

            if game.wins == true {
                totalWins += 1
            } else if game.wins == false {
                totalLosses += 1
                playSound(name: "warukunai_yo_ne")
            } else {
                totalDraws += 1
            }

            // 5秒後重置遊戲
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                game.reset()
            }
        }
    }
    
    // 播放音效
    func playSound(name: String) {
        if let audioURL = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.play()
            } catch {
                print("無法播放音樂: \(error)")
            }
        }
    }


    @State private var mlGameStep = 0
    @State private var isCountingDown = false
    @State private var countdownTimer: Timer?
    @State private var countdownSeconds = 3
    @State private var firstRockDetected = false
    @State private var secondRockDetected = false

    func handleMLPrediction(newValue: String) {
        guard game.showButton else { return }
        
        switch mlGameStep {
        case 0: // First rock gesture
            if newValue == "Rock" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    firstRockDetected = true
                    mlGameStep = 1
                }
            }
        case 1: // First hand down
            if newValue == "" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    mlGameStep = 2
                }
            }
        case 2: // Second rock gesture
            if newValue == "Rock" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    secondRockDetected = true
                    mlGameStep = 3
                }
            }
        case 3: // Second hand down
            if newValue == "" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    startCountdown()
                }
            }
        default:
            break
        }
    }

    func startCountdown() {
        isCountingDown = true
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownSeconds > 0 {
                countdownSeconds -= 1
            } else {
                timer.invalidate()
                finalizeMLGame()
            }
        }
    }

    func finalizeMLGame() {
        guard let sign = Sign.fromLabel(appModel.predictionLabel) else {
            resetMLGame()
            return
        }
        game.playerMove = sign
        startGame()
        resetMLGame()
    }

    func resetMLGame() {
        mlGameStep = 0
        isCountingDown = false
        countdownTimer?.invalidate()
        countdownSeconds = 3
        firstRockDetected = false
        secondRockDetected = false
    }
}

struct GameResultView: View {
    @Environment(RPSGameState.self) private var game

    var body: some View {
        HStack {
            Spacer()
            PlayerView(name: "You", move: game.playerMove?.rawValue ?? "🤔", color: .blue)
            Spacer()
            PlayerView(name: "Watame", move: game.computerMove?.rawValue ?? "🐏", color: .purple)
            Spacer()
        }
    }
}

struct PlayerView: View {
    let name: String
    let move: String
    let color: Color

    var body: some View {
        VStack {
            Text(name)
                .font(.headline)
                .foregroundColor(color)
            Circle()
                .fill(Color.white)
                .shadow(radius: 10)
                .overlay(Circle().stroke(color, lineWidth: 4))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(move)
                        .font(.system(size: 50))
                )
        }
    }
}

struct MoveDisplay: View {
    let move: String
    let borderColor: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .shadow(radius: 10)
                .overlay(Circle().stroke(borderColor, lineWidth: 4))
                .frame(width: 100, height: 100)
            
            Text(move)
                .font(.system(size: 50))
        }
    }
}
