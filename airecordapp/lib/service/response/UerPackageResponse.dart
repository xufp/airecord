import '../../constant/ErrConstants.dart';

class Transcription {
  int used;
  int total;

  Transcription({
    required this.used,
    required this.total,
  });

  factory Transcription.fromJson(Map<String, dynamic> json) {
    return Transcription(
      used: json['used'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['used'] = used;
    data['total'] = total;
    return data;
  }
}

class Storage {
  int used;
  int total;

  Storage({
    required this.used,
    required this.total,
  });

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      used: json['used'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['used'] = used;
    data['total'] = total;
    return data;
  }
}

class UerPackageResponse {
  int? code;
  String? msg;
  Transcription? convert;
  Storage? storage;

  UerPackageResponse({
    this.code,
    this.msg,
    this.convert,
    this.storage,
  });

  factory UerPackageResponse.fromJson(Map<String, dynamic> json) {
    return UerPackageResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      convert: Transcription.fromJson(json['convert']),
      //storage: Storage.fromJson(json['storage']),
    );
  }
}
