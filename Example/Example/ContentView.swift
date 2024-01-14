//
//  ContentView.swift
//  Example
//
//  Created by lei on 2024/1/14.
//

import SwiftUI
import Deeplx

struct ContentView: View {
    
    @State var text: String = ""
    
    @State var translateResult:String = ""
    
    var body: some View {
        VStack {
            TextField("Type text", text: $text)
            Button("Translate") {
                print(text)
                
                translateResult = ""
                
                translate(translateText: text, source: "en", target: "fr") { result, error in
                    print(error)
                    print(result)
                    
                    guard let result = result else {
                        return
                    }
                     
                    guard var resultInfo = result["result"] as? [String:Any],
                            let resultTexts = resultInfo["texts"] as? [[String:Any]],
                            var resultText = (resultTexts.first)?["text"] as? String else {
                        return
                    }
                    
                    print(resultText)
                    translateResult = resultText 
                }
            }
            
            Text(translateResult)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
