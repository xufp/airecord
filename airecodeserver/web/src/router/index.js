import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Config from '../views/Config.vue'
import Card from '../views/Card.vue'
import User from '../views/User.vue'
import Package from '../views/Package.vue'
import PackageDetail from '../views/PackageDetail.vue'

const routes = [
  { path: '/login', component: Login },
  { path: '/config', component: Config },
  { path: '/card', component: Card },
  { path: '/user', component: User },
  { path: '/package', component: Package },
  { path: '/package/detail/:id', component: PackageDetail },
  { path: '/', redirect: '/config' }
]

const router = createRouter({
  history: createWebHistory('/admin/'),
  routes
})

// 简单鉴权
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('access_token')
  if (to.path !== '/login' && !token) {
    next('/login')
  } else {
    next()
  }
})

export default router 