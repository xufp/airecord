// 简体中文
export default {
  common: {
    confirm: '确定',
    cancel: '取消',
    submit: '提交',
    search: '查询',
    reset: '重置',
    refresh: '刷新',
    detail: '详情',
    tip: '提示',
    unknown: '未知',
    backToLogin: '返回登录',
    sendCode: '获取验证码',
    resendIn: '{n}s 后重发',
    minutes: '分钟',
    of: '/',
    yes: '是',
    no: '否',
    none: '-',
    copyright: '© {year} YiGuo Voice. All rights reserved.'
  },
  language: {
    label: '语言',
    'zh-CN': '简体中文',
    'en-US': 'English',
    'ja-JP': '日本語',
    'ko-KR': '한국어'
  },
  header: {
    brand: 'YiGuo Voice',
    sub: '套餐购买',
    nav: {
      packages: '套餐购买',
      orders: '我的订单',
      profile: '个人中心'
    },
    accountFallback: '我的账号',
    login: '登录',
    logout: '退出登录',
    logoutConfirm: '确认退出登录？'
  },
  login: {
    titleLogin: '登录后购买套餐 · 查看余额',
    email: '邮箱',
    password: '密码',
    forgot: '忘记密码？',
    login: '登录',
    rules: {
      emailRequired: '请输入邮箱',
      emailInvalid: '邮箱格式不正确',
      passwordRequired: '请输入密码',
      passwordMin: '密码至少 8 位'
    },
    msg: {
      loginSuccess: '登录成功',
      loginFail: '登录失败'
    },
    agreeTip: '登录即视为同意 ',
    userAgreement: '用户协议',
    and: '和 ',
    privacyPolicy: '隐私政策'
  },
  reset: {
    title: '重置密码',
    subtitle: '通过邮箱验证码重置登录密码',
    newPassword: '新密码（8 位以上）',
    confirmPassword: '确认新密码',
    submit: '重置密码',
    rules: {
      confirmRequired: '请再次输入密码',
      mismatch: '两次密码不一致',
      newPwdRequired: '请输入新密码'
    },
    msg: {
      success: '密码已重置，请使用新密码登录'
    }
  },
  packages: {
    title: '套餐购买',
    leftQuotaPrefix: '剩余',
    tabs: {
      paid: '付费套餐',
      subscription: '订阅计划',
      free: '免费体验'
    },
    empty: '暂无可购买的套餐',
    confirmDialog: '确认下单',
    fields: {
      packageName: '套餐名称',
      payable: '应付金额',
      payChannel: '支付方式'
    },
    payChannels: {
      paypal: '海外信用卡 / PayPal 余额'
    },
    actions: {
      goPay: '前往支付'
    },
    msg: {
      receiveConfirm: '确认领取「{name}」吗？',
      receiveSuccess: '套餐领取成功',
      noPayLink: '未能获取支付链接，请稍后再试',
      redirecting: '正在跳转 PayPal...'
    },
    card: {
      noDesc: '暂无描述',
      free: '免费',
      claim: '免费领取',
      subscribe: '订阅购买',
      buyNow: '立即购买',
      recommend: '推荐',
      tagFree: '免费体验',
      tagPaid: '付费购买',
      tagSubscription: '订阅计划',
      tagDefault: '套餐'
    }
  },
  orders: {
    title: '我的订单',
    filter: {
      state: '订单状态',
      all: '全部'
    },
    columns: {
      orderId: '订单号',
      packageName: '套餐名称',
      amount: '支付金额',
      payChannel: '支付渠道',
      payTime: '支付时间',
      state: '状态',
      actions: '操作'
    },
    empty: '暂无订单',
    detailTitle: '订单详情',
    states: {
      1: '待支付',
      2: '已支付',
      3: '支付失败',
      4: '已发货/已激活',
      5: '订阅已取消'
    },
    payChannels: {
      1: 'PayPal',
      other: '渠道 {n}'
    }
  },
  profile: {
    title: '个人中心',
    cards: {
      account: '账号信息',
      changePwd: '修改密码',
      quota: '语音转写余额',
      tips: '温馨提示'
    },
    fields: {
      sex: '性别',
      country: '国家',
      location: '所在地',
      memberExpire: '会员到期',
      memberLevel: '会员等级：Lv.{n}',
      defaultName: '未命名用户',
      currentPwd: '当前密码',
      newPwd: '新密码',
      confirmPwd: '确认新密码'
    },
    sex: { male: '男', female: '女' },
    quota: {
      used: '已用量 / 总量',
      left: '剩余可用：',
      buy: '立即购买套餐',
      orders: '查看订单'
    },
    tips: [
      '套餐购买仅在 Web 端开放，购买后将自动同步到 App 中。',
      '支付成功后通常会在数秒内到账，如长时间未到账请刷新订单状态。',
      '如需发票或其他支持，请通过 App 提交反馈。'
    ],
    pwd: {
      success: '密码修改成功',
      rules: {
        currentRequired: '请输入当前密码',
        newRequired: '请输入新密码',
        newMin: '密码至少 8 位',
        confirmRequired: '请再次输入新密码',
        mismatch: '两次密码不一致'
      }
    }
  },
  pay: {
    success: {
      title: '支付成功',
      loading: '订单状态查询中...',
      ok: '套餐 {name} 已购买成功，套餐内容已自动到账。',
      fallback: '支付已完成。如套餐未到账，请稍后查看订单状态。',
      continue: '继续购买',
      orders: '查看订单',
      orderId: '订单号',
      amount: '支付金额',
      state: '订单状态'
    },
    cancel: {
      title: '支付已取消',
      desc: '您取消了本次支付，订单未生效。如需购买，请重新发起。',
      retry: '重新选购',
      orders: '查看订单'
    }
  },
  http: {
    fail: '请求失败',
    badRequest: '请求参数错误',
    forbidden: '权限不足',
    notFound: '请求的资源不存在',
    serverError: '服务器内部错误',
    failWithCode: '请求失败 ({code})',
    network: '网络连接失败，请检查网络设置',
    unknown: '未知错误'
  }
}
