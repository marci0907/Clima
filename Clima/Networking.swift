import Foundation

enum EndPoint {
    static func baseURL() -> String {
        return "http://api.openweathermap.org/data/2.5/weather"
    }
    
    static func queryWithLonLat(latitude: String, longitude: String) -> String {
        return "?lat=\(latitude)&lon=\(longitude)&appid=\(APP_ID)"
    }
    
    static func queryWithName(name: String) -> String {
        return "?q=\(name)&appid=\(APP_ID)"
    }
}
