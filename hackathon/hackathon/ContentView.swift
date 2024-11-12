//
//  ContentView.swift
//  hackathon
//
//  Created by Dylan Kwok Heng Yi on 12/11/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var randomPositions: [CGSize] = []
    @State private var timer: Timer? = nil

    var body: some View {
        NavigationView {
            Color(red: 1, green: 0.3411764705882353, blue: 0.2)
                .ignoresSafeArea()
                .overlay(
                    VStack {
                        GeometryReader { geometry in
                            HStack {
                                ForEach(0..<randomPositions.count, id: \.self) { index in
                                    ZStack {
                                        if index % 2 == 0 {
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                                .frame(width: 30, height: 30)
                                                .offset(randomPositions[index])
                                        } else {
                                            Text("×")
                                                .font(.system(size: 50))
                                                .fontWeight(.light)
                                                .foregroundColor(.white)
                                                .offset(randomPositions[index])
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                randomPositions = (0..<6).map { _ in
                                    CGSize(width: CGFloat.random(in: 0...geometry.size.width), height: CGFloat.random(in: 0...geometry.size.height))
                                }
                                
                                timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                                    randomPositions = (0..<6).map { _ in
                                        CGSize(width: CGFloat.random(in: 0...geometry.size.width), height: CGFloat.random(in: 0...geometry.size.height))
                                    }
                                }
                            }
                            .onDisappear {
                                timer?.invalidate()
                            }
                        }

                        Spacer().frame(height: 40)

                        HStack() {
                            Text("Tic Tac Toe")
                                .font(.system(size: 50))
                                .fontWeight(.bold)
                            
                            Text("+")
                                .font(.system(size: 50))
                                .fontWeight(.bold)
                        }

                        Spacer()

                        NavigationLink(destination: GamemodeSelection()) {
                            Text("Start")
                                .fontWeight(.bold)
                                .font(.title)
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }

                        Spacer()

                        Text("made by ping pong produshuns")
                            .font(.system(size: 6))
                    }
                    .padding()
                )
        }
    }

    struct GamemodeSelection: View {
        var body: some View {
            VStack {
                Text("Select Gamemode")
                    .font(.system(size: 35))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1, green: 0.3411764705882353, blue: 0.2))

                Spacer()

                NavigationLink(destination: NormalMode()) {
                    Text("Normal Mode")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 1, green: 0.3411764705882353, blue: 0.2))
                }
                
                Spacer().frame(height: 20)
                
                NavigationLink(destination: PlusMode()) {
                    Text("Plus Mode")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 1, green: 0.3411764705882353, blue: 0.2))
                }

                Spacer()

                Text("made by ping pong produshuns")
                    .font(.system(size: 8))
            }
            .padding()
        }
    }
}

struct PlusMode: View {
    @State private var grid: [String] = Array(repeating: "", count: 9)
    @State private var currentPlayer: String = "X"
    @State private var winningLine: [Int]? = nil
    @State private var timeRemaining = 3
    @State private var gameOver = false
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("TIC-TAC-TOE +")
                    .font(.system(size: 50))
                    .foregroundStyle(.red)
                    .shadow(color: .red, radius: 10, x: 0, y: 0)
                    .padding()
                
                GridViewPlus(grid: $grid, currentPlayer: $currentPlayer, winningLine: $winningLine)

                Text("Turn: \(currentPlayer)")
                    .font(.title)
                    .foregroundColor(currentPlayer == "X" ? .blue : .red)
                    .shadow(color: currentPlayer == "X" ? .blue : .red, radius: 20, x: 0, y: 0)
                    .padding()

                Text("\(timeRemaining) seconds left")
                    .font(.title)
                    .foregroundColor(timeRemaining <= 1 ? .red : .white)
                    .padding()

                if let winner = checkWinner(grid: grid) {
                    Text("\(winner) wins!")
                        .font(.title)
                        .foregroundColor(winner == "X" ? .blue : .red)
                        .shadow(color: winner == "X" ? .blue : .red, radius: 10, x: 0, y: 0)
                        .padding()
                }

                Button(action: resetGame) {
                    Text("Reset Game")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Capsule().stroke(Color.blue, lineWidth: 2))
                        .shadow(color: .blue, radius: 10, x: 0, y: 0)
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 && !gameOver {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                switchPlayer()
                resetTimer()
            }
        }
        .onAppear {
            resetTimer()
        }
    }

    func checkWinner(grid: [String]) -> String? {
        let winningLines = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]
        for line in winningLines {
            let player = grid[line[0]]
            if player != "" && player == grid[line[1]] && player == grid[line[2]] {
                winningLine = line
                return player
            }
        }
        winningLine = nil
        return nil
    }

    func resetGame() {
        grid = Array(repeating: "", count: 9)
        currentPlayer = "X"
        winningLine = nil
        resetTimer()
    }

    func switchPlayer() {
        if currentPlayer == "X" {
            currentPlayer = "O"
        } else {
            currentPlayer = "X"
        }
    }

    func resetTimer() {
        timeRemaining = 3
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        let scanner = Scanner(string: hexSanitized)
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)

        let red = Double((hexValue & 0xFF0000) >> 16) / 255.0
        let green = Double((hexValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(hexValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

struct GridViewPlus: View {
    @Binding var grid: [String]
    @Binding var currentPlayer: String
    @Binding var winningLine: [Int]?

    private let gridOutlineColor = Color(hex: "#FF5713")

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { col in
                        let index = row * 3 + col
                        Button(action: {
                            if grid[index] == "" {
                                grid[index] = currentPlayer
                                currentPlayer = currentPlayer == "X" ? "O" : "X"
                            }
                        }) {
                            Text(grid[index])
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(grid[index] == "X" ? .blue : .red)
                                .shadow(color: grid[index] == "X" ? .blue : .red, radius: 10, x: 0, y: 0)
                                .frame(width: 80, height: 80)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(winningLine?.contains(index) == true ? Color.purple : gridOutlineColor, lineWidth: 3)
                                        .overlay(
                                            winningLine?.contains(index) == true ?
                                                Rectangle().stroke(Color.purple, lineWidth: 4).rotationEffect(.degrees(45)) : nil
                                        )
                                )
                        }
                        .disabled(grid[index] != "")
                    }
                }
            }
        }
    }
}

struct NormalMode: View {
    @State private var grid: [String] = Array(repeating: "", count: 9)
     @State private var currentPlayer: String = "X"
     @State private var gameOver = false
    var body: some View {
        ZStack {
             Color.black.ignoresSafeArea()

             VStack(spacing: 20) {
               GridView(grid: $grid, currentPlayer: $currentPlayer)

               Text("Turn: \(currentPlayer)")
                 .font(.title)
                 .foregroundColor(currentPlayer == "X" ? .blue : .red)
                 .shadow(color: currentPlayer == "X" ? .blue : .red, radius: 10, x: 0, y: 0)
                 .padding()

               if let winner = checkWinner(grid: grid) {
                 Text("\(winner) wins!")
                   .font(.title)
                   .foregroundColor(winner == "X" ? .blue : .red)
                   .shadow(color: winner == "X" ? .blue : .red, radius: 10, x: 0, y: 0)
                   .padding()
               }

               Button(action: resetGame) {
                 Text("Reset Game")
                   .font(.title)
                   .foregroundColor(.blue)
                   .padding()
                   .background(Capsule().stroke(Color.blue, lineWidth: 2))
                   .shadow(color: .blue, radius: 10, x: 0, y: 0)
               }
             }
             .padding()
           }
         }

         func checkWinner(grid: [String]) -> String? {
           let winningLines = [
             [0, 1, 2], [3, 4, 5], [6, 7, 8],
             [0, 3, 6], [1, 4, 7], [2, 5, 8],
             [0, 4, 8], [2, 4, 6]
           ]
           for line in winningLines {
             let player = grid[line[0]]
             if player != "" && player == grid[line[1]] && player == grid[line[2]] {
               return player
             }
           }
           return nil
         }

         func resetGame() {
           grid = Array(repeating: "", count: 9)
           currentPlayer = "X"
         }
       }

       struct GridView: View {
         @Binding var grid: [String]
         @Binding var currentPlayer: String

         var body: some View {
           VStack(spacing: 10) {
             ForEach(0..<3, id: \.self) { row in
               HStack(spacing: 10) {
                 ForEach(0..<3, id: \.self) { col in
                   let index = row * 3 + col
                   Button(action: {
                     if grid[index] == "" {
                       grid[index] = currentPlayer
                       currentPlayer = currentPlayer == "X" ? "O" : "X"
                     }
                   }) {
                     Text(grid[index])
                       .font(.system(size: 60, weight: .bold, design: .rounded))
                       .foregroundColor(grid[index] == "X" ? .blue : .red)
                       .frame(width: 80, height: 80)
                       .background(Color.clear)
                       .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 3))
                   }
                   .disabled(grid[index] != "")
                 }
               }
             }
           }
         }
       }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
