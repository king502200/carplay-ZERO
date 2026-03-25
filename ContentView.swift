import SwiftUI
import SafariServices

struct ContentView: View {
    @State private var speed: Double = 0.0
    @State private var searchText: String = ""
    @State private var showBrowser = false
    @State private var browserURL = URL(string: "https://www.google.com")!
    
    // --- ميزة التحكم باللون ---
    @State private var accentColor: Color = .cyan // اللون الافتراضي (أزرق ثلجي)
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // --- القسم العلوي: عداد السرعة الملون ---
                ZStack {
                    GaugeBackground(color: accentColor)
                    
                    GaugeNeedle(speed: speed, color: accentColor)
                    
                    DigitalDashboard(speed: speed, color: accentColor)
                }
                .frame(width: 300, height: 300)
                
                // --- أدوات التحكم (البحث + يوتيوب + مغير الألوان) ---
                HStack(spacing: 15) {
                    // مغير الألوان (تنسيق دائري صغير)
                    VStack(spacing: 5) {
                        ColorPicker("", selection: $accentColor)
                            .labelsHidden()
                            .scaleEffect(1.2)
                        Text("اللون").font(.caption2).foregroundColor(.gray)
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)

                    // شريط البحث
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("بحث...", text: $searchText, onCommit: openSearch)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    
                    // زر يوتيوب
                    Button(action: { openLink("https://m.youtube.com") }) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .shadow(color: .red.opacity(0.4), radius: 10)
                    }
                }
                .padding(.horizontal, 25)
            }
        }
        .fullScreenCover(isPresented: $showBrowser) { SafariView(url: browserURL) }
        .onReceive(timer) { _ in
            if speed < 141 { speed += 1.0 }
        }
    }

    func openSearch() {
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        openLink("https://www.google.com/search?q=\(query)")
    }
    
    func openLink(_ urlStr: String) {
        browserURL = URL(string: urlStr)!
        showBrowser = true
    }
}

// --- مكونات التصميم المعدلة لتدعم تغيير الألوان ---

struct GaugeBackground: View {
    var color: Color
    var body: some View {
        ZStack {
            // الحلقة المتوهجة
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(color.opacity(0.8), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .rotationEffect(.degrees(135))
                .shadow(color: color.opacity(0.6), radius: 15)
            
            // الخطوط (Ticks)
            ForEach(0..<23) { tick in
                Rectangle()
                    .fill(tick % 2 == 0 ? color : Color.white.opacity(0.3))
                    .frame(width: tick % 2 == 0 ? 3 : 1, height: 10)
                    .offset(y: -135)
                    .rotationEffect(.degrees(Double(tick) * 12 + 135))
            }
            
            // الأرقام
            ForEach([0, 40, 80, 120, 160, 200, 240], id: \.self) { num in
                Text("\(num)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                    .position(numTextPosition(for: num, radius: 105))
            }
        }
    }
    
    func numTextPosition(for num: Int, radius: CGFloat) -> CGPoint {
        let angle = CGFloat(num) / 240.0 * 270.0 + 135.0
        let radian = angle * CGFloat.pi / 180.0
        let x = radius * cos(radian) + 150 
        let y = radius * sin(radian) + 150
        return CGPoint(x: x, y: y)
    }
}

struct GaugeNeedle: View {
    var speed: Double
    var color: Color
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.white, color], startPoint: .top, endPoint: .bottom))
                .frame(width: 3, height: 120)
                .offset(y: -50)
            
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
                .shadow(color: color, radius: 5)
        }
        .rotationEffect(.degrees(Double(speed) / 240.0 * 270.0 + 135.0))
    }
}

struct DigitalDashboard: View {
    var speed: Double
    var color: Color
    var body: some View {
        VStack(spacing: -5) {
            Text("\(Int(speed))")
                .font(.system(size: 70, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: color.opacity(0.5), radius: 10)
            Text("KM/H")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
                .tracking(3)
        }
        .padding(.top, 130)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ ui: SFSafariViewController, context: Context) {}
}
