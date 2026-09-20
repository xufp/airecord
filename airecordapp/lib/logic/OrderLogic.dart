import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/request/CreateOrderRequest.dart';
import 'package:airecordapp/service/request/OrderDetailRequest.dart';
import 'package:airecordapp/service/response/CreateOrderResponse.dart';
import 'package:airecordapp/service/response/OrderDetailResponse.dart';
import 'package:airecordapp/util/LogUtil.dart';

/**
 * 订单操作
 */
class OrderLogic {
  final logger = LogUtil.inItLog();

  // 创建订单
  Future<CreateOrderResponse> createOrder(int packageId) async {
    try {
      CreateOrderRequest request =
          CreateOrderRequest(packageId: packageId, payChannel: 1);
      final resp = await DioService.createOrder(request);
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        return resp;
      }
    } catch (e) {
      logger.e('创建订单异常:$e');
    }
    return CreateOrderResponse(
        code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
  }

  //查询订单详情
  Future<OrderDetailResponse> queryOrderDetail(String orderId) async {
    try {
      OrderDetailRequest request = OrderDetailRequest(orderId: orderId);
      final resp = await DioService.queryOrderDetail(request);
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        return resp;
      }
    } catch (e) {
      logger.e('查询订单明细:$e');
    }
    return OrderDetailResponse(
        code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
  }
}
