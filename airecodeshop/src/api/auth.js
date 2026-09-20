import request from './request'

/**
 * 用户登录（邮箱+密码）
 * @param {Object} payload { email, password, register }
 *  - register=true 表示首次注册，未注册邮箱将自动注册并发送邮箱验证码
 *  - 返回 state=1 邮箱待验证；state=2 登录成功
 */
export function login(payload) {
  return request.post('/v1/auth/login', {
    email: payload.email,
    password: payload.password,
    register: !!payload.register
  })
}

/**
 * 获取邮箱/手机验证码
 * @param {Object} payload { email } 或 { phone }
 */
export function getCode(payload) {
  return request.post('/v1/auth/get_code', payload)
}

/**
 * 验证码验证（注册流程二阶段）
 * @param {Object} payload { email/phone, code }
 */
export function verifyCode(payload) {
  return request.post('/v1/auth/verify_code', payload)
}

/**
 * 修改密码（已登录）
 */
export function changePassword(payload) {
  return request.post('/v1/auth/change_password', {
    current_password: payload.current_password,
    new_password: payload.new_password
  })
}

/**
 * 重置密码：
 *   第一步：仅传 email，会发送验证码
 *   第二步：传 email + code + new_password
 */
export function resetPassword(payload) {
  return request.post('/v1/auth/reset_password', payload)
}
