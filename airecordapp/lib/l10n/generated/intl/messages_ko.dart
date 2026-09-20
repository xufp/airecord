// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ko';

  static String m0(pageNumber, pagesCount) =>
      "${pagesCount} 페이지 중 ${pageNumber} 페이지";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "AboutPage_k1": MessageLookupByLibrary.simpleMessage("정보"),
        "AboutPage_k2": MessageLookupByLibrary.simpleMessage("업데이트"),
        "AboutPage_k3": MessageLookupByLibrary.simpleMessage("웹사이트"),
        "AboutPage_k4": MessageLookupByLibrary.simpleMessage("Facebook"),
        "AboutPage_k5": MessageLookupByLibrary.simpleMessage("Instagram"),
        "AboutPage_k6": MessageLookupByLibrary.simpleMessage("TikTok"),
        "AboutPage_k7": MessageLookupByLibrary.simpleMessage("이용약관"),
        "AboutPage_k8": MessageLookupByLibrary.simpleMessage("개인정보"),
        "AccountSecurityPage_k1":
            MessageLookupByLibrary.simpleMessage("계정 및 보안"),
        "AccountSecurityPage_k2": MessageLookupByLibrary.simpleMessage("계정 삭제"),
        "AccountSecurityPage_k3":
            MessageLookupByLibrary.simpleMessage("계정 삭제 확인"),
        "AccountSecurityPage_k4": MessageLookupByLibrary.simpleMessage(
            "계정을 삭제하면 모든 데이터가 삭제되며 복구할 수 없습니다. 계속하시겠습니까?"),
        "AccountSecurityPage_k5": MessageLookupByLibrary.simpleMessage("취소"),
        "AccountSecurityPage_k6": MessageLookupByLibrary.simpleMessage("삭제 확인"),
        "AccountSecurityPage_k7": MessageLookupByLibrary.simpleMessage(
            "계정 삭제에 실패했습니다. 나중에 다시 시도해 주세요"),
        "AskAiPage_dialogAudio":
            MessageLookupByLibrary.simpleMessage("오디오에 질문"),
        "AskAiPage_dialogGeneral":
            MessageLookupByLibrary.simpleMessage("일반 질문"),
        "AskAiPage_promptHighlight":
            MessageLookupByLibrary.simpleMessage("본문에서 인상적인 문장을 발췌해 주세요"),
        "AskAiPage_promptMinutes":
            MessageLookupByLibrary.simpleMessage("정식 회의록을 작성해 주세요"),
        "AskAiPage_promptSummary":
            MessageLookupByLibrary.simpleMessage("회의의 핵심 요점을 요약해 주세요"),
        "AskAiPage_promptTodo":
            MessageLookupByLibrary.simpleMessage("회의의 할 일 목록을 정리해 주세요"),
        "AudioFilePickerPage_k1":
            MessageLookupByLibrary.simpleMessage("지원되지 않는 형식"),
        "AudioFilePickerPage_k10": MessageLookupByLibrary.simpleMessage("파일에서"),
        "AudioFilePickerPage_k11":
            MessageLookupByLibrary.simpleMessage("로컬 파일 일괄 가져오기"),
        "AudioFilePickerPage_k12":
            MessageLookupByLibrary.simpleMessage("갤러리에서"),
        "AudioFilePickerPage_k13":
            MessageLookupByLibrary.simpleMessage("갤러리에서 선택"),
        "AudioFilePickerPage_k14": MessageLookupByLibrary.simpleMessage("요구사항"),
        "AudioFilePickerPage_k15": MessageLookupByLibrary.simpleMessage(
            "형식: MP3, M4A, WAV, AMR, FLAC, AAC"),
        "AudioFilePickerPage_k16":
            MessageLookupByLibrary.simpleMessage("제한: 5시간 미만, 1GB 미만/파일"),
        "AudioFilePickerPage_k2":
            MessageLookupByLibrary.simpleMessage("현재 파일: "),
        "AudioFilePickerPage_k3":
            MessageLookupByLibrary.simpleMessage("지원 형식:"),
        "AudioFilePickerPage_k4": MessageLookupByLibrary.simpleMessage("확인"),
        "AudioFilePickerPage_k5":
            MessageLookupByLibrary.simpleMessage("시뮬레이터 지원 안 함"),
        "AudioFilePickerPage_k6":
            MessageLookupByLibrary.simpleMessage("실제 기기에서 테스트하세요"),
        "AudioFilePickerPage_k7": MessageLookupByLibrary.simpleMessage("확인"),
        "AudioFilePickerPage_k8":
            MessageLookupByLibrary.simpleMessage("가져오기 실패"),
        "AudioFilePickerPage_k9":
            MessageLookupByLibrary.simpleMessage("오디오 가져오기"),
        "AudioImportPage_k1":
            MessageLookupByLibrary.simpleMessage("지원되지 않는 형식"),
        "AudioImportPage_k10": MessageLookupByLibrary.simpleMessage("아래 예시"),
        "AudioImportPage_k11": MessageLookupByLibrary.simpleMessage("선택 실패"),
        "AudioImportPage_k12": MessageLookupByLibrary.simpleMessage("파일 가져오기"),
        "AudioImportPage_k13": MessageLookupByLibrary.simpleMessage("로컬에서"),
        "AudioImportPage_k14":
            MessageLookupByLibrary.simpleMessage("로컬 파일 일괄 가져오기"),
        "AudioImportPage_k15": MessageLookupByLibrary.simpleMessage("앱에서"),
        "AudioImportPage_k16":
            MessageLookupByLibrary.simpleMessage("다른 앱에서 공유"),
        "AudioImportPage_k17": MessageLookupByLibrary.simpleMessage("갤러리에서"),
        "AudioImportPage_k18": MessageLookupByLibrary.simpleMessage("갤러리에서 선택"),
        "AudioImportPage_k19": MessageLookupByLibrary.simpleMessage("요구사항"),
        "AudioImportPage_k2": MessageLookupByLibrary.simpleMessage("현재 파일: "),
        "AudioImportPage_k20": MessageLookupByLibrary.simpleMessage(
            "형식: MP3, M4A, WAV, AMR, FLAC, AAC"),
        "AudioImportPage_k21":
            MessageLookupByLibrary.simpleMessage("제한: 5시간 미만, 1GB 미만/파일"),
        "AudioImportPage_k3": MessageLookupByLibrary.simpleMessage("지원 형식:"),
        "AudioImportPage_k4": MessageLookupByLibrary.simpleMessage("확인"),
        "AudioImportPage_k5": MessageLookupByLibrary.simpleMessage("앱에서 가져오기"),
        "AudioImportPage_k6":
            MessageLookupByLibrary.simpleMessage("1. 오디오 열고 공유 탭"),
        "AudioImportPage_k7": MessageLookupByLibrary.simpleMessage("왼쪽 예시"),
        "AudioImportPage_k8": MessageLookupByLibrary.simpleMessage("오른쪽 예시"),
        "AudioImportPage_k9":
            MessageLookupByLibrary.simpleMessage("2. YiGuo Voice 선택"),
        "BlueAudioFileList_k1":
            MessageLookupByLibrary.simpleMessage("오디오 파일 동기화"),
        "BlueAudioFileList_k2": MessageLookupByLibrary.simpleMessage("완료"),
        "BlueAudioFileList_k3":
            MessageLookupByLibrary.simpleMessage("동기화된 파일 없음"),
        "BlueAudioFileList_k5":
            MessageLookupByLibrary.simpleMessage("오디오 재동기화"),
        "BlueController_audio_sync_completed":
            MessageLookupByLibrary.simpleMessage("오디오 파일 전송이 완료되었습니다!"),
        "BlueController_device_disconnected_jump_home":
            MessageLookupByLibrary.simpleMessage("기기 연결이 끊어졌습니다. 홈으로 돌아갑니다…"),
        "BluetoothPage_k1": MessageLookupByLibrary.simpleMessage("기기 연결"),
        "BluetoothPage_k10": MessageLookupByLibrary.simpleMessage("기기 상태 확인"),
        "BluetoothPage_k11": MessageLookupByLibrary.simpleMessage("재스캔"),
        "BluetoothPage_k2": MessageLookupByLibrary.simpleMessage("스캔 중..."),
        "BluetoothPage_k3": MessageLookupByLibrary.simpleMessage("기기와 블루투스 켜기"),
        "BluetoothPage_k4": MessageLookupByLibrary.simpleMessage("기기를 범위 내에"),
        "BluetoothPage_k5": MessageLookupByLibrary.simpleMessage("아래를 탭하여 재스캔"),
        "BluetoothPage_k6": MessageLookupByLibrary.simpleMessage("재스캔"),
        "BluetoothPage_k7": MessageLookupByLibrary.simpleMessage("신호"),
        "BluetoothPage_k8": MessageLookupByLibrary.simpleMessage("연결"),
        "BluetoothPage_k9": MessageLookupByLibrary.simpleMessage("실패"),
        "BuyRecommendWidget_k1":
            MessageLookupByLibrary.simpleMessage("멤버십 업그레이드"),
        "BuyRecommendWidget_k10": MessageLookupByLibrary.simpleMessage("나중에"),
        "BuyRecommendWidget_k2":
            MessageLookupByLibrary.simpleMessage("모든 프리미엄 기능 잠금 해제"),
        "BuyRecommendWidget_k3":
            MessageLookupByLibrary.simpleMessage("무제한 AI 음성 변환"),
        "BuyRecommendWidget_k4":
            MessageLookupByLibrary.simpleMessage("빠르고 정확한 음성 인식"),
        "BuyRecommendWidget_k5":
            MessageLookupByLibrary.simpleMessage("실시간 동시 통역"),
        "BuyRecommendWidget_k6":
            MessageLookupByLibrary.simpleMessage("다국어 실시간 번역"),
        "BuyRecommendWidget_k7":
            MessageLookupByLibrary.simpleMessage("전문 회의 요약"),
        "BuyRecommendWidget_k8":
            MessageLookupByLibrary.simpleMessage("AI로 회의 핵심 자동 생성"),
        "BuyRecommendWidget_k9": MessageLookupByLibrary.simpleMessage("기기 바인딩"),
        "ClearCachePage_k1": MessageLookupByLibrary.simpleMessage("캐시 삭제"),
        "ClearCachePage_k2": MessageLookupByLibrary.simpleMessage("크기"),
        "ClearCachePage_k3": MessageLookupByLibrary.simpleMessage("삭제"),
        "ClearCachePage_k4": MessageLookupByLibrary.simpleMessage("성공"),
        "ConvertRecordPage_k1": MessageLookupByLibrary.simpleMessage("기록"),
        "ConvertRecordPage_k2": MessageLookupByLibrary.simpleMessage("기록 없음"),
        "ConvertRecordPage_k3": MessageLookupByLibrary.simpleMessage("시간"),
        "ConvertRecordPage_k4": MessageLookupByLibrary.simpleMessage("날짜"),
        "ConvertRecordPage_k5": MessageLookupByLibrary.simpleMessage("분"),
        "DevicePage_k1": MessageLookupByLibrary.simpleMessage("기기"),
        "DevicePage_k10": MessageLookupByLibrary.simpleMessage(
            "확인:\n• 전원 켜짐\n• 범위 내\n• 사용 중 아님\n• 블루투스 OK"),
        "DevicePage_k11": MessageLookupByLibrary.simpleMessage("취소"),
        "DevicePage_k12": MessageLookupByLibrary.simpleMessage("재시도"),
        "DevicePage_k13": MessageLookupByLibrary.simpleMessage("연결됨"),
        "DevicePage_k14": MessageLookupByLibrary.simpleMessage("확인"),
        "DevicePage_k15": MessageLookupByLibrary.simpleMessage("연결 해제"),
        "DevicePage_k16": MessageLookupByLibrary.simpleMessage("기기 삭제"),
        "DevicePage_k17": MessageLookupByLibrary.simpleMessage("기기를 삭제하시겠습니까?"),
        "DevicePage_k18": MessageLookupByLibrary.simpleMessage("되돌릴 수 없습니다"),
        "DevicePage_k19": MessageLookupByLibrary.simpleMessage("연결을 해제하시겠습니까?"),
        "DevicePage_k2": MessageLookupByLibrary.simpleMessage("충전 중"),
        "DevicePage_k20": MessageLookupByLibrary.simpleMessage("다시 페어링해야 합니다"),
        "DevicePage_k25": MessageLookupByLibrary.simpleMessage("취소"),
        "DevicePage_k26": MessageLookupByLibrary.simpleMessage("확인"),
        "DevicePage_k3": MessageLookupByLibrary.simpleMessage("연결 끊김"),
        "DevicePage_k4": MessageLookupByLibrary.simpleMessage("정보"),
        "DevicePage_k5": MessageLookupByLibrary.simpleMessage(
            "• 처음엔 수동 연결\n• 자동 파일 동기화\n• 배터리 확인\n• 원격 제어"),
        "DevicePage_k6": MessageLookupByLibrary.simpleMessage("연결"),
        "DevicePage_k7": MessageLookupByLibrary.simpleMessage("연결 중..."),
        "DevicePage_k8": MessageLookupByLibrary.simpleMessage("기기 상태 확인"),
        "DevicePage_k9": MessageLookupByLibrary.simpleMessage("실패"),
        "DioClient_network_error":
            MessageLookupByLibrary.simpleMessage("네트워크 연결 오류, 나중에 다시 시도해 주세요"),
        "DioClient_network_timeout":
            MessageLookupByLibrary.simpleMessage("네트워크 연결 시간 초과"),
        "DioClient_receive_timeout":
            MessageLookupByLibrary.simpleMessage("데이터 수신 시간 초과"),
        "DioClient_unknown_error":
            MessageLookupByLibrary.simpleMessage("알 수 없는 오류"),
        "EmailLoginPage_account_deactivated":
            MessageLookupByLibrary.simpleMessage("해당 계정이 존재하지 않습니다"),
        "EmailLoginPage_email_address":
            MessageLookupByLibrary.simpleMessage("이메일"),
        "EmailLoginPage_email_empty_error":
            MessageLookupByLibrary.simpleMessage("이메일을 입력하세요"),
        "EmailLoginPage_email_format_error":
            MessageLookupByLibrary.simpleMessage("올바른 이메일을 입력하세요"),
        "EmailLoginPage_find_password":
            MessageLookupByLibrary.simpleMessage("비밀번호 찾기"),
        "EmailLoginPage_k1": MessageLookupByLibrary.simpleMessage("이메일 로그인"),
        "EmailLoginPage_k2": MessageLookupByLibrary.simpleMessage("환영합니다"),
        "EmailLoginPage_k3": MessageLookupByLibrary.simpleMessage("계정에 로그인"),
        "EmailLoginPage_k4":
            MessageLookupByLibrary.simpleMessage("로그인하면 동의하는 것입니다"),
        "EmailLoginPage_k5": MessageLookupByLibrary.simpleMessage("이용약관"),
        "EmailLoginPage_k6": MessageLookupByLibrary.simpleMessage("및"),
        "EmailLoginPage_k7": MessageLookupByLibrary.simpleMessage("개인정보 처리방침"),
        "EmailLoginPage_login": MessageLookupByLibrary.simpleMessage("로그인"),
        "EmailLoginPage_login_error":
            MessageLookupByLibrary.simpleMessage("이메일 또는 비밀번호가 잘못되었습니다"),
        "EmailLoginPage_network_error":
            MessageLookupByLibrary.simpleMessage("네트워크 오류"),
        "EmailLoginPage_password": MessageLookupByLibrary.simpleMessage("비밀번호"),
        "EmailLoginPage_password_empty_error":
            MessageLookupByLibrary.simpleMessage("비밀번호를 입력하세요"),
        "EmailLoginPage_password_format_error":
            MessageLookupByLibrary.simpleMessage("8-16자로 입력하세요"),
        "EmailLoginPage_password_uncorrect":
            MessageLookupByLibrary.simpleMessage("잘못된 비밀번호"),
        "EmailLoginPage_register": MessageLookupByLibrary.simpleMessage("가입"),
        "EmailLoginPage_unknown_error":
            MessageLookupByLibrary.simpleMessage("오류가 발생했습니다"),
        "EmailLoginPage_user_agreement":
            MessageLookupByLibrary.simpleMessage("이용약관과 개인정보 처리방침에 동의"),
        "EmailLoginPage_user_not_found":
            MessageLookupByLibrary.simpleMessage("등록되지 않은 이메일"),
        "FeedBackPage_k1": MessageLookupByLibrary.simpleMessage("피드백"),
        "FeedBackPage_k10": MessageLookupByLibrary.simpleMessage("연락처"),
        "FeedBackPage_k2": MessageLookupByLibrary.simpleMessage("문제"),
        "FeedBackPage_k3": MessageLookupByLibrary.simpleMessage("설명 (필수)"),
        "FeedBackPage_k4": MessageLookupByLibrary.simpleMessage("연락처 (선택)"),
        "FeedBackPage_k5": MessageLookupByLibrary.simpleMessage("제출"),
        "FeedBackPage_k6": MessageLookupByLibrary.simpleMessage("설명 입력"),
        "FeedBackPage_k7": MessageLookupByLibrary.simpleMessage("성공"),
        "FeedBackPage_k8": MessageLookupByLibrary.simpleMessage("감사합니다"),
        "FeedBackPage_k9": MessageLookupByLibrary.simpleMessage("피드백 내용"),
        "HelperPage_k1": MessageLookupByLibrary.simpleMessage("도움말"),
        "HelperPage_k2": MessageLookupByLibrary.simpleMessage("FAQ"),
        "HelperPage_k3": MessageLookupByLibrary.simpleMessage("사용 방법"),
        "HelperPage_k4": MessageLookupByLibrary.simpleMessage("가져오기 방법"),
        "HelperPage_k5": MessageLookupByLibrary.simpleMessage("내보내기 방법"),
        "HelperPage_k6": MessageLookupByLibrary.simpleMessage("지원 형식"),
        "HelperPage_k7": MessageLookupByLibrary.simpleMessage("업그레이드 방법"),
        "HomePage_menu_filelist": MessageLookupByLibrary.simpleMessage("파일"),
        "HomePage_menu_usercenter":
            MessageLookupByLibrary.simpleMessage("내 정보"),
        "ItemWidget_AI": MessageLookupByLibrary.simpleMessage("AI 분석"),
        "ItemWidget_k1": MessageLookupByLibrary.simpleMessage("파일 없음"),
        "ItemWidget_k2": MessageLookupByLibrary.simpleMessage("기기를 연결하여 가져오기"),
        "ItemWidget_k3": MessageLookupByLibrary.simpleMessage("삭제"),
        "ItemWidget_k4": MessageLookupByLibrary.simpleMessage("이름 변경"),
        "ItemWidget_k5": MessageLookupByLibrary.simpleMessage("공유"),
        "ListPage_bluetooth_connected":
            MessageLookupByLibrary.simpleMessage("연결됨"),
        "ListPage_k1": MessageLookupByLibrary.simpleMessage("AI 음성 변환"),
        "ListPage_k10": MessageLookupByLibrary.simpleMessage("실시간 동기화"),
        "ListPage_k11": MessageLookupByLibrary.simpleMessage("취소"),
        "ListPage_k12": MessageLookupByLibrary.simpleMessage("연결"),
        "ListPage_k2": MessageLookupByLibrary.simpleMessage("정확도 98%"),
        "ListPage_k3": MessageLookupByLibrary.simpleMessage("기기 연결"),
        "ListPage_k4": MessageLookupByLibrary.simpleMessage("오디오 가져오기"),
        "ListPage_k5": MessageLookupByLibrary.simpleMessage("기기를 먼저 연결하세요"),
        "ListPage_k6": MessageLookupByLibrary.simpleMessage("녹음 시작"),
        "ListPage_k7": MessageLookupByLibrary.simpleMessage("파일"),
        "ListPage_k8": MessageLookupByLibrary.simpleMessage("기기 연결"),
        "ListPage_k9": MessageLookupByLibrary.simpleMessage("일괄 가져오기"),
        "ListPage_menu_name": MessageLookupByLibrary.simpleMessage("파일"),
        "LoginPage_Privacy": MessageLookupByLibrary.simpleMessage("개인정보 처리방침"),
        "LoginPage_and": MessageLookupByLibrary.simpleMessage("및"),
        "LoginPage_apple": MessageLookupByLibrary.simpleMessage("Apple 로그인"),
        "LoginPage_continue_operator":
            MessageLookupByLibrary.simpleMessage("계속하면 동의하는 것입니다"),
        "LoginPage_email": MessageLookupByLibrary.simpleMessage("이메일 로그인"),
        "LoginPage_google": MessageLookupByLibrary.simpleMessage("Google 로그인"),
        "LoginPage_user_agreement":
            MessageLookupByLibrary.simpleMessage("이용약관"),
        "MemPage_k1": MessageLookupByLibrary.simpleMessage("멤버십"),
        "MemPage_k10": MessageLookupByLibrary.simpleMessage("AI 질문"),
        "MemPage_k11": MessageLookupByLibrary.simpleMessage("스마트 분석"),
        "MemPage_k12": MessageLookupByLibrary.simpleMessage("가져오기"),
        "MemPage_k13": MessageLookupByLibrary.simpleMessage("어디서나 가져오기"),
        "MemPage_k14": MessageLookupByLibrary.simpleMessage("내보내기"),
        "MemPage_k15": MessageLookupByLibrary.simpleMessage("다양한 형식"),
        "MemPage_k16": MessageLookupByLibrary.simpleMessage("Pro로 업그레이드"),
        "MemPage_k17": MessageLookupByLibrary.simpleMessage("업그레이드"),
        "MemPage_k18": MessageLookupByLibrary.simpleMessage("시간 추가"),
        "MemPage_k19": MessageLookupByLibrary.simpleMessage("모든 상황에 대응"),
        "MemPage_k2": MessageLookupByLibrary.simpleMessage("Pro"),
        "MemPage_k20": MessageLookupByLibrary.simpleMessage("환불 불가"),
        "MemPage_k21": MessageLookupByLibrary.simpleMessage("365일 유효"),
        "MemPage_k22": MessageLookupByLibrary.simpleMessage("결제"),
        "MemPage_k23": MessageLookupByLibrary.simpleMessage("WeChat Pay"),
        "MemPage_k24": MessageLookupByLibrary.simpleMessage("PayPal"),
        "MemPage_k3": MessageLookupByLibrary.simpleMessage("모든 기능"),
        "MemPage_k4": MessageLookupByLibrary.simpleMessage("잔액"),
        "MemPage_k5": MessageLookupByLibrary.simpleMessage("분"),
        "MemPage_k6": MessageLookupByLibrary.simpleMessage("만료"),
        "MemPage_k7": MessageLookupByLibrary.simpleMessage("Pro 기능"),
        "MemPage_k8": MessageLookupByLibrary.simpleMessage("Pro 템플릿"),
        "MemPage_k9": MessageLookupByLibrary.simpleMessage("전문가용 템플릿"),
        "OperateFilePage_k1": MessageLookupByLibrary.simpleMessage("파일 검색"),
        "OperateFilePage_k10":
            MessageLookupByLibrary.simpleMessage("선택한 파일을 삭제하시겠습니까?"),
        "OperateFilePage_k11":
            MessageLookupByLibrary.simpleMessage("되돌릴 수 없습니다"),
        "OperateFilePage_k12":
            MessageLookupByLibrary.simpleMessage("기기 파일도 삭제"),
        "OperateFilePage_k13": MessageLookupByLibrary.simpleMessage("취소"),
        "OperateFilePage_k14": MessageLookupByLibrary.simpleMessage("삭제"),
        "OperateFilePage_k2": MessageLookupByLibrary.simpleMessage("완료"),
        "OperateFilePage_k3": MessageLookupByLibrary.simpleMessage("이름 변경"),
        "OperateFilePage_k4": MessageLookupByLibrary.simpleMessage("삭제"),
        "OperateFilePage_k5": MessageLookupByLibrary.simpleMessage("이름 변경"),
        "OperateFilePage_k6": MessageLookupByLibrary.simpleMessage("파일 이름 입력"),
        "OperateFilePage_k7": MessageLookupByLibrary.simpleMessage("취소"),
        "OperateFilePage_k8": MessageLookupByLibrary.simpleMessage("저장"),
        "OperateFilePage_k9": MessageLookupByLibrary.simpleMessage("파일 이름 필수"),
        "PenPageList_k1": MessageLookupByLibrary.simpleMessage("스마트 펜"),
        "PenPageList_k10": MessageLookupByLibrary.simpleMessage("기능"),
        "PenPageList_k11": MessageLookupByLibrary.simpleMessage("변환"),
        "PenPageList_k12": MessageLookupByLibrary.simpleMessage("정확한 변환"),
        "PenPageList_k13": MessageLookupByLibrary.simpleMessage("실시간"),
        "PenPageList_k14": MessageLookupByLibrary.simpleMessage("실시간 텍스트"),
        "PenPageList_k15": MessageLookupByLibrary.simpleMessage("편집"),
        "PenPageList_k16": MessageLookupByLibrary.simpleMessage("언제든지 편집"),
        "PenPageList_k17": MessageLookupByLibrary.simpleMessage("언어"),
        "PenPageList_k18": MessageLookupByLibrary.simpleMessage("다국어 지원"),
        "PenPageList_k19": MessageLookupByLibrary.simpleMessage("요약"),
        "PenPageList_k2": MessageLookupByLibrary.simpleMessage("로딩 중..."),
        "PenPageList_k20": MessageLookupByLibrary.simpleMessage("핵심 포인트"),
        "PenPageList_k21": MessageLookupByLibrary.simpleMessage("AI 질문"),
        "PenPageList_k22": MessageLookupByLibrary.simpleMessage("AI 어시스턴트"),
        "PenPageList_k23": MessageLookupByLibrary.simpleMessage("지금 연결"),
        "PenPageList_k3": MessageLookupByLibrary.simpleMessage("로드 실패"),
        "PenPageList_k4": MessageLookupByLibrary.simpleMessage("재시도"),
        "PenPageList_k5": MessageLookupByLibrary.simpleMessage("기기 정보 없음"),
        "PenPageList_k6": MessageLookupByLibrary.simpleMessage("탭하여 새로고침"),
        "PenPageList_k7": MessageLookupByLibrary.simpleMessage("새로고침"),
        "PenPageList_k8": MessageLookupByLibrary.simpleMessage("로드 실패"),
        "PenPageList_k9": MessageLookupByLibrary.simpleMessage("AI 스마트 펜"),
        "PenPageList_v1_desc": MessageLookupByLibrary.simpleMessage(
            "브로드캐스트 이름 GSS-01, 실시간 변환 및 AI 분석 지원"),
        "PenPageList_v1_title": MessageLookupByLibrary.simpleMessage("녹음기 V1"),
        "PenPageList_v2_connect": MessageLookupByLibrary.simpleMessage("지금 연결"),
        "PenPageList_v2_desc": MessageLookupByLibrary.simpleMessage(
            "브로드캐스트 이름 AI-RTCAPEN, 실시간 변환 및 AI 분석 지원"),
        "PenPageList_v2_title": MessageLookupByLibrary.simpleMessage("녹음기 V2"),
        "PenPage_k1": MessageLookupByLibrary.simpleMessage("설명"),
        "PenPage_k2": MessageLookupByLibrary.simpleMessage("처음엔 수동 연결, 이후 자동"),
        "PenPage_k3": MessageLookupByLibrary.simpleMessage("연결 해제 시 확인:"),
        "PenPage_k4": MessageLookupByLibrary.simpleMessage("블루투스 켜짐"),
        "PenPage_k5": MessageLookupByLibrary.simpleMessage("기기 전원 켜짐"),
        "PenPage_k6": MessageLookupByLibrary.simpleMessage("다음"),
        "PlayerPage_k1": MessageLookupByLibrary.simpleMessage("변환"),
        "PlayerPage_k10": MessageLookupByLibrary.simpleMessage("이름 입력"),
        "PlayerPage_k11": MessageLookupByLibrary.simpleMessage("취소"),
        "PlayerPage_k12": MessageLookupByLibrary.simpleMessage("저장"),
        "PlayerPage_k13": MessageLookupByLibrary.simpleMessage("이름 필수"),
        "PlayerPage_k14": MessageLookupByLibrary.simpleMessage("저장됨"),
        "PlayerPage_k15": MessageLookupByLibrary.simpleMessage("공유"),
        "PlayerPage_k16": MessageLookupByLibrary.simpleMessage("오디오 내보내기"),
        "PlayerPage_k17": MessageLookupByLibrary.simpleMessage("텍스트 내보내기"),
        "PlayerPage_k18": MessageLookupByLibrary.simpleMessage("요약 내보내기"),
        "PlayerPage_k19": MessageLookupByLibrary.simpleMessage("형식"),
        "PlayerPage_k2": MessageLookupByLibrary.simpleMessage("높은 정확도"),
        "PlayerPage_k20": MessageLookupByLibrary.simpleMessage("내보내기"),
        "PlayerPage_k21": MessageLookupByLibrary.simpleMessage("타임스탬프"),
        "PlayerPage_k22": MessageLookupByLibrary.simpleMessage("AI"),
        "PlayerPage_k23": MessageLookupByLibrary.simpleMessage("다시 요약을 탭하여 요약 표시"),
        "PlayerPage_k24": MessageLookupByLibrary.simpleMessage("먼저 변환"),
        "PlayerPage_k25": MessageLookupByLibrary.simpleMessage("수정순"),
        "PlayerPage_k26": MessageLookupByLibrary.simpleMessage("생성순"),
        "PlayerPage_k27": MessageLookupByLibrary.simpleMessage("필터"),
        "PlayerPage_k28": MessageLookupByLibrary.simpleMessage("출시 예정"),
        "PlayerPage_k29": MessageLookupByLibrary.simpleMessage("업로드"),
        "PlayerPage_k3": MessageLookupByLibrary.simpleMessage("변환 중..."),
        "PlayerPage_k30": MessageLookupByLibrary.simpleMessage("동기화"),
        "PlayerPage_k31": MessageLookupByLibrary.simpleMessage("로드 실패"),
        "PlayerPage_k32": MessageLookupByLibrary.simpleMessage("오류"),
        "PlayerPage_k33": MessageLookupByLibrary.simpleMessage("대기"),
        "PlayerPage_k34": MessageLookupByLibrary.simpleMessage("AI 변환"),
        "PlayerPage_k35": MessageLookupByLibrary.simpleMessage("언어"),
        "PlayerPage_k36": MessageLookupByLibrary.simpleMessage("템플릿"),
        "PlayerPage_k37": MessageLookupByLibrary.simpleMessage("먼저 변환"),
        "PlayerPage_k38": MessageLookupByLibrary.simpleMessage("생각 중..."),
        "PlayerPage_k39": MessageLookupByLibrary.simpleMessage("AI 정리"),
        "PlayerPage_k4": MessageLookupByLibrary.simpleMessage("더 보기"),
        "PlayerPage_k40": MessageLookupByLibrary.simpleMessage("AI 질문"),
        "PlayerPage_k41": MessageLookupByLibrary.simpleMessage("질문"),
        "PlayerPage_k42": MessageLookupByLibrary.simpleMessage("복사됨"),
        "PlayerPage_k43": MessageLookupByLibrary.simpleMessage("텍스트 복사"),
        "PlayerPage_k44": MessageLookupByLibrary.simpleMessage("비어 있음"),
        "PlayerPage_k45": MessageLookupByLibrary.simpleMessage("요약 복사"),
        "PlayerPage_k46": MessageLookupByLibrary.simpleMessage("비어 있음"),
        "PlayerPage_k47": MessageLookupByLibrary.simpleMessage("공유"),
        "PlayerPage_k48": MessageLookupByLibrary.simpleMessage("더보기"),
        "PlayerPage_k49": m0,
        "PlayerPage_k5": MessageLookupByLibrary.simpleMessage("언어"),
        "PlayerPage_k6": MessageLookupByLibrary.simpleMessage("템플릿"),
        "PlayerPage_k7": MessageLookupByLibrary.simpleMessage("제출"),
        "PlayerPage_k8": MessageLookupByLibrary.simpleMessage("성공"),
        "PlayerPage_k9": MessageLookupByLibrary.simpleMessage("이름 편집"),
        "PrivacyPolicyPage_k1": MessageLookupByLibrary.simpleMessage("개인정보"),
        "PrivacyPolicyPage_k2": MessageLookupByLibrary.simpleMessage("로딩 중..."),
        "ProfilePage_k1": MessageLookupByLibrary.simpleMessage("멤버십"),
        "ProfilePage_k10": MessageLookupByLibrary.simpleMessage("바인딩"),
        "ProfilePage_k11": MessageLookupByLibrary.simpleMessage("로그아웃하시겠습니까?"),
        "ProfilePage_k12": MessageLookupByLibrary.simpleMessage("취소"),
        "ProfilePage_k13": MessageLookupByLibrary.simpleMessage("오류"),
        "ProfilePage_k14": MessageLookupByLibrary.simpleMessage("로그아웃"),
        "ProfilePage_k15": MessageLookupByLibrary.simpleMessage("코드 입력"),
        "ProfilePage_k16": MessageLookupByLibrary.simpleMessage("취소"),
        "ProfilePage_k17": MessageLookupByLibrary.simpleMessage("잘못된 코드"),
        "ProfilePage_k18": MessageLookupByLibrary.simpleMessage("사용된 코드"),
        "ProfilePage_k19": MessageLookupByLibrary.simpleMessage("실패"),
        "ProfilePage_k2": MessageLookupByLibrary.simpleMessage("기록"),
        "ProfilePage_k20": MessageLookupByLibrary.simpleMessage("활성화"),
        "ProfilePage_k21": MessageLookupByLibrary.simpleMessage("계정 및 보안"),
        "ProfilePage_k3": MessageLookupByLibrary.simpleMessage("주문"),
        "ProfilePage_k4": MessageLookupByLibrary.simpleMessage("피드백"),
        "ProfilePage_k5": MessageLookupByLibrary.simpleMessage("도움말"),
        "ProfilePage_k6": MessageLookupByLibrary.simpleMessage("캐시 삭제"),
        "ProfilePage_k7": MessageLookupByLibrary.simpleMessage("정보"),
        "ProfilePage_k8": MessageLookupByLibrary.simpleMessage("기기 바인딩"),
        "ProfilePage_k9": MessageLookupByLibrary.simpleMessage("기기 코드로 바인딩"),
        "RecordPenWidget_k1": MessageLookupByLibrary.simpleMessage("녹음펜 녹음"),
        "RecordPenWidget_k2": MessageLookupByLibrary.simpleMessage("언어 선택"),
        "RecordSourceEnum_import": MessageLookupByLibrary.simpleMessage("가져오기"),
        "RecordSourceEnum_pen": MessageLookupByLibrary.simpleMessage("녹음펜"),
        "RegisterPage_email_address":
            MessageLookupByLibrary.simpleMessage("이메일"),
        "RegisterPage_k1": MessageLookupByLibrary.simpleMessage("회원가입"),
        "RegisterPage_k2": MessageLookupByLibrary.simpleMessage("계정 만들기"),
        "RegisterPage_k3": MessageLookupByLibrary.simpleMessage("정보 입력"),
        "RegisterPage_k4":
            MessageLookupByLibrary.simpleMessage("가입하면 동의하는 것입니다"),
        "RegisterPage_k5": MessageLookupByLibrary.simpleMessage("이용약관"),
        "RegisterPage_k6": MessageLookupByLibrary.simpleMessage("및"),
        "RegisterPage_k7": MessageLookupByLibrary.simpleMessage("개인정보 처리방침"),
        "RegisterPage_password": MessageLookupByLibrary.simpleMessage("비밀번호"),
        "RegisterPage_register": MessageLookupByLibrary.simpleMessage("다음"),
        "RegisterPage_send_verifycode":
            MessageLookupByLibrary.simpleMessage("인증번호 받기"),
        "RegisterPage_user_exist":
            MessageLookupByLibrary.simpleMessage("이미 가입된 이메일"),
        "RegisterPage_verification_code":
            MessageLookupByLibrary.simpleMessage("인증번호"),
        "RegisterPage_verify_password":
            MessageLookupByLibrary.simpleMessage("비밀번호 확인"),
        "ResetPasswordPage_commit_error":
            MessageLookupByLibrary.simpleMessage("재설정 실패"),
        "ResetPasswordPage_confirm_password_empty_error":
            MessageLookupByLibrary.simpleMessage("비밀번호 확인"),
        "ResetPasswordPage_confirm_password_format_error":
            MessageLookupByLibrary.simpleMessage("잘못된 형식"),
        "ResetPasswordPage_form_commit":
            MessageLookupByLibrary.simpleMessage("시작"),
        "ResetPasswordPage_k1":
            MessageLookupByLibrary.simpleMessage("비밀번호 재설정"),
        "ResetPasswordPage_k2":
            MessageLookupByLibrary.simpleMessage("정보를 입력하여 재설정"),
        "ResetPasswordPage_k3": MessageLookupByLibrary.simpleMessage("초"),
        "ResetPasswordPage_password_error":
            MessageLookupByLibrary.simpleMessage("비밀번호가 일치하지 않습니다"),
        "ResetPasswordPage_reset_password":
            MessageLookupByLibrary.simpleMessage("비밀번호 재설정"),
        "ResetPasswordPage_success":
            MessageLookupByLibrary.simpleMessage("재설정 완료"),
        "ResetPasswordPage_user_not_found":
            MessageLookupByLibrary.simpleMessage("이메일을 찾을 수 없음"),
        "ResetPasswordPage_verifyCode_empty":
            MessageLookupByLibrary.simpleMessage("인증번호 입력"),
        "ResetPasswordPage_verifyCode_resend":
            MessageLookupByLibrary.simpleMessage("재전송"),
        "ResetPasswordPage_verifyCode_send_error":
            MessageLookupByLibrary.simpleMessage("전송 실패"),
        "ResetPasswordPage_verifyCode_send_success":
            MessageLookupByLibrary.simpleMessage("전송 완료"),
        "SearchFilePage_k1": MessageLookupByLibrary.simpleMessage("파일 검색"),
        "SearchFilePage_k2": MessageLookupByLibrary.simpleMessage("취소"),
        "SummaryPage_regenerate": MessageLookupByLibrary.simpleMessage("다시 요약"),
        "SummaryPage_regenerateFailed": MessageLookupByLibrary.simpleMessage(
            "다시 요약에 실패했습니다. 잠시 후 다시 시도해 주세요"),
        "SummaryPage_regenerating":
            MessageLookupByLibrary.simpleMessage("다시 요약하는 중..."),
        "SyncAudioWidget_k1":
            MessageLookupByLibrary.simpleMessage("오디오 파일 동기화 중"),
        "TradeRecordPage_k1": MessageLookupByLibrary.simpleMessage("주문"),
        "TradeRecordPage_k2": MessageLookupByLibrary.simpleMessage("주문 없음"),
        "TradeRecordPage_k3": MessageLookupByLibrary.simpleMessage("금액"),
        "TradeRecordPage_k4": MessageLookupByLibrary.simpleMessage("시간"),
        "TradeRecordPage_k5": MessageLookupByLibrary.simpleMessage("상태"),
        "TradeRecordPage_k6": MessageLookupByLibrary.simpleMessage("성공"),
        "TradeRecordPage_k7": MessageLookupByLibrary.simpleMessage("실패"),
        "TradeRecordPage_k8": MessageLookupByLibrary.simpleMessage("취소됨"),
        "UserAgreementPage_k1": MessageLookupByLibrary.simpleMessage("이용약관"),
        "UserAgreementPage_k2": MessageLookupByLibrary.simpleMessage("로딩 중..."),
        "VerifyCodePage_code_invalidate":
            MessageLookupByLibrary.simpleMessage("인증번호 만료"),
        "VerifyCodePage_k1": MessageLookupByLibrary.simpleMessage("인증번호 확인"),
        "VerifyCodePage_k2": MessageLookupByLibrary.simpleMessage("인증번호 입력"),
        "VerifyCodePage_k3": MessageLookupByLibrary.simpleMessage("이메일로 전송됨"),
        "VerifyCodePage_k4": MessageLookupByLibrary.simpleMessage("초"),
        "VerifyCodePage_k5":
            MessageLookupByLibrary.simpleMessage("계속하면 동의하는 것입니다"),
        "VerifyCodePage_k6": MessageLookupByLibrary.simpleMessage("이용약관"),
        "VerifyCodePage_k7": MessageLookupByLibrary.simpleMessage("및"),
        "VerifyCodePage_k8": MessageLookupByLibrary.simpleMessage("개인정보 처리방침"),
        "VerifyCodePage_resend_code_1":
            MessageLookupByLibrary.simpleMessage("재전송"),
        "VerifyCodePage_resend_code_2":
            MessageLookupByLibrary.simpleMessage("인증번호 미수신"),
        "app_title": MessageLookupByLibrary.simpleMessage("YiguoAi")
      };
}
