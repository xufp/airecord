// English
export default {
  common: {
    confirm: 'OK',
    cancel: 'Cancel',
    submit: 'Submit',
    search: 'Search',
    reset: 'Reset',
    refresh: 'Refresh',
    detail: 'Detail',
    tip: 'Tip',
    unknown: 'Unknown',
    backToLogin: 'Back to login',
    sendCode: 'Get code',
    resendIn: 'Resend in {n}s',
    minutes: 'min',
    of: '/',
    yes: 'Yes',
    no: 'No',
    none: '-',
    copyright: '© {year} YiGuo Voice. All rights reserved.'
  },
  language: {
    label: 'Language',
    'zh-CN': '简体中文',
    'en-US': 'English',
    'ja-JP': '日本語',
    'ko-KR': '한국어'
  },
  header: {
    brand: 'YiGuo Voice',
    sub: 'Plans',
    nav: {
      packages: 'Plans',
      orders: 'My Orders',
      profile: 'Profile'
    },
    accountFallback: 'My Account',
    login: 'Sign in',
    logout: 'Sign out',
    logoutConfirm: 'Sign out now?'
  },
  login: {
    titleLogin: 'Sign in to buy plans · check balance',
    email: 'Email',
    password: 'Password',
    forgot: 'Forgot password?',
    login: 'Sign in',
    rules: {
      emailRequired: 'Please enter email',
      emailInvalid: 'Invalid email format',
      passwordRequired: 'Please enter password',
      passwordMin: 'Password must be at least 8 chars'
    },
    msg: {
      loginSuccess: 'Signed in',
      loginFail: 'Sign in failed'
    },
    agreeTip: 'By signing in, you agree to the ',
    userAgreement: 'User Agreement',
    and: ' and ',
    privacyPolicy: 'Privacy Policy'
  },
  reset: {
    title: 'Reset password',
    subtitle: 'Reset your password via email verification code',
    newPassword: 'New password (min 8 chars)',
    confirmPassword: 'Confirm new password',
    submit: 'Reset password',
    rules: {
      confirmRequired: 'Please re-enter the password',
      mismatch: 'Passwords do not match',
      newPwdRequired: 'Please enter new password'
    },
    msg: {
      success: 'Password reset. Please sign in with the new password.'
    }
  },
  packages: {
    title: 'Buy Plans',
    leftQuotaPrefix: 'Left',
    tabs: {
      paid: 'Paid plans',
      subscription: 'Subscriptions',
      free: 'Free trial'
    },
    empty: 'No plan available',
    confirmDialog: 'Confirm order',
    fields: {
      packageName: 'Plan name',
      payable: 'Amount payable',
      payChannel: 'Payment method'
    },
    payChannels: {
      paypal: 'Credit card / PayPal balance'
    },
    actions: {
      goPay: 'Pay now'
    },
    msg: {
      receiveConfirm: 'Claim "{name}"?',
      receiveSuccess: 'Plan claimed',
      noPayLink: 'Failed to get payment link, please retry later',
      redirecting: 'Redirecting to PayPal...'
    },
    card: {
      noDesc: 'No description',
      free: 'Free',
      claim: 'Claim free',
      subscribe: 'Subscribe',
      buyNow: 'Buy now',
      recommend: 'Recommend',
      tagFree: 'Free trial',
      tagPaid: 'Paid plan',
      tagSubscription: 'Subscription',
      tagDefault: 'Plan'
    }
  },
  orders: {
    title: 'My Orders',
    filter: {
      state: 'Status',
      all: 'All'
    },
    columns: {
      orderId: 'Order ID',
      packageName: 'Plan',
      amount: 'Amount',
      payChannel: 'Channel',
      payTime: 'Paid at',
      state: 'Status',
      actions: 'Actions'
    },
    empty: 'No orders',
    detailTitle: 'Order detail',
    states: {
      1: 'Pending',
      2: 'Paid',
      3: 'Failed',
      4: 'Delivered',
      5: 'Cancelled'
    },
    payChannels: {
      1: 'PayPal',
      other: 'Channel {n}'
    }
  },
  profile: {
    title: 'Profile',
    cards: {
      account: 'Account info',
      changePwd: 'Change password',
      quota: 'Transcription balance',
      tips: 'Tips'
    },
    fields: {
      sex: 'Gender',
      country: 'Country',
      location: 'Location',
      memberExpire: 'Membership expires',
      memberLevel: 'Membership level: Lv.{n}',
      defaultName: 'Unnamed user',
      currentPwd: 'Current password',
      newPwd: 'New password',
      confirmPwd: 'Confirm new password'
    },
    sex: { male: 'Male', female: 'Female' },
    quota: {
      used: 'Used / Total',
      left: 'Available:',
      buy: 'Buy plan now',
      orders: 'View orders'
    },
    tips: [
      'Plans can only be purchased on Web; balance will sync to the App automatically.',
      'Payment usually settles within seconds. If not delivered, please refresh the order status.',
      'For invoices or further support, please submit feedback in the App.'
    ],
    pwd: {
      success: 'Password updated',
      rules: {
        currentRequired: 'Please enter current password',
        newRequired: 'Please enter new password',
        newMin: 'Password must be at least 8 chars',
        confirmRequired: 'Please re-enter the new password',
        mismatch: 'Passwords do not match'
      }
    }
  },
  pay: {
    success: {
      title: 'Payment successful',
      loading: 'Checking order status...',
      ok: 'Plan {name} purchased successfully and credited automatically.',
      fallback: 'Payment completed. If your plan is not credited yet, please check the order later.',
      continue: 'Continue shopping',
      orders: 'View orders',
      orderId: 'Order ID',
      amount: 'Amount',
      state: 'Status'
    },
    cancel: {
      title: 'Payment cancelled',
      desc: 'You cancelled this payment and the order is not active. Please retry if needed.',
      retry: 'Try again',
      orders: 'View orders'
    }
  },
  http: {
    fail: 'Request failed',
    badRequest: 'Bad request',
    forbidden: 'Forbidden',
    notFound: 'Not found',
    serverError: 'Server error',
    failWithCode: 'Request failed ({code})',
    network: 'Network error, please check your connection',
    unknown: 'Unknown error'
  }
}
