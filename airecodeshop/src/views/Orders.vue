<template>
  <div class="page-container">
    <h1 class="page-title">{{ t('orders.title') }}</h1>

    <el-form :inline="true" class="filter-bar">
      <el-form-item :label="t('orders.filter.state')">
        <el-select v-model="filterStates" multiple collapse-tags collapse-tags-tooltip :placeholder="t('orders.filter.all')" style="min-width: 220px">
          <el-option v-for="s in stateOptions" :key="s.value" :label="s.label" :value="s.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSearch">{{ t('common.search') }}</el-button>
        <el-button @click="onReset">{{ t('common.reset') }}</el-button>
      </el-form-item>
    </el-form>

    <!-- 桌面端表格 -->
    <el-table
      v-loading="loading"
      :data="list"
      border
      stripe
      class="desktop-table"
      :empty-text="t('orders.empty')"
    >
      <el-table-column prop="order_id" :label="t('orders.columns.orderId')" min-width="200" show-overflow-tooltip />
      <el-table-column prop="package_name" :label="t('orders.columns.packageName')" min-width="200" show-overflow-tooltip />
      <el-table-column :label="t('orders.columns.amount')" width="140">
        <template #default="{ row }">
          <span class="amount">{{ row.currency || 'CNY' }} {{ formatYuan(row.amount) }}</span>
        </template>
      </el-table-column>
      <el-table-column :label="t('orders.columns.payChannel')" width="110">
        <template #default="{ row }">{{ payChannelLabel(row.pay_channel) }}</template>
      </el-table-column>
      <el-table-column :label="t('orders.columns.payTime')" width="180">
        <template #default="{ row }">{{ row.pay_time || '-' }}</template>
      </el-table-column>
      <el-table-column :label="t('orders.columns.state')" width="130">
        <template #default="{ row }">
          <el-tag :type="stateTagType(row.state)" size="small" effect="light">
            {{ stateLabel(row.state) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column :label="t('orders.columns.actions')" width="120" fixed="right">
        <template #default="{ row }">
          <el-button size="small" link type="primary" @click="viewDetail(row)">{{ t('common.detail') }}</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 移动端卡片 -->
    <div class="mobile-list" v-loading="loading">
      <div v-for="item in list" :key="item.order_id" class="m-card">
        <div class="m-head">
          <span class="m-name">{{ item.package_name }}</span>
          <el-tag :type="stateTagType(item.state)" size="small" effect="light">
            {{ stateLabel(item.state) }}
          </el-tag>
        </div>
        <div class="m-row"><span class="muted">{{ t('orders.columns.orderId') }}</span><span class="ellipsis">{{ item.order_id }}</span></div>
        <div class="m-row">
          <span class="muted">{{ t('orders.columns.amount') }}</span>
          <span class="amount">{{ item.currency || 'CNY' }} {{ formatYuan(item.amount) }}</span>
        </div>
        <div class="m-row"><span class="muted">{{ t('orders.columns.payTime') }}</span><span>{{ item.pay_time || '-' }}</span></div>
        <div class="m-actions">
          <el-button size="small" type="primary" @click="viewDetail(item)">{{ t('common.detail') }}</el-button>
        </div>
      </div>
      <el-empty v-if="!loading && !list.length" :description="t('orders.empty')" />
    </div>

    <div class="pager" v-if="total > 0">
      <el-pagination
        v-model:current-page="page"
        v-model:page-size="size"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        background
        @current-change="loadList"
        @size-change="onSizeChange"
      />
    </div>

    <!-- 订单详情对话框 -->
    <el-dialog v-model="detailVisible" :title="t('orders.detailTitle')" width="480px">
      <div v-if="detail" class="detail-block">
        <div class="line"><span class="muted">{{ t('orders.columns.orderId') }}</span><span class="ellipsis">{{ detail.order_id }}</span></div>
        <div class="line"><span class="muted">{{ t('orders.columns.packageName') }}</span><span>{{ detail.package_name }}</span></div>
        <div class="line">
          <span class="muted">{{ t('orders.columns.amount') }}</span>
          <span class="amount">{{ detail.currency || 'CNY' }} {{ formatYuan(detail.amount) }}</span>
        </div>
        <div class="line"><span class="muted">{{ t('orders.columns.payChannel') }}</span><span>{{ payChannelLabel(detail.pay_channel) }}</span></div>
        <div class="line"><span class="muted">{{ t('orders.columns.payTime') }}</span><span>{{ detail.pay_time || '-' }}</span></div>
        <div class="line">
          <span class="muted">{{ t('orders.columns.state') }}</span>
          <el-tag :type="stateTagType(detail.state)" size="small">{{ stateLabel(detail.state) }}</el-tag>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { listOrders, getOrderDetail } from '@/api/order'

const { t } = useI18n()

const stateOptions = computed(() => [
  { value: 1, label: t('orders.states.1') },
  { value: 2, label: t('orders.states.2') },
  { value: 3, label: t('orders.states.3') },
  { value: 4, label: t('orders.states.4') },
  { value: 5, label: t('orders.states.5') }
])

const filterStates = ref([])
const list = ref([])
const loading = ref(false)
const page = ref(1)
const size = ref(20)
const total = ref(0)

const detailVisible = ref(false)
const detail = ref(null)

const stateLabel = (s) => {
  const key = `orders.states.${s}`
  // 兼容未知状态
  return t(key) === key ? t('common.unknown') : t(key)
}
const stateTagType = (s) => {
  switch (s) {
    case 1: return 'warning'
    case 2: return 'success'
    case 3: return 'danger'
    case 4: return 'success'
    case 5: return 'info'
    default: return ''
  }
}
const payChannelLabel = (c) => {
  if (c === 1) return t('orders.payChannels.1')
  if (!c) return '-'
  return t('orders.payChannels.other', { n: c })
}
const formatYuan = (cent) => (Number(cent || 0) / 100).toFixed(2)

const loadList = async () => {
  loading.value = true
  try {
    const res = await listOrders({
      page: page.value,
      size: size.value,
      states: filterStates.value && filterStates.value.length ? filterStates.value : undefined
    })
    const data = res.data || {}
    list.value = data.data || []
    total.value = data.total || 0
  } finally {
    loading.value = false
  }
}

const onSearch = () => { page.value = 1; loadList() }
const onReset = () => { filterStates.value = []; page.value = 1; loadList() }
const onSizeChange = (s) => { size.value = s; page.value = 1; loadList() }

const viewDetail = async (row) => {
  try {
    const res = await getOrderDetail(row.order_id)
    detail.value = res.data || row
    detailVisible.value = true
  } catch {
    detail.value = row
    detailVisible.value = true
  }
}

onMounted(loadList)
</script>

<style scoped>
.filter-bar { margin-bottom: 12px; }
.amount { color: var(--danger); font-weight: 600; }
.pager { margin-top: 16px; display:flex; justify-content: flex-end; }

.desktop-table { display: block; }
.mobile-list { display: none; }

.m-card {
  background:#fff; border:1px solid var(--border); border-radius: 10px;
  padding: 14px; margin-bottom: 10px;
}
.m-head {
  display:flex; justify-content: space-between; align-items: center; margin-bottom: 10px;
  padding-bottom: 8px; border-bottom: 1px dashed var(--border);
}
.m-name { font-weight: 600; }
.m-row {
  display:flex; justify-content: space-between; align-items: center;
  font-size: 13px; margin-bottom: 6px; gap: 12px;
}
.m-row .muted { flex-shrink: 0; }
.m-row .ellipsis { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.m-actions { margin-top: 10px; display:flex; justify-content: flex-end; }

.detail-block .line {
  display:flex; justify-content: space-between; align-items: center;
  font-size: 14px; padding: 8px 0;
  border-bottom: 1px dashed var(--border);
  gap: 16px;
}
.detail-block .line:last-child { border-bottom: none; }
.detail-block .ellipsis { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 60%; }

@media (max-width: 768px) {
  .desktop-table { display: none; }
  .mobile-list { display: block; }
  .filter-bar :deep(.el-form-item) { margin-right: 8px; }
}
</style>
