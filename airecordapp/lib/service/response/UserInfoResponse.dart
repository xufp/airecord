import '../../constant/ErrConstants.dart';

class UserInfoResponse {
  final int? code;
  final String? msg;
  String? nickName;
  int? sex;
  String? province;
  String? city;
  String? country;
  String? headImgUrl;
  int? membershipLevel;
  String? membershipExpireTime;

  UserInfoResponse({
    this.code,
    this.msg,
    this.nickName,
    this.sex,
    this.province,
    this.city,
    this.country,
    this.headImgUrl,
    this.membershipLevel,
    this.membershipExpireTime,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      nickName: json['nick_name'],
      sex: json['sex'],
      province: json['province'],
      city: json['city'],
      country: json['country'],
      headImgUrl: json['head_img_url'],
      membershipLevel: json['membership_level'],
      membershipExpireTime: json['membership_expire_time'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nick_name'] = nickName;
    data['sex'] = sex;
    data['province'] = province;
    data['city'] = city;
    data['country'] = country;
    data['head_img_url'] = headImgUrl;
    data['membership_level'] = membershipLevel;
    data['membership_expire_time'] = membershipExpireTime;
    return data;
  }
}
