<template>
  <div class="reset-root">
    <div class="card">
      <div class="brand">
        <div class="logo">YG</div>
        <div>
          <div class="title">{{ t('reset.title') }}</div>
          <div class="subtitle muted">{{ t('reset.subtitle') }}</div>
        </div>
      </div>

      <el-form :model="form" :rules="rules" ref="formRef" size="large" label-position="top">
        <el-form-item prop="email">
          <el-input v-model="form.email" :placeholder="t('login.email')">
            <template #prefix><el-icon><Message /></el-icon></template>
          </el-input>
        </el-form-item>
        <el-form-item prop="code">
          <el-input v-model="form.code" :placeholder="t('login.code')" maxlength="6">
            <template #prefix><el-icon><Key /></el-icon></template>
            <template #append>
              <el-button :disabled="cdLeft > 0" @click="onSendCode">
                {{ cdLeft > 0 ? t('common.resendIn', { n: cdLeft }) : t('common.sendCode') }}
              </el-button>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item prop="new_password">
          <el-input v-model="form.new_password" type="password" :placeholder="t('reset.newPassword')" show-password>
            <template #prefix><el-icon><Lock /></el-icon></template>
          </el-input>
        </el-form-item>
        <el-form-item prop="confirm">
          <el-input v-model="form.confirm" type="password" :placeholder="t('reset.confirmPassword')" show-password>
            <template #prefix><el-icon><Lock /></el-icon></template>
          </el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" style="width:100%" :loading="submitting" @click="onSubmit">{{ t('reset.submit') }}</el-button>
        </el-form-item>

        <div class="row-link">
          <router-link to="/login">{{ t('common.backToLogin') }}</router-link>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ElMessage } from 'element-plus'
import { Message, Lock, Key } from '@element-plus/icons-vue'
import { resetPassword } from '@/api/auth'

const router = useRouter()
const { t } = useI18n()
const formRef = ref(null)
const submitting = ref(false)
const form = reactive({ email: '', code: '', new_password: '', confirm: '' })

const rules = computed(() => ({
  email: [
    { required: true, message: t('login.rules.emailRequired'), trigger: 'blur' },
    { type: 'email', message: t('login.rules.emailInvalid'), trigger: 'blur' }
  ],
  code: [{ required: true, message: t('login.rules.codeRequired'), trigger: 'blur' }],
  new_password: [
    { required: true, message: t('reset.rules.newPwdRequired'), trigger: 'blur' },
    { min: 8, message: t('login.rules.passwordMin'), trigger: 'blur' }
  ],
  confirm: [
    { required: true, message: t('reset.rules.confirmRequired'), trigger: 'blur' },
    {
      validator: (_, v, cb) => (v === form.new_password ? cb() : cb(new Error(t('reset.rules.mismatch')))),
      trigger: 'blur'
    }
  ]
}))

const cdLeft = ref(0)
let timer = null
const startCountdown = () => {
  cdLeft.value = 60
  timer = setInterval(() => { cdLeft.value--; if (cdLeft.value <= 0) { clearInterval(timer); timer = null } }, 1000)
}
onBeforeUnmount(() => { if (timer) clearInterval(timer) })

const onSendCode = async () => {
  if (!form.email) { ElMessage.warning(t('login.msg.emailFirst')); return }
  try {
    await resetPassword({ email: form.email.trim() })
    ElMessage.success(t('login.msg.codeSent'))
    startCountdown()
  } catch (e) { /* 拦截器已提示 */ }
}

const onSubmit = async () => {
  try { await formRef.value.validate() } catch { return }
  submitting.value = true
  try {
    await resetPassword({
      email: form.email.trim(),
      code: form.code.trim(),
      new_password: form.new_password
    })
    ElMessage.success(t('reset.msg.success'))
    router.replace('/login')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.reset-root {
  min-height: 100vh;
  display:flex; align-items:center; justify-content:center;
  background: linear-gradient(135deg,#eef3fb 0%,#f7f9fc 100%);
  padding: 24px;
}
.card {
  width: 100%; max-width: 420px;
  background:#fff; border-radius: 14px;
  box-shadow: 0 10px 30px rgba(31,41,55,0.08);
  padding: 32px 28px;
}
.brand { display:flex; align-items:center; gap:12px; margin-bottom: 18px; }
.logo {
  width:44px; height:44px; border-radius:10px;
  background: linear-gradient(135deg,#409EFF,#2c7be5);
  color:#fff; font-weight:700; display:flex; align-items:center; justify-content:center;
}
.title { font-size: 20px; font-weight: 700; }
.subtitle { font-size: 13px; }
.row-link { text-align: center; margin-top: 6px; font-size: 13px; }
</style>
