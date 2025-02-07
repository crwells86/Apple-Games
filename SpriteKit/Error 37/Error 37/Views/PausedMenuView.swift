//
//  PausedMenuView.swift
//  Error 37
//
//  Created by Caleb Wells on 2/1/25.
//


import SwiftUI

struct PausedMenuView: View {
//    @Binding var gameSceneController: GameSceneController
    
    @Binding var gameState: GameState
    
    var body: some View {
        VStack {
            Button {
                gameState = .playing
//                gameSceneController.gameState = .playing
            } label: {
                Text("Resume")
                    .font(.title2)
            }
            .padding()
            
            Button {
                gameState = .gameOver
//                gameSceneController.gameOver()
//                gameSceneController.gameState = .mainMenu
            } label: {
                Text("Quit")
                    .font(.title2)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .padding()
        .background(.black)
        .buttonStyle(.plain)
    }
}

#Preview {
    PausedMenuView(gameState: .constant(.paused)) //(gameSceneController: .constant(GameSceneController()))
}
