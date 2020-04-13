import CoreLocation
import RxCocoa
import RxSwift
import UIKit

class WeatherViewController: UIViewController {
    
    //MARK: - Constants
    
    private enum Constants {
        static let changeCityVCId = "ChangeCityViewController"
    }
    
    let locationManager = CLLocationManager()
    let weatherData = PublishSubject<WeatherData>()
    let disposeBag = DisposeBag()
    
    //MARK: - Variables
    
    var currentShownTemperature = 0

    //MARK: - IBOutlets
    
    @IBOutlet weak var celsiusOrFahrenheit: UISwitch!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityChanger: UIButton!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        subscribeToSwitcher()
        subscribeToWeatherData()
        subscribeToCityChangerButton()
    }
    
    //MARK: - Subscriptions
    
    private func subscribeToSwitcher() {
        celsiusOrFahrenheit.rx.isOn
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, self.temperatureLabel.text != "" else { return }
                self.temperatureLabel.text = self.celsiusOrFahrenheit.isOn ? "\(self.currentShownTemperature)°C" : "\(Int(Double(self.currentShownTemperature) * 1.8 + 32))°F"
            }).disposed(by: disposeBag)
    }
    
    private func subscribeToWeatherData() {
        weatherData
            .observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.updateUI(withWeatherData: data)
            }).disposed(by: disposeBag)
    }
    
    private func subscribeToCityChangerButton() {
        cityChanger.rx.tap
            .flatMap { [weak self] _ -> PublishSubject<String> in
                guard let self = self else { return PublishSubject<String>() }
                let changeCityVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.changeCityVCId) as! ChangeCityViewController
                self.present(changeCityVC, animated: true)
                return changeCityVC.newCity
            }
            .subscribe(onNext: { [weak self] newCityName in
                guard let self = self else { return }
                let cityNameWithouthSpaces = newCityName.replacingOccurrences(of: " ", with: "+")
                let finalURL = EndPoint.baseURL() + EndPoint.queryWithName(name: cityNameWithouthSpaces)
                self.getWeatherData(url: finalURL)
            }).disposed(by: self.disposeBag)
    }
    
    //MARK: - Networking
        
    func getWeatherData(url: String) {
        guard let url = URL(string: url) else {
            self.weatherData.onNext(WeatherData.noDataWeather())
            return
        }
        
        let request = createRequest(fromUrl: url)
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            guard error == nil,
                let response = response as? HTTPURLResponse, (200...300).contains(response.statusCode),
                let data = data else {
                    print("Either an error occurred, the HTML response was wrong or the data was nil.")
                    self.weatherData.onNext(WeatherData.noDataWeather())
                    return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                self.currentShownTemperature = decodedData.tempInCelsius
                self.weatherData.onNext(decodedData)
            } catch {
                fatalError("Error during JSON parsing")
            }
        }.resume()
    }
    
    private func createRequest(fromUrl url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    //MARK: - UI Updates
        
    private func updateUI(withWeatherData data: WeatherData) {
        temperatureLabel.text = data.main.temp == 0.0 ? "" : "\(data.tempInCelsius)°C"
        weatherIcon.image = UIImage(named: data.weatherIcon)
        cityLabel.text = data.name
    }
       
}
    
//MARK: - Location Manager Delegate Methods

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
                        
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)

            let finalURL = EndPoint.baseURL() + EndPoint.queryWithLonLat(latitude: latitude, longitude: longitude)
            getWeatherData(url: finalURL)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavailable"
    }
}
