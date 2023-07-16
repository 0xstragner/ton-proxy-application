# ton-proxy-application

The iOS application that utilizes [0xstragner/ton-proxy-swift](https://github.com/0xstragner/ton-proxy-swift)

| NetworkExtension                                                                                                                                                 | WKWebView                                                                                                                                                        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <img width="242" alt="image" src="https://github.com/0xstragner/ton-proxy-application/blob/15419c467f14c4049e658ac02826a5527616370f/Screenshots/0.PNG?raw=true"> | <img width="242" alt="image" src="https://github.com/0xstragner/ton-proxy-application/blob/15419c467f14c4049e658ac02826a5527616370f/Screenshots/1.PNG?raw=true"> |

## Run

1. Open `Tonproxy.xcproject`
2. Replace content of `SharedPackage/Configuration-Debug.xcconfig` &`SharedPackage/Configuration-Release.xcconfig` with your code signing details.
3. Press `CMD+R`

> NOTE: Simulators are not supported.

## Details

Since Apple restricts the use of proxies inside WKWebView in a legal way, I have implemented a small workaround (hack) for it.

## Authors

- adam@stragner.com / stragner.ton
