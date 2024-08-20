import SwiftUI


struct NaturalSection<Content: View>: View {
    internal init(content: Content) {
        self.content = content
    }
    
    @ViewBuilder
    var content: Content

    init(
        @ViewBuilder content: () -> Content
    ) {
        self.init(content: content())
    }

    var body: some View {
        NaturalLayout {
            ForEach(subviews: content) { subview in
                subview
                    .modifier(NaturalItemStyle())
            }
        }
        .textFieldStyle(.roundedBorder)
        .pickerStyle(.menu)
        .buttonStyle(.bordered)
        .toggleStyle(.button)
        .font(.body)
        .labelsHidden()
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .overlay {
            ContainerRelativeShape()
                .stroke(
                    Appearance(
                        light: .quinary,
                        dark: .quinary
                    ),
                    lineWidth: 1
                )
        }
        .background(.background.secondary)
        .containerShape(RoundedRectangle(cornerRadius: 10))
        .padding(10)
    }
}

struct Appearance<Light: ShapeStyle, Dark: ShapeStyle>: ShapeStyle {
    let light: Light
    let dark: Dark

    func resolve(in environment: EnvironmentValues) -> AnyShapeStyle {
        if environment.colorScheme == .dark {
            AnyShapeStyle(dark)
        } else {
            AnyShapeStyle(light)
        }
    }
}


#Preview("Section") {
    @Previewable @State
    var text = "Hello World"

    @Previewable @State
    var isChecked = true

    NaturalSection {
        Text("A Button you can")
        Button("tap") { print("tapped") }
        Text("but how")
        Text("about some text?")
        TextField("Name", text: $text)
        Text("and a toggle")
        Toggle(isChecked ? "on" : "off", isOn: $isChecked)
    }
    .frame(maxWidth: 400)
}
