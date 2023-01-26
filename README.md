# SwiftUI ScrollView Events

SwiftUI ScrollView Modifier to handle the following scroll events:
- willBeginDragging
- willEndDragging (velocity: CGPoint, contentOffset: inout CGPoint)
- didEndDragging (decelerate: Bool)
- willBeginDecelerating
- didEndDecelerating
- didEndScrollingAnimation

This is compatible with `ScrollViewReader`, any custom-reading of the scrollView's contentOffset will work as well.

See example below:

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
