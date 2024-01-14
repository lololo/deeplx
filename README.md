
# DeepLX Swift

Swift package for unlimited DeepL translation


## Related Project
[OwO-Network/DeepLX](https://github.com/OwO-Network/DeepLX): Permanently free DeepL API written in Golang.


## Integration

### Swift Package Manager
You can use The Swift Package Manager to install SwiftyJSON by adding the proper description to your Package.swift file:
```swift
// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "(https://github.com/lololo/deeplx.git)", from: "1.0.0"),
    ]
)
```


## Usage

imoprt package
``` swift
import Deeplx
```


``` swift
 translate(translateText: "Hello World", source: "en", target: "fr") { result, error in
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
                }
```

Output

``` swift
["id": 8358676001, "result": {
    detectedLanguages =     {
        BG = "0.000753";
        CS = "0.012803";
        DA = "0.01073";
        DE = "0.023874";
        EL = "0.000895";
        EN = "0.161438";
        ES = "0.041793";
        ET = "0.018925";
        FI = "0.009996999999999999";
        FR = "0.013077";
        HU = "0.0057469999999999999";
        ID = "0.007049";
        IT = "0.102223";
        JA = "0.003075";
        KO = "0.001235";
        LT = "0.004771";
        LV = "0.004285";
        NB = "0.046237";
        NL = "0.032621";
        PL = "0.009514";
        PT = "0.015116";
        RO = "0.0060019999999999999";
        RU = "0.0008749999999999999";
        SK = "0.014391999999999999";
        SL = "0.003932";
        SV = "0.008517";
        TR = "0.002515";
        UK = "0.000672";
        ZH = "0.008598";
        unsupported = "0.42834";
    };
    lang = EN;
    "lang_is_confident" = 0;
    texts =     (
                {
            alternatives =             (
                                {
                    text = "Hello World";
                }
            );
            text = "Bonjour le monde";
        }
    );
}, "jsonrpc": 2.0]
```