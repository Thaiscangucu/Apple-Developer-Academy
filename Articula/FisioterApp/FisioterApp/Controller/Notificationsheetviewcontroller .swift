import UIKit
import UserNotifications

class NotificationSheetViewController: UIViewController {
    
    var notificationTitle: String = "FisioterApp"
    var notificationSubtitle: String = "Hora do seu exercício!"

    // Views
    private let subtitleView = SubtitleView()
    private let notificationToggle = NotificationToggleView()
    private let timePicker = TimePickerView()
    private let frequencyView = FrequencyView()
    private let confirmView = ConfirmView()

    private let blur: UIVisualEffectView = {
            let effect = UIBlurEffect(style: .systemThinMaterial)
            let view = UIVisualEffectView(effect: effect)
            view.isUserInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupLayout()
        setupSheetPresentation()
        setupActions()
        
        notificationToggle.toggleSwitch.isOn = true
        notificationToggle.syncGradient()
        updateControlsState()
    }
    
    

    private func setupLayout() {
        view.addSubview(subtitleView)
        view.addSubview(notificationToggle)
        view.addSubview(timePicker)
        view.addSubview(frequencyView)
        view.addSubview(confirmView)
       
        blur.alpha = 0.99
                view.insertSubview(blur, at: 0)
                
            NSLayoutConstraint.activate([
                    blur.topAnchor.constraint(equalTo: view.topAnchor),
                    blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    blur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        notificationToggle.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        frequencyView.translatesAutoresizingMaskIntoConstraints = false
        confirmView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            
            // Subtitle
                subtitleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 166),
                subtitleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 61),
                subtitleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

                // Toggle
                notificationToggle.topAnchor.constraint(equalTo: subtitleView.bottomAnchor, constant: 20),
                notificationToggle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 61),
                notificationToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
                notificationToggle.heightAnchor.constraint(equalToConstant: 50),

                // Time Picker (bem próximo)
                timePicker.topAnchor.constraint(equalTo: notificationToggle.bottomAnchor, constant: 8),
                timePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 61),
                timePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
                timePicker.heightAnchor.constraint(equalToConstant: 50),

                // Frequency (um pouco mais separado)
                frequencyView.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 16),
                frequencyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 61),
                frequencyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
                frequencyView.heightAnchor.constraint(equalToConstant: 80),

                // Confirm (bem destacado)
                confirmView.topAnchor.constraint(equalTo: frequencyView.bottomAnchor, constant: 65),
                confirmView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 61),
                confirmView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
                confirmView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func setupSheetPresentation() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }

    private func setupActions() {
        notificationToggle.toggleSwitch.addTarget(
            self,
            action: #selector(toggleChanged(_:)),
            for: .valueChanged
        )
        
        confirmView.confirmButton.addTarget(
            self,
            action: #selector(confirmTapped),
            for: .touchUpInside
        )
        
        confirmView.deleteButton.addTarget(
            self,
            action: #selector(cancelTapped),
            for: .touchUpInside
        )
    }

    @objc private func toggleChanged(_ sender: UISwitch) {
        updateControlsState()
    }

    private func updateControlsState() {
        let isOn = notificationToggle.toggleSwitch.isOn
        
        timePicker.alpha = isOn ? 1.0 : 0.4
        frequencyView.alpha = isOn ? 1.0 : 0.4
        
        timePicker.isUserInteractionEnabled = isOn
        frequencyView.isUserInteractionEnabled = isOn
        
        confirmView.confirmButton.backgroundColor = isOn ? .systemBlue : .gray
    }

    @objc private func confirmTapped() {
        let isOn = notificationToggle.toggleSwitch.isOn
        let selectedTime = timePicker.datePicker.date
        let selectedDays = frequencyView.selectedDays
        let selectedIdxs = frequencyView.selectedIndexes

        if isOn {
            guard !selectedDays.isEmpty else {
                showAlert(message: "Selecione ao menos um dia da semana.")
                return
            }
            
            requestPermission { [weak self] granted in
                guard let self else { return }
                
                if granted {
                    self.scheduleNotifications(time: selectedTime, weekdayIndexes: selectedIdxs)
                    self.saveAndDismiss(isOn: true, time: selectedTime, days: selectedDays)
                } else {
                    self.showAlert(message: "Permissão negada. Ative nas Configurações.")
                }
            }
        } else {
            cancelAllNotifications()
            saveAndDismiss(isOn: false, time: selectedTime, days: selectedDays)
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    private func saveAndDismiss(isOn: Bool, time: Date, days: [String]) {
        dismiss(animated: true)
    }

    //Notifications
    private func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
    }

    private func scheduleNotifications(time: Date, weekdayIndexes: [Int]) {
        cancelAllNotifications()

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        for index in weekdayIndexes {
            let content = UNMutableNotificationContent()
            content.title = notificationTitle
            content.subtitle = notificationSubtitle
            content.sound = .default

            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            components.weekday = index + 1

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let request = UNNotificationRequest(
                identifier: notificationIdentifier(for: index),
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }
    }

    private func cancelAllNotifications() {
        let ids = (0..<7).map { notificationIdentifier(for: $0) }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func notificationIdentifier(for weekdayIndex: Int) -> String {
        return "fisioterapp.exercicio1.weekday.\(weekdayIndex)"
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

#Preview {
    NotificationSheetViewController()
}
