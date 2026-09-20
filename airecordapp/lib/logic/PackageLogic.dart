import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/request/PackageAvailableRequest.dart';
import 'package:airecordapp/service/request/UserPackageGiveRequest.dart';
import 'package:airecordapp/service/response/PackageAvailableResponse.dart';
import 'package:airecordapp/util/LogUtil.dart';

/**
 * 套餐包操作
 */
class PackageLogic {
  final logger = LogUtil.inItLog();

  /// 新用户注册赠送的免费体验套餐包 ID（对应服务端 t_package 表 package_type=1）
  static const int NEW_USER_FREE_PACKAGE_ID = 90010001;

  /// 服务端「套餐不允许重复领取」错误码
  /// 参考 airecodeserver/internal/infrastructure/errorcode/error_code.go
  /// ErrPackageRepeatGive = ModuleID(10001*1000) + 302
  static const int ERR_PACKAGE_REPEAT_GIVE = 10001302;

  // 获取可购买的套餐包
  Future<PackageAvailableResponse> queryPackageAvailable(
      int packageType) async {
    try {
      PackageAvailableRequest request =
          PackageAvailableRequest(packageType: packageType);
      final resp = await DioService.queryPackageAvailable(request);
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        return resp;
      }
    } catch (e) {
      logger.e('获取可购买的套餐包异常:$e');
    }
    return PackageAvailableResponse(
        code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
  }

  // 判断用户是否有转写套餐
  Future<bool> isHasTrans() async {
    // try {
    //   final resp = await DioService.userPackage();
    //   if (resp.code == ErrConstants.SUCCESS_CODE) {
    //     int remind = (resp.convert?.total ?? 0) - (resp.convert?.used ?? 0);
    //     if (remind > 0) {
    //       return Future.value(true);
    //     }
    //   }
    // } catch (e) {
    //   logger.e('获取套餐信息异常:$e');
    // }
    // return Future.value(false);

    final resp = await DioService.userPackage();
    if (resp.code == ErrConstants.SUCCESS_CODE) {
      int remind = (resp.convert?.total ?? 0) - (resp.convert?.used ?? 0);
      if (remind > 0) {
        return Future.value(true);
      }
    }
    return Future.value(false);
  }

  /// 静默领取免费套餐包（用于注册成功后自动领取）
  ///
  /// 特性：
  /// 1. 静默：不弹出任何 UI 反馈，成功/失败均只写日志，不影响调用方主流程；
  /// 2. 幂等：服务端限领一次，若已领取（错误码 [ERR_PACKAGE_REPEAT_GIVE]）
  ///    在本方法内被视为业务上成功，返回 true；
  /// 3. 依赖：调用前必须保证已保存有效登录 token（Cache.saveToken），
  ///    否则接口会 401 触发 DioClient 拦截器跳登录页。
  ///
  /// 返回值：是否已成功获得该套餐（首次领取成功 或 之前已领取过 → true）。
  Future<bool> giveFreePackage(int packageId) async {
    try {
      final resp = await DioService.userPackageGive(
        req: UserPackageGiveRequest(packageId: packageId),
      );
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        logger.i('免费套餐领取成功, packageId=$packageId');
        return true;
      }
      if (resp.code == ERR_PACKAGE_REPEAT_GIVE) {
        // 已领取过，视为业务成功
        logger.i('免费套餐已领取过, packageId=$packageId');
        return true;
      }
      logger.e(
          '免费套餐领取失败, packageId=$packageId, code=${resp.code}, msg=${resp.msg}');
    } catch (e) {
      logger.e('免费套餐领取异常, packageId=$packageId, error=$e');
    }
    return false;
  }
}
