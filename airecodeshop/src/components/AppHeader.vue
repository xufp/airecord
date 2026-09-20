<template>
  <header class="app-header">
    <div class="inner">
      <div class="brand" @click="goHome">
        <div class="logo">YG</div>
        <div class="title">{{ t('header.brand') }}<span class="sub">{{ t('header.sub') }}</span></div>
      </div>

      <nav class="nav">
        <router-link to="/packages" class="nav-item" active-class="active">{{ t('header.nav.packages') }}</router-link>
        <router-link to="/orders" class="nav-item" active-class="active">{{ t('header.nav.orders') }}</router-link>
        <router-link to="/profile" class="nav-item" active-class="active">{{ t('header.nav.profile') }}</router-link>
      </nav>

      <div class="account">
        <!-- 语言切换 -->
        <el-dropdown trigger="click" @command="onLangCmd" class="lang-dropdown">
          <span class="lang-link">
            <el-icon><Promotion /></el-icon>
            <span class="lang-name">{{ currentLangLabel }}</span>
            <el-icon><ArrowDown /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item
                v-for="l in SUPPORTED_LOCALES"
                :key="l.code"
                :command="l.code"
                :class="{ 'is-current': l.code === locale }"
              >
                {{ l.label }}
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>

        <template v-if="userStore.token">
          <el-dropdown trigger="click" @command="onCmd">
            <span class="user-link">
              <el-avatar :size="28" :src="avatar" class="avatar">
                {{ avatarFallback }}
              </el-avatar>
              <span class="user-name">{{ userName }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">{{ t('header.nav.profile') }}</el-dropdown-item>
                <el-dropdown-item command="orders">{{ t('header.nav.orders') }}</el-dropdown-item>
                <el-dropdown-item divided command="logout">{{ t('header.logout') }}</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
        <template v-else>
          <el-button type="primary" size="small" @click="$router.push('/login')">{{ t('header.login') }}</el-button>
        </template>
      </div>
    </div>
  </header>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ArrowDown, Promotion } from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'
import { userStore } from '@/stores/user'
import { SUPPORTED_LOCALES, setLocale } from '@/locales'

const router = useRouter()
const { t, locale } = useI18n()

const avatar = computed(() => userStore.info?.head_img_url || '')
const userName = computed(() => userStore.info?.nick_name || t('header.accountFallback'))
const avatarFallback = computed(() => {
  const n = userStore.info?.nick_name || ''
  return n ? n.charAt(0).toUpperCase() : 'U'
})

const currentLangLabel = computed(() =>
  SUPPORTED_LOCALES.find(l => l.code === locale.value)?.label || locale.value
)

const goHome = () => router.push('/packages')

const onLangCmd = (code) => setLocale(code)

const onCmd = async (cmd) => {
  if (cmd === 'logout') {
    try {
      await ElMessageBox.confirm(t('header.logoutConfirm'), t('common.tip'), {
        type: 'warning',
        confirmButtonText: t('common.confirm'),
        cancelButtonText: t('common.cancel')
      })
      userStore.logout()
      router.push('/login')
    } catch (e) { /* cancel */ }
  } else if (cmd === 'profile') {
    router.push('/profile')
  } else if (cmd === 'orders') {
    router.push('/orders')
  }
}

onMounted(() => {
  if (userStore.token && !userStore.info) {
    userStore.refresh()
  }
})
</script>

<style scoped>
.app-header {
  background: #fff;
  box-shadow: 0 1px 0 var(--border);
  position: sticky;
  top: 0;
  z-index: 100;
}
.inner {
  max-width: 1100px;
  margin: 0 auto;
  height: 60px;
  padding: 0 20px;
  display: flex;
  align-items: center;
  gap: 20px;
}
.brand {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  flex-shrink: 0;
}
.logo {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  background: linear-gradient(135deg, #409EFF, #2c7be5);
  color: #fff;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  letter-spacing: 0.5px;
  font-size: 14px;
}
.title {
  font-weight: 700;
  font-size: 16px;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 8px;
}
.sub {
  font-weight: 500;
  color: var(--muted);
  font-size: 13px;
  border-left: 1px solid var(--border);
  padding-left: 8px;
}
.nav {
  flex: 1;
  display: flex;
  gap: 6px;
}
.nav-item {
  padding: 6px 14px;
  border-radius: 6px;
  color: #555;
  font-size: 14px;
  text-decoration: none;
}
.nav-item:hover { background: #f0f4ff; color: var(--primary); text-decoration: none; }
.nav-item.active { color: var(--primary); background: #ecf5ff; font-weight: 500; }

.account { flex-shrink: 0; display: inline-flex; align-items: center; gap: 14px; }
.lang-dropdown { cursor: pointer; }
.lang-link {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #555;
  font-size: 13px;
  padding: 4px 8px;
  border-radius: 6px;
  cursor: pointer;
}
.lang-link:hover { background: #f0f4ff; color: var(--primary); }
.is-current { color: var(--primary); font-weight: 600; }

.user-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  color: #333;
  font-size: 14px;
}
.avatar {
  background: #ecf5ff;
  color: var(--primary);
  font-weight: 600;
}

@media (max-width: 768px) {
  .inner { padding: 0 12px; gap: 8px; height: 54px; }
  .sub { display: none; }
  .title { font-size: 15px; }
  .nav-item { padding: 6px 8px; font-size: 13px; }
  .user-name { display: none; }
  .lang-name { display: none; }
  .account { gap: 8px; }
}
</style>
