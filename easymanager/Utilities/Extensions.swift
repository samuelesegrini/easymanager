//
//  Extensions.swift
//  easymanager
//
//  Created by Samuele Segrini on 01/04/23.
//

import SwiftUI


extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}
extension Array: Identifiable where Element: Hashable {
   public var id: Self { self }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {

        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func specificCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}

public struct StripesConfig {
    var background: Color
    var foreground: Color
    var degrees: Double
    var barWidth: CGFloat
    var barSpacing: CGFloat

    public init(background: Color = Color.pink.opacity(0.5), foreground: Color = Color.pink.opacity(0.8),
                degrees: Double = 30, barWidth: CGFloat = 20, barSpacing: CGFloat = 20) {
        self.background = background
        self.foreground = foreground
        self.degrees = degrees
        self.barWidth = barWidth
        self.barSpacing = barSpacing
    }

    public static let `default` = StripesConfig()
}


public struct Stripes: View {
    var config: StripesConfig

    public init(config: StripesConfig) {
        self.config = config
    }

    public var body: some View {
        GeometryReader { geometry in
            let longSide = max(geometry.size.width, geometry.size.height)
            let itemWidth = config.barWidth + config.barSpacing
            let items = Int(2 * longSide / itemWidth)
            HStack(spacing: config.barSpacing) {
                ForEach(0..<items, id: \.self) { index in
                    config.foreground
                        .frame(width: config.barWidth, height: 2 * longSide)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .rotationEffect(Angle(degrees: config.degrees), anchor: .center)
            .offset(x: -longSide / 2, y: -longSide / 2)
            .background(config.background)
        }
        .clipped()
    }
}

extension Date{
    func toString(_ format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

extension Calendar{
    var hours : [Date] {
        let startOfDay = self.startOfDay(for: Date())
        var hours : [Date] = []
        for index in 0..<24 {
            if let date = self.date(byAdding: .hour, value: index, to: startOfDay){
                hours.append(date)
            }
        }
        return hours
    }
    
    var currentWeek: [Weekday]{
        guard let firstWeekday = self.dateInterval(of: .weekOfMonth, for: Date())?.start else {return []}
        var week : [Weekday] = []
        for index in 0..<7{
            if let day = self.date(byAdding: .day,value: index, to: firstWeekday){
                let weekDaySymbol : String = day.toString("EEEE")
                let isToday = self.isDateInToday(day)
                week.append(.init(string: weekDaySymbol, date: day, isToday : isToday))
            }
        }
        return week
    }
    
    struct Weekday: Identifiable {
        var id : UUID = .init()
        var string: String
        var date : Date
        var isToday : Bool = false
    }
}

extension View {
    func hAllign(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    func vAllign(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
}

