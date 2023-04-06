//
//  ReceiptDraw.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 27/02/23.
//

import SwiftUI

struct LREdgeCutShapeView: Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.addArc(center: CGPoint(x: rect.minX, y: rect.midY),
                        radius: 12.0,
                        startAngle: Angle(degrees: 90),
                        endAngle: Angle(degrees: 270),
                        clockwise: true)
            path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY),
                        radius: 12.0,
                        startAngle: Angle(degrees: 270),
                        endAngle: Angle(degrees: 90),
                        clockwise: true)
        }
    }
}

struct LineShape: Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
struct receiptDrawComponent: View {
    
    var body: some View {
        ZStack {
            LREdgeCutShapeView()
                .fill(Color(UIColor.tertiarySystemGroupedBackground), style: FillStyle(eoFill: false, antialiased: false))
                .frame(maxWidth: .infinity)
                .frame(height: 24.0)
            LineShape()
                .stroke(Color(uiColor: .lightGray), style: StrokeStyle(lineWidth: 1.0, dash: [5]))
                .frame(height: 1.0)
                .padding(.horizontal)
        }
    }
}
