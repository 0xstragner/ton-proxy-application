# ton-proxy-application

The iOS application that utilizes [0xstragner/ton-proxy-swift](https://github.com/0xstragner/ton-proxy-swift)

- WKWebView
- NetworkExtension

<img width="735" alt="image" src="https://user-images.githubusercontent.com/9332353/202722921-a2f7a92b-c5d8-496d-aaf2-446f01fad0ae.png">
<img width="735" alt="image" src="https://user-images.githubusercontent.com/9332353/202722921-a2f7a92b-c5d8-496d-aaf2-446f01fad0ae.png">

## Run

1. Open `Tonproxy.xcproject`
2. Replace content of `SharedPackage/Configuration-Debug.xcconfig` &`SharedPackage/Configuration-Release.xcconfig` with your code signing details.
3. Press `CMD+R`

> NOTE: Simulators are not supported.

## Details

Since Apple restricts the use of proxies inside WKWebView in a legal way, I have implemented a small workaround (hack) for it.

## Authors

- adam@stragner.com / stragner.ton
