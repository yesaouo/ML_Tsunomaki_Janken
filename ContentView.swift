import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showingGame = false
    @State private var isGestureMode = false
    @State private var player: AVAudioPlayer?
    
    var body: some View {   
        VStack {
            Spacer()
            
            Text("角卷猜拳")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(Color(red: 254/255, green: 242/255, blue: 158/255))
                .shadow(radius: 5)
                .padding(.bottom, 50)
            
            Spacer()
            
            // 歷史紀錄 Widget
            HistoryWidget()
                .padding(.bottom)
            
            Spacer()
            
            // 一般模式按鈕
            Button {
                self.isGestureMode = false
                self.showingGame = true
            } label: {
                Text("一般模式")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            
            // 手勢辨識模式按鈕
            Button {
                self.isGestureMode = true
                self.showingGame = true
            } label: {
                Text("手勢辨識")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 音量控制使用 Emoji
            HStack {
                Text("🔈")
                    .font(.largeTitle)
                Slider(value: Binding(get: {
                    Double(self.player?.volume ?? 0)
                }, set: { (newVal) in
                    self.player?.volume = Float(newVal)
                }), in: 0...1)
                    .accentColor(.white)
                Text("🔊")
                    .font(.largeTitle)
            }
            .padding()
        }
        .background(BackgroundView())
        .onAppear {
            playBackgroundMusic()
        }
        .fullScreenCover(isPresented: $showingGame) {
            GameView(isMLGame: $isGestureMode, showingGame: $showingGame)
        }
    }

    // 播放背景音樂
    private func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "2_23_AM", withExtension: "mp3") else {
            print("找不到音樂檔案")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 0.5
            player?.numberOfLoops = -1 // 重複播放
            player?.play()
        } catch {
            print("無法播放音樂: \(error.localizedDescription)")
        }
    }
}

// 歷史紀錄 Widget
struct HistoryWidget: View {
    @AppStorage("totalWins") private var totalWins: Int = 0
    @AppStorage("totalDraws") private var totalDraws: Int = 0
    @AppStorage("totalLosses") private var totalLosses: Int = 0
    
    var body: some View {
        ZStack {
            // 灰色透明背景
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.4))
                .frame(height: 100)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("🏆 勝利：\(totalWins)")
                    Text("🤝 平手：\(totalDraws)")
                    Text("💔 失敗：\(totalLosses)")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)
                
                Spacer()
                
                // 重置按鈕
                Button {
                    self.totalWins = 0
                    self.totalDraws = 0
                    self.totalLosses = 0
                } label: {
                    Image(systemName: "arrow.clockwise.circle")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .padding(.trailing)
            }
        }
        .padding(.horizontal)
    }
}
