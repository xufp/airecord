<template>
  <el-container class="root-container" v-if="$route.path !== '/login'">
    <!-- 移动端遮罩层 -->
    <div v-if="isMobile && !collapsed" class="mobile-mask" @click="collapsed = true"></div>
    
    <!-- 侧边栏 -->
    <el-aside 
      :width="isMobile ? (collapsed ? '0px' : '280px') : (collapsed ? '64px' : '220px')" 
      class="side-aside"
      :class="{ 'mobile-sidebar': isMobile, 'mobile-sidebar-open': isMobile && !collapsed }"
    >
      <div class="logo-area">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCI+PHBhdGggZmlsbD0iIzJjM2U1MCIgZD0iTTEyIDJDNi40OCAyIDIgNi40OCAyIDEyczQuNDggMTAgMTAgMTAgMTAtNC40OCAxMC0xMFMxNy41MiAyIDEyIDJ6bTAgMThjLTQuNDIgMC04LTMuNTgtOC04czMuNTgtOCA4LTggOCAzLjU4IDggOC0zLjU4IDgtOCA4eiIvPjxwYXRoIGZpbGw9IiMyYzNlNTAiIGQ9Ik0xMiA2Yy0zLjMxIDAtNiAyLjY5LTYgNiAwIDMuMzEgMi42OSA2IDYgNiAzLjMxIDAgNi0yLjY5IDYtNiAwLTMuMzEtMi42OS02LTYtNnpNMTIgMTBjLTEuMSAwLTItLjktMi0ycy45LTIgMi0yIDIgLjkgMiAyLS45IDItMiAyeiIvPjwvc3ZnPg==" alt="Logo" class="logo" v-if="!collapsed || isMobile" />
        <span class="logo-text" v-if="!collapsed || isMobile">AiRecord</span>
        <i class="el-icon-s-fold toggle-btn" @click="collapsed = !collapsed" />
      </div>
      <el-menu
        :default-active="$route.path"
        router
        background-color="#001529"
        text-color="#fff"
        active-text-color="#409EFF"
        :collapse="!isMobile && collapsed"
        class="side-menu"
        @select="onMenuSelect"
      >
        <el-menu-item index="/config">
          <i class="el-icon-setting"></i>
          <span>配置管理</span>
        </el-menu-item>
        <el-menu-item index="/card">
          <i class="el-icon-credit-card"></i>
          <span>激活卡管理</span>
        </el-menu-item>
        <el-menu-item index="/user">
          <i class="el-icon-user"></i>
          <span>用户管理</span>
        </el-menu-item>
        <el-menu-item index="/package">
          <i class="el-icon-goods"></i>
          <span>套餐管理</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    
    <!-- 主体 -->
    <el-container>
      <!-- 顶部栏 -->
      <el-header class="header-bar">
        <div class="header-left">
          <!-- 移动端菜单按钮 -->
          <div v-if="isMobile" class="mobile-menu-btn" @click="collapsed = !collapsed">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M3 12H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M3 6H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M3 18H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
          <el-breadcrumb separator="/" :class="{ 'mobile-breadcrumb': isMobile }">
            <el-breadcrumb-item>首页</el-breadcrumb-item>
            <el-breadcrumb-item>{{ breadcrumb }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <el-dropdown>
            <span class="el-dropdown-link">
              <i class="el-icon-user"></i> 
              <span v-if="!isMobile">管理员</span>
              <i class="el-icon-arrow-down"></i>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item>个人中心</el-dropdown-item>
                <el-dropdown-item divided @click="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      
      <!-- 内容区 -->
      <el-main class="main-area">
        <el-card class="main-card">
          <router-view />
        </el-card>
      </el-main>
    </el-container>
  </el-container>
  <router-view v-else />
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const collapsed = ref(false)
const isMobile = ref(false)
const route = useRoute()
const router = useRouter()

// 检测是否为移动端
const checkMobile = () => {
  const width = window.innerWidth
  const wasMobile = isMobile.value
  isMobile.value = width <= 768
  
  // 如果从桌面端切换到移动端，收起侧边栏
  if (!wasMobile && isMobile.value) {
    collapsed.value = true
  }
  // 如果从移动端切换到桌面端，展开侧边栏
  else if (wasMobile && !isMobile.value) {
    collapsed.value = false
  }
}

const breadcrumb = computed(() => {
  if (route.path.startsWith('/config')) return '配置管理'
  if (route.path.startsWith('/card')) return '激活码管理'
  if (route.path.startsWith('/user')) return '用户管理'
  if (route.path.startsWith('/package')) return '套餐管理'
  return ''
})

const logout = () => {
  localStorage.removeItem('access_token')
  router.push('/login')
}

// 移动端菜单选择处理
const onMenuSelect = () => {
  if (isMobile.value) {
    collapsed.value = true
  }
}

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', checkMobile)
})
</script>

<style scoped>
.menu-icon {
  display: inline-block;
  vertical-align: middle;
  margin-right: 8px;
}

.root-container {
  height: 100vh;
  width: 100vw;
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  position: fixed;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
}

/* 移动端遮罩层 */
.mobile-mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 999;
}

.side-aside {
  margin: 0;
  padding: 0;
  box-shadow: none;
  border: none;
  min-height: 100vh;
  background: #001529;
  transition: all 0.3s ease;
  z-index: 1000;
}

/* 移动端侧边栏样式 */
.mobile-sidebar {
  position: fixed;
  top: 0;
  left: 0;
  height: 100vh;
  z-index: 1000;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.15);
  transform: translateX(-100%);
  transition: transform 0.3s ease;
}

.mobile-sidebar-open {
  transform: translateX(0);
}

.logo-area {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  background: #001529;
  border-bottom: 1px solid #222b3a;
}

.logo {
  height: 36px;
  margin-right: 8px;
}

.logo-text {
  color: #fff;
  font-size: 20px;
  font-weight: bold;
  letter-spacing: 2px;
}

.toggle-btn {
  color: #fff;
  font-size: 20px;
  cursor: pointer;
}

.side-menu {
  border-right: none;
  min-height: calc(100vh - 60px);
}

.header-bar {
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 56px;
  box-shadow: 0 1px 4px rgba(0,21,41,.08);
  padding: 0 24px;
  z-index: 100;
}

.header-left {
  display: flex;
  align-items: center;
}

/* 移动端菜单按钮 */
.mobile-menu-btn {
  margin-right: 12px;
  cursor: pointer;
  color: #666;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.3s ease;
  background: transparent;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
}

.mobile-menu-btn:hover {
  background: #e6f7ff;
  color: #1890ff;
}

.mobile-menu-btn svg {
  width: 20px;
  height: 20px;
}

.mobile-breadcrumb {
  font-size: 14px;
}

.header-right {
  display: flex;
  align-items: center;
}

.main-area {
  background: #f0f2f5;
  min-height: calc(100vh - 56px);
  padding: 32px 24px;
}

.main-card {
  width: 100%;
  min-height: 600px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  border-radius: 8px;
  background: #fff;
}

/* 移动端响应式样式 */
@media (max-width: 768px) {
  .header-bar {
    padding: 0 16px;
  }
  
  .main-area {
    padding: 16px 12px;
  }
  
  .main-card {
    min-height: 400px;
    border-radius: 6px;
  }
  
  .logo-text {
    font-size: 18px;
  }
  
  .side-menu .el-menu-item {
    padding: 0 20px;
  }
  
  .side-menu .el-menu-item span {
    font-size: 16px;
  }
}

@media (max-width: 480px) {
  .header-bar {
    padding: 0 12px;
  }
  
  .main-area {
    padding: 12px 8px;
  }
  
  .logo-area {
    padding: 0 12px;
  }
  
  .logo {
    height: 32px;
  }
  
  .logo-text {
    font-size: 16px;
  }
  
  .mobile-breadcrumb {
    font-size: 12px;
  }
  
  .mobile-breadcrumb .el-breadcrumb__item:last-child {
    display: none;
  }
}

</style> 