import './assets/main.css'

import { createApp, computed, h } from 'vue'
import App from './App.vue'
import router from './router'
import ElementPlus, { ElConfigProvider } from 'element-plus'
import 'element-plus/dist/index.css'
import { i18n, elementLocaleState } from '@/locales'

// 包一层 ConfigProvider，使 Element Plus 的内置文案随语言切换
const RootApp = {
  name: 'RootApp',
  setup() {
    const locale = computed(() => elementLocaleState.current)
    return () => h(ElConfigProvider, { locale: locale.value }, () => h(App))
  }
}

const app = createApp(RootApp)
app.use(router)
app.use(i18n)
app.use(ElementPlus)
app.mount('#app')
