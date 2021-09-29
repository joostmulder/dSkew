import 'package:dskew/Models/google_news_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';
import 'package:flutter/material.dart';

class ApiService {
  static ApiService _instance = ApiService();
  static ApiService get instance => _instance;

  // static String endPoint =
  //     'https://api.serpwow.com/live/search?api_key=9C8300A47A434485A44B65C2DBD4E76C';

  static String endPoint = "http://10.10.10.119:8000/api";
  _setHeaders() => {'Accept': '*/*'};

  /***********************************************************************
   * @Desc: Get Latest News
   * @Date: 2021.5.5
   * @Auth: SoftWinner
   ********************************************************************** */
  Future<Map> getNews() async {
    String url = '$endPoint/getNews';
    var uri = Uri.parse(url);
    try {
      var response = await http.get(
        uri,
        headers: _setHeaders(),
      );

      if (response.statusCode == 200) {
        Map jsonResponse = convert.jsonDecode(response.body);
        return jsonResponse;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /***********************************************************************
   * @Desc: Search News With Topic(Query)
   * @Date: 2021.5.5
   * @Auth: SoftWinner
   ********************************************************************** */
  Future<Map> searchNews(String query) async {
    String url = '$endPoint/search';
    var uri = Uri.parse(url);
    var sendData = {"query": '$query'};
    try {
      var response = await http.post(
        uri,
        body: sendData,
        headers: _setHeaders(),
      );

      if (response.statusCode == 200) {
        Map jsonResponse = convert.jsonDecode(response.body);
        return jsonResponse;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /***********************************************************************
   * @Desc: Analyze News
   * @Date: 2021.5.5
   * @Auth: SoftWinner
   ********************************************************************** */
  Future<Map> analyze(int id, String link) async {
    var sendData;
    if (id != null) {
      // ID Data
      sendData = {"id": '$id', 'link': 'null'};
    } else {
      // Share Link Data
      sendData = {'id': 'null', 'link': '$link'};
    }

    String url = '$endPoint/analyze';
    var uri = Uri.parse(url);
    try {
      var response = await http.post(
        uri,
        body: sendData,
        headers: _setHeaders(),
      );

      if (response.statusCode == 200) {
        Map jsonResponse = convert.jsonDecode(response.body);
        return jsonResponse;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<Map> getData(String term,
      {String searchType = 'news', String timePeriod = 'last_hour'}) async {
    String url =
        '$endPoint&q=$term&search_type=$searchType&time_period=$timePeriod';
    var uri = Uri.parse(url);
    try {
      var response = await http.get(
        uri,
      );

      if (response.statusCode == 200) {
        Map jsonResponse = convert.jsonDecode(response.body);

        // List<GoogleNewsModel> _googleNewsModels = [];
        // print(jsonResponse['news_results']);

        // for (var json in jsonResponse['news_results']) {
        //   print(json);
        //   GoogleNewsModel gnModel = GoogleNewsModel.fromJson(json);
        //   _googleNewsModels.add(gnModel);
        // }

        // return _googleNewsModels;
        return jsonResponse;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<Map> getDataFromURL(String url) async {
    var uri = Uri.parse(url);

    try {
      var response = await http.get(uri, headers: _setHeaders());

      if (response.statusCode == 200) {
        Map jsonResponse = convert.jsonDecode(response.body);

        // List<GoogleNewsModel> _googleNewsModels = [];
        // print(jsonResponse['news_results']);

        // for (var json in jsonResponse['news_results']) {
        //   print(json);
        //   GoogleNewsModel gnModel = GoogleNewsModel.fromJson(json);
        //   _googleNewsModels.add(gnModel);
        // }

        // return _googleNewsModels;\
        print(jsonResponse);
        return jsonResponse;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
