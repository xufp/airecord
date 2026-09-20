// 日本語
export default {
  common: {
    confirm: 'OK',
    cancel: 'キャンセル',
    submit: '送信',
    search: '検索',
    reset: 'リセット',
    refresh: '更新',
    detail: '詳細',
    tip: 'ヒント',
    unknown: '不明',
    backToLogin: 'ログインへ戻る',
    sendCode: 'コードを取得',
    resendIn: '{n}秒後に再送信',
    minutes: '分',
    of: '/',
    yes: 'はい',
    no: 'いいえ',
    none: '-',
    copyright: '© {year} YiGuo Voice. All rights reserved.'
  },
  language: {
    label: '言語',
    'zh-CN': '简体中文',
    'en-US': 'English',
    'ja-JP': '日本語',
    'ko-KR': '한국어'
  },
  header: {
    brand: 'YiGuo Voice',
    sub: 'プラン購入',
    nav: {
      packages: 'プラン購入',
      orders: '注文履歴',
      profile: 'マイページ'
    },
    accountFallback: 'マイアカウント',
    login: 'ログイン',
    logout: 'ログアウト',
    logoutConfirm: 'ログアウトしますか？'
  },
  login: {
    titleLogin: 'ログインしてプランを購入・残高確認',
    email: 'メールアドレス',
    password: 'パスワード',
    forgot: 'パスワードを忘れた？',
    login: 'ログイン',
    rules: {
      emailRequired: 'メールアドレスを入力してください',
      emailInvalid: 'メールアドレスの形式が正しくありません',
      passwordRequired: 'パスワードを入力してください',
      passwordMin: 'パスワードは8文字以上です'
    },
    msg: {
      loginSuccess: 'ログインしました',
      loginFail: 'ログインに失敗しました'
    },
    agreeTip: 'ログインすることで、',
    userAgreement: '利用規約',
    and: ' と ',
    privacyPolicy: 'プライバシーポリシー'
  },
  reset: {
    title: 'パスワード再設定',
    subtitle: 'メール認証コードでパスワードを再設定します',
    newPassword: '新しいパスワード（8文字以上）',
    confirmPassword: '新しいパスワード（確認）',
    submit: 'パスワードを再設定',
    rules: {
      confirmRequired: 'パスワードをもう一度入力してください',
      mismatch: 'パスワードが一致しません',
      newPwdRequired: '新しいパスワードを入力してください'
    },
    msg: {
      success: 'パスワードを再設定しました。新しいパスワードでログインしてください。'
    }
  },
  packages: {
    title: 'プラン購入',
    leftQuotaPrefix: '残り',
    tabs: {
      paid: '有料プラン',
      subscription: 'サブスク',
      free: '無料体験'
    },
    empty: '購入可能なプランはありません',
    confirmDialog: '注文確認',
    fields: {
      packageName: 'プラン名',
      payable: 'お支払い金額',
      payChannel: '支払い方法'
    },
    payChannels: {
      paypal: 'クレジットカード / PayPal 残高'
    },
    actions: {
      goPay: '支払いへ進む'
    },
    msg: {
      receiveConfirm: '「{name}」を受け取りますか？',
      receiveSuccess: 'プランを受け取りました',
      noPayLink: '支払いリンクの取得に失敗しました。後でやり直してください。',
      redirecting: 'PayPalへ移動中...'
    },
    card: {
      noDesc: '説明はありません',
      free: '無料',
      claim: '無料で受け取る',
      subscribe: 'サブスクで購入',
      buyNow: '今すぐ購入',
      recommend: 'おすすめ',
      tagFree: '無料体験',
      tagPaid: '有料プラン',
      tagSubscription: 'サブスク',
      tagDefault: 'プラン'
    }
  },
  orders: {
    title: '注文履歴',
    filter: {
      state: '注文ステータス',
      all: 'すべて'
    },
    columns: {
      orderId: '注文番号',
      packageName: 'プラン名',
      amount: 'お支払い金額',
      payChannel: '支払いチャネル',
      payTime: '支払い時間',
      state: 'ステータス',
      actions: '操作'
    },
    empty: '注文はありません',
    detailTitle: '注文詳細',
    states: {
      1: '未払い',
      2: '支払い済み',
      3: '支払い失敗',
      4: '配送/有効化済み',
      5: '解約済み'
    },
    payChannels: {
      1: 'PayPal',
      other: 'チャネル {n}'
    }
  },
  profile: {
    title: 'マイページ',
    cards: {
      account: 'アカウント情報',
      changePwd: 'パスワード変更',
      quota: '文字起こし残高',
      tips: 'お知らせ'
    },
    fields: {
      sex: '性別',
      country: '国',
      location: '所在地',
      memberExpire: '有効期限',
      memberLevel: '会員ランク：Lv.{n}',
      defaultName: '未設定ユーザー',
      currentPwd: '現在のパスワード',
      newPwd: '新しいパスワード',
      confirmPwd: '新しいパスワード（確認）'
    },
    sex: { male: '男性', female: '女性' },
    quota: {
      used: '使用量 / 総量',
      left: '残り：',
      buy: 'プランを購入',
      orders: '注文を見る'
    },
    tips: [
      'プランの購入はWebのみで提供しており、購入後はAppに自動同期されます。',
      'お支払いは通常数秒以内に反映されます。反映されない場合は注文ステータスを更新してください。',
      '請求書やその他のサポートが必要な場合は、Appからフィードバックをお送りください。'
    ],
    pwd: {
      success: 'パスワードを変更しました',
      rules: {
        currentRequired: '現在のパスワードを入力してください',
        newRequired: '新しいパスワードを入力してください',
        newMin: 'パスワードは8文字以上です',
        confirmRequired: '新しいパスワードをもう一度入力してください',
        mismatch: 'パスワードが一致しません'
      }
    }
  },
  pay: {
    success: {
      title: '支払い完了',
      loading: '注文ステータスを確認中...',
      ok: 'プラン {name} の購入が完了し、内容が自動的に付与されました。',
      fallback: 'お支払いは完了しました。プランが未反映の場合は後ほど注文をご確認ください。',
      continue: '続けて購入',
      orders: '注文を見る',
      orderId: '注文番号',
      amount: 'お支払い金額',
      state: '注文ステータス'
    },
    cancel: {
      title: '支払いがキャンセルされました',
      desc: '今回の支払いをキャンセルしました。注文は有効になっていません。必要であれば再度ご注文ください。',
      retry: '再度購入',
      orders: '注文を見る'
    }
  },
  http: {
    fail: 'リクエストに失敗しました',
    badRequest: 'リクエストパラメータエラー',
    forbidden: '権限が不足しています',
    notFound: 'リソースが見つかりません',
    serverError: 'サーバー内部エラー',
    failWithCode: 'リクエストに失敗しました ({code})',
    network: 'ネットワーク接続に失敗しました。接続を確認してください。',
    unknown: '不明なエラー'
  }
}
