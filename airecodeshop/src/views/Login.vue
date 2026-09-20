<template>
  <div class="login-root">
    <div class="login-bg"></div>

    <!-- 登录页右上角语言切换 -->
    <div class="login-lang">
      <el-dropdown trigger="click" @command="onLangCmd">
        <span class="lang-link">
          <el-icon><Promotion /></el-icon>
          <span>{{ currentLangLabel }}</span>
          <el-icon><ArrowDown /></el-icon>
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item
              v-for="l in SUPPORTED_LOCALES"
              :key="l.code"
              :command="l.code"
              :class="{ 'is-current': l.code === locale }"
            >{{ l.label }}</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>

    <div class="login-card">
      <div class="login-brand">
        <div class="logo">YG</div>
        <div>
          <div class="title">{{ t('header.brand') }}</div>
          <div class="subtitle">{{ t('login.titleLogin') }}</div>
        </div>
      </div>

      <!-- 登录表单 -->
      <el-form
        :model="loginForm"
        :rules="loginRules"
        ref="loginRef"
        size="large"
        label-position="top"
        class="login-form"
        @submit.prevent="onLogin"
      >
        <el-form-item prop="email">
          <el-input v-model="loginForm.email" :placeholder="t('login.email')" clearable>
            <template #prefix><el-icon><Message /></el-icon></template>
          </el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="loginForm.password" type="password" :placeholder="t('login.password')" show-password>
            <template #prefix><el-icon><Lock /></el-icon></template>
          </el-input>
        </el-form-item>
        <div class="row-link">
          <router-link to="/reset-password">{{ t('login.forgot') }}</router-link>
        </div>
        <el-form-item>
          <el-button type="primary" style="width:100%" :loading="submitting" @click="onLogin">{{ t('login.login') }}</el-button>
        </el-form-item>
      </el-form>

      <div class="footer-tip muted">
        {{ t('login.agreeTip') }}<a :href="agreementUrl" target="_blank">{{ t('login.userAgreement') }}</a>{{ t('login.and') }}<a :href="privacyUrl" target="_blank">{{ t('login.privacyPolicy') }}</a>
      </div>
    </div>

    <div class="login-footer">{{ t('common.copyright', { year: new Date().getFullYear() }) }}</div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ElMessage } from 'element-plus'
import { Message, Lock, ArrowDown, Promotion } from '@element-plus/icons-vue'
import { login } from '@/api/auth'
import { userStore } from '@/stores/user'
import { SUPPORTED_LOCALES, setLocale } from '@/locales'

const route = useRoute()
const router = useRouter()
const { t, locale } = useI18n()

const submitting = ref(false)
const loginRef = ref(null)
const loginForm = reactive({ email: '', password: '' })

const emailRule = computed(() => ([
  { required: true, message: t('login.rules.emailRequired'), trigger: 'blur' },
  { type: 'email', message: t('login.rules.emailInvalid'), trigger: 'blur' }
]))
const passwordRule = computed(() => ([
  { required: true, message: t('login.rules.passwordRequired'), trigger: 'blur' },
  { min: 8, message: t('login.rules.passwordMin'), trigger: 'blur' }
]))
const loginRules = computed(() => ({ email: emailRule.value, password: passwordRule.value }))

const goAfterLogin = () => {
  const redirect = route.query.redirect || '/packages'
  router.replace(redirect)
}

const langForUrl = computed(() => {
  switch (locale.value) {
    case 'en-US': return 'en'
    case 'ja-JP': return 'ja'
    case 'ko-KR': return 'ko'
    default: return 'zh'
  }
})
const agreementUrl = computed(() => `https://your-api-domain.com/v1/user_agreement?lang=${langForUrl.value}`)
const privacyUrl = computed(() => `https://your-api-domain.com/v1/privacy_policy?lang=${langForUrl.value}`)

const currentLangLabel = computed(() =>
  SUPPORTED_LOCALES.find(l => l.code === locale.value)?.label || locale.value
)
const onLangCmd = (code) => setLocale(code)

const onLogin = async () => {
  try {
    await loginRef.value.validate()
  } catch { return }
  submitting.value = true
  try {
    const res = await login({
      email: loginForm.email.trim(),
      password: loginForm.password,
      register: false
    })
    const data = res.data || {}
    if (data.state === 2 && data.access_token) {
      userStore.setToken(data.access_token)
      await userStore.refresh()
      ElMessage.success(t('login.msg.loginSuccess'))
      goAfterLogin()
    } else {
      ElMessage.error(data.msg || t('login.msg.loginFail'))
    }
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.login-root {
  position: relative;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #eef3fb 0%, #f7f9fc 100%);
  padding: 24px;
}
.login-bg {
  position: fixed;
  inset: 0;
  background:
    radial-gradient(circle at 15% 30%, rgba(64,158,255,0.18), transparent 40%),
    radial-gradient(circle at 80% 70%, rgba(64,158,255,0.10), transparent 40%);
  pointer-events: none;
  z-index: 0;
}
.login-lang {
  position: absolute;
  top: 16px;
  right: 20px;
  z-index: 2;
}
.lang-link {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #555;
  font-size: 13px;
  background: rgba(255,255,255,0.7);
  padding: 6px 10px;
  border-radius: 18px;
  cursor: pointer;
  backdrop-filter: blur(4px);
}
.lang-link:hover { color: var(--primary); }
.is-current { color: var(--primary); font-weight: 600; }

.login-card {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 420px;
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 10px 30px rgba(31,41,55,0.08);
  padding: 32px 28px 20px;
}
.login-brand {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}
.logo {
  width: 44px; height: 44px; border-radius: 10px;
  background: linear-gradient(135deg,#409EFF,#2c7be5);
  color:#fff; font-weight:700; display:flex; align-items:center; justify-content:center; font-size: 16px;
}
.title { font-size: 20px; font-weight: 700; color:#1f2937; }
.subtitle { color: var(--muted); font-size: 13px; margin-top: 2px; }

.login-form { margin-top: 16px; }
.row-link { text-align: right; margin: -8px 0 12px; }
.row-link a { font-size: 13px; }
.footer-tip {
  font-size: 12px;
  text-align: center;
  margin-top: 4px;
}
.login-footer {
  position: relative;
  margin-top: 18px;
  font-size: 12px;
  color: var(--muted);
  z-index: 1;
}

@media (max-width: 480px) {
  .login-card { padding: 24px 18px 16px; max-width: 100%; }
  .title { font-size: 18px; }
  .login-lang { top: 10px; right: 12px; }
}
</style>
