<template>
  <div class="result-root">
    <div class="result-card">
      <div class="icon ok">
        <el-icon :size="48"><CircleCheckFilled /></el-icon>
      </div>
      <h2>{{ t('pay.success.title') }}</h2>
      <p class="muted" v-if="state.loading">{{ t('pay.success.loading') }}</p>
      <i18n-t v-else-if="state.detail" keypath="pay.success.ok" tag="p" class="muted">
        <template #name><strong>{{ state.detail.package_name }}</strong></template>
      </i18n-t>
      <p class="muted" v-else>{{ t('pay.success.fallback') }}</p>

      <div v-if="state.detail" class="info">
        <div class="line"><span class="muted">{{ t('pay.success.orderId') }}</span><span class="ellipsis">{{ state.detail.order_id }}</span></div>
        <div class="line">
          <span class="muted">{{ t('pay.success.amount') }}</span>
          <span class="amount">{{ state.detail.currency || 'CNY' }} {{ formatYuan(state.detail.amount) }}</span>
        </div>
        <div class="line">
          <span class="muted">{{ t('pay.success.state') }}</span>
          <el-tag :type="stateTagType(state.detail.state)" size="small">{{ stateLabel(state.detail.state) }}</el-tag>
        </div>
      </div>

      <div class="actions">
        <el-button type="primary" @click="goPackages">{{ t('pay.success.continue') }}</el-button>
        <el-button @click="goOrders">{{ t('pay.success.orders') }}</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { CircleCheckFilled } from '@element-plus/icons-vue'
import { getOrderDetail } from '@/api/order'

const route = useRoute()
const router = useRouter()
const { t } = useI18n()

const state = reactive({ loading: true, detail: null })

const stateLabel = (s) => {
  const key = `orders.states.${s}`
  return t(key) === key ? t('common.unknown') : t(key)
}
const stateTagType = (s) => (s === 2 || s === 4 ? 'success' : s === 3 ? 'danger' : 'warning')
const formatYuan = (cent) => (Number(cent || 0) / 100).toFixed(2)

const fetchDetail = async () => {
  // 优先从 query 取（后端 redirect 带上），其次取本地缓存（兼容旧流程）
  const orderId = route.query.order_id || localStorage.getItem('last_order_id')
  if (!orderId) { state.loading = false; return }
  // 轮询等待后端完成发货：最多 6 次，间隔 2s（共约 12s），覆盖 Webhook 延迟
  for (let i = 0; i < 6; i++) {
    try {
      const res = await getOrderDetail(orderId)
      state.detail = res.data || null
      // state 2=已支付, 4=已完成(已发货)
      if (state.detail && (state.detail.state === 2 || state.detail.state === 4)) break
    } catch { /* 忽略，继续轮询 */ }
    if (i < 5) await new Promise(r => setTimeout(r, 2000))
  }
  state.loading = false
  localStorage.removeItem('last_order_id')
}

const goPackages = () => router.replace('/packages')
const goOrders = () => router.replace('/orders')

onMounted(fetchDetail)
</script>

<style scoped>
.result-root {
  min-height: 100vh;
  display:flex; align-items:center; justify-content:center;
  background: linear-gradient(135deg, #eef3fb 0%, #f7f9fc 100%);
  padding: 24px;
}
.result-card {
  width: 100%; max-width: 480px;
  background:#fff; border-radius: 14px;
  box-shadow: 0 10px 30px rgba(31,41,55,0.08);
  padding: 32px 28px;
  text-align: center;
}
.icon { margin-bottom: 12px; }
.icon.ok { color: var(--success); }
.icon.fail { color: var(--warning); }
h2 { margin: 4px 0 8px; }
.info {
  text-align: left;
  background: #fafbfd;
  border-radius: 8px;
  padding: 14px 16px;
  margin: 16px 0 20px;
}
.info .line {
  display:flex; justify-content: space-between; align-items: center;
  padding: 6px 0; font-size: 13px;
  gap: 12px;
}
.info .ellipsis { max-width: 60%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.amount { color: var(--danger); font-weight: 600; }
.actions { display:flex; justify-content: center; gap: 10px; flex-wrap: wrap; }
</style>
