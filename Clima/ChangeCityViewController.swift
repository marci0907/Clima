import RxSwift
import RxCocoa
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
    
    private func subscribeToBackButton() {
        backButton.rx.tap
            .subscribe(onNext: { _ in
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func subscribeToGetWeather() {
        getWeatherButton.rx.tap
            .filter({ _ in
                !self.changeCityTextField.text!.isEmpty })
            .do(onNext: {
                self.dismiss(animated: true)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if #available(iOS 13.0, *) {
                    self.newCity.onNext(self.changeCityTextField.text!)
                }
            }).disposed(by: disposeBag)
    }

}
