//
//  CounterViewController.swift
//  ViewcodeAtividade
//
//  Created by Diego Saragoza Da Silva on 20/03/26.
//

import UIKit
import CoreMotion


class ExerciseViewController: UIViewController {
    
    let popUp: ExercisePopUp = {
        let view = ExercisePopUp()
        return view
    }()
    
    let popUp2: FeedbackView = {
        let view = FeedbackView()
        return view
    }()
    
    let exerciseView: ExerciseView = {
        let view = ExerciseView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let motion = CMMotionManager()
    let queue = OperationQueue()
    let generator = UINotificationFeedbackGenerator()
    
    var movimento: [Int] = []
    var exerciseTimer = ExerciseTimer()
    var viewModel: CoreDataViewModel =  CoreDataViewModel()
    
    var isCorrect: Bool = false {
        didSet {
            view.backgroundColor = isCorrect ? .systemGreen : .white
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exerciseTimer.startTimer()
        setUpController()
        viewDidAppear(true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        exerciseView.counter.counter = 0
        generator.prepare()
        setUpController()
    }
    
    
    private func setUpController() {
        view.backgroundColor = .white
        generator.prepare()
        accelerometer()
        
        title = "Exercício 1"
        configureNavigationBarAppearance()
                
        // Add subchilds
        view.addSubview(exerciseView)
        addChildController(popUp, frame: view.bounds.insetBy(dx: 10, dy: 150))
        
        

        
        //Create the constraints
        NSLayoutConstraint.activate([
            exerciseView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exerciseView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func increment() {
        exerciseView.counter.counter += 1
    }
    
    private func accelerometer(){
        print("Acelerometro rodando")
        motion.accelerometerUpdateInterval = 0.02
        motion.startAccelerometerUpdates(to: .main) { (data, error) in
            self.checkCircle()
            if let trueData = data {
                
                // Move the image based on acceleration
                self.updateCircleYPos(data: trueData)
            }
        }
    }
    
    func updateCircleYPos(data: CMAccelerometerData) {
        var newY = self.exerciseView.circle.center.y
        newY -= CGFloat(data.acceleration.y * 12)
        newY = max(-100, min(newY, 140))
        self.exerciseView.circle.center.y = newY
    }
    
    private func checkCircle(){
        
        if self.exerciseView.circle.center.y < -95{
            self.movimento.append(1)
        }
        if self.exerciseView.circle.center.y > 135{
            self.movimento.append(2)
        }
        
        // Se existe a sequencia 1 e 2 no vetor de movimento, incrementa as repetições
        if self.movimento.firstIndex(of: [1, 2]) != nil {
            self.movimento.removeAll()
            self.increment()
            
            generator.notificationOccurred(.success)
            UIView.animate(withDuration: 0.2) {
                self.view.backgroundColor = .green
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 0.2) {
                    self.view.backgroundColor = .white
                }
            }
        }
        
        //Se chegar no objetivo de repetições para o acelerometro e o timer
        if self.exerciseView.counter.counter == 5{
            
            //Para os timers e o sensor
            self.exerciseTimer.stopTimer()
            if self.motion.isAccelerometerActive {
                self.motion.stopAccelerometerUpdates()
                print("Acelerometetro parado!")
            }
        
            let duration = "\(self.exerciseTimer.minutos):\(self.exerciseTimer.segundos)"
    
            viewModel.createReport(autonomy: "", completed: "Sim", difficulty: "", duration: duration, painRate: 0, dateCreate: Date.now, datePeriod1: Date.now, datePeriod2: Date.now)
            viewModel.getReport()
            
//            self.showSheet()
            addChildController(popUp2, frame: view.bounds.insetBy(dx: 30, dy: 110))
            

        }
    }
    
    
    @objc func showSheet() {
        let vc = ExerciseFeedbackView()
        
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        present(vc, animated: true)
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.gray,
            .font: UIFont(descriptor: descriptor, size: 15)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
    }
    
}

#Preview {
    let counterVC = ExerciseViewController()
    return counterVC.view
}
