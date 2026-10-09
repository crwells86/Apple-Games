import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RenderedView()
                .ignoresSafeArea()
            
            Text("Hello, Metal!")
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundStyle(.white)
                .padding()
        }
    }
}

#Preview {
    ContentView()
}
