import { reactive } from 'vue'
import { getUserInfo, getUserPackage } from '@/api/user'

/**
 * 简易全局用户状态（不引入 pinia，保持依赖最少）
 */
export const userStore = reactive({
  token: localStorage.getItem('access_token') || '',
  info: null,         // 用户信息
  pkg: null,          // 套餐余额 { convert: {used,total} }
  loading: false,

  setToken(token) {
    this.token = token || ''
    if (token) localStorage.setItem('access_token', token)
    else localStorage.removeItem('access_token')
  },

  async refresh() {
    if (!this.token) return
    this.loading = true
    try {
      const [infoRes, pkgRes] = await Promise.all([
        getUserInfo().catch(() => ({ data: null })),
        getUserPackage().catch(() => ({ data: null }))
      ])
      this.info = infoRes.data || null
      this.pkg = pkgRes.data || null
      if (this.info) {
        localStorage.setItem('user_info', JSON.stringify(this.info))
      }
    } finally {
      this.loading = false
    }
  },

  logout() {
    this.setToken('')
    this.info = null
    this.pkg = null
    localStorage.removeItem('user_info')
  }
})
