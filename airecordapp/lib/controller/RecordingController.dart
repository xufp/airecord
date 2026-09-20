import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/service/RecordingService.dart';
import 'package:airecordapp/util/LogUtil.dart';
import 'package:get/get.dart';

class RecordingController extends GetxController {
  final logger = LogUtil.inItLog();
  var selectedFilter = '全部音频'.obs; // 筛选数据， 默认全部音频， 转写和未转写
  var isAllSelected = false.obs;
  var searchText = ''.obs;
  final RxList<Recording> dataList = <Recording>[].obs;
  var labelList = <String>[].obs;
  var page = 1.obs;
  var isLoading = false.obs; // 是否正在加载中
  RecordingService recordingService = RecordingService();
  var isMore = false.obs; // 是否更多
  var isAll = false.obs;
  var sortColumn = 'updated_at'.obs; // 排序键，创建时间和修改时间，默认按创建时间
  var cardSelected = {}.obs;

  bool getAll = true;

  RecordingController({bool getAll = true}) {
    this.getAll = getAll;
  }

  Future<void> updateFilter(String filter) async {
    selectedFilter.value = filter;
    clearAll();
    await fetchData();
  }

  void updateCardSelected(int index) async {
    cardSelected.value[index] = true;
  }

  @override
  void onInit() {
    super.onInit();
    if (getAll) {
      getAllList(); // 页面刚进来时加载数据
    }
    labelList.value = [
      '语文',
      '数学',
      '英语',
      '物理',
      '化学',
      '生物',
      '历史',
      '地理',
      '政治',
      '其他'
    ];
  }

  // 页面刚进来默认查询所有数据
  Future<void> getAllList() async {
    clearAll();
    await fetchData();
  }

  Future<void> selectAll(bool value) async {
    isAllSelected.value = value;
    // 更新列表中所有项的选中状态
  }

  /**
   * 排序，按创建时间或更新时间排序
   */
  Future<void> sort(String sortColumn) async {
    this.sortColumn.value = sortColumn;
    clearAll();
    await fetchData();
  }

  /**
   * 过滤按转写状态来过滤
   */
  Future<void> filter(String filter) async {
    this.selectedFilter.value = filter;
    clearAll();
    await fetchData();
  }

  Future<void> search(String text) async {
    if (text.isEmpty && getAll == false) {
      searchText.value = '';
      clearAll();
    } else if (text.isEmpty && getAll == true) {
      searchText.value = '';
      clearAll();
      await fetchData();
    } else {
      searchText.value = text;
      clearAll();
      await fetchData();
      searchText.value = '';
    }
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    int limit = 5000;
    int offset = (page.value - 1) * limit;

    try {
      var itemList;
      /*itemList = await recordingService.searchRecordingsByPage(
          searchText.value, limit, offset);*/
       if (searchText.value.isNotEmpty) {
         itemList = await recordingService.searchRecordingsByPage(
             searchText.value, limit, offset);
       } else {
         var filter = '-1';
         if (selectedFilter.value == '已转写') {
           filter = '1';
         } else if (selectedFilter.value == '未转写') {
           filter = '0';
         }
         if (filter != '-1') {
           itemList = await recordingService.filterRecordingsByPage(
               filter, sortColumn.value, limit, offset);
         } else {
           itemList = await recordingService.sortRecordingsByPage(
               limit, offset, sortColumn.value);
         }
       }

      // 只在第一页时替换数据，其他情况追加数据
      if (page.value == 1) {
        dataList.clear();
      }
      if (itemList.isNotEmpty) {
        dataList.addAll(itemList);
      }
      isMore.value = itemList.length == limit;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isMore.value) {
      page.value++;
      await fetchData();
    }
  }

  Future<void> reloadData() async {
    clearAll(); // 确保清理所有数据
    await fetchData();
  }

  // 初始化所有条件
  clearAll() {
    dataList.clear();
    isMore.value = false;
    page.value = 1;
  }

  //Future<bool> updateFileName(int id, int mediaId, String fileName) async {
  //  if (id == 0 || fileName == null || fileName.isEmpty) {
  //    return false;
  //  }
  //  MediaUpdateRequest request = MediaUpdateRequest(mediaId:mediaId, mediaName:fileName);
  //  //调用后端更改文件名操作
  //  MediaUpdateResponse response = await DioService.mediaUpdate(request);
//
  //  if (response.code == ErrConstants.SUCCESS_CODE) {
  //    //更新本地数据库名称
  //    await recordingService.updateFileName(id, fileName);
  //    return true;
  //  } else {
  //    return false;
  //  }
  //}
}
