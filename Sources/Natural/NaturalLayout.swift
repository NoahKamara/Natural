import SwiftUI



struct NaturalLayout: Layout {
    struct Cache {
        var sizes: [CGSize]
        var offsets: [CGFloat]
        var spacings: [CGFloat]
        var layout: [Int] = []

        @discardableResult
        mutating func updateLayout(in proposal: ProposedViewSize, subviews: Subviews) -> CGSize {
            for i in subviews.indices { // swiftlint:disable:this identifier_name
                let subview = subviews[i]

                let size = subview.sizeThatFits(.init(width: .infinity, height: nil))


                if let proposalWidth = proposal.width, proposalWidth < size.width {
                    sizes[i] = subview.sizeThatFits(.init(width: proposalWidth, height: nil))
                } else {
                    sizes[i] = size
                }

                offsets[i] = subview.dimensions(in: .init(size))[.lastTextBaseline]

                spacings[i] = if i > 0 {
                    subview.spacing.distance(
                        to: subviews[i-1].spacing,
                        along: .horizontal
                    )
                } else {
                    CGFloat.zero
                }
            }



            // swiftlint:disable identifier_name
            var i = 0
            var layout: [Int] = []
            var height: CGFloat = 0
            var maxWidth = CGFloat.zero

            while i < subviews.endIndex {
                var rowWidth: CGFloat = 0
                var columns = 0

                for j in (i..<subviews.endIndex) {
                    var potentialWidth = rowWidth

                    // add size
                    potentialWidth += sizes[j].width

                    // this is not the first column
                    if j > i {
                        // add spacing to previous column
                        potentialWidth += spacings[i+columns]
                    } else if i > 0 {
                        height += subviews[i].spacing.distance(to: subviews[i-1].spacing, along: .horizontal)
                    }

                    // ensure there is space for another column
                    guard potentialWidth <= (proposal.width ?? .infinity) else {
                        columns = max(1, columns)
                        break
                    }

                    rowWidth = potentialWidth
                    columns += 1
                }

                if maxWidth < rowWidth {
                    maxWidth = rowWidth
                }

                height += sizes[i..<(i+columns)].map(\.height).max() ?? 0
                i += columns
                layout.append(columns)
            }

            self.layout = layout
            return CGSize(width: maxWidth, height: height)
            // swiftlint:enable identifier_name
        }
    }

    var lineSpacing: CGFloat?

    init(lineSpacing: CGFloat? = nil) {
        self.lineSpacing = lineSpacing
    }

    func makeCache(subviews: Subviews) -> Cache {
        return Cache(
            sizes: .init(repeating: .zero, count: subviews.count),
            offsets: .init(repeating: .zero, count: subviews.count),
            spacings: .init(repeating: .zero, count: subviews.count)
        )
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let size = cache.updateLayout(in: proposal, subviews: subviews)
        return size
    }

    struct SubviewInfo {
        let size: CGSize
        let spacing: CGFloat
        let offset: CGFloat
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        cache = makeCache(subviews: subviews)
        cache.updateLayout(in: .init(bounds.size), subviews: subviews)

        var cursor = bounds.origin

        var i = 0 // swiftlint:disable:this identifier_name
        var row = 0

        for columns in cache.layout {
            let rowRange = i..<(i+columns)
            row += 1
            cursor.x = bounds.minX
            let rowOffset = cache.offsets[rowRange].max() ?? 0

            defer {
                if i < subviews.endIndex {
                    cursor.y += cache.sizes[rowRange].map(\.height).max() ?? 0
                }
            }

            if i > 0 {
                let customSpacing = subviews[i].spacing.distance(to: subviews[i-1].spacing, along: .vertical)

                let verticalSpacing = lineSpacing.flatMap({
                    min($0, customSpacing)
                }) ?? customSpacing

                cursor.y += verticalSpacing
            }

            for col in (0..<columns) {
                defer {
                    cursor.x += cache.sizes[i].width
                    i += 1
                }

                if col > 0 {
                    cursor.x += cache.spacings[i]
                }

                subviews[i].place(
                    at: cursor.applying(.init(translationX: 0, y: rowOffset-cache.offsets[i])),
                    anchor: .topLeading,
                    proposal: .init(cache.sizes[i])
                )
            }
        }
    }
}

enum NaturalContentHeight {
    case `default`
    case fill
}

extension View {
    func naturalHeight(_ mode: NaturalContentHeight) -> some View {
        self.layoutValue(key: NaturalLayoutKey.self, value: mode)
    }
}

struct NaturalLayoutKey: LayoutValueKey {
    static let defaultValue: NaturalContentHeight = .default
}

#Preview {
    @Previewable @State
    var text: String = "Hello World this is a "

    @Previewable @State
    var mode: String = "none"

    NaturalSection {

        Group {
            Text("A Button you can")
            Button("tap") { print("tapped") }
            Text("but how about")
            Text("some Text")

            TextField("4", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)

            TextField("4", text: $text, axis: .horizontal)
                .textFieldStyle(.roundedBorder)


            Text("or even")

            Text("1 How about a picker in the next")

            Picker("2 A picker", selection: $mode) {
                Text("Mode A").tag("A")
                Text("Mode B").tag("B")
                Text("Mode C").tag("C")
                Text("None").tag("none")
            }

            Text("3 How about a picker")

            Button("4 wow") { print("more") }

            Text("5 in the next")
        }

    }
}
