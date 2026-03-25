import SwiftUI
import CoreLocation // ضروري للـ GPS الحقيقي
import SafariServices

// مدير الموقع (GPS Manager)
class SpeedManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentSpeedKH: Double = 0.0
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        // طلب تصريح الموقع (يجب تفعيله في Info.plist)
        locationManager.requestWhenInUseAuthorization()
        // ضبط الدقة العالية (Best for Navigation) لسرعة دقيقة
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // سرعة الـ GPS تأتي بالمتر/ثانية، نحولها كم/ساعة
            let speedMS = location.speed
            if speedMS > 0 {
                self.currentSpeedKH = speedMS * 3.6
            } else {
                self.currentSpeedKH = 0.0 // السيارة واقفة
            }
        }
    }
}

struct ContentView: View {
    // ربط العداد بمدير السرعة الفعلي
    @StateObject private var speedManager = SpeedManager()
    @State private var accentColor: Color = .purple // اللون الأرجواني الافتراضي
    @State private var searchText: String = ""
    @State private var showBrowser = false
    @State private var browserURL = URL(string: "https://www.google.com")!
    
    var body: some View {
        // استخدم GeometryReader لوزن المقاسات بدقة
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height
            
            // حساب حجم العداد بناءً على أقصر بُعد للشاشة
            let gaugeSize = min(screenWidth, screenHeight) * 0.85
            
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // العداد - محتشم وموزون في المنتصف
                    ZStack {
                        GaugeBackground(color: accentColor, size: gaugeSize)
                        GaugeNeedle(speed: speedManager.currentSpeedKH, color: accentColor, size: gaugeSize)
                        DigitalDashboard(speed: speedManager.currentSpeedKH, color: accentColor, size: gaugeSize)
                    }
                    .frame(width: gaugeSize, height: gaugeSize)
                    .padding(.top, (screenHeight - gaugeSize) * 0.4) // توسيط عمودي دقيق
                    
                    Spacer() // دفع الأدوات للأسفل
                    
                    // شريط الأدوات السفلي
                    HStack(spacing: 20) {
                        // مغير الألوان
                        VStack(spacing: 5) {
                            ColorPicker("", selection: $accentColor)
                                .labelsHidden()
                                .scaleEffect(1.3)
                            Text("اللون").font(.caption2).foregroundColor(.gray)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // شريط البحث
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            TextField("بحث Google...", text: $searchText, onCommit: openSearch)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        
                        // زر YouTube
                        Button(action: { openLink("https://m.youtube.com") }) {
                            Image(systemName: "play.tv.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.red)
                                .shadow(color: .red.opacity(0.7), radius: 15)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
                .frame(width: screenWidth, height: screenHeight) // ملء الشاشة
            }
        }
        .fullScreenCover(isPresented: $showBrowser) { SafariView(url: browserURL) }
    }
    
    // وظائف البحث والروابط
    func openSearch() {
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        openLink("https://www.google.com/search?q=\(query)")
    }
    
    func openLink(_ urlStr: String) {
        browserURL = URL(string: urlStr)!
        showBrowser = true
    }
}

// --- مكونات التصميم الموزونة (تأخذ الحجم كبارامتر) ---

struct GaugeBackground: View {
    var color: Color
    var size: CGFloat
    
    var body: some View {
        ZStack {
            // الحلقة الخارجية
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.05, lineCap: .round))
                .rotationEffect(.degrees(135))
                .shadow(color: color.opacity(0.6), radius: size * 0.05)
            
            // الخطوط (Ticks)
            let tickCount = 23
            ForEach(0..<tickCount) { tick in
                Rectangle()
                    .fill(tick % 2 == 0 ? color : Color.white.opacity(0.4))
                    .frame(width: tick % 2 == 0 ? size * 0.01 : size * 0.003, height: size * 0.035)
                    .offset(y: -size / 2 + size * 0.05)
                    .rotationEffect(.degrees(Double(tick) * 12 + 135))
            }
            
            // الأرقام
            let numbers = [0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240]
            ForEach(numbers, id: \.self) { num in
                Text("\(num)")
                    .font(.system(size: size * 0.045, weight: .bold))
                    .foregroundColor(color)
                    .position(numTextPosition(for: num, radius: size / 2 - size * 0.12, gaugeSize: size))
            }
        }
    }
    
    // حساب موقع الأرقام بناءً على حجم العداد
    func numTextPosition(for num: Int, radius: CGFloat, gaugeSize: CGFloat) -> CGPoint {
        let angle = CGFloat(num) / 240.0 * 270.0 + 135.0
        let radian = angle * CGFloat.pi / 180.0
        let x = radius * cos(radian) + gaugeSize / 2
        let y = radius * sin(radian) + gaugeSize / 2
        return CGPoint(x: x, y: y)
    }
}

struct GaugeNeedle: View {
    var speed: Double
    var color: Color
    var size: CGFloat
    
    var body: some View {
        ZStack {
            // الإبرة
            Rectangle()
                .fill(LinearGradient(colors: [.white, color], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.01, height: size * 0.45)
                .offset(y: -size * 0.18)
            
            // المركز
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.06, height: size * 0.06)
                .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 2))
        }
        // زاوية الدوران بناءً على السرعة الحقيقية
        .rotationEffect(.degrees(min(Double(speed), 240.0) / 240.0 * 270.0 + 135.0))
    }
}

struct DigitalDashboard: View {
    var speed: Double
    var color: Color
    var size: CGFloat
    
    var body: some View {
        VStack(spacing: -size * 0.01) {
            Text("\(Int(speed))")
                .font(.system(size: size * 0.28, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: color.opacity(0.6), radius: size * 0.05)
            Text("KM/H")
                .font(.system(size: size * 0.06, weight: .bold))
                .foregroundColor(color)
                .tracking(size * 0.01)
        }
        .padding(.top, size * 0.45) // توسيط عمودي دقيق للرقم
    }
}

// مكون المتصفح الداخلي
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ ui: SFSafariViewController, context: Context) {}
}
