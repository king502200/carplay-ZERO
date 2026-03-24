import SwiftUI
import MapKit
import SafariServices

struct ContentView: View {
    @State private var speed: Double = 0.0
    @State private var accentColor: Color = .green
    @State private var searchText: String = ""
    @State private var showBrowser = false
    @State private var browserURL = URL(string: "https://www.google.com")!

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 30) {
                // الجانب الأيسر
                VStack(spacing: 20) {
                    // كوكب الأرض
                    Map()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue.opacity(0.4), lineWidth: 3))
                    
                    // البحث
                    TextField("بحث...", text: $searchText, onCommit: {
                        openSearch()
                    })
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    
                    HStack {
                        Button("YouTube") {
                            browserURL = URL(string: "https://m.youtube.com")!
                            showBrowser = true
                        }.buttonStyle(.borderedProminent).tint(.red)
                        
                        Button("Google") {
                            browserURL = URL(string: "https://www.google.com")!
                            showBrowser = true
                        }.buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity)

                // الجانب الأيمن: العداد
                VStack {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(accentColor.opacity(0.2), lineWidth: 20)
                            .rotationEffect(.degrees(135))
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(speed / 240) * 0.7)
                            .stroke(accentColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(135))
                        
                        VStack {
                            Text("\(Int(speed))").font(.system(size: 60, weight: .black)).foregroundColor(.white)
                            Text("KM/H").foregroundColor(accentColor)
                        }
                    }
                    .frame(width: 240, height: 240)
                    
                    ColorPicker("", selection: $accentColor).labelsHidden()
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showBrowser) {
            if let url = browserURL { SafariView(url: url) }
        }
    }

    func openSearch() {
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        browserURL = URL(string: "https://www.google.com/search?q=\(query)")!
        showBrowser = true
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ ui: SFSafariViewController, context: Context) {}
}
