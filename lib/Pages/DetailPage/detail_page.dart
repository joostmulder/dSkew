import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dskew/Helpers/index.dart';
import 'package:dskew/Models/index.dart';
import 'package:dskew/Pages/App/Styles/colors.dart';
import 'package:dskew/Pages/App/Styles/index.dart';
import 'package:dskew/Services/index.dart';
import 'package:dskew/Utility/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:html/parser.dart';
import './Styles/index.dart';
import 'package:flutter/services.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key key, this.data, this.link}) : super(key: key);

  final GoogleNewsModel data;
  final String link;
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  DetailPageColors pageColors = new DetailPageColors();
  DetailPageStrings pageStrings = new DetailPageStrings();
  DetailPageStyles pageStyles = new DetailPageStyles();

  AppColors appColors = new AppColors();
  AppStyles appStyles = new AppStyles();
  final apiServiceInstance = ApiService.instance;

  // Gloabal key for progress dialog
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

// Custom Toast
  CustomToast cToast = new CustomToast();

// WebView Loading Vars
  bool _loading = false;
  double _progressValue;

  // isShare
  bool isShare = false;
  int id;
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    setState(() {
      isShare = (widget.link != null) ? true : false;
      _loading = false;
      _progressValue = 0.0;
      id = (isShare) ? 0 : widget.data.id;
    });
  }

  // ========================= Analyze ================
  Future<void> analyze(WebViewController controller) async {
    //------------ Show Progress Dialog -------------------------
    if (appStyles.darkTheme) {
      Dialogs.showLoadingDarkDialog(context, _keyLoader, "Please wait...");
    } else {
      Dialogs.showLoadingDialog(context, _keyLoader, "Please wait...");
    }
    Map response = await apiServiceInstance.analyze(
      (!isShare) ? id : null,
      (isShare) ? widget.link : null,
    );

    //------------ Dismiss Porgress Dialog  -------------------
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

    // Get Request is success
    if (response != null) {
      // if Correct Data
      if (response['status'] == 200) {
        var fieldsJson = (response['similarNews'] != null)
            ? response['similarNews'] as List
            : [];

        // if there are some data in response
        if (fieldsJson.length > 0) {
          List<GoogleNewsModel> similarNews =
              fieldsJson.map((json) => GoogleNewsModel.fromJson(json)).toList();

          // Show Similar News Bottom Sheet
          _similarNewsDialog(context, similarNews, controller);
        } else {
          // if ther is no any data  in response
          cToast.errorAlert(context, pageStrings.noDataError);
        }
      } else {
        print(response['message']);

        cToast.errorAlert(context, response['message']);
      }
    } else {
      cToast.errorAlert(context, pageStrings.serverError);
      ;
    }
  }

//------------------------ END ANALYZE -------------------

//----------------------- NAVIGATION URL -----------------
  void _onNavigationDelegate(
      WebViewController controller, BuildContext context, String url) async {
    await controller.loadUrl(url);
  }

  //-------------------- END NAVIGATION URL ---------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageStrings.title),
        centerTitle: true,
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        // actions: <Widget>[
        //   NavigationControls(_controller.future),
        //   SampleMenu(_controller.future),
        // ],
      ),
      body: Builder(builder: (BuildContext context) {
        return Container(
          // color: Theme.of(context).primaryColor,
          child: Column(
            children: <Widget>[
              (_loading)
                  ? LinearProgressIndicator(
                      value: _progressValue,
                      minHeight: 5,
                    )
                  : Container(),
              Expanded(
                child: WebView(
                  initialUrl: (isShare) ? widget.link : widget.data.link,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
                  },
                  onProgress: (int progress) {
                    print("WebView is loading (progress : $progress%)");
                    if (progress < 100) {
                      setState(() {
                        _loading = true;
                        _progressValue = progress / 100;
                      });
                    } else {
                      setState(() {
                        _loading = false;
                        _progressValue = 0.0;
                      });
                    }
                  },
                  javascriptChannels: <JavascriptChannel>{
                    _toasterJavascriptChannel(context),
                  },
                  navigationDelegate: (NavigationRequest request) {
                    // if (request.url.startsWith('https://www.youtube.com/')) {
                    //   print('blocking navigation to $request}');
                    //   return NavigationDecision.prevent;
                    // }
                    // print('allowing navigation to $request');
                    // return NavigationDecision.navigate;
                    print("Navigation");
                    return NavigationDecision.prevent;
                  },
                  onPageStarted: (String url) {
                    // Dialogs.showProgressBarDialog(
                    //     context, _keyLoader, "Please wait...");
                    print('Page started loading: $url');
                  },
                  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                    setState(() {
                      _loading = false;
                      _progressValue = 0.0;
                    });
                  },
                  gestureNavigationEnabled: true,
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: (!_loading) ? analyzeButton() : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  Widget analyzeButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              // foregroundColor: Colors.white,
              onPressed: () async {
                await analyze(controller.data);
              },
              icon: Icon(Icons.search),
              label: Text(pageStrings.analyzeBtn),
            );
          }
          return Container();
        });
  }

/************************** BOTTOM DIALOG SHEET ************ */
  void _similarNewsDialog(BuildContext context, List<GoogleNewsModel> news,
      WebViewController controller) {
    showModalBottomSheet(
      enableDrag: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
                color: (appStyles.darkTheme)
                    ? appColors.backgroundColorDark
                    : appColors.backgroundColor,
              ),
              child: ListView.separated(
                separatorBuilder: (BuildContext bc, int index) => Divider(
                  color: pageColors.listDividColor,
                ),
                itemBuilder: (c, i) => ListTile(
                  leading: (news[i].imageType != null)
                      ? CircleAvatar(
                          radius: 30.0,
                          backgroundImage: (news[i].imageType)
                              ? NetworkImage(news[i].imageURL)
                              : MemoryImage(news[i].image),
                          backgroundColor: Colors.transparent,
                        )
                      : CircleAvatar(
                          radius: 30.0,
                          backgroundImage: AssetImage(pageStrings.defaultImg),
                          backgroundColor: Colors.transparent,
                        ),
                  title: Column(
                    children: <Widget>[
                      Text(
                        news[i].topic,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                'by ',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              Text(
                                news[i].source,
                                style: pageStyles.sourceTxt,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                DskewFont.clock_1,
                                color: pageColors.dateColor,
                                size: 14,
                              ),
                              Text(
                                ' ${news[i].pushDate}',
                                style: pageStyles.dateTxt,
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  subtitle: Text(
                    '\n${news[i].summary}',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  // trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    isShare = false;
                    id = news[i].id;
                    _onNavigationDelegate(
                      controller, context,
                      // 'https://www.scmp.com/magazines/post-magazine/food-drink/article/3131373/neapolitan-pizzaiolo-angelo-dambrosio-talks');
                      news[i].link,
                    );
                    Navigator.of(context).pop();
                  },
                ),
                // itemExtent: 100.0,
                itemCount: news.length,
              ),
            );
          },
        );
      },
    );
  }
/************************** END BOTTOM DIALOG SHEET ************ */
}
