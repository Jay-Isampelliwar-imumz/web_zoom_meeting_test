import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class ZoomWebViewMeetingPage extends StatefulWidget {
  const ZoomWebViewMeetingPage({super.key});

  @override
  State<ZoomWebViewMeetingPage> createState() => _ZoomWebViewMeetingPageState();
}

class _ZoomWebViewMeetingPageState extends State<ZoomWebViewMeetingPage> {
  late final _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('WebView is loading (progress : $progress%)');
        },
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            debugPrint('blocking navigation to ${request.url}');
            return NavigationDecision.prevent;
          }
          debugPrint('allowing navigation to ${request.url}');
          return NavigationDecision.navigate;
        },
        onUrlChange: (UrlChange change) {
          debugPrint('url change to ${change.url}');
        },
        onHttpAuthRequest: (HttpAuthRequest request) {
          openDialog(request);
        },
      ),
    )
    ..addJavaScriptChannel(
      'Toaster',
      onMessageReceived: (JavaScriptMessage message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      },
    )
    ..loadRequest(Uri.parse(
        "https://b5cc-2401-4900-4bce-6fea-48ff-97b1-7c00-8d6a.ngrok-free.app"));
  @override
  void initState() {
    super.initState();

    // late final PlatformWebViewControllerCreationParams params;
    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   params = WebKitWebViewControllerCreationParams(
    //     allowsInlineMediaPlayback: true,
    //     mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    //   );
    // } else {
    //   params = const PlatformWebViewControllerCreationParams();
    // }

    // final WebViewController controller =
    //     WebViewController.fromPlatformCreationParams(params);
// ···
    // if (controller.platform is AndroidWebViewController) {
    //   AndroidWebViewController.enableDebugging(true);
    //   (controller.platform as AndroidWebViewController)
    //       .setMediaPlaybackRequiresUserGesture(false);
    // }

//     _controller
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             debugPrint('WebView is loading (progress : $progress%)');
//           },
//           onPageStarted: (String url) {
//             debugPrint('Page started loading: $url');
//           },
//           onPageFinished: (String url) {
//             debugPrint('Page finished loading: $url');
//           },
//           onWebResourceError: (WebResourceError error) {
//             debugPrint('''
// Page resource error:
//   code: ${error.errorCode}
//   description: ${error.description}
//   errorType: ${error.errorType}
//   isForMainFrame: ${error.isForMainFrame}
//           ''');
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.startsWith('https://www.youtube.com/')) {
//               debugPrint('blocking navigation to ${request.url}');
//               return NavigationDecision.prevent;
//             }
//             debugPrint('allowing navigation to ${request.url}');
//             return NavigationDecision.navigate;
//           },
//           onUrlChange: (UrlChange change) {
//             debugPrint('url change to ${change.url}');
//           },
//           onHttpAuthRequest: (HttpAuthRequest request) {
//             openDialog(request);
//           },
//         ),
//       )
//       ..addJavaScriptChannel(
//         'Toaster',
//         onMessageReceived: (JavaScriptMessage message) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(message.message)),
//           );
//         },
//       )
//       ..loadRequest(
//           Uri.parse("https://zoom.us/wc/join/93993906817?pwd=j0Uygt"));

    requestPermissions();
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.location,
      Permission.notification,
    ].request();
    print(statuses);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }

  Future<void> openDialog(HttpAuthRequest httpRequest) async {
    final TextEditingController usernameTextController =
        TextEditingController();
    final TextEditingController passwordTextController =
        TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${httpRequest.host}: ${httpRequest.realm ?? '-'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  autofocus: true,
                  controller: usernameTextController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  controller: passwordTextController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // Explicitly cancel the request on iOS as the OS does not emit new
            // requests when a previous request is pending.
            TextButton(
              onPressed: () {
                httpRequest.onCancel();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                httpRequest.onProceed(
                  WebViewCredential(
                    user: usernameTextController.text,
                    password: passwordTextController.text,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Authenticate'),
            ),
          ],
        );
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// class ZoomMeetingScreen extends StatefulWidget {
//   final String meetingId;
//   final String meetingPassword; // Optional based on your Zoom meeting settings
//   ZoomMeetingScreen({Key? key, required this.meetingId, this.meetingPassword = ""}) : super(key: key);
//   @override
//   _ZoomMeetingScreenState createState() => _ZoomMeetingScreenState();
// }
// class _ZoomMeetingScreenState extends State<ZoomMeetingScreen> {
//   late WebViewController _controller;
//   @override
//   void initState() {
//     super.initState();
//     // Enable hybrid composition.
//     WebView.platform = SurfaceAndroidWebView();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Zoom Meeting'),
//       ),
//       body: WebView(
//         initialUrl: '',
//         javascriptMode: JavascriptMode.unrestricted,
//         onWebViewCreated: (WebViewController webViewController) {
//           _controller = webViewController;
//         },
//         onProgress: (int progress) {
//           print("WebView is loading (progress : $progress%)");
//         },
//         javascriptChannels: <JavascriptChannel>{
//           _zoomJavascriptChannel(context),
//         },
//         navigationDelegate: (NavigationRequest request) {
//           if (request.url.startsWith('https://zoom.us')) {
//             print('blocking navigation to $request}');
//             return NavigationDecision.navigate;
//           }
//           print('allowing navigation to $request');
//           return NavigationDecision.prevent;
//         },
//         onPageStarted: (String url) {
//           print('Page started loading: $url');
//         },
//         onPageFinished: (String url) {
//           print('Page finished loading: $url');
//         },
//         gestureNavigationEnabled: true,
//       ),
//     );
//   }
//   JavascriptChannel _zoomJavascriptChannel(BuildContext context) {
//     return JavascriptChannel(
//         name: 'Zoom',
//         onMessageReceived: (JavascriptMessage message) {
//           print(message.message);
//         });
//   }
// }