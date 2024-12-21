// To parse this JSON data, do
//
//     final reviewEntry = reviewEntryFromJson(jsonString);

import 'dart:convert';

List<ReviewEntry> reviewEntryFromJson(String str) => List<ReviewEntry>.from(json.decode(str).map((x) => ReviewEntry.fromJson(x)));

String reviewEntryToJson(List<ReviewEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewEntry {
    String model;
    int pk;
    Fields fields;

    ReviewEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int user;
    int product;
    DateTime time;
    String reviewText;

    Fields({
        required this.user,
        required this.product,
        required this.time,
        required this.reviewText,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        product: json["product"],
        time: DateTime.parse(json["time"]),
        reviewText: json["review_text"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "product": product,
        "time": time.toIso8601String(),
        "review_text": reviewText,
    };
}