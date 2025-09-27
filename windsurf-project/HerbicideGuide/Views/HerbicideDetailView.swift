import SwiftUI

struct HerbicideDetailView: View {
    let herbicide: Herbicide
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(herbicide.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(herbicide.commonName)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom)
                    
                    // Quick Info
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(title: "Type", value: herbicide.type)
                        DetailRow(title: "Application Rate", value: herbicide.applicationRate)
                        DetailRow(title: "Rainfastness", value: herbicide.rainfastness)
                        DetailRow(title: "Grazing Restriction", value: herbicide.grazingRestriction)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Active Ingredients
                    SectionView(title: "Active Ingredients") {
                        ForEach(herbicide.activeIngredients, id: \.self) { ingredient in
                            Text("• \(ingredient)")
                        }
                    }
                    
                    // Application Timing
                    SectionView(title: "Application Timing") {
                        ForEach(herbicide.applicationTiming, id: \.self) { timing in
                            Text("• \(timing)")
                        }
                    }
                    
                    // Weeds Controlled
                    SectionView(title: "Weeds Controlled") {
                        FlowLayout(mode: .scrollable, items: herbicide.weedsControlled) { weed in
                            Text(weed)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(15)
                        }
                    }
                    
                    // Notes
                    if !herbicide.notes.isEmpty {
                        SectionView(title: "Notes") {
                            Text(herbicide.notes)
                                .padding(.top, 4)
                        }
                    }
                    
                    // Safety Information
                    if !herbicide.safetyInformation.isEmpty {
                        SectionView(title: "Safety Information") {
                            Text(herbicide.safetyInformation)
                                .padding(.top, 4)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

// Helper view for flow layout
struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    // Use a concrete array to simplify layout math and access to last element
    private let items: [Data.Element]
    let content: (Data.Element) -> Content
    var spacing: CGFloat = 8
    var alignment: Alignment = .leading
    
    init(mode: LayoutMode = .scrollable, items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = Array(items)
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            contentView(in: geometry)
        }
    }
    
    private func contentView(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding([.trailing, .bottom], spacing)
                    .alignmentGuide(.leading) { dimension in
                        if (abs(width - dimension.width) > geometry.size.width) {
                            width = 0
                            height -= dimension.height
                        }
                        let result = width
                        if item == items.last { width = 0 }
                        else { width -= dimension.width + spacing }
                        return result
                    }
                    .alignmentGuide(.top) { dimension in
                        let result = height
                        if item == items.last { height = 0 }
                        return result
                    }
            }
        }
    }
    
    enum LayoutMode {
        case scrollable, fixed
    }
}

struct HerbicideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sample = Herbicide(
            name: "Sample Herbicide",
            commonName: "Test Chemical",
            type: "Test Type",
            activeIngredients: ["Ingredient 1", "Ingredient 2"],
            applicationRate: "1.0 L/ha",
            applicationTiming: ["Pre-emergence", "Post-emergence"],
            weedsControlled: ["Weed 1", "Weed 2", "Weed 3"],
            phytoxicity: "Low",
            rainfastness: "6 hours",
            grazingRestriction: "7 days",
            notes: "This is a sample herbicide for testing purposes.",
            safetyInformation: "Wear protective equipment when handling."
        )
        HerbicideDetailView(herbicide: sample)
    }
}
