//
//  File.swift
//  
//
//  Created by lei on 2024/1/13.
//

import Foundation
import Combine

let url = "https://www2.deepl.com/jsonrpc"

struct Lang: Codable {
    let sourceLangUserSelected: String
    let targetLang: String
    
    private enum CodingKeys : String, CodingKey {
        case sourceLangUserSelected = "source_lang_user_selected"
        case targetLang = "target_lang"
    }
}

struct CommonJobParams: Codable {
    let wasSpoken: Bool
    let transcribeAS: String
    // let regionalVariant: String  // Commented out as in the original code
    
    private enum CodingKeys : String, CodingKey {
        case transcribeAS = "transcribe_as"
        case wasSpoken = "wasSpoken"
    }
}

struct Params: Codable {
    var texts: [Text]
    let splitting: String
    let lang: Lang
    var timestamp: Int64
    let commonJobParams: CommonJobParams
}

struct Text: Codable {
    let text: String
    let requestAlternatives: Int
}

struct PostData: Codable {
    let jsonrpc: String
    let method: String
    var id: Int64
    var params: Params
}

func getICount(translateText: String) -> Int64 {
    return Int64(translateText.filter { $0 == "i" }.count)
}

func getRandomNumber() -> Int64 {
    let random = Int64.random(in: 0...99999) + 8300000  // Use Swift's random number generation
    return random * 1000
}

func getTimeStamp(iCount: Int64) -> Int64 {
    let ts = Int64(Date().timeIntervalSince1970 * 1000)  // Milliseconds since epoch
    if iCount != 0 {
        return ts - (ts % (iCount + 1)) + (iCount + 1)
    } else {
        return ts
    }
}

func initData(sourceLang: String, targetLang: String) -> PostData {
    return PostData(
        jsonrpc: "2.0",
        method: "LMT_handle_texts",
        id:0,
        params: Params(
            texts: [],
            splitting: "newlines",
            lang: Lang(
                sourceLangUserSelected: sourceLang,
                targetLang: targetLang
            ),
            timestamp: Int64(Date().timeIntervalSince1970),
            commonJobParams: CommonJobParams(
                wasSpoken: false,
                transcribeAS: ""
                // regionalVariant: "en-US"  // Commented out as in the original code
            )  // Added empty texts array
        )
    )
}


var id = getRandomNumber()

let encoder = JSONEncoder()

var getRequest = { (text:Text, postData: PostData) -> URLRequest  in
    let postByte = try encoder.encode(postData)
    var postStr = String(data: postByte, encoding: String.Encoding.utf8)

    if (id+5)%29 == 0 || (id+3)%13 == 0 {
        postStr = postStr?.replacingOccurrences(of: "\"method\":\"", with: "\"method\" : \"")
    } else {
        postStr = postStr?.replacingOccurrences(of: "\"method\":\"", with: "\"method\": \"")
    }
    
    let jsonData =  postStr?.data(using: String.Encoding.utf8)
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "POST"

    request.httpBody = jsonData
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("*/*", forHTTPHeaderField: "Accept")
    request.setValue("iOS", forHTTPHeaderField: "x-app-os-name")
    request.setValue("16.3.0", forHTTPHeaderField: "x-app-os-version")
    request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.setValue("iPhone13,2", forHTTPHeaderField: "x-app-device")
    request.setValue("DeepL-iOS/2.9.1 iOS 16.3.0 (iPhone13,2)", forHTTPHeaderField: "User-Agent")
    request.setValue("510265", forHTTPHeaderField: "x-app-build")
    request.setValue("2.9.1", forHTTPHeaderField: "x-app-version")
    request.setValue("keep-alive", forHTTPHeaderField: "Connection")
    return request
}


public func translate(translateText: String, source:String, target:String, alternatives:Int = 1, completionHandler:  ( (_ result:[String:Any]?, _ error:Error?)->Void )?)  {
    
    id = id + 1
    
    let text = Text(text: translateText, requestAlternatives: 1)
    var postData = initData(sourceLang: source.uppercased(), targetLang: target.uppercased())

    postData.id = id
    postData.params.texts.append(text)
    postData.params.timestamp = getTimeStamp(iCount: getICount(translateText: translateText))
    let request : URLRequest
    
    do {
        request = try getRequest(text, postData)
    } catch let error {
        completionHandler?(nil, error)
        return;
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            completionHandler?(nil, error)
            return
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("Invalid response")
            completionHandler?(nil, nil)
            return
        }
        
        if let data = data {
            do {
                // Parse JSON data, for example
                let parsedData = try JSONSerialization.jsonObject(with: data)
                guard let jsonMap = parsedData as? [String: Any] else {
                    print("Invalid JSON format")
                    return
                }
                
                completionHandler?(jsonMap, nil)
                
            } catch {
                completionHandler?(nil, error)
            }
        }
    }
    
    task.resume()
}

@available(iOS 13.0, macOS 10.15.0, *)
public func translate(translateText: String, source:String, target:String, alternatives:Int = 1) async throws -> [String:Any]? {
    
    return try await withCheckedThrowingContinuation { continuation in
        translate(translateText: translateText, source: source, target: target, alternatives: alternatives) { result, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            
            continuation.resume(returning: result)
        }
    }
    
}
