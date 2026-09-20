<template>
  <div class="app-root">
    <AppHeader v-if="showHeader" />
    <router-view />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import AppHeader from '@/components/AppHeader.vue'

const route = useRoute()
// 登录/支付落地页不显示顶栏
const showHeader = computed(() => {
  return !['/login', '/reset-password', '/pay/success', '/pay/cancel'].includes(route.path)
})
</script>

<style>
.app-root {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}
</style>
