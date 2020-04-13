import RxCocoa
import RxSwift
import UIKit

class ChangeCityViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var changeCityTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var getWeatherButton: UIButton!
    
    let disposeBag = DisposeBag()
    let newCity = PublishSubject<String>()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeCityTextField.becomeFirstResponder()
        
        subscribeToBackButton()
        subscribeToGetWeather()
    }
    
    //MARK: - Subscriptions
    
    private func subscribeToBackButton() {
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func subscribeToGetWeather() {
        getWeatherButton.rx.tap
            .filter({ _ in
                return !self.changeCityTextField.text!.isEmpty
            })
            .do(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.newCity.onNext(self.changeCityTextField.text!)
            }).disposed(by: disposeBag)
    }

}
