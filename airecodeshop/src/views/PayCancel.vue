<template>
  <div class="result-root">
    <div class="result-card">
      <div class="icon">
        <el-icon :size="48"><WarningFilled /></el-icon>
      </div>
      <h2>{{ t('pay.cancel.title') }}</h2>
      <p class="muted">{{ t('pay.cancel.desc') }}</p>

      <div class="actions">
        <el-button type="primary" @click="$router.replace('/packages')">{{ t('pay.cancel.retry') }}</el-button>
        <el-button @click="$router.replace('/orders')">{{ t('pay.cancel.orders') }}</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { WarningFilled } from '@element-plus/icons-vue'

const { t } = useI18n()

onMounted(() => { localStorage.removeItem('last_order_id') })
</script>

<style scoped>
.result-root {
  min-height: 100vh;
  display:flex; align-items:center; justify-content:center;
  background: linear-gradient(135deg, #fff7e6 0%, #f7f9fc 100%);
  padding: 24px;
}
.result-card {
  width: 100%; max-width: 480px;
  background:#fff; border-radius: 14px;
  box-shadow: 0 10px 30px rgba(31,41,55,0.08);
  padding: 32px 28px;
  text-align: center;
}
.icon { color: var(--warning); margin-bottom: 12px; }
h2 { margin: 4px 0 8px; }
.actions { display:flex; justify-content: center; gap: 10px; margin-top: 18px; flex-wrap: wrap; }
</style>
