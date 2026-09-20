class GetAsrEngineModelsResponse {
  int code;
  String msg;
  List<AsrEngineModel>? data;

  GetAsrEngineModelsResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory GetAsrEngineModelsResponse.fromJson(Map<String, dynamic> json) {
    return GetAsrEngineModelsResponse(
      code: json['code'] ?? 200,
      msg: json['msg'] ?? 'success',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => AsrEngineModel.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AsrEngineModel {
  String engineType;
  String engineDesc;

  AsrEngineModel({
    required this.engineType,
    required this.engineDesc,
  });

  factory AsrEngineModel.fromJson(Map<String, dynamic> json) {
    return AsrEngineModel(
      engineType: json['engine_type'],
      engineDesc: json['engine_desc'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['engine_type'] = this.engineType;
    data['engine_desc'] = this.engineDesc;
    return data;
  }
}