import Foundation

struct WeatherData: Codable {
    let main: Temperature
    let name: String
    let weather: [Weather]
    var weatherIcon: String {
        switch weather.first!.id {
        case 0...300 :
            return "tstorm1"

        case 301...500 :
            return "light_rain"

        case 501...600 :
            return "shower3"

        case 601...700 :
            return "snow4"

        case 701...771 :
            return "fog"

        case 772...799 :
            return "tstorm3"

        case 800 :
            return "sunny"

        case 801...804 :
            return "cloudy2"

        case 900...903, 905...1000  :
            return "tstorm3"

        case 903 :
            return "snow5"

        case 904 :
            return "sunny"

        default :
            return "dunno"
        }
    }
    var tempInCelsius: Int {
        return Int(self.main.temp - 273.15)
    }
}

struct Temperature: Codable {
    let temp: Double
}

struct Weather: Codable {
    let id: Int
}

extension WeatherData {
    static func noDataWeather() -> WeatherData {
        return WeatherData(
            main: Temperature(temp: 0.0),
            name: "Location not available",
            weather: [Weather(id: -1)])
    }
}
