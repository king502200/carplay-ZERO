import SwiftUI
import WebKit
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
            
            HStack(spacing: 40) {
                // --- القسم الأيسر: البحث والتحكم ---
                VStack(spacing: 25) {
                    // أيقونة الكرة الأرضية (بدلاً من الخريطة المعقدة لتجنب الخطأ)
                    Image(systemName: "globe.americas.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.5), radius: 20)
                    
                    TextField("ابحث هنا...", text: $searchText, onCommit: {
                        openSearch()
                    })
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    
                    HStack(spacing: 20) {
                        Button("YouTube") {
                            browserURL = URL(string: "https://m.youtube.com")!
                            showBrowser = true
                        }
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        
                        Button("Google") {
                            browserURL = URL(string: "https://www.google.com")!
                            showBrowser = true
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)

                // --- القسم الأيمن: العداد الفخم ---
                VStack {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(accentColor.opacity(0.2), lineWidth: 25)
                            .rotationEffect(.degrees(135))
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(speed / 240) * 0.7)
                            .stroke(accentColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                            .rotationEffect(.degrees(135))
                            .shadow(color: accentColor, radius: 10)
                        
                        VStack {
                            Text("\(Int(speed))")
                                .font(.system(size: 80, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            Text("KM/H")
                                .font(.bold(.system(size: 20))())
                                .foregroundColor(accentColor)
                        }
                    }
                    .frame(width: 280, height: 280)
                    
                    ColorPicker("لون العداد", selection: $accentColor)
                        .labelsHidden()
                        .padding(.top)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(40)
        }
        .fullScreenCover(isPresented: $showBrowser) {
            SafariView(url: browserURL)
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
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
