import './assets/main.css'

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import { ElMessage } from 'element-plus'
import axios from 'axios'

// 配置axios请求拦截器
axios.interceptors.request.use(
  config => {
    // 从localStorage获取token
    const token = localStorage.getItem('access_token')
    if (token) {
      // 为所有请求添加Authorization头
      config.headers.Authorization = `token ${token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 配置axios响应拦截器
axios.interceptors.response.use(
  response => {
    return response
  },
  error => {
    // 如果是401未授权，清除token并跳转到登录页
    if (error.response && error.response.status === 401) {
      localStorage.removeItem('access_token')
      window.location.href = '/admin/login'
      return Promise.reject(error)
    }
    
    // 统一错误提示
    let errorMessage = '请求失败'
    
    if (error.response) {
      // 服务器返回错误状态码
      const { status, data } = error.response
      
      if (data) {
        // 优先显示服务器返回的error信息
        if (data.error) {
          errorMessage = data.error
        } else if (data.msg) {
          // 如果没有error字段，使用msg字段
          errorMessage = data.msg
        } else {
          // 根据状态码显示默认错误信息
          switch (status) {
            case 400:
              errorMessage = '请求参数错误'
              break
            case 403:
              errorMessage = '权限不足'
              break
            case 404:
              errorMessage = '请求的资源不存在'
              break
            case 500:
              errorMessage = '服务器内部错误'
              break
            default:
              errorMessage = `请求失败 (${status})`
          }
        }
      } else {
        // 根据状态码显示默认错误信息
        switch (status) {
          case 400:
            errorMessage = '请求参数错误'
            break
          case 403:
            errorMessage = '权限不足'
            break
          case 404:
            errorMessage = '请求的资源不存在'
            break
          case 500:
            errorMessage = '服务器内部错误'
            break
          default:
            errorMessage = `请求失败 (${status})`
        }
      }
    } else if (error.request) {
      // 网络错误
      errorMessage = '网络连接失败，请检查网络设置'
    } else {
      // 其他错误
      errorMessage = error.message || '未知错误'
    }
    
    // 显示错误提示
    ElMessage.error(errorMessage)
    
    return Promise.reject(error)
  }
)

const app = createApp(App)
app.use(router)
app.use(ElementPlus)

// 全局挂载ElMessage
app.config.globalProperties.$message = ElMessage

app.mount('#app')
