<template>
  <div class="package-card" :class="{ recommend: recommend }">
    <div v-if="recommend" class="ribbon">{{ t('packages.card.recommend') }}</div>

    <div class="head">
      <el-tag :type="typeTag.type" size="small" effect="plain">{{ typeTag.label }}</el-tag>
      <span class="muted pkg-id">#{{ pkg.package_id }}</span>
    </div>

    <h3 class="name">{{ pkg.package_name }}</h3>
    <div class="desc muted">{{ pkg.description || t('packages.card.noDesc') }}</div>

    <div class="price-block">
      <template v-if="payable > 0">
        <span class="cur">{{ pkg.currency || 'CNY' }}</span>
        <span class="amount">{{ formatYuan(payable) }}</span>
        <span v-if="hasDiscount" class="origin">{{ pkg.currency || 'CNY' }} {{ formatYuan(pkg.price) }}</span>
        <span v-if="hasDiscount" class="off-tag">{{ Math.round(pkg.rates) }}% OFF</span>
      </template>
      <template v-else>
        <span class="amount free">{{ t('packages.card.free') }}</span>
      </template>
    </div>

    <el-button
      class="buy-btn"
      type="primary"
      size="large"
      :loading="loading"
      @click="$emit('buy', pkg)"
    >
      {{ pkg.package_type === 1 ? t('packages.card.claim') : (pkg.package_type === 3 ? t('packages.card.subscribe') : t('packages.card.buyNow')) }}
    </el-button>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = defineProps({
  pkg: { type: Object, required: true },
  loading: { type: Boolean, default: false },
  recommend: { type: Boolean, default: false }
})
defineEmits(['buy'])

// 实际支付金额（单位：分）= price * rates / 100
// rates=100 表示无折扣
const payable = computed(() => {
  const price = Number(props.pkg.price || 0)
  const rates = props.pkg.rates === undefined ? 100 : Number(props.pkg.rates)
  return Math.round(price * rates / 100)
})
const hasDiscount = computed(() => {
  const r = Number(props.pkg.rates ?? 100)
  return r > 0 && r < 100 && Number(props.pkg.price || 0) > 0
})
const formatYuan = (cent) => (Number(cent || 0) / 100).toFixed(2)

const typeTag = computed(() => {
  switch (props.pkg.package_type) {
    case 1: return { label: t('packages.card.tagFree'), type: 'success' }
    case 2: return { label: t('packages.card.tagPaid'), type: '' }
    case 3: return { label: t('packages.card.tagSubscription'), type: 'warning' }
    default: return { label: t('packages.card.tagDefault'), type: 'info' }
  }
})
</script>

<style scoped>
.package-card {
  position: relative;
  background: #fff;
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  transition: all .2s;
  height: 100%;
}
.package-card:hover {
  border-color: var(--primary);
  box-shadow: 0 6px 16px rgba(64,158,255,0.12);
  transform: translateY(-2px);
}
.package-card.recommend {
  border-color: var(--primary);
  background: linear-gradient(180deg, #f6fbff 0%, #ffffff 100%);
}
.ribbon {
  position: absolute;
  top: 12px; right: -4px;
  background: linear-gradient(135deg, #ff7a00, #ff4d4f);
  color: #fff;
  font-size: 12px;
  padding: 2px 10px;
  border-radius: 4px 0 0 4px;
  box-shadow: 0 2px 6px rgba(255,77,79,0.3);
}
.head { display:flex; align-items:center; justify-content: space-between; }
.pkg-id { font-size: 12px; }
.name { font-size: 18px; margin: 4px 0 0; font-weight: 600; }
.desc { font-size: 13px; line-height: 1.6; min-height: 38px; }

.price-block {
  display: flex;
  align-items: baseline;
  flex-wrap: wrap;
  gap: 6px;
  padding: 8px 0;
  border-top: 1px dashed var(--border);
  border-bottom: 1px dashed var(--border);
  margin-top: auto;
}
.cur { color: var(--danger); font-size: 14px; }
.amount { color: var(--danger); font-size: 28px; font-weight: 700; line-height: 1; }
.amount.free { color: var(--success); }
.origin { color: #aaa; text-decoration: line-through; font-size: 13px; margin-left: 4px; }
.off-tag {
  background: #fff1f0;
  color: var(--danger);
  font-size: 11px;
  padding: 1px 6px;
  border-radius: 4px;
}
.buy-btn { width: 100%; }
</style>
