//
//  APIManager.swift
//  IOS-App
//
//  Created by SDC-USER on 08/01/26.
//
import Foundation

class APIManager {
    static func sendLocation(lat: Double, long: Double, completion: @escaping (Bool) -> Void) {

        let url = URL(string: "https://your-backend.com/api/updateLocation")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = [
            "latitude": lat,
            "longitude": long,
            "patientID": "12345"
        ] as [String : Any]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { completion(false); return }
            completion(true)
        }.resume()
    }
}
