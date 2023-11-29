import SwiftUI

protocol SimpleViewDelegate {
    func onButtonTap()
}
struct SimpleView: View {
    var delegate: SimpleViewDelegate?
    var body: some View {
        VStack {
            Text("Hello, SwiftUI!")
                .font(.title)
                .padding()

            Button(action: {
                delegate?.onButtonTap()
                print("Button tapped")
            }) {
                Text("Tap me")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
    }
}
