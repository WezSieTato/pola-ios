import UIKit

protocol CheckoutDeliveryViewDelegate: class {
    func checkoutDeliveryViewDidSelectAddress(view: CheckoutDeliveryView, atIndex addressIndex: Int)
    func checkoutDeliveryViewDidTapAddAddressButton(view: CheckoutDeliveryView)
    func checkoutDeliveryViewDidTapEditAddressButton(view: CheckoutDeliveryView)
    func checkoutDeliveryViewDidTapChooseKioskButton(view: CheckoutDeliveryView)
    func checkoutDeliveryViewDidTapChangeKioskButton(view: CheckoutDeliveryView)
    func checkoutDeliveryViewDidTapNextButton(view: CheckoutDeliveryView)
}

class CheckoutValidator: Validator {
    @objc var failedMessage: String? = nil
    
    @objc func validate(currentValue: AnyObject?) -> Bool {
        guard let deliveryView = currentValue as? CheckoutDeliveryView else { return false }
        guard let optionViews = deliveryView.addressOptionViews else { return true }
        
        var selected = false
        for optionView in optionViews {
            if optionView.selected {
                selected = true
                break
            }
        }
        return selected
    }
}

class CheckoutDeliveryView: UIView {
    static let buttonHeight: CGFloat = 52.0
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let nextButton = UIButton()
    
    var contentValidators: [ContentValidator] = []
    let keyboardHelper = KeyboardHelper()
    
    private(set) var addressInput: AddressInput
    
    var addressOptionViews: [CheckoutDeliveryAddressOptionView]?
    var selectedAddressIndex: Int! {
        didSet {
            guard case .Options = addressInput else { return }
            updateAddressOptions(selectedIndex: selectedAddressIndex)
        }
    }
    
    weak var delegate: CheckoutDeliveryViewDelegate?
    
    init(addressInput: AddressInput, delivery: Delivery, didAddAddress: Bool) {
        self.addressInput = addressInput
        super.init(frame: CGRectZero)
        
        addValidator(CheckoutValidator())
        
        keyboardHelper.delegate = self
        
        if case .Options = addressInput {
            addressOptionViews = [CheckoutDeliveryAddressOptionView]()
            selectedAddressIndex = 0
        }
        
        backgroundColor = UIColor(named: .White)
        
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)
        
        stackView.axis = .Vertical
        updateStackView(addressInput, delivery: delivery, didAddAddress: didAddAddress)
        scrollView.addSubview(stackView)
        
        nextButton.setTitle(tr(.CheckoutDeliveryNext), forState: .Normal)
        nextButton.addTarget(self, action: #selector(CheckoutDeliveryView.didTapNextButton), forControlEvents: .TouchUpInside)
        nextButton.applyBlueStyle()
        addSubview(nextButton)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CheckoutDeliveryView.dismissKeyboard))
        scrollView.addGestureRecognizer(tap)
        
        configureCustomCostraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCustomCostraints() {
        scrollView.snp_makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        stackView.snp_makeConstraints { make in
            make.edges.equalTo(scrollView.snp_edges).inset(UIEdgeInsetsMake(0, Dimensions.defaultMargin, 0, Dimensions.defaultMargin))
            make.width.equalTo(self).offset(-2 * Dimensions.defaultMargin)
        }
        
        nextButton.snp_makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(scrollView.snp_bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(CheckoutDeliveryView.buttonHeight)
        }
    }
    
    func registerOnKeyboardEvent() {
        keyboardHelper.register()
    }
    
    func unregisterOnKeyboardEvent() {
        keyboardHelper.unregister()
    }
    
    func updateStackView(addressInput: AddressInput, delivery: Delivery, didAddAddress: Bool) {
        addressOptionViews?.removeAll()
        contentValidators.removeAll()
        contentValidators.append(self)
        
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        stackView.addArrangedSubview(CheckoutDeliveryInfoHeaderView(delivery: .Courier))
        
        switch addressInput {
        case .Form(let fields):
            for (index, field) in fields.enumerate() {
                let inputView = CheckoutDeliveryInputView(addressField: field)
                inputView.inputTextField.tag = index
                inputView.inputTextField.returnKeyType = index == (fields.count - 1) ? .Done : .Next
                inputView.inputTextField.keyboardType = field.keyboardType
                inputView.inputTextField.delegate = self
                contentValidators.append(inputView)
                stackView.addArrangedSubview(inputView)
            }
            
        case .Options(let addresses):
            stackView.addArrangedSubview(CheckoutDeliveryLabelView(text: tr(.CheckoutDeliveryAdressHeader)))
            
            for address in addresses {
                let addressOptionView = CheckoutDeliveryAddressOptionView(address: stringFromAddressFormFields(address), selected: false)
                addressOptionView.deliveryView = self
                stackView.addArrangedSubview(addressOptionView)
                addressOptionViews?.append(addressOptionView)
            }
            
            let editButtonView = CheckoutDeliveryEditButtonView(editingType: (didAddAddress ? .Edit : .Add))
            editButtonView.deliveryView = self
            stackView.addArrangedSubview(editButtonView)
            
            updateAddressOptions(selectedIndex: selectedAddressIndex)
        }
        
        stackView.addArrangedSubview(CheckoutDeliveryLabelView(text: tr(.CheckoutDeliveryDeliveryHeader)))
        
        let deliveryDetailsView = CheckoutDeliveryDetailsView(delivery: delivery)
        deliveryDetailsView.deliveryView = self
        stackView.addArrangedSubview(deliveryDetailsView)
    }
    
    func updateAddressOptions(selectedIndex selectedIndex: Int) {
        guard case .Options = addressInput else { return }
        for (index, addressOptionView) in addressOptionViews!.enumerate() {
            addressOptionView.selected = (index == selectedIndex)
        }
    }
    
    func didTapAddressOptionView(addressOptionView: CheckoutDeliveryAddressOptionView) {
        selectedAddressIndex = addressOptionViews?.indexOf(addressOptionView)
        delegate?.checkoutDeliveryViewDidSelectAddress(self, atIndex: selectedAddressIndex)
    }
    
    func dataSourceDidTapAddAddressButton() {
        delegate?.checkoutDeliveryViewDidTapAddAddressButton(self)
    }
    
    func dataSourceDidTapEditAddressButton() {
        delegate?.checkoutDeliveryViewDidTapEditAddressButton(self)
    }
    
    func dataSourceDidTapChooseKioskButton() {
        delegate?.checkoutDeliveryViewDidTapChooseKioskButton(self)
    }
    
    func dataSourceDidTapChangeKioskButton() {
        delegate?.checkoutDeliveryViewDidTapChangeKioskButton(self)
    }
    
    func didTapNextButton() {
        delegate?.checkoutDeliveryViewDidTapNextButton(self)
    }
    
    func dismissKeyboard() {
        endEditing(true)
    }
    
    func stringFromAddressFormFields(formFields: [AddressFormField]) -> String {
        var string = ""
        for addressField in formFields {
            switch addressField {
            case .FirstName(let value?): string += value + " "
            case .LastName(let value?): string += value + "\n"
            case .StreetAndApartmentNumbers(let value?): string += tr(.CheckoutDeliveryAdressStreet) + " " + value + "\n"
            case .PostalCode(let value?): string += value + " "
            case .City(let value?): string += value + "\n"
            case .Phone(let value?): string += tr(.CheckoutDeliveryAdressPhoneNumber) + " " + value
            default: break
            }
        }
        return string
    }
}

extension CheckoutDeliveryView: ContentValidator {
    func getValue() -> AnyObject? {
        return self
    }
    func showError(error: String) { }
    func hideError() { }
}

extension CheckoutDeliveryView: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return handleTextFieldReturn(textField)
    }
}

extension CheckoutDeliveryView: FormView {
    func onFormReachedEnd() {
        dismissKeyboard()
    }
}

extension CheckoutDeliveryView: KeyboardHelperDelegate, KeyboardHandler {
    func keyboardHelperChangedKeyboardState(fromFrame: CGRect, toFrame: CGRect, duration: Double, animationOptions: UIViewAnimationOptions) {
        let bottomOffset = keyboardHelper.retrieveBottomMargin(self, keyboardToFrame: toFrame) - nextButton.bounds.height
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, max(bottomOffset, 0), 0)
    }
}