import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'package:client/models/report.dart';
import 'package:client/hogweedgo.dart';
import 'package:client/models/user.dart';
import 'package:client/models/comment.dart';
import 'package:client/repositories/support.dart';


class ViewRepository {
  final viewController = StreamController<Report>();


  Future<void> loadView(Report view) async {
    var response = await get(Uri.parse("${HogWeedGo.server}/api/users/${view.subsID}"));
    final report = view.copyWithUser(User.fromJson(response.json()));
    final comments = report.comments;
    report.comments.clear();
    for (var comment in comments) {
      response = await get(Uri.parse("${HogWeedGo.server}/api/users/${comment.subsID}"));
      report.comments.add(comment.copyWithUser(User.fromJson(response.json())));
    }
    viewController.add(report);
  }

  Future<void> setComment(Report view, String token, Comment comment) async {
    final request = Request('POST', Uri.parse("${HogWeedGo.server}/api/comments"))
      ..body = jsonEncode(comment.toJson());
    await request.auth(token);
    final response = await request.response();
    view.comments.add(Comment.fromJson(response.json()));
    viewController.add(view);
  }

  void dispose() => viewController.close();
}
