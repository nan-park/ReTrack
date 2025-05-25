import SwiftUI

extension Date {
    func formattedKoreanStyle() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd a hh:mm"
        return formatter.string(from: self)
    }
}

