import CoreML
import Vision
import SwiftUI

class CoreMLViewModel {
    
    func checkImage(_ image: UIImage) -> String {
        guard let ciImage = CIImage(image: image) else {
            print("Could not convert UIImage to CIImage.")
            exit(0)
        }
        
        var classificationLabel: String = ""
        
        do {
            let config = MLModelConfiguration()
            let model = try VNCoreMLModel(for: FacialExpressions(configuration: config).model)
            
            let request = VNCoreMLRequest(model: model) { request, error in
                if let results = request.results as? [VNClassificationObservation] {
                    classificationLabel = results.first!.identifier
                } else {
                    print("Invalid Classify")
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage)
            
            try handler.perform([request])
            
        } catch {
            // something went wrong!
            print("Could not load model: \(error.localizedDescription)")
        }
        return classificationLabel
    }
}


