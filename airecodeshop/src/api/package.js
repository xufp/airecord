import request from './request'
import { apiLang } from '@/locales'

/**
 * 查询可购买（领取）套餐
 * @param {number} packageType 1-免费体验类 / 2-付费购买套餐 / 3-订阅计划
 *
 * 多语言：后端通过 URL query 参数 `lang`（zh/en/ja/ko）返回对应语言的
 * package_name / description，需显式在 query 里传递（后端不识别 Accept-Language header）。
 */
export function listAvailablePackages(packageType = 2) {
  return request.get('/v1/packages/available', {
    params: { package_type: packageType, lang: apiLang() },
    silent: true
  })
}

/**
 * 免费套餐领取
 */
export function givePackage(packageId) {
  return request.post('/v1/user/package_give', { package_id: packageId })
}
