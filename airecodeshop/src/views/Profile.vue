<template>
  <div class="page-container">
    <h1 class="page-title">{{ t('profile.title') }}</h1>

    <el-row :gutter="16" class="row">
      <!-- 左侧：账号信息 -->
      <el-col :xs="24" :md="10">
        <el-card shadow="never" class="card">
          <template #header><span class="card-title">{{ t('profile.cards.account') }}</span></template>
          <div class="info-block" v-loading="userStore.loading">
            <div class="avatar-wrap">
              <el-avatar :size="64" :src="userStore.info?.head_img_url">
                {{ avatarFallback }}
              </el-avatar>
              <div class="name-block">
                <div class="nick">{{ userStore.info?.nick_name || t('profile.fields.defaultName') }}</div>
                <div class="muted">{{ t('profile.fields.memberLevel', { n: userStore.info?.membership_level ?? 0 }) }}</div>
              </div>
            </div>
            <el-descriptions :column="1" border size="small" class="mt-16">
              <el-descriptions-item :label="t('profile.fields.memberExpire')">
                {{ userStore.info?.membership_expire_time || '-' }}
              </el-descriptions-item>
            </el-descriptions>
          </div>
        </el-card>


      </el-col>

      <!-- 右侧：套餐余额 + 快捷入口 -->
      <el-col :xs="24" :md="14">
        <el-card shadow="never" class="card">
          <template #header>
            <div class="card-header">
              <span class="card-title">{{ t('profile.cards.quota') }}</span>
              <el-button type="primary" link @click="loadPackage">
                <el-icon><Refresh /></el-icon>
                <span>{{ t('common.refresh') }}</span>
              </el-button>
            </div>
          </template>

          <div class="quota-card" v-loading="loadingPkg">
            <div class="quota-row">
              <div class="quota-label">{{ t('profile.quota.used') }}</div>
              <div class="quota-value">
                <span class="num">{{ usedMin }}</span>
                <span class="unit">{{ t('common.minutes') }}</span>
                <span class="muted"> / {{ totalMin }} {{ t('common.minutes') }}</span>
              </div>
            </div>
            <el-progress
              :percentage="percent"
              :status="percent >= 90 ? 'exception' : (percent >= 70 ? 'warning' : 'success')"
              :stroke-width="14"
              striped
              striped-flow
            />
            <div class="quota-foot">
              <span class="muted">{{ t('profile.quota.left') }}</span>
              <span class="left-num">{{ leftMin }} {{ t('common.minutes') }}</span>
            </div>
          </div>

          <div class="quick-actions">
            <el-button type="primary" @click="$router.push('/packages')">{{ t('profile.quota.buy') }}</el-button>
            <el-button @click="$router.push('/orders')">{{ t('profile.quota.orders') }}</el-button>
          </div>
        </el-card>

        <el-card shadow="never" class="card mt-16">
          <template #header><span class="card-title">{{ t('profile.cards.tips') }}</span></template>
          <ul class="tips muted">
            <li v-for="(tip, i) in tm('profile.tips')" :key="i">{{ tip }}</li>
          </ul>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { Refresh } from '@element-plus/icons-vue'
import { getUserPackage } from '@/api/user'
import { userStore } from '@/stores/user'

const { t, tm } = useI18n()

const loadingPkg = ref(false)
const pkgData = ref(null)

const avatarFallback = computed(() => {
  const n = userStore.info?.nick_name || ''
  return n ? n.charAt(0).toUpperCase() : 'U'
})

// 后端返回的 used/total 单位已经是「分钟」，直接使用
const usedMin = computed(() => pkgData.value?.convert?.used || 0)
const totalMin = computed(() => pkgData.value?.convert?.total || 0)
const leftMin = computed(() => Math.max(0, totalMin.value - usedMin.value))
const percent = computed(() => {
  if (!totalMin.value) return 0
  return Math.min(100, Math.round((usedMin.value / totalMin.value) * 100))
})

const loadPackage = async () => {
  loadingPkg.value = true
  try {
    const res = await getUserPackage()
    pkgData.value = res.data || { convert: { used: 0, total: 0 } }
    userStore.pkg = pkgData.value
  } finally {
    loadingPkg.value = false
  }
}

onMounted(async () => {
  if (!userStore.info) await userStore.refresh()
  await loadPackage()
})
</script>

<style scoped>
.row { row-gap: 16px; }
.card { border-radius: 10px; }
.card + .card { margin-top: 16px; }
.mt-16 { margin-top: 16px; }
.card-title { font-weight: 600; }
.card-header { display:flex; justify-content:space-between; align-items:center; }

.info-block .avatar-wrap {
  display:flex; align-items:center; gap:14px;
}
.nick { font-size: 16px; font-weight: 600; }

.quota-card { padding: 4px 0 8px; }
.quota-row { display:flex; justify-content: space-between; align-items: baseline; margin-bottom: 8px; }
.quota-label { color: var(--muted); font-size: 13px; }
.quota-value .num { font-size: 26px; font-weight: 700; color: var(--primary); }
.quota-value .unit { font-size: 14px; color: var(--text); margin-left: 4px; }
.quota-foot { margin-top: 10px; font-size: 13px; }
.left-num { color: var(--success); font-weight: 600; }

.quick-actions { margin-top: 16px; display:flex; gap: 10px; flex-wrap: wrap; }

.tips { padding-left: 18px; line-height: 1.9; font-size: 13px; }
</style>
