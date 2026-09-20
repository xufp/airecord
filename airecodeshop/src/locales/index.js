import { createI18n } from 'vue-i18n'
import { reactive } from 'vue'
import zhCN from './zh-CN'
import enUS from './en-US'
import jaJP from './ja-JP'
import koKR from './ko-KR'

// Element Plus locale 包
import elZhCn from 'element-plus/es/locale/lang/zh-cn'
import elEn from 'element-plus/es/locale/lang/en'
import elJa from 'element-plus/es/locale/lang/ja'
import elKo from 'element-plus/es/locale/lang/ko'

export const SUPPORTED_LOCALES = [
  { code: 'zh-CN', label: '简体中文' },
  { code: 'en-US', label: 'English' },
  { code: 'ja-JP', label: '日本語' },
  { code: 'ko-KR', label: '한국어' }
]

const STORAGE_KEY = 'app_locale'

const ELEMENT_LOCALES = {
  'zh-CN': elZhCn,
  'en-US': elEn,
  'ja-JP': elJa,
  'ko-KR': elKo
}

function detectLocale() {
  const saved = localStorage.getItem(STORAGE_KEY)
  if (saved && SUPPORTED_LOCALES.some(l => l.code === saved)) return saved
  const nav = (navigator.language || 'zh-CN').toLowerCase()
  if (nav.startsWith('zh')) return 'zh-CN'
  if (nav.startsWith('ja')) return 'ja-JP'
  if (nav.startsWith('ko')) return 'ko-KR'
  if (nav.startsWith('en')) return 'en-US'
  return 'zh-CN'
}

export const initialLocale = detectLocale()

export const i18n = createI18n({
  legacy: false,
  globalInjection: true,
  locale: initialLocale,
  fallbackLocale: 'en-US',
  messages: {
    'zh-CN': zhCN,
    'en-US': enUS,
    'ja-JP': jaJP,
    'ko-KR': koKR
  }
})

// 暴露当前 Element Plus locale，让 main.js 中 ElementPlus 选项可响应式更新
export const elementLocaleState = reactive({
  current: ELEMENT_LOCALES[initialLocale] || elZhCn
})

// 把 i18n locale（如 en-US）映射成后端约定的语言代码（zh/en/ja/ko）。
// 与 app 端及后端 t_app_config 里的 package_{id}_{lang} key 保持一致。
export function apiLang(code) {
  const c = code || i18n.global.locale.value
  switch (c) {
    case 'en-US': return 'en'
    case 'ja-JP': return 'ja'
    case 'ko-KR': return 'ko'
    default: return 'zh'
  }
}

export function setLocale(code) {
  if (!SUPPORTED_LOCALES.some(l => l.code === code)) return
  i18n.global.locale.value = code
  localStorage.setItem(STORAGE_KEY, code)
  document.documentElement.lang = code
  elementLocaleState.current = ELEMENT_LOCALES[code] || elZhCn
}

// 初始化 <html lang>
if (typeof document !== 'undefined') {
  document.documentElement.lang = initialLocale
}
