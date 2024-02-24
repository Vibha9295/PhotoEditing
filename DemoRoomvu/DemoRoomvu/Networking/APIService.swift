import Foundation
import UIKit

class APIClient: NSObject, URLSessionDataDelegate {
    
    typealias ProgressHandler = (Float) -> Void
    typealias CompletionHandler = (Result<APIResponseModel, APIClientError>) -> Void
    
    private var progressHandler: ProgressHandler?
    private var session: URLSession!
    
    
    
    // MARK: - Public Methods
    
    static func uploadImage(image: UIImage, token: String, progressHandler: @escaping ProgressHandler, completion: @escaping CompletionHandler) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(.invalidImageData))
            return
        }
        
        guard let apiUrl = URL(string: "https://www.roomvu.com/api/v1/agent-dashboard/user-image/enhance") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "token")
        
        let boundary = UUID().uuidString
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let configuration = URLSessionConfiguration.default
        let apiClient = APIClient()
        apiClient.progressHandler = progressHandler
        apiClient.session = URLSession(configuration: configuration, delegate: apiClient, delegateQueue: OperationQueue.main)
        
        let task = apiClient.session.uploadTask(with: request, from: body) { (data, response, error) in
            
            // Decode API response
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(APIResponseModel.self, from: data)
                    completion(.success(apiResponse))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            } else if let error = error {
                completion(.failure(APIClientError(error: error)))
            } else {
                completion(.failure(.invalidResponse))
            }
        }
        
        // Observe the `fractionCompleted` to get progress updates
        let progressObservation = task.progress.observe(\.fractionCompleted) { (progress, _) in
            DispatchQueue.main.async {
                apiClient.progressHandler?(Float(progress.fractionCompleted))
            }
        }
        
        task.resume()
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let fractionCompleted = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            self.progressHandler?(fractionCompleted)
        }
    }
    
    deinit {
        session.invalidateAndCancel()
    }
}

