//
//  UDChatMessagesView.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDChatMessagesView: View {
    @ObservedObject var viewModel: UDChatMessagesViewModel

    @State private var floatingDateSectionIndex: Int = 0
    @State private var pinnedSectionIndex: Int? = nil
    @State private var floatingDatePushOffset: CGFloat = 0
    @State private var isScrolling = false
    @State private var isTouchActive = false
    @State private var hideFloatingDateWorkItem: DispatchWorkItem?
    @State private var headerFrames: [Int: CGRect] = [:]
    @State private var floatingHeaderHeight: CGFloat = 0
    @State private var visibleItemCountsBySection: [Int: Int] = [:]
    @State private var lastViewportHeight: CGFloat = 0
    @State private var pendingScrollFieldId: String? = nil
    @State private var itemFrames: [String: CGRect] = [:]
    @State private var currentOffset: CGFloat = 0
    @State private var repinAnchorId: String? = nil
    @State private var repinAnchorPoint: UnitPoint = .top

    private let scrolledUpThreshold: CGFloat = 30

    private var floatingDateMessage: UDMessage? {
        guard viewModel.sections.indices.contains(floatingDateSectionIndex) else { return nil }
        return viewModel.sections[floatingDateSectionIndex].items.first?.message
    }

    private let bottomAnchorId = "ud_chat_bottom_anchor"
    private let scrollCoordinateSpace = "udChatScroll"

    var body: some View {
        GeometryReader { outer in
            let viewportHeight = outer.size.height
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0) {
                        Color.clear
                            .frame(height: viewModel.configurationStyle.bubbleStyle.spacingOneSender)
                            .id(bottomAnchorId)
                            .udFlippedUpsideDown()

                        ForEach(viewModel.sections) { section in
                            ForEach(section.items) { item in
                                UDChatMessageRow(item: item, viewModel: viewModel)
                                    .id(item.id)
                                    .background(itemFrameReader(itemId: item.id))
                                    .background(visibilityReporter(messageId: item.message.id, viewportHeight: viewportHeight))
                                    .udFlippedUpsideDown()
                                    .padding(.bottom, item.topSpacing)
                                    .onAppear {
                                        viewModel.onWillDisplay?(item.message)
                                        markSectionAppeared(section.id)
                                    }
                                    .onDisappear {
                                        markSectionDisappeared(section.id)
                                    }
                            }

                            UDChatSectionHeaderView(
                                message: section.items.first?.message ?? UDMessage(),
                                style: viewModel.configurationStyle.sectionHeaderStyle,
                                usedesk: viewModel.usedesk
                            )
                            .udFlippedUpsideDown()
                            .background(headerTopPositionReader(sectionId: section.id))
                            .opacity(pinnedSectionIndex == section.id ? 0 : 1)
                            .onAppear {
                                markSectionAppeared(section.id)
                            }
                            .onDisappear {
                                markSectionDisappeared(section.id)
                            }
                        }

                        if viewModel.isLoadingHistory {
                            ProgressView()
                                .tint(Color(viewModel.configurationStyle.chatStyle.backgroundColorLoaderView))
                                .padding(8)
                                .udFlippedUpsideDown()
                        }

                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                viewModel.onReachTopForPagination?()
                            }
                    }
                    .background(
                        UDScrollObserver(
                            onUserScroll: {
                                markUserScrolling()
                                viewModel.onUserScrolled?()
                            },
                            onUserDragBegan: {
                                viewModel.onDismissKeyboard?()
                            },
                            onOffsetChange: { offset in
                                currentOffset = offset
                                viewModel.onScrollOffsetChanged?(offset)
                            },
                            onTouchStateChange: { active in
                                handleTouchStateChange(active)
                            }
                        )
                    )
                }
                .coordinateSpace(name: scrollCoordinateSpace)
                .udFlippedUpsideDown()
                .overlay(floatingDateView, alignment: .top)
                .background(Color(viewModel.configurationStyle.chatStyle.backgroundColor))
                .onPreferenceChange(UDHeaderAnchorKey.self) { frames in
                    headerFrames = frames
                    recomputeFloatingDatePush(viewportHeight: viewportHeight)
                }
                .onPreferenceChange(UDItemFrameKey.self) { frames in
                    itemFrames = frames
                }
                .frame(maxWidth: .infinity)
                .onChange(of: viewModel.scrollToBottomToken) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(bottomAnchorId, anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.pendingScrollMessageId) { messageId in
                    guard let messageId, let itemId = viewModel.itemId(forMessageId: messageId) else { return }
                    proxy.scrollTo(itemId, anchor: .top)
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(itemId, anchor: .top)
                        }
                        viewModel.pendingScrollMessageId = nil
                    }
                }
                .onChange(of: viewModel.preserveOffsetToken) { _ in
                    captureRepinAnchor(viewportHeight: viewportHeight)
                }
                .onChange(of: viewModel.appliedToken) { _ in
                    guard let anchorId = repinAnchorId else { return }
                    repinAnchorId = nil
                    proxy.scrollTo(anchorId, anchor: repinAnchorPoint)
                }
                .onChange(of: viewModel.focusedFormFieldId) { fieldId in
                    pendingScrollFieldId = fieldId
                    guard let fieldId = fieldId else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(fieldId, anchor: .center)
                    }
                }
                .onChange(of: viewportHeight) { _ in
                    guard let fieldId = pendingScrollFieldId else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(fieldId, anchor: .center)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Floating date
    @ViewBuilder
    private var floatingDateView: some View {
        if pinnedSectionIndex != nil, let message = floatingDateMessage {
            UDChatSectionHeaderView(
                message: message,
                style: viewModel.configurationStyle.sectionHeaderStyle,
                usedesk: viewModel.usedesk
            )
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: UDFloatingHeaderHeightKey.self, value: geo.size.height)
                }
            )
            .onPreferenceChange(UDFloatingHeaderHeightKey.self) { height in
                floatingHeaderHeight = height
            }
            .offset(y: floatingDatePushOffset)
            .opacity(isScrolling ? 1 : 0)
            .animation(.easeInOut(duration: 0.25), value: isScrolling)
            .allowsHitTesting(false)
            .clipped()
        }
    }

    private func headerTopPositionReader(sectionId: Int) -> some View {
        GeometryReader { geo in
            Color.clear.preference(
                key: UDHeaderAnchorKey.self,
                value: [sectionId: geo.frame(in: .named(scrollCoordinateSpace))]
            )
        }
    }

    private func itemFrameReader(itemId: String) -> some View {
        GeometryReader { geo in
            Color.clear.preference(
                key: UDItemFrameKey.self,
                value: [itemId: geo.frame(in: .named(scrollCoordinateSpace))]
            )
        }
    }

    private func visibilityReporter(messageId: Int, viewportHeight: CGFloat) -> some View {
        UDMessageVisibilityReporter(
            messageId: messageId,
            viewportHeight: viewportHeight,
            coordinateSpace: scrollCoordinateSpace,
            onShown: { id in
                viewModel.onVisibleMessages?([id])
            }
        )
    }

    private func captureRepinAnchor(viewportHeight: CGFloat) {
        guard viewportHeight > 0, currentOffset > scrolledUpThreshold else {
            repinAnchorId = nil
            return
        }
        let fullyVisible = itemFrames.filter { $0.value.minY >= 0 && $0.value.maxY <= viewportHeight }
        if let anchor = fullyVisible.min(by: { $0.value.minY < $1.value.minY }) {
            let d = anchor.value.minY
            let h = anchor.value.height
            let denom = viewportHeight - h
            let p = denom > 0 ? min(max(d / denom, 0), 1) : 0
            repinAnchorId = anchor.key
            repinAnchorPoint = UnitPoint(x: 0.5, y: p)
        } else if let anchor = itemFrames.filter({ $0.value.minY >= 0 }).min(by: { $0.value.minY < $1.value.minY }) {
            repinAnchorId = anchor.key
            repinAnchorPoint = .top
        } else {
            repinAnchorId = nil
        }
    }

    private func markSectionAppeared(_ sectionId: Int) {
        visibleItemCountsBySection[sectionId, default: 0] += 1
        updatePinnedSectionState()
    }

    private func markSectionDisappeared(_ sectionId: Int) {
        if let count = visibleItemCountsBySection[sectionId] {
            if count <= 1 {
                visibleItemCountsBySection.removeValue(forKey: sectionId)
            } else {
                visibleItemCountsBySection[sectionId] = count - 1
            }
        }
        updatePinnedSectionState()
    }

    private func updatePinnedSectionState() {
        let pinned = pinnedSectionByGeometry()
        if pinnedSectionIndex != pinned {
            pinnedSectionIndex = pinned
        }
        if let pinned {
            if floatingDateSectionIndex != pinned {
                floatingDateSectionIndex = pinned
            }
        } else if let bottommostVisibleSection = visibleItemCountsBySection.keys.max(), floatingDateSectionIndex != bottommostVisibleSection {
            floatingDateSectionIndex = bottommostVisibleSection
        }
    }

    private func pinnedSectionByGeometry() -> Int? {
        guard lastViewportHeight > 0, let bottommostVisibleSection = visibleItemCountsBySection.keys.max() else { return nil }
        guard let frame = headerFrames[bottommostVisibleSection] else {
            return bottommostVisibleSection
        }
        let onScreenTop = lastViewportHeight - frame.maxY
        return onScreenTop <= 0 ? bottommostVisibleSection : nil
    }

    private func recomputeFloatingDatePush(viewportHeight: CGFloat) {
        guard viewportHeight > 0 else { return }
        lastViewportHeight = viewportHeight

        let headerTops = headerFrames.map {
            (section: $0.key, onScreenTop: viewportHeight - $0.value.maxY)
        }
        let below = headerTops.filter { $0.onScreenTop > 0 }
        let nextHeaderOnScreenTop = below.min(by: { $0.onScreenTop < $1.onScreenTop })?.onScreenTop

        let pushTriggerDistance = floatingHeaderHeight + viewModel.configurationStyle.sectionHeaderStyle.floatingHeaderSpacing
        let push: CGFloat = (nextHeaderOnScreenTop.map { $0 < pushTriggerDistance ? -(pushTriggerDistance - $0) : 0 }) ?? 0

        if floatingDatePushOffset != push {
            floatingDatePushOffset = push
        }

        updatePinnedSectionState()
    }

    private func markUserScrolling() {
        isScrolling = true
        scheduleHideFloatingDateIfNeeded()
    }

    private func handleTouchStateChange(_ active: Bool) {
        isTouchActive = active
        if active {
            hideFloatingDateWorkItem?.cancel()
        } else {
            scheduleHideFloatingDateIfNeeded()
        }
    }

    private func scheduleHideFloatingDateIfNeeded() {
        hideFloatingDateWorkItem?.cancel()
        guard !isTouchActive else { return }
        let work = DispatchWorkItem {
            isScrolling = false
        }
        hideFloatingDateWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: work)
    }
}

private struct UDHeaderAnchorKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

private struct UDFloatingHeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct UDItemFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

private struct UDMessageVisibilityReporter: View {
    let messageId: Int
    let viewportHeight: CGFloat
    let coordinateSpace: String
    let onShown: (Int) -> Void
    @State private var shown = false

    var body: some View {
        GeometryReader { geo -> Color in
            if !shown, viewportHeight > 0 {
                let rect = geo.frame(in: .named(coordinateSpace))
                let overlap = min(rect.maxY, viewportHeight) - max(rect.minY, 0)
                if overlap > 0.5 {
                    DispatchQueue.main.async {
                        shown = true
                        onShown(messageId)
                    }
                }
            }
            return Color.clear
        }
    }
}

private struct UDScrollObserver: UIViewRepresentable {
    let onUserScroll: () -> Void
    let onUserDragBegan: () -> Void
    let onOffsetChange: (CGFloat) -> Void
    let onTouchStateChange: (Bool) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            context.coordinator.attach(from: view)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.attach(from: uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onUserScroll: onUserScroll, onUserDragBegan: onUserDragBegan, onOffsetChange: onOffsetChange, onTouchStateChange: onTouchStateChange)
    }

    final class Coordinator: NSObject {
        private let onUserScroll: () -> Void
        private let onUserDragBegan: () -> Void
        private let onOffsetChange: (CGFloat) -> Void
        private let onTouchStateChange: (Bool) -> Void
        private weak var scrollView: UIScrollView?
        private var observation: NSKeyValueObservation?

        init(onUserScroll: @escaping () -> Void, onUserDragBegan: @escaping () -> Void, onOffsetChange: @escaping (CGFloat) -> Void, onTouchStateChange: @escaping (Bool) -> Void) {
            self.onUserScroll = onUserScroll
            self.onUserDragBegan = onUserDragBegan
            self.onOffsetChange = onOffsetChange
            self.onTouchStateChange = onTouchStateChange
        }

        func attach(from view: UIView) {
            guard scrollView == nil else { return }
            var parent: UIView? = view.superview
            while let current = parent {
                if let scroll = current as? UIScrollView {
                    scrollView = scroll
                    observation = scroll.observe(\.contentOffset, options: [.new]) { [weak self] scroll, _ in
                        DispatchQueue.main.async {
                            self?.onOffsetChange(scroll.contentOffset.y)
                        }
                        guard scroll.isDragging || scroll.isDecelerating || scroll.isTracking else { return }
                        DispatchQueue.main.async {
                            self?.onUserScroll()
                        }
                    }
                    scroll.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
                    break
                }
                parent = current.superview
            }
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began:
                onUserDragBegan()
                onTouchStateChange(true)
            case .changed:
                onTouchStateChange(true)
            case .ended, .cancelled, .failed:
                onTouchStateChange(false)
            default:
                break
            }
        }

        deinit {
            observation?.invalidate()
            scrollView?.panGestureRecognizer.removeTarget(self, action: #selector(handlePan(_:)))
        }
    }
}
