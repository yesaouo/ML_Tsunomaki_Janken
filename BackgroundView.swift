import SwiftUI

struct RandomEmojiBackground: View {
    let count = 20 // 背景符號數量
    let size: CGFloat = 50 // 符號大小
    @State private var emojis: [String] = []
    @State private var positions: [CGPoint] = []
    @State private var velocities: [CGSize] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    let emoji = emojis.count > index ? emojis[index] : "🐏"
                    let position = positions.count > index ? positions[index] : .zero
                    Text(emoji)
                        .font(.system(size: size))
                        .position(position)
                        .opacity(0.6)
                }
            }
            .onAppear {
                initializePositionsAndVelocities(geometry: geometry)
                startAnimation(geometry: geometry)
            }
        }
    }
    
    // 初始化位置和速度
    private func initializePositionsAndVelocities(geometry: GeometryProxy) {
        let width = geometry.size.width
        let height = geometry.size.height
        let emoji = ["✊", "🤚", "✌️", "🐏"]

        emojis = (0..<count).map { _ in emoji.randomElement() ?? "🐏" }
        
        positions = (0..<count).map { _ in
            CGPoint(
                x: CGFloat.random(in: size...width - size),
                y: CGFloat.random(in: size...height - size)
            )
        }
        
        velocities = (0..<count).map { _ in
            CGSize(
                width: CGFloat.random(in: -2...2),
                height: CGFloat.random(in: -2...2)
            )
        }
    }
    
    // 啟動動畫
    private func startAnimation(geometry: GeometryProxy) {
        let animationDuration = 0.02
        DispatchQueue.global(qos: .userInteractive).async {
            while true {
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: animationDuration)) {
                        updatePositions(geometry: geometry)
                    }
                }
                Thread.sleep(forTimeInterval: animationDuration)
            }
        }
    }
    
    // 更新符號位置並檢查邊界反彈
    private func updatePositions(geometry: GeometryProxy) {
        let width = geometry.size.width
        let height = geometry.size.height
        
        for index in positions.indices {
            var newPosition = positions[index]
            var velocity = velocities[index]
            
            // 更新位置
            newPosition.x += velocity.width
            newPosition.y += velocity.height
            
            // 檢查邊界反彈
            if newPosition.x <= size / 2 || newPosition.x >= width - size / 2 {
                velocity.width = -velocity.width
            }
            if newPosition.y <= size / 2 || newPosition.y >= height - size / 2 {
                velocity.height = -velocity.height
            }
            
            // 更新位置和速度
            positions[index] = newPosition
            velocities[index] = velocity
        }
    }
}

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Image("bg_blue")
                .resizable()
                .scaledToFill()
            RandomEmojiBackground()
        }
        .ignoresSafeArea()
    }
}

struct GameBackgroundView: View {
    var body: some View {
        Image("fixed_bg")
            .resizable()
            .scaledToFill()
    }
}