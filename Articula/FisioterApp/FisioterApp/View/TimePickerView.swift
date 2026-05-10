import UIKit

class TimePickerView: UIView {

    let text: UILabel = {
        let label = UILabel()
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
                    .addingAttributes([
                        .traits: [UIFontDescriptor.TraitKey.width: 0.5]
                    ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        label.text = "Horário"
        label.textColor = .darkGray
        
        return label
    }()

    var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "00:00"
        tf.textColor = .darkGray
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textAlignment = .right
        return tf
    }()

    var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .time
        dp.preferredDatePickerStyle = .wheels
        return dp
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        // Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Concluído", style: .done,
                                   target: self, action: #selector(closePicker))

        toolbar.setItems([spacer, done], animated: false)

        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar

        datePicker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)

        addSubview(text)
        addSubview(textField)

        text.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            // Label (esquerda)
            text.leadingAnchor.constraint(equalTo: leadingAnchor),
            text.centerYAnchor.constraint(equalTo: centerYAnchor),

            // TextField (direita)
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: 80),

            // Altura da view
            heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func pickerChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        textField.text = formatter.string(from: sender.date)
    }

    @objc private func closePicker() {
        textField.resignFirstResponder()
    }
}

#Preview{
    TimePickerView()
}
