import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/service/request/ActivateMemberRequest.dart';
import 'package:airecordapp/service/request/FeedBackRequest.dart';
import 'package:airecordapp/service/response/ActivateMemberResponse.dart';
import 'package:airecordapp/service/response/DeleteAccountResponse.dart';
import 'package:airecordapp/service/response/FeedBackResponse.dart';
import 'package:airecordapp/util/LogUtil.dart';
import '../service/response/UerPackageResponse.dart';
import '../service/DioService.dart';
import '../service/response/UserInfoResponse.dart';

class ProfileLogic {
  final logger = LogUtil.inItLog();

  // 获取用户信息
  Future<UserInfoResponse> userInfo() async {
    try {
      UserInfoResponse response = await Cache.userInfo;
      if (response != null &&
          response.nickName != null &&
          response.nickName!.isNotEmpty) {
        return response;
      }
      final resp = await DioService.userInfo();
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        await Cache.saveUserInfo(resp);
        return resp;
      }
    } catch (e) {
      logger.e('获取用户信息异常:$e');
    }
    return UserInfoResponse(
        code: ErrConstants.SUCCESS_CODE, msg: ErrConstants.SUCCESS_MSG);
  }

  // 判断用户信息是否发生变化
  Future<bool> isChanged() async {
    try {
      // 从缓存获取用户信息
      UserInfoResponse response = await Cache.userInfo;
      // 从服务端获取用户信息
      final resp = await DioService.userInfo();
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        if(response == null) {
          await Cache.saveUserInfo(resp);
          return Future.value(true);
        }
        if(resp.headImgUrl != response.headImgUrl){
          await Cache.saveUserInfo(resp);
          return Future.value(true);
        }
        if(resp.membershipExpireTime != response.membershipExpireTime){
          await Cache.saveUserInfo(resp);
          return Future.value(true);
        }
        if(resp.membershipLevel != response.membershipLevel){
          await Cache.saveUserInfo(resp);
          return Future.value(true);
        }
      }
      return Future.value(false);
    } catch (e) {
      logger.e('判断用户信息是否发生变化:$e');
    }
    return Future.value(false);
  }

  // 获取用户信息
  Future<ActivateMemberResponse> activateMember(String activateCode) async {
    ActivateMemberResponse? resp = null;
    try {
      ActivateMemberRequest req = ActivateMemberRequest(cardNo: activateCode);
      resp = await DioService.activateMember(req);
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        await isChanged();
      }
    } catch (e) {
      logger.e('绑定设备异常:$e');
    }
    return resp!;
  }

  // 获取套餐信息
  Future<UerPackageResponse> userPackage() async {
    try {
      final resp = await DioService.userPackage();
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        return resp;
      }
    } catch (e) {
      logger.e('获取套餐信息异常:$e');
    }
    return UerPackageResponse(
        code: ErrConstants.SUCCESS_CODE, msg: ErrConstants.SUCCESS_MSG);
  }

  // 提交反馈
  Future<FeedBackResponse> feedBack(String content, String contract) async {
    try {
      final resp = await DioService.userFeedBack(FeedBackRequest(content: content, contract: contract));
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        return resp;
      }
    } catch (e) {
      logger.e('提交反馈异常:$e');
    }
    return FeedBackResponse(
        code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
  }

  // 删除账号
  Future<DeleteAccountResponse> deleteAccount() async {
    try {
      final resp = await DioService.deleteAccount();
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        await Cache.removeAll();
        return resp;
      }
    } catch (e) {
      logger.e('删除账号异常:$e');
    }
    return DeleteAccountResponse(
        code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
  }
}
