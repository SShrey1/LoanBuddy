//
//  OCRHelper.swift
//  LoanBuddy
//
//  Created by user@59 on 18/03/2025.
//

import Foundation
import Alamofire

struct GoogleCloudVisionResponse: Codable {
    let responses: [VisionResponse]
}

struct VisionResponse: Codable {
    let fullTextAnnotation: FullTextAnnotation?
}

struct FullTextAnnotation: Codable {
    let text: String?
}

func extractTextFromImage(imageData: Data, completion: @escaping (String?) -> Void) {
    let apiKey = "AIzaSyDArEKryFDsTm5ARUOyY4pn2wv8fzgt2GI"
    let url = "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"
    
    let base64Image = imageData.base64EncodedString()
    let parameters: [String: Any] = [
        "requests": [
            "image": [
                "content": base64Image
            ],
            "features": [
                [
                    "type": "TEXT_DETECTION"
                ]
            ]
        ]
    ]
    
    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: GoogleCloudVisionResponse.self) { response in
        switch response.result {
        case .success(let visionResponse):
            let extractedText = visionResponse.responses.first?.fullTextAnnotation?.text
            completion(extractedText)
        case .failure(let error):
            print("Error extracting text: \(error)")
            completion(nil)
        }
    }
}

func extractDetailsFromText(text: String) -> ExtractedDetails {
    // Extract Name (for Aadhaar)
    let nameRegex = "(?i)name\\s*[:\\-]?\\s*([A-Za-z\\s]+)"
    let name = text.matches(for: nameRegex).first
    
    // Extract DOB (for Aadhaar and PAN)
    let dobRegex = "(\\d{2}/\\d{2}/\\d{4})|(\\d{2}-\\d{2}-\\d{4})"
    let dob = text.matches(for: dobRegex).first
    
    // Extract Income (for Income Proof)
    let incomeRegex = "(?i)(income|salary)\\s*[:\\-]?\\s*(\\d+,?\\d+)"
    let income = text.matches(for: incomeRegex).first
    
    // Extract Employment Type (for Income Proof)
    let employmentRegex = "(?i)(employment\\s*type|job\\s*type)\\s*[:\\-]?\\s*([A-Za-z\\s]+)"
    let employmentType = text.matches(for: employmentRegex).first
    
    return ExtractedDetails(
        name: name,
        dob: dob,
        income: income,
        employmentType: employmentType
    )
}

extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch {
            print("Invalid regex: \(error)")
            return []
        }
    }
}
