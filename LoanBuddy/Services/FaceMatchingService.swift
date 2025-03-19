import Vision
import AVFoundation
import UIKit

class FaceMatchingService {
    static let shared = FaceMatchingService()
    private var profileFaceObservation: VNFaceObservation?
    
    func setProfileFace(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let observations = request.results as? [VNFaceObservation],
                  let firstFace = observations.first else { return }
            
            self?.profileFaceObservation = firstFace
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    func matchFaceInVideo(url: URL, completion: @escaping (Bool) -> Void) {
        guard let profileFace = profileFaceObservation else {
            completion(false)
            return
        }
        
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        // Sample frames from the video
        let times = [CMTime(seconds: 0.5, preferredTimescale: 600)]
        
        generator.generateCGImagesAsynchronously(forTimes: times.map { NSValue(time: $0) }) { _, cgImage, _, _, _ in
            guard let cgImage = cgImage else {
                completion(false)
                return
            }
            
            let request = VNDetectFaceRectanglesRequest { request, error in
                guard let observations = request.results as? [VNFaceObservation],
                      let videoFace = observations.first else {
                    completion(false)
                    return
                }
                
                // Compare face characteristics
                let match = self.compareFaces(profileFace, videoFace)
                completion(match)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
    
    private func compareFaces(_ face1: VNFaceObservation, _ face2: VNFaceObservation) -> Bool {
        // Compare face characteristics like position, size, and orientation
        let boundingBoxSimilarity = compareBoundingBoxes(face1.boundingBox, face2.boundingBox)
        return boundingBoxSimilarity > 0.7 // Threshold for similarity
    }
    
    private func compareBoundingBoxes(_ box1: CGRect, _ box2: CGRect) -> Double {
        let intersection = box1.intersection(box2)
        let union = box1.union(box2)
        return Double(intersection.width * intersection.height) / Double(union.width * union.height)
    }
} 
