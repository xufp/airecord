// 한국어
export default {
  common: {
    confirm: '확인',
    cancel: '취소',
    submit: '제출',
    search: '조회',
    reset: '초기화',
    refresh: '새로고침',
    detail: '상세',
    tip: '안내',
    unknown: '알 수 없음',
    backToLogin: '로그인으로 돌아가기',
    sendCode: '인증코드 받기',
    resendIn: '{n}초 후 재전송',
    minutes: '분',
    of: '/',
    yes: '예',
    no: '아니오',
    none: '-',
    copyright: '© {year} YiGuo Voice. All rights reserved.'
  },
  language: {
    label: '언어',
    'zh-CN': '简体中文',
    'en-US': 'English',
    'ja-JP': '日本語',
    'ko-KR': '한국어'
  },
  header: {
    brand: 'YiGuo Voice',
    sub: '플랜 구매',
    nav: {
      packages: '플랜 구매',
      orders: '주문 내역',
      profile: '마이페이지'
    },
    accountFallback: '내 계정',
    login: '로그인',
    logout: '로그아웃',
    logoutConfirm: '로그아웃하시겠습니까?'
  },
  login: {
    titleLogin: '로그인 후 플랜 구매 · 잔액 확인',
    email: '이메일',
    password: '비밀번호',
    forgot: '비밀번호를 잊으셨나요?',
    login: '로그인',
    rules: {
      emailRequired: '이메일을 입력하세요',
      emailInvalid: '이메일 형식이 올바르지 않습니다',
      passwordRequired: '비밀번호를 입력하세요',
      passwordMin: '비밀번호는 8자 이상이어야 합니다'
    },
    msg: {
      loginSuccess: '로그인되었습니다',
      loginFail: '로그인에 실패했습니다'
    },
    agreeTip: '로그인 시 ',
    userAgreement: '이용약관',
    and: ' 및 ',
    privacyPolicy: '개인정보처리방침'
  },
  reset: {
    title: '비밀번호 재설정',
    subtitle: '이메일 인증코드로 비밀번호를 재설정합니다',
    newPassword: '새 비밀번호 (8자 이상)',
    confirmPassword: '새 비밀번호 확인',
    submit: '비밀번호 재설정',
    rules: {
      confirmRequired: '비밀번호를 다시 입력하세요',
      mismatch: '비밀번호가 일치하지 않습니다',
      newPwdRequired: '새 비밀번호를 입력하세요'
    },
    msg: {
      success: '비밀번호가 재설정되었습니다. 새 비밀번호로 로그인하세요.'
    }
  },
  packages: {
    title: '플랜 구매',
    leftQuotaPrefix: '잔여',
    tabs: {
      paid: '유료 플랜',
      subscription: '구독 플랜',
      free: '무료 체험'
    },
    empty: '구매 가능한 플랜이 없습니다',
    confirmDialog: '주문 확인',
    fields: {
      packageName: '플랜명',
      payable: '결제 금액',
      payChannel: '결제 수단'
    },
    payChannels: {
      paypal: '신용카드 / PayPal 잔액'
    },
    actions: {
      goPay: '결제하러 가기'
    },
    msg: {
      receiveConfirm: '「{name}」을(를) 수령하시겠습니까?',
      receiveSuccess: '플랜을 수령했습니다',
      noPayLink: '결제 링크를 가져오지 못했습니다. 잠시 후 다시 시도하세요.',
      redirecting: 'PayPal로 이동 중...'
    },
    card: {
      noDesc: '설명 없음',
      free: '무료',
      claim: '무료로 받기',
      subscribe: '구독 구매',
      buyNow: '바로 구매',
      recommend: '추천',
      tagFree: '무료 체험',
      tagPaid: '유료 플랜',
      tagSubscription: '구독',
      tagDefault: '플랜'
    }
  },
  orders: {
    title: '주문 내역',
    filter: {
      state: '주문 상태',
      all: '전체'
    },
    columns: {
      orderId: '주문번호',
      packageName: '플랜',
      amount: '결제 금액',
      payChannel: '결제 채널',
      payTime: '결제 시간',
      state: '상태',
      actions: '작업'
    },
    empty: '주문이 없습니다',
    detailTitle: '주문 상세',
    states: {
      1: '결제 대기',
      2: '결제 완료',
      3: '결제 실패',
      4: '발송/활성화',
      5: '구독 취소'
    },
    payChannels: {
      1: 'PayPal',
      other: '채널 {n}'
    }
  },
  profile: {
    title: '마이페이지',
    cards: {
      account: '계정 정보',
      changePwd: '비밀번호 변경',
      quota: '음성 변환 잔액',
      tips: '안내'
    },
    fields: {
      sex: '성별',
      country: '국가',
      location: '지역',
      memberExpire: '멤버십 만료',
      memberLevel: '멤버십 등급: Lv.{n}',
      defaultName: '이름 미설정',
      currentPwd: '현재 비밀번호',
      newPwd: '새 비밀번호',
      confirmPwd: '새 비밀번호 확인'
    },
    sex: { male: '남성', female: '여성' },
    quota: {
      used: '사용량 / 총량',
      left: '사용 가능:',
      buy: '플랜 바로 구매',
      orders: '주문 보기'
    },
    tips: [
      '플랜은 웹에서만 구매할 수 있으며, 구매 후 App에 자동 동기화됩니다.',
      '결제는 보통 몇 초 안에 반영됩니다. 반영되지 않으면 주문 상태를 새로고침하세요.',
      '세금계산서나 추가 지원이 필요하면 App에서 피드백을 남겨주세요.'
    ],
    pwd: {
      success: '비밀번호가 변경되었습니다',
      rules: {
        currentRequired: '현재 비밀번호를 입력하세요',
        newRequired: '새 비밀번호를 입력하세요',
        newMin: '비밀번호는 8자 이상이어야 합니다',
        confirmRequired: '새 비밀번호를 다시 입력하세요',
        mismatch: '비밀번호가 일치하지 않습니다'
      }
    }
  },
  pay: {
    success: {
      title: '결제 완료',
      loading: '주문 상태 확인 중...',
      ok: '플랜 {name} 구매가 완료되었으며 자동으로 적용되었습니다.',
      fallback: '결제가 완료되었습니다. 플랜이 반영되지 않은 경우 잠시 후 주문을 확인하세요.',
      continue: '계속 구매',
      orders: '주문 보기',
      orderId: '주문번호',
      amount: '결제 금액',
      state: '주문 상태'
    },
    cancel: {
      title: '결제가 취소되었습니다',
      desc: '이번 결제를 취소했으며 주문은 적용되지 않았습니다. 필요 시 다시 시도하세요.',
      retry: '다시 구매',
      orders: '주문 보기'
    }
  },
  http: {
    fail: '요청 실패',
    badRequest: '잘못된 요청입니다',
    forbidden: '권한이 없습니다',
    notFound: '리소스를 찾을 수 없습니다',
    serverError: '서버 내부 오류',
    failWithCode: '요청 실패 ({code})',
    network: '네트워크 연결에 실패했습니다. 연결 상태를 확인하세요.',
    unknown: '알 수 없는 오류'
  }
}
