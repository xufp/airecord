import 'dart:convert';

import '../../constant/ErrConstants.dart';

class ServiceDetail {
  int serviceType;
  String beginDate;
  String endDate;
  int quantity;

  ServiceDetail({
    required this.serviceType,
    required this.beginDate,
    required this.endDate,
    required this.quantity,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      serviceType: json['service_type'],
      beginDate: json['begin_date'],
      endDate: json['end_date'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
    'service_type': serviceType,
    'begin_date': beginDate,
    'end_date': endDate,
    'quantity': quantity,
  };
}

class PackageDetail {
  int packageId;
  List<ServiceDetail> serviceDetails;

  PackageDetail({
    required this.packageId,
    required this.serviceDetails,
  });

  factory PackageDetail.fromJson(Map<String, dynamic> json) {
    return PackageDetail(
      packageId: json['package_id'],
      serviceDetails: List<ServiceDetail>.from(
        json['package_detail'].map((x) => ServiceDetail.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'package_id': packageId,
    'package_detail': List<dynamic>.from(serviceDetails.map((x) => x.toJson())),
  };
}

class UserPackageGiveResponse {
  final int code;
  final String msg;
  PackageDetail packageDetail;

  UserPackageGiveResponse({
    required this.code,
    required this.msg,
    required this.packageDetail,
  });

  factory UserPackageGiveResponse.fromJson(Map<String, dynamic> json) {
    return UserPackageGiveResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      packageDetail: PackageDetail.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => {
    'package_detail': packageDetail.toJson(),
  };
}

// 解析JSON字符串为Dart对象
UserPackageGiveResponse userPackageGiveResponse(String jsonString) {
  final jsonMap = jsonDecode(jsonString);
  return UserPackageGiveResponse.fromJson(jsonMap);
}