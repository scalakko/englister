import 'package:dio/dio.dart';
import 'package:englister/api/rest/response_type/get_topic_response.dart';
import 'package:englister/api/rest/response_type/send_english_response.dart';
import 'package:englister/api/rest/response_type/send_japanese_response.dart';
import 'package:englister/api/rest/response_type/translate_response.dart';
import 'package:englister/api/rest/rest_client.dart';
import 'package:englister/models/auth/AuthService.dart';
import 'package:englister/models/localstorage/LocalStorageHelper.dart';

class StudyApi {
  static Future<GetTopicResponse> getTopic() async {
    var userId = await LocalStorageHelper.getUserId();
    var studySessionId = await LocalStorageHelper.getStudySessionId();
    if (userId == null || studySessionId == null) {
      throw Exception('UserId or StudySessionId is null');
    }

    final dio = Dio(); // Provide a dio instance
    final client = RestClient(dio);
    var it = await client.getTopic({
      "data": {"userId": userId, "studySessionId": studySessionId},
      "headers": await AuthService.getHeader()
    });
    return it;
  }

  static studyStart(String categorySlug) async {
    var userId = await LocalStorageHelper.getUserId();
    if (userId == null) {
      throw Exception('UserId is null');
    }

    final dio = Dio(); // Provide a dio instance
    final client = RestClient(dio);
    var it = await client.studyStart({
      "data": {"userId": userId, "categorySlug": categorySlug},
      "headers": await AuthService.getHeader()
    });
    var studySessionId = it.studySessionId;
    if (studySessionId != null) {
      await LocalStorageHelper.saveStudySessionId(studySessionId);
    } else {
      throw Exception('StudySessionId is null');
    }
  }

  static Future<SendJapaneseResponse> sendJapanese(String japanese) async {
    var userId = await LocalStorageHelper.getUserId();
    var studySessionId = await LocalStorageHelper.getStudySessionId();
    if (userId == null || studySessionId == null) {
      throw Exception('UserId or StudySessionId is null');
    }

    final dio = Dio(); // Provide a dio instance
    final client = RestClient(dio);
    var it = await client.sendJapanese({
      "data": {
        "userId": userId,
        "studySessionId": studySessionId,
        "japanese": japanese
      },
      "headers": await AuthService.getHeader()
    });
    return it;
  }

  static Future<SendEnglishResponse> sendEnglish(String english) async {
    var userId = await LocalStorageHelper.getUserId();
    var studySessionId = await LocalStorageHelper.getStudySessionId();
    if (userId == null || studySessionId == null) {
      throw Exception('UserId or StudySessionId is null');
    }

    final dio = Dio(); // Provide a dio instance
    final client = RestClient(dio);
    var it = await client.sendEnglish({
      "data": {
        "userId": userId,
        "studySessionId": studySessionId,
        "english": english
      },
      "headers": await AuthService.getHeader()
    });
    return it;
  }

  static Future<TranslateResponse> translate(String japanese) async {
    var userId = await LocalStorageHelper.getUserId();
    var studySessionId = await LocalStorageHelper.getStudySessionId();
    if (userId == null || studySessionId == null) {
      throw Exception('UserId or StudySessionId is null');
    }

    final dio = Dio(); // Provide a dio instance
    final client = RestClient(dio);
    var it = await client.translate({
      "data": {
        "userId": userId,
        "studySessionId": studySessionId,
        "japanese": japanese
      },
      "headers": await AuthService.getHeader()
    });
    return it;
  }
}