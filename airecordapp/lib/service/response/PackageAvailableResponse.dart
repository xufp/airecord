import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/response/MediaConvertRecord.dart';
import 'package:airecordapp/service/response/PackageRecord.dart';

class PackageAvailableResponse {
  int code;
  String msg;
  List<PackageRecord>? packages;

  PackageAvailableResponse({
    required this.code,
    required this.msg,
    this.packages,
  });

  factory PackageAvailableResponse.fromJson(Map<String, dynamic> json) {
    var data = json['packages'];
    List<PackageRecord> packageRecordList = [];
    if(data != null && data.isNotEmpty) {
      List<dynamic>  dataList= data;
      dataList.forEach((element){
        if(element is Map<String, dynamic>) {
          Map<String, dynamic> map = element;
          int packageId = map['package_id'];
          int packageType = map['package_type'];
          String packageName = map['package_name'];
          String description = map['description'];
          int price = map['price'];
          int rates = map['rates'];
          PackageRecord mediaConvertRecord = PackageRecord(packageId: packageId, packageType: packageType, packageName: packageName, description: description, price: price, rates: rates);
          packageRecordList.add(mediaConvertRecord);
        }
      });
    }
    return PackageAvailableResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      packages: packageRecordList,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
      };
}
