
import Foundation

struct DailyForecast {
    var date: Date?
    var epochDate: Int?
    var temperature: Temperature?
    var day, night: Day?
    var sources: [String]?
    var mobileLink, link: String?
}
