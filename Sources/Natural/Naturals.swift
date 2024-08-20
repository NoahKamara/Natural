import SwiftUI


public struct Naturals<Content: View>: View {
    @ViewBuilder
    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ForEach(sections: content) { section in
            NaturalSection {
                if !section.header.isEmpty {
                    section.header
                        .fontWeight(.semibold)
                }
                section.content
            }
        }
//        .onMove { offsets, index in
//            print(offsets, index)
//        }
    }
}


#Preview("Paragraph Blocks") {
    @Previewable @State
    var text: String = "Hello World"

    VStack(spacing: 0) {
        Naturals {
            Section("A Section") {
                Text("A Button you can")
                Button("tap") { print("tapped") }
            }

            Section {
                Text("A Button you can")
                Button("tap") { print("tapped") }
                Text("but how")
                Text("about some text?")
                Text("or even more")
                TextField("Name", text: $text)
            } header: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundStyle(.green.mix(with: .black, by: 0.1).gradient)

                    Image(systemName: "gear")
                        .padding(2)
                        .foregroundStyle(.white)
                }
                .colorScheme(.dark)
            }

        }
    }
}
