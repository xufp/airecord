import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  { path: '/', redirect: '/packages' },
  { path: '/login', name: 'login', component: () => import('@/views/Login.vue'), meta: { public: true } },
  { path: '/reset-password', name: 'reset', component: () => import('@/views/ResetPassword.vue'), meta: { public: true } },

  { path: '/packages', name: 'packages', component: () => import('@/views/Packages.vue'), meta: { title: '套餐购买' } },
  { path: '/orders', name: 'orders', component: () => import('@/views/Orders.vue'), meta: { title: '我的订单' } },
  { path: '/profile', name: 'profile', component: () => import('@/views/Profile.vue'), meta: { title: '个人中心' } },

  // PayPal Return / Cancel 落地页（用于 paypal 回跳到前端展示结果）
  { path: '/pay/success', name: 'pay-success', component: () => import('@/views/PaySuccess.vue'), meta: { public: true } },
  { path: '/pay/cancel', name: 'pay-cancel', component: () => import('@/views/PayCancel.vue'), meta: { public: true } },

  { path: '/:pathMatch(.*)*', redirect: '/packages' }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('access_token')
  if (!to.meta.public && !token) {
    next({ name: 'login', query: { redirect: to.fullPath } })
  } else {
    next()
  }
})

export default router
