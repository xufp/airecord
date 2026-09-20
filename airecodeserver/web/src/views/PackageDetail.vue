<template>
  <div class="package-detail-container">
    <!-- 返回按钮 -->
    <div class="back-button">
      <el-button @click="goBack" icon="el-icon-arrow-left">返回套餐列表</el-button>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container">
      <el-skeleton :rows="8" animated />
    </div>

    <!-- 套餐基本信息 -->
    <div v-else-if="packageInfo" class="detail-content">
      <el-card class="info-card" header="套餐基本信息">
        <div class="info-grid">
          <div class="info-item">
            <label>套餐ID:</label>
            <span>{{ packageInfo.package_id }}</span>
          </div>
          <div class="info-item">
            <label>套餐名称:</label>
            <span>{{ packageInfo.package_name }}</span>
          </div>
          <div class="info-item">
            <label>套餐类型:</label>
            <span class="type-tag" :class="getTypeClass(packageInfo.package_type)">
              {{ packageTypeLabel(packageInfo.package_type) }}
            </span>
          </div>
          <div class="info-item">
            <label>套餐描述:</label>
            <span>{{ packageInfo.description || '-' }}</span>
          </div>
          <div class="info-item">
            <label>原价:</label>
            <span v-if="packageInfo.price > 0" class="price-text">
              {{ formatPrice(packageInfo.price) }} {{ packageInfo.currency }}
            </span>
            <span v-else class="free-text">免费</span>
          </div>
          <div class="info-item">
            <label>折扣率(%):</label>
            <span class="discount-text">{{ packageInfo.rates.toFixed(2) }}%</span>
          </div>
          <div class="info-item" v-if="packageInfo.price > 0 && packageInfo.rates > 0">
            <label>实际价格:</label>
            <span class="actual-price">
              {{ formatPrice(packageInfo.price * packageInfo.rates / 100) }} {{ packageInfo.currency }}
            </span>
          </div>
          <div class="info-item">
            <label>币种:</label>
            <span>{{ packageInfo.currency }}</span>
          </div>
          <div class="info-item">
            <label>有效期开始:</label>
            <span>{{ packageInfo.begin_date }}</span>
          </div>
          <div class="info-item">
            <label>有效期结束:</label>
            <span>{{ packageInfo.end_date }}</span>
          </div>
          <div class="info-item">
            <label>创建时间:</label>
            <span>{{ packageInfo.create_time }}</span>
          </div>
          <div class="info-item">
            <label>更新时间:</label>
            <span>{{ packageInfo.last_update_time }}</span>
          </div>
        </div>
      </el-card>

      <!-- 套餐服务信息 -->
      <el-card class="services-card" header="套餐包含服务">
        <div v-if="services.length === 0" class="no-services">
          <el-empty description="该套餐暂无服务信息" />
        </div>
        <div v-else class="services-list">
          <div v-for="service in services" :key="service.service_id" class="service-item">
            <div class="service-header">
              <span class="service-name">{{ service.service_name }}</span>
              <span class="service-type">{{ serviceTypeLabel(service.service_type) }}</span>
            </div>
            <div class="service-content">
              <div class="service-desc">{{ service.description || '暂无描述' }}</div>
              <div class="service-details">
                <div class="detail-item">
                  <label>服务量:</label>
                  <span>{{ formatQuantity(service.quantity) }}</span>
                </div>
                <div class="detail-item">
                  <label>单价:</label>
                  <span v-if="service.price > 0">
                    {{ formatPrice(service.price) }} {{ service.currency }}
                  </span>
                  <span v-else class="free-text">免费</span>
                </div>
                <div class="detail-item">
                  <label>有效期:</label>
                  <span>{{ service.validity_days }}天</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 错误状态 -->
    <div v-else class="error-container">
      <el-result
        icon="error"
        title="获取套餐信息失败"
        sub-title="请检查网络连接或稍后重试"
      >
        <template #extra>
          <el-button type="primary" @click="loadPackageDetail">重新加载</el-button>
        </template>
      </el-result>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()

const packageInfo = ref(null)
const services = ref([])
const loading = ref(true)

// 套餐类型标签
const packageTypeLabel = (type) => {
  switch(type) {
    case 1: return '免费体验'
    case 2: return '付费购买'
    case 3: return '订阅计划'
    case 4: return '激活卡'
    default: return '未知'
  }
}

// 服务类型标签
const serviceTypeLabel = (type) => {
  switch(type) {
    case 1: return '语音转写'
    default: return '未知'
  }
}

// 套餐类型样式类
const getTypeClass = (type) => {
  switch(type) {
    case 1: return 'type-free'
    case 2: return 'type-paid'
    case 3: return 'type-subscription'
    case 4: return 'type-card'
    default: return ''
  }
}

// 格式化价格
const formatPrice = (price) => {
  return (price / 100).toFixed(2)
}

// 格式化服务量
const formatQuantity = (quantity) => {
  if (quantity >= 3600) {
    return `${(quantity / 3600).toFixed(1)}小时`
  } else if (quantity >= 60) {
    return `${(quantity / 60).toFixed(1)}分钟`
  } else {
    return `${quantity}秒`
  }
}

const loadPackageDetail = async () => {
  const packageId = route.params.id
  if (!packageId) {
    ElMessage.error('套餐ID不能为空')
    return
  }

  loading.value = true
  try {
    // 获取套餐基本信息
    const packageRes = await axios.get(`/api/package/detail/${packageId}`)
    packageInfo.value = packageRes.data

    // 获取套餐服务信息
    const servicesRes = await axios.get(`/api/package/services/${packageId}`)
    services.value = servicesRes.data.list || []
  } catch (error) {
    console.error('获取套餐详情失败:', error)
    ElMessage.error('获取套餐详情失败')
    packageInfo.value = null
    services.value = []
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  router.push('/package')
}

onMounted(() => {
  loadPackageDetail()
})
</script>

<style scoped>
.package-detail-container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
}

.back-button {
  margin-bottom: 16px;
}

.loading-container {
  padding: 20px;
}

.detail-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.info-card, .services-card {
  width: 100%;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 16px;
}

.info-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}

.info-item:last-child {
  border-bottom: none;
}

.info-item label {
  font-weight: 500;
  color: #666;
  font-size: 12px;
  margin-right: 8px;
  flex-shrink: 0;
  min-width: 100px;
  text-align: right;
}

.info-item span {
  color: #333;
  font-size: 14px;
  word-break: break-all;
  flex: 1;
  text-align: left;
}

.type-tag {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.type-free {
  background: #f6ffed;
  color: #52c41a;
}

.type-paid {
  background: #e6f7ff;
  color: #1890ff;
}

.type-subscription {
  background: #fff7e6;
  color: #fa8c16;
}

.type-card {
  background: #f9f0ff;
  color: #722ed1;
}

.price-text {
  color: #f56c6c;
  font-weight: 500;
}

.free-text {
  color: #52c41a;
  font-weight: 500;
}

.discount-text {
  color: #fa8c16;
  font-weight: 500;
}

.actual-price {
  color: #f56c6c;
  font-weight: bold;
  font-size: 16px;
}

.no-services {
  text-align: center;
  padding: 40px 0;
}

.services-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.service-item {
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 16px;
  background: #fafafa;
}

.service-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #e4e7ed;
}

.service-name {
  font-size: 16px;
  font-weight: 500;
  color: #333;
}

.service-type {
  padding: 2px 8px;
  background: #e6f7ff;
  color: #1890ff;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.service-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.service-desc {
  color: #666;
  font-size: 14px;
  line-height: 1.5;
}

.service-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 12px;
  margin-top: 8px;
}

.detail-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 6px;
}

.detail-item label {
  font-size: 12px;
  color: #999;
  min-width: 60px;
  margin-right: 8px;
  flex-shrink: 0;
  text-align: right;
}

.detail-item span {
  font-size: 14px;
  color: #333;
  font-weight: 500;
  flex: 1;
  text-align: left;
}

.error-container {
  text-align: center;
  padding: 40px 0;
}

/* 移动端响应式样式 */
@media (max-width: 768px) {
  .info-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .info-item {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
  }
  
  .info-item label {
    min-width: 80px;
    margin-right: 8px;
    text-align: right;
    font-size: 11px;
  }
  
  .info-item span {
    font-size: 13px;
  }
  
  .service-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  
  .service-details {
    grid-template-columns: 1fr;
    gap: 8px;
  }
  
  .detail-item {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
  }
  
  .detail-item label {
    min-width: 50px;
    text-align: right;
    font-size: 11px;
  }
  
  .detail-item span {
    font-size: 13px;
  }
}

@media (max-width: 480px) {
  .package-detail-container {
    padding: 0 8px;
  }
  
  .service-item {
    padding: 12px;
  }
  
  .back-button {
    margin-bottom: 12px;
  }
  
  .back-button .el-button {
    width: 100%;
  }
  
  .info-item label {
    min-width: 70px;
    font-size: 10px;
  }
  
  .info-item span {
    font-size: 12px;
  }
  
  .detail-item label {
    min-width: 45px;
    font-size: 10px;
  }
  
  .detail-item span {
    font-size: 12px;
  }
}
</style>
