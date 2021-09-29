import 'dart:async';

import 'package:dskew/Helpers/index.dart';
import 'package:dskew/Models/index.dart';
import 'package:dskew/Pages/App/Styles/index.dart';
import 'package:dskew/Pages/DetailPage/detail_page.dart';
import 'package:dskew/Services/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'dart:convert';
import './Styles/index.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:toast/toast.dart';
import 'dart:convert' as convert;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool load = false;
  List<GoogleNewsModel> newsData = [];
  final apiServiceInstance = ApiService.instance;
  HomePageStrings pageStrings = new HomePageStrings();
  HomePageColors pageColors = new HomePageColors();
  HomePageStyles pageStyles = new HomePageStyles();

  AppColors appColors = new AppColors();
  AppStyles appStyles = new AppStyles();
  /*****************************************************************
   * Share Content Vars
   */
  StreamSubscription _intentDataStreamSubscription;

  /************************************************************* */

  // =================== BEGIN PULL REFRESH FUNCTION PART ===================
  String term = '';
  String nextPage = '';
  String error = '';

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // Get Latest News
  void _getNews() async {
    newsData = [];
    try {
      await getNewsData(true);
      setState(() {
        load = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        error = pageStrings.connectionError;
      });
    }
  }

  // Refresh Data
  void _onRefresh() async {
    newsData = [];

    try {
      if (term != '') {
// Search News with topic(query)
        await getNewsData(false);
      } else {
        await getNewsData(true);
      }

      setState(() {
        load = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        error = pageStrings.connectionError;
      });
    }

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  // Load Pagination Data
  void _onLoading() async {
    // monitor network fetch
    try {
      // await getNewsData(nextPage);
    } catch (e) {
      print(e.toString());
    }

    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  /***************** Get New Data  ***********/
  Future<void> getNewsData(bool init) async {
    // setState(() {
    //   load = true;
    // });
    Map response;
    if (init) {
      response = await apiServiceInstance.getNews();
    } else {
      response = await apiServiceInstance.searchNews(term);
    }
    // Get Request is success
    if (response != null) {
      // if Correct Data
      if (response['status'] == 200) {
        var fieldsJson =
            (response['data'] != null) ? response['data'] as List : [];

        // if there are some data in response
        if (fieldsJson.length > 0) {
          List<GoogleNewsModel> fields =
              fieldsJson.map((json) => GoogleNewsModel.fromJson(json)).toList();
          setState(() {
            // load = false;
            newsData = fields;
            // if (response['pagination'] != null) {
            //   String next = response['pagination']['api_pagination']['next'];
            //   nextPage = next;
            // }
          });
        } else {
          // if ther is no any data  in response
          setState(() {
            error = pageStrings.noDataError;
          });
        }
      } else {
        // if Correct Data
        print(response['message']);
        setState(() {
          error = response['message'];
        });
      }
    } else {
      setState(() {
        error = pageStrings.serverError;
      });
    }
  }

  // =================== BEGIN PULL REFRESH FUNCTION PART ===================

  // =================== BEGIN SEACH BAR PART ================
  SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Container(
            //   height: 30,
            //   width: 80,
            //   decoration: BoxDecoration(
            //     image: new DecorationImage(
            //       image: new ExactAssetImage('lib/Assets/Images/icon.png'),
            //       fit: BoxFit.contain,
            //     ),
            //   ),
            // ),
            Icon(Icons.home),
            Text(' ${pageStrings.title}'),
          ],
        ),
        centerTitle: true,
        actions: [searchBar.getSearchAction(context)]);
  }

  void onSubmitted(String value) async {
    setState(() {
      load = true;
      error = '';
      term = value;
    });

    await getNewsData(false);
    setState(() {
      load = false;
    });
  }

  _HomePageState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted,
        onCleared: () {
          print("cleared");
        },
        onClosed: () {
          print("closed");
        });
  }
  // =================== END SEACH BAR PART ================

  //======== Background Gradient ===========
  List<Color> _colors = [Colors.blue, Colors.lightBlue];
  List<double> _stops = [0.0, 0.7];

  /*****************************************************************************
   * Check Url and Navigation to DetailPage
   * */
  void check(String shareURL) {
    if (shareURL != null) {
      Validator validator = new Validator();
      bool _validURL = validator.isURL(shareURL);
      if (_validURL) {
        print("Valid URL ===> $shareURL");

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailPage(
                    data: null,
                    link: shareURL,
                  )),
        );
      } else {
        ReceiveSharingIntent.reset();
        // Toast.show("Not Valid URL", context,
        //     duration: Toast.LENGTH_LONG,
        //     gravity: Toast.BOTTOM,
        //     backgroundColor: Colors.white,
        //     textColor: Colors.red);
        print("Not Valid URL ===> $shareURL");
      }
    }
  }
  /***************************************************************************** */

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    /*********************** SHARE CONTENT STREAM ******************************* */

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      check(value);
    }, onError: (err) {
      ReceiveSharingIntent.reset();
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      check(value);
    });

    /************************* END SHARE CONTENT STREAM ************************* */

    /************************* Get Latest News Data *******************/
    setState(() {
      load = true;
    });
    _getNews();

    /************************** END Get Latest News Data ********* */
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: (appStyles.darkTheme)
            ? appColors.backgroundColorDark
            : appColors.backgroundColor,
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 5,
        ),
        child: Center(
            child: (error != '')
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: pageStyles.errorTxt,
                      ),
                      ButtonTheme(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: RaisedButton(
                          onPressed: () async {
                            setState(() {
                              error = '';
                              load = true;
                            });
                            _getNews();
                          },
                          child: Text(
                            pageStrings.retryButton,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : (error == '' && load)
                    ? CircularProgressIndicator()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          (term != '')
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '"$term"',
                                      style: pageStyles.termTxt,
                                    ),
                                    Text(
                                      '  Search Result...',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                )
                              : Container(),
                          (term != '') ? Divider() : Container(),
                          Expanded(
                            child: SmartRefresher(
                              enablePullDown: false,
                              enablePullUp: true,
                              header: WaterDropHeader(),
                              footer: CustomFooter(
                                builder:
                                    (BuildContext context, LoadStatus mode) {
                                  Widget body;
                                  if (mode == LoadStatus.idle) {
                                    body = Text("pull up load");
                                  } else if (mode == LoadStatus.loading) {
                                    body = CupertinoActivityIndicator();
                                  } else if (mode == LoadStatus.failed) {
                                    body = Text("Load Failed!Please retry!");
                                  } else if (mode == LoadStatus.canLoading) {
                                    body = Text("loading more...");
                                  } else {
                                    body = Text("No more Data");
                                  }
                                  return Container(
                                    height: 55.0,
                                    child: Center(child: body),
                                  );
                                },
                              ),
                              controller: _refreshController,
                              onRefresh: _onRefresh,
                              onLoading: _onLoading,
                              child: ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        Divider(
                                  color: pageColors.listDividColor,
                                ),
                                itemBuilder: (c, i) => GestureDetector(
                                  child: ListTile(
                                    leading: (newsData[i].imageType != null)
                                        ? CircleAvatar(
                                            radius: 30.0,
                                            backgroundImage:
                                                (newsData[i].imageType)
                                                    ? NetworkImage(
                                                        newsData[i].imageURL)
                                                    : MemoryImage(
                                                        newsData[i].image),
                                            backgroundColor: Colors.transparent,
                                          )
                                        : CircleAvatar(
                                            radius: 30.0,
                                            backgroundImage: AssetImage(
                                                pageStrings.defaultImg),
                                            backgroundColor: Colors.transparent,
                                          ),
                                    title: Column(
                                      children: <Widget>[
                                        Text(
                                          newsData[i].topic,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  'by ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2,
                                                ),
                                                Text(
                                                  newsData[i].source,
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
                                                  ' ${newsData[i].pushDate}',
                                                  style: pageStyles.dateTxt,
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    subtitle: Text(
                                      '\n${newsData[i].summary}',
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                    // trailing: Icon(Icons.keyboard_arrow_right),
                                    onTap: () {
                                      print(newsData[i].link);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                                  data: newsData[i],
                                                  link: null,
                                                )),
                                      );
                                    },
                                  ),
                                  // itemExtent: 100.0,
                                ),
                                itemCount: newsData.length,
                              ),
                            ),
                          ),
                        ],
                      )),
      ),
    );
  }
}
