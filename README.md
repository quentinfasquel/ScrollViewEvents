# SwiftUI ScrollView Events

SwiftUI ScrollView Modifier to handle the following scroll events:
- willBeginDragging
- willEndDragging (velocity: CGPoint, contentOffset: inout CGPoint)
- didEndDragging (decelerate: Bool)
- willBeginDecelerating
- didEndDecelerating
- didEndScrollingAnimation

```
struct ContentView: View {
   var body: some View {
      ScrollView {
            VStack {
                ForEach(0..<10) { _ in
                    RoundedRectangle(cornerRadius: 20)
                        .frame(height: 200)
                        .foregroundColor(Color.gray)
                }
            }
            .padding()
      }
      .scrollWillBeginDragging {

      } willEndDragging: { velocity, contentOffset in

          // contentOffset is 'inout' therefore it can be modified

      } didEndDragging: { decelerate in

      } willBeginDecelerating: {

      } didEndDecelerating: {

      } didEndScrollingAnimation: {

      }
      .edgesIgnoringSafeArea(.all)
   }
}
```
