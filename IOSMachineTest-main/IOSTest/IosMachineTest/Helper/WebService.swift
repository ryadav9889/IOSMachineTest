//
//  WebService.swift

import Foundation
import UIKit
//import SwiftyJSON

enum NetworkError: String, Error {
    case decodingError = "Server not found. Please try again later."
    case domainError = "Server Not Found!"
    case urlError = ""
    case networkError = "You have a poor network connection. Please reconnect & try again later."
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}


struct Resource<T: Codable> {
    let url: URL
    var httpMethods: HttpMethod = .post//.get
    var body: [String: Any]?
}

extension Resource {
    init(url: URL) {
        self.url = url
    }
}



class WebService {
    

    func load<T>(resource: Resource<T>, image: UIImage? = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        // Create the request
        var request = URLRequest(url: resource.url)
        request.httpMethod = resource.httpMethods.rawValue
        
        // Set the content type to "multipart/form-data"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Construct the form-data body
        var httpBody = Data()
        
        // Append the form fields from the body dictionary
        if let body = resource.body {
            for (key, value) in body {
                httpBody.append("--\(boundary)\r\n")
                httpBody.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                httpBody.append("\(value)\r\n")
            }
        }
        
        // Append the image data if an image is provided
        if let image = image {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                httpBody.append("--\(boundary)\r\n")
                httpBody.append("Content-Disposition: form-data; name=\"user_image\"; filename=\"image.jpg\"\r\n")
                httpBody.append("Content-Type: image/jpeg\r\n\r\n")
                httpBody.append(imageData)
                httpBody.append("\r\n")
            }
        }
        
        httpBody.append("--\(boundary)--\r\n")
        request.httpBody = httpBody
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Api Name:: ", resource.url)
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(.networkError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.domainError))
                return
            }
            
            // Log the raw JSON response for debugging purposes
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }
            
            // Attempt to decode the response data into the model
            let result = try? JSONDecoder().decode(T.self, from: data)
            if let result = result {
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    // Helper function to create the body for multipart/form-data
    private func createFormDataBody(from parameters: [String: Any], boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            // Add the boundary and content disposition for the field
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            
            if let stringValue = value as? String {
                body.append("\(stringValue)\r\n")
            } else if let dataValue = value as? Data {
                body.append("\(dataValue)\r\n")
            }
        }
        
        // Add the final boundary to close the form data body
        body.append("--\(boundary)--\r\n")
        
        return body
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


struct Connectivity {
//    static let sharedInstance = NetworkReachabilityManager()
//    static var isConnectedToInternet:Bool {
//        return self.sharedInstance?.isReachable ?? false
//    }
}
