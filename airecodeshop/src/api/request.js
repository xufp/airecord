import axios from 'axios'
import { ElMessage } from 'element-plus'
import { i18n, apiLang } from '@/locales'

// 创建 axios 实例
// 后端基路径为 /v1（参考《AI 录音笔服务端接口文档》），
// dev 通过 vite.config.js 中的 proxy 转发到真实域名；
// 生产环境如果与后端同域部署，留空即可。
const request = axios.create({
  baseURL: '',
  timeout: 30000,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  }
})

const t = (k, p) => i18n.global.t(k, p)

// 请求拦截：注入 Authorization & 语言
// 说明：语言优先通过各接口的 query 参数 `lang` 传递（后端按 query 识别语言，
// 例如 /v1/packages/available?lang=en）。这里同时补一个标准 header `Accept-Language`
// 作为兜底，不影响后端 schema 校验。
request.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token')
    if (token) {
      // 接口文档要求格式：Authorization: token ${access_token}
      config.headers.Authorization = `token ${token}`
    }
    if (!config.headers['Accept-Language']) {
      config.headers['Accept-Language'] = apiLang()
    }
    return config
  },
  (error) => Promise.reject(error)
)

// 响应拦截：统一错误处理
request.interceptors.response.use(
  (response) => response,
  (error) => {
    // 静默选项：调用方可通过 config.silent = true 关闭统一报错
    const silent = error.config && error.config.silent
    let message = t('http.fail')

    if (error.response) {
      const { status, data } = error.response
      if (status === 401) {
        // 鉴权失败：清理 token，跳登录
        localStorage.removeItem('access_token')
        localStorage.removeItem('user_info')
        if (location.pathname.indexOf('/login') === -1) {
          // 使用 base 路径
          location.href = `${import.meta.env.BASE_URL}login`
        }
        return Promise.reject(error)
      }
      if (data && (data.msg || data.error || data.message)) {
        message = data.msg || data.error || data.message
      } else {
        switch (status) {
          case 400: message = t('http.badRequest'); break
          case 403: message = t('http.forbidden'); break
          case 404: message = t('http.notFound'); break
          case 500: message = t('http.serverError'); break
          default: message = t('http.failWithCode', { code: status })
        }
      }
    } else if (error.request) {
      message = t('http.network')
    } else {
      message = error.message || t('http.unknown')
    }

    if (!silent) ElMessage.error(message)
    return Promise.reject(error)
  }
)

export default request
