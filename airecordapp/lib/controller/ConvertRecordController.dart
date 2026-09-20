import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/request/MediaConvertRecordsRequest.dart';
import 'package:airecordapp/service/response/MediaConvertRecord.dart';
import 'package:airecordapp/service/response/MediaConvertRecordsResponse.dart';
import 'package:get/get.dart';

class ConvertRecordController extends GetxController {
  final RxList<MediaConvertRecord> dataList = <MediaConvertRecord>[].obs;
  var isLoading = false.obs; // 是否正在加载中
  var page = 1.obs;
  var size = 20.obs;
  var isMore = false.obs; // 是否更多

  @override
  void onInit() {
    super.onInit();
    getAllList(); // 页面刚进来时加载数据
  }

  // 页面刚进来默认查询所有数据
  Future<void> getAllList() async {
    clearAll();
    await fetchData();
  }

  Future<void> fetchData() async {
    // 模拟分页数据获取
    isLoading.value = true;
    // 这里可以调用API获取数据
    var itemList;
    MediaConvertRecordsRequest req =
        MediaConvertRecordsRequest(page: page.value, size: size.value);
    MediaConvertRecordsResponse response =
        await DioService.queryConvertRecord(req);
    if (response.data != null && response.data!.length > 0) {
      itemList = response.data;
    }

    if (itemList != null && itemList.isNotEmpty) {
      // 更新dataList
      dataList.addAll(itemList);
    } else {
      page.value--;
    }
    if (itemList != null && itemList.length == size.value) {
      isMore.value = true;
    } else {
      isMore.value = false;
    }
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (isMore.value) {
      page.value++;
      await fetchData();
    }
  }

  Future<void> reloadData() async {
    dataList.clear();
    fetchData();
  }

  // 初始化所有条件
  clearAll() {
    dataList.clear();
    isMore.value = false;
    page.value = 1;
  }
}
