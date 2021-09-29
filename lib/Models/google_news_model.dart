import 'dart:math';

import 'dart:convert';

import 'dart:typed_data';

import 'package:dskew/Helpers/index.dart';

class GoogleNewsModel {
  int id;
  String topic;
  String time;
  String link;
  String source;
  String pushDate;
  String summary;
  String content;
  Uint8List image;
  String imageURL;
  String domain;
  bool imageType;

  GoogleNewsModel({
    this.id,
    this.topic,
    this.time,
    this.link,
    this.domain,
    this.source,
    this.pushDate,
    this.summary,
    this.image,
    this.imageURL,
    this.content,
    this.imageType,
  });

  GoogleNewsModel.fromJson(Map<String, dynamic> json) {
    id = (json['news_id'] != null) ? json['news_id'] : 0;
    topic = (json['news_topic'] != null) ? json['news_topic'] : "";
    time = (json['news_time'] != null) ? json['news_time'] : "";
    link = (json['news_link'] != null) ? json['news_link'] : "";
    domain = (json['news_domain'] != null) ? json['news_domain'] : "";
    source = (json['news_source'] != null) ? json['news_source'] : "";
    pushDate = (json['news_push_date'] != null) ? json['news_push_date'] : "";
    summary = (json['news_summary'] != null) ? json['news_summary'] : "";
    content = (json['news_content'] != null) ? json['news_content'] : "";

    if (json['news_image'] != null && json['news_image'] != '') {
      String str = json['news_image'];
      //Check Online Image URL
      // bool _validURL = Uri.parse(str).isAbsolute;
      Validator validator = new Validator();
      bool _validURL = validator.isURL(str);
      imageType = _validURL;
      if (_validURL) {
        imageURL = str;
      } else {
        var strArr = str.split('base64,');
        print(strArr[1]);
        // image = base64.decode(strArr[1]);
        try {
          image = base64.decode(base64.normalize(strArr[1]));
        } catch (e) {
          image = null;
        }
      }
    } else {
      imageType = null;
      image = null;
      imageURL = '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": (id == null) ? 0 : id,
      "topic": (topic == null) ? "" : topic,
      "time": (time == null) ? "" : time,
      "link": (link == null) ? "" : link,
      "domain": (domain == null) ? "" : domain,
      "source": (source == null) ? "" : source,
      "pushDate": (pushDate == null) ? "" : pushDate,
      "summary": (summary == null) ? "" : summary,
      "image": (image == null) ? null : image,
      "imageURL": (imageURL == null) ? null : imageURL,
    };
  }
}
