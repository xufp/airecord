/**
 * 套餐包信息
 */
class PackageRecord {
  int packageId; // 套餐ID
  int packageType; // 套餐类型 1：免费体验类，2：付费类，3：订阅计划
  String packageName; // 套餐名称
  String description; // 套餐描述
  int price; // 套餐总价(单位：分)
  int rates; // 套餐折扣率(%) 购买价格 = price * (rates / 100)

  PackageRecord({
    required this.packageId,
    required this.packageType,
    required this.packageName,
    required this.description,
    required this.price,
    required this.rates,
  });

  factory PackageRecord.fromJson(Map<String, dynamic> json) {
    return PackageRecord(
      packageId: json['package_id'],
      packageType: json['package_type'],
      packageName: json['package_name'],
      description: json['description'],
      price: json['price'],
      rates: json['rates'],
    );
  }

  Map<String, dynamic> toJson() => {
        'package_id': packageId,
        'package_type': packageType,
        'package_name': packageName,
        'description': description,
        'price': price,
        'rates': rates,
      };
}
