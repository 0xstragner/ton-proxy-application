# tonproxy

The iOS application that utilizes [0xstragner/ton-proxy-swift](https://github.com/0xstragner/ton-proxy-swift)

- WKWebView
- NetworkExtension

## Run

1. Open `Tonproxy.xcproject`
2. Replace content of `SharedPackage/Configuration-Debug.xcconfig` &`SharedPackage/Configuration-Release.xcconfig` with your code signing details.
3. Press `CMD+R`

> NOTE: Simulators are not supported.

## Details

Since Apple restricts the use of proxies inside WKWebView in a legal way, I have implemented a small workaround (hack) for it.

## Authors

- adam@stragner.com / stragner.ton
