import SwiftUI

struct NaturalItemStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
            .pickerStyle(.menu)
            .buttonStyle(.bordered)
            .toggleStyle(.button)
            .font(.body)
            .labelsHidden()
    }
}


struct NaturalForm<Content: View>: View {
    @ViewBuilder
    var content: Content

    var body: some View {
        VStack(spacing: 0) {
            ForEach(sectionOf: content) { section in
                NaturalSection {
                    if !section.header.isEmpty {
                        section.header
                            .fontWeight(.semibold)
                    }
                    section.content
                }
            }
        }
        .modifier(NaturalItemStyle())
    }
}

#Preview("Paragraph Blocks") {
    @Previewable @State
    var text: String = "Hello World"

    NaturalForm {
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
