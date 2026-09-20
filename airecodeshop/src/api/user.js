import request from './request'

/**
 * 获取用户基本信息
 */
export function getUserInfo() {
  return request.get('/v1/user_info', { silent: true })
}

/**
 * 获取用户当前套餐余额
 * 返回：{ convert: { used, total } }   单位：毫秒
 */
export function getUserPackage() {
  return request.get('/v1/user/package', { silent: true })
}

/**
 * 用户反馈登记
 */
export function feedback(payload) {
  return request.post('/v1/user/feedback', payload)
}
