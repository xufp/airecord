<template>
  <div class="page-container">
    <div class="title-row">
      <h1 class="page-title" style="margin:0">{{ t('packages.title') }}</h1>
      <div class="quota-pill" v-if="userStore.pkg">
        <el-icon><Tickets /></el-icon>
        <span>{{ t('packages.leftQuotaPrefix') }}</span>
        <strong>{{ leftMin }}</strong>
        <span>{{ t('common.minutes') }}</span>
      </div>
    </div>

    <el-tabs v-model="currentType" class="type-tabs" @tab-change="loadList">
      <el-tab-pane :label="t('packages.tabs.paid')" :name="2" />
      <el-tab-pane :label="t('packages.tabs.subscription')" :name="3" />
      <el-tab-pane :label="t('packages.tabs.free')" :name="1" />
    </el-tabs>

    <div v-loading="loading" class="grid">
      <PackageCard
        v-for="(pkg, idx) in list"
        :key="pkg.package_id"
        :pkg="pkg"
        :loading="buyingId === pkg.package_id"
        :recommend="idx === recommendIdx"
        @buy="onBuy"
      />
      <el-empty v-if="!loading && !list.length" :description="t('packages.empty')" />
    </div>

    <!-- 支付方式选择对话框 -->
    <el-dialog v-model="payDialog" :title="t('packages.confirmDialog')" width="420px" :close-on-click-modal="false">
      <div v-if="selectedPkg" class="confirm-block">
        <div class="line"><span class="muted">{{ t('packages.fields.packageName') }}</span><span>{{ selectedPkg.package_name }}</span></div>
        <div class="line">
          <span class="muted">{{ t('packages.fields.payable') }}</span>
          <span class="amount">
            {{ selectedPkg.currency || 'CNY' }}
            {{ formatYuan(payableOf(selectedPkg)) }}
          </span>
        </div>
        <el-divider style="margin: 12px 0;" />
        <div class="muted" style="margin-bottom: 8px;">{{ t('packages.fields.payChannel') }}</div>
        <el-radio-group v-model="payChannel">
          <el-radio :label="1">
            <span class="paypal-row">
              <span class="paypal-logo">PayPal</span>
              <span class="muted">{{ t('packages.payChannels.paypal') }}</span>
            </span>
          </el-radio>
        </el-radio-group>
      </div>
      <template #footer>
        <el-button @click="payDialog = false">{{ t('common.cancel') }}</el-button>
        <el-button type="primary" :loading="creating" @click="onConfirmPay">{{ t('packages.actions.goPay') }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Tickets } from '@element-plus/icons-vue'
import PackageCard from '@/components/PackageCard.vue'
import { listAvailablePackages, givePackage } from '@/api/package'
import { createOrder } from '@/api/order'
import { userStore } from '@/stores/user'

const { t, locale } = useI18n()

const currentType = ref(2)
const list = ref([])
const loading = ref(false)
const buyingId = ref(null)

const payDialog = ref(false)
const selectedPkg = ref(null)
const payChannel = ref(1)
const creating = ref(false)

const leftMin = computed(() => {
  const t = userStore.pkg?.convert?.total || 0
  const u = userStore.pkg?.convert?.used || 0
  return Math.max(0, t - u)
})

// 推荐：付费类下，价格非 0 中价格中位的那一项
const recommendIdx = computed(() => {
  if (currentType.value !== 2) return -1
  const arr = list.value.filter(p => p.price > 0)
  if (arr.length < 2) return -1
  const sorted = [...arr].sort((a, b) => a.price - b.price)
  const mid = sorted[Math.floor(sorted.length / 2)]
  return list.value.indexOf(mid)
})

const formatYuan = (cent) => (Number(cent || 0) / 100).toFixed(2)
const payableOf = (pkg) => Math.round(Number(pkg.price || 0) * Number(pkg.rates ?? 100) / 100)

const loadList = async () => {
  loading.value = true
  try {
    const res = await listAvailablePackages(currentType.value)
    list.value = res.data?.packages || []
  } catch (e) {
    list.value = []
  } finally {
    loading.value = false
  }
}

const onBuy = async (pkg) => {
  // 免费体验类：直接领取
  if (pkg.package_type === 1 || pkg.price === 0) {
    try {
      await ElMessageBox.confirm(
        t('packages.msg.receiveConfirm', { name: pkg.package_name }),
        t('common.tip'),
        { type: 'info', confirmButtonText: t('common.confirm'), cancelButtonText: t('common.cancel') }
      )
    } catch { return }
    buyingId.value = pkg.package_id
    try {
      await givePackage(pkg.package_id)
      ElMessage.success(t('packages.msg.receiveSuccess'))
      await userStore.refresh()
    } finally {
      buyingId.value = null
    }
    return
  }

  // 付费 / 订阅：弹窗确认 + 创建订单 + 跳转 PayPal
  selectedPkg.value = pkg
  payChannel.value = 1
  payDialog.value = true
}

const onConfirmPay = async () => {
  if (!selectedPkg.value) return
  creating.value = true
  try {
    const res = await createOrder({
      package_id: selectedPkg.value.package_id,
      pay_channel: payChannel.value
    })
    const data = res.data || {}
    const href = data.link?.href
    if (!href) {
      ElMessage.error(t('packages.msg.noPayLink'))
      return
    }
    // 记录待支付订单 ID，回跳后用于轮询
    if (data.order_id) localStorage.setItem('last_order_id', String(data.order_id))
    payDialog.value = false
    ElMessage.success(t('packages.msg.redirecting'))
    window.location.href = href
  } finally {
    creating.value = false
  }
}

onMounted(async () => {
  if (!userStore.pkg) await userStore.refresh()
  await loadList()
})

// 切换页面语言时，重新拉取套餐（后端按 lang 返回对应语言的名称/描述）
watch(locale, () => {
  loadList()
})
</script>

<style scoped>
.title-row {
  display:flex; align-items:center; justify-content: space-between;
  margin-bottom: 12px;
}
.quota-pill {
  display:inline-flex; align-items:center; gap:6px;
  background:#ecf5ff; color: var(--primary);
  padding: 4px 12px; border-radius: 100px;
  font-size: 13px;
}
.quota-pill strong { font-size: 15px; }
.type-tabs { margin-bottom: 8px; }

.grid {
  display: grid;
  gap: 16px;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
}

.confirm-block .line {
  display:flex; justify-content: space-between; align-items: center;
  margin-bottom: 10px; font-size: 14px;
}
.confirm-block .amount { color: var(--danger); font-weight: 700; font-size: 18px; }
.paypal-row { display:inline-flex; align-items:center; gap: 8px; }
.paypal-logo {
  font-weight: 700; color: #003087;
  background: #ffc439;
  padding: 2px 8px; border-radius: 4px;
}

@media (max-width: 480px) {
  .title-row { flex-direction: column; align-items:flex-start; gap: 8px; }
  .grid { grid-template-columns: 1fr; }
}
</style>
