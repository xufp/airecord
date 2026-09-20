import request from './request'

/**
 * 创建购买套餐订单
 * @param {Object} payload { package_id, pay_channel } pay_channel: 1-paypal
 * 返回：{ order_id, state, link: { method, href } }
 */
export function createOrder(payload) {
  return request.post('/v1/order/create', {
    package_id: payload.package_id,
    pay_channel: payload.pay_channel || 1
  })
}

/**
 * 订单详情查询
 */
export function getOrderDetail(orderId) {
  return request.get('/v1/order/detail', {
    params: { order_id: orderId }
  })
}

/**
 * 订单列表查询
 * @param {Object} params { page, size, states }
 *   states: 状态值数组或逗号分隔字符串，1-待支付 2-已支付 3-支付失败 4-已发货/已激活 5-订阅取消
 */
export function listOrders(params) {
  const query = {
    page: params.page || 1,
    size: params.size || 20
  }
  if (params.states !== undefined && params.states !== null && params.states !== '') {
    query.states = Array.isArray(params.states) ? params.states.join(',') : params.states
  }
  return request.get('/v1/order/list', { params: query })
}
