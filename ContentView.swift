import SwiftUI
import MapKit
import WebKit
import SafariServices

struct ContentView: View {
    // إعدادات العداد والواجهة
    @State private var speed: Double = 0.0
    @State private var accentColor: Color = .green // يمكنك تغيير اللون الافتراضي من هنا
    @State private var searchText: String = ""
    @State private var showBrowser = false
    @State private var browserURL = URL(string: "https://www.google.com")!

    var body: some View {
        ZStack {
            // خلفية سوداء فخمة تناسب شاشات السيارات
            Color.black.edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 30) {
                
                // --- الجانب الأيسر: كوكب الأرض والبحث ---
                VStack(spacing: 20) {
                    // كوكب الأرض 3D التفاعلي
                    Map(mapType: .satelliteFlyover)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue.opacity(0.6), lineWidth: 4))
                        .shadow(color: .blue, radius: 15)
                    
                    // خانة البحث المتطورة
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("بحث أو رابط موقع...", text: $searchText, onCommit: {
                            openSearch()
                        })
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    
                    // أزرار الوصول السريع
                    HStack(spacing: 15) {
                        QuickButton(title: "YouTube", color: .red) {
                            self.browserURL = URL(string: "https://www.youtube.com")!
                            self.showBrowser = true
                        }
                        QuickButton(title: "Google", color: .blue) {
                            self.browserURL = URL(string: "https://www.google.com")!
                            self.showBrowser = true
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // --- الجانب الأيمن: عداد السرعة الاحترافي ---
                VStack {
                    ZStack {
                        // إطار العداد الخلفي
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(accentColor.opacity(0.2), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(135))
                        
                        // مؤشر السرعة المتحرك (تفاعلي)
                        Circle()
                            .trim(from: 0, to: CGFloat(speed / 240) * 0.7)
                            .stroke(accentColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(135))
                            .shadow(color: accentColor, radius: 10)
                        
                        VStack {
                            Text("\(Int(speed))")
                                .font(.system(size: 80, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            Text("KM/H")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(accentColor)
                        }
                    }
                    .frame(width: 280, height: 280)
                    
                    // مغير الألوان الفوري (تخصيص الـ Modder)
                    ColorPicker("تخصيص لون الطبلون", selection: $accentColor)
                        .labelsHidden()
                        .padding(.top, 10)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(40)
        }
        // فتح المتصفح عند البحث أو الضغط على الأزرار
        .fullScreenCover(isPresented: $showBrowser) {
            SafariView(url: browserURL)
        }
    }
    
    // وظيفة البحث الذكي
    func openSearch() {
        let encodedSearch = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if searchText.contains("http") {
            self.browserURL = URL(string: searchText) ?? URL(string: "https://www.google.com")!
        } else {
            self.browserURL = URL(string: "https://www.google.com/search?q=\(encodedSearch)")!
        }
        self.showBrowser = true
    }
}

// تصميم الأزرار السريعة
struct QuickButton: View {
    var title: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 110, height: 45)
                .background(color)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
    }
}

// مكون المتصفح الداخلي (WebView)
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
