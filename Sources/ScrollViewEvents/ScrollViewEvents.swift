import SwiftUI

public extension ScrollView {

    /// Set the scroll view's event callbacks
    /// - Parameters:
    ///   - willBegingDragging:
    ///   - willEndDragging:
    ///   - didEndDragging:
    ///   - willBeginDecelerating:
    ///   - didEndDecelerating:
    ///   - didEndScrollingAnimation:
    /// - Note: Using this modifier will override the SwiftUI view hierarchy, inserting a UIHostingController
    /// that will inspect the UI view hierarchy and find the `UIScrollView`. It will sets a `UIScrollViewDelegate`
    /// and responds to each of its methods.
    /// - Returns:
    func scrollWillBeginDragging(
        _ willBegingDragging: @escaping () -> Void,
        willEndDragging: ((_ velocity: CGPoint, _ contentOffset: inout CGPoint) -> Void)? = nil,
        didEndDragging: ((_ decelerate: Bool) -> Void)? = nil,
        willBeginDecelerating: (() -> Void)? = nil,
        didEndDecelerating: (() -> Void)? = nil,
        didEndScrollingAnimation: (() -> Void)? = nil
    ) -> some View {
        modifier(ScrollViewEventModifier(
            context: ScrollViewEventContext(
                willBeginDragging: willBegingDragging,
                willEndDragging: willEndDragging,
                didEndDragging: didEndDragging,
                willBeginDecelerating: willBeginDecelerating,
                didEndDecelerating: didEndDecelerating,
                didEndScrollingAnimation: didEndScrollingAnimation
            )
        ))
    }

    ///
    /// - Parameter isDragging:
    /// - Returns:
    func scroll(isDragging: Binding<Bool>) -> some View {
        return scrollWillBeginDragging {
            isDragging.wrappedValue = true
        } didEndDragging: { _ in
            isDragging.wrappedValue = false
        }
    }
}

// MARK: - Private API

private struct ScrollViewEventModifier: ViewModifier {
    let context: ScrollViewEventContext
    @State private var size: CGSize = .zero

    func body(content: Content) -> some View {
        ScrollViewRepresentable(eventContext: context, content: content, size: $size)
            .frameIfNotZero(size)
    }
}

// MARK: Event Context

struct ScrollViewEventContext {
    var willBeginDragging: (() -> Void)?
    var willEndDragging: ((_ velocity: CGPoint, _ contentOffset: inout CGPoint) -> Void)?
    var didEndDragging: ((_ decelerate: Bool) -> Void)?
    var willBeginDecelerating: (() -> Void)?
    var didEndDecelerating: (() -> Void)?
    var didEndScrollingAnimation: (() -> Void)?
}

// MARK: View Controller Representable

struct ScrollViewRepresentable<Content: View>: UIViewControllerRepresentable {
    let eventContext: ScrollViewEventContext
    let content: Content
    @Binding var size: CGSize

    func makeUIViewController(context: Context) -> ScrollViewUIHostingController<Content> {
        return ScrollViewUIHostingController(eventContext: eventContext, size: $size, rootView: content)
    }

    func updateUIViewController(_ viewController: ScrollViewUIHostingController<Content>, context: Context) {
    }
}

// MARK: Scroll View Hosting Controller

class ScrollViewUIHostingController<Content: View>: UIHostingController<Content>, UIScrollViewDelegate {
    private let eventContext: ScrollViewEventContext
    private let size: Binding<CGSize>
    private var scrollView: UIScrollView? = nil
    private var viewHasAppeared: Bool = false

    init(eventContext: ScrollViewEventContext, size: Binding<CGSize>, rootView: Content) {
        self.eventContext = eventContext
        self.size = size
        super.init(rootView: rootView)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        if !viewHasAppeared {
            viewHasAppeared = true
            scrollView = findScrollView(view: self.view)
            scrollView?.delegate = self
        }
        super.viewDidAppear(animated)
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent != nil, let viewHost = view.superview, scrollView != nil {
            let contentSize = view.intrinsicContentSize
            size.wrappedValue = CGSize(
                width: min(viewHost.bounds.width, contentSize.width),
                height: min(viewHost.bounds.height, contentSize.height))
        }
    }

    private func findScrollView(view: UIView?) -> UIScrollView? {
        if view?.isKind(of: UIScrollView.self) ?? false {
            return (view as? UIScrollView)
        }
        for subview in view?.subviews ?? [] {
            if let scrollView = findScrollView(view: subview) {
                return scrollView
            }
        }
        return nil
    }

    // MARK: - Scroll View Delegate

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        eventContext.willBeginDragging?()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        eventContext.didEndDragging?(decelerate)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var contentOffset: CGPoint = targetContentOffset.pointee
        eventContext.willEndDragging?(velocity, &contentOffset)
        targetContentOffset.pointee = contentOffset
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        eventContext.willBeginDecelerating?()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        eventContext.didEndDecelerating?()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        eventContext.didEndScrollingAnimation?()
    }
}

// MARK: -

private struct NonZeroFrame: ViewModifier {
    let size: CGSize
    func body(content: Content) -> some View {
        if size != .zero {
            content.frame(width: size.width, height: size.height)
        } else {
            content
        }
    }
}

private extension View {
    func frameIfNotZero(_ size: CGSize) -> some View {
        modifier(NonZeroFrame(size: size))
    }
}
