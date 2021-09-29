import 'dart:math';

import 'dart:convert';

import 'dart:typed_data';

import 'package:dskew/Models/google_news_model.dart';

class NewsModel {
  int pk;
  GoogleNewsModel fields;

  NewsModel({
    this.pk,
    this.fields,
  });

  NewsModel.fromJson(Map<String, dynamic> json) {
    pk = (json['pk'] != null) ? json['pk'] : 0;
    fields = (json['fields'] != null)
        ? GoogleNewsModel.fromJson(json['fields'])
        : "";
  }

  Map<String, dynamic> toJson() {
    return {
      "pk": (pk == null) ? 0 : pk,
      "fields": (fields == null) ? null : fields,
    };
  }
}
