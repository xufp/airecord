<template>
  <div class="package-container">
    <!-- 搜索表单 -->
    <el-form :inline="true" :model="search" class="search-form mb-2">
      <div class="search-row">
        <el-form-item label="套餐类型">
          <el-select v-model="search.package_type" placeholder="全部" class="search-select">
            <el-option label="全部" :value="''" />
            <el-option label="免费体验" :value="1" />
            <el-option label="付费购买" :value="2" />
            <el-option label="订阅计划" :value="3" />
            <el-option label="激活卡" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="套餐ID">
          <el-input 
            v-model="search.package_id" 
            placeholder="请输入套餐ID" 
            class="search-input" 
            clearable
            @input="validatePackageId"
          />
        </el-form-item>
        <el-form-item label="关键字">
          <el-input 
            v-model="search.keyword" 
            placeholder="套餐名称/描述" 
            class="search-input" 
            clearable
          />
        </el-form-item>
      </div>
      <div class="search-actions">
        <el-button type="primary" @click="getList">查询</el-button>
        <el-button @click="reset">重置</el-button>
      </div>
    </el-form>
    
    <!-- 桌面端表格 -->
    <el-table :data="list" style="width: 100%" border class="desktop-table">
      <el-table-column prop="package_id" label="套餐ID" width="100"/>
      <el-table-column prop="package_name" label="套餐名称" min-width="180"/>
      <el-table-column prop="package_type" label="套餐类型" width="100">
        <template #default="scope">{{ packageTypeLabel(scope.row.package_type) }}</template>
      </el-table-column>
      <el-table-column prop="price" label="价格" width="120">
        <template #default="scope">
          <span v-if="scope.row.price > 0">
            {{ formatPrice(scope.row.price) }} {{ scope.row.currency }}
          </span>
          <span v-else class="free-text">免费</span>
        </template>
      </el-table-column>
      <el-table-column prop="rates" label="折扣率(%)" width="120">
        <template #default="scope">
          {{ scope.row.rates.toFixed(2) }}%
        </template>
      </el-table-column>
      <el-table-column prop="begin_date" label="有效期开始" width="180"/>
      <el-table-column prop="end_date" label="有效期结束" width="180"/>
      <el-table-column prop="create_time" label="创建时间" width="180"/>
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button 
            size="small" 
            type="primary" 
            @click="viewDetail(scope.row)"
          >
            详情
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 移动端卡片列表 -->
    <div class="mobile-list">
      <div v-for="item in list" :key="item.package_id" class="mobile-card">
        <div class="card-header">
          <span class="card-id">#{{ item.package_id }}</span>
          <span class="card-type" :class="getTypeClass(item.package_type)">{{ packageTypeLabel(item.package_type) }}</span>
        </div>
        <div class="card-content">
          <div class="card-item">
            <label>套餐名称:</label>
            <span>{{ item.package_name }}</span>
          </div>
          <div class="card-item">
            <label>价格:</label>
            <span v-if="item.price > 0" class="price-text">
              {{ formatPrice(item.price) }} {{ item.currency }}
            </span>
            <span v-else class="free-text">免费</span>
          </div>
          <div class="card-item">
            <label>折扣率(%):</label>
            <span>{{ item.rates.toFixed(2) }}%</span>
          </div>
          <div class="card-item">
            <label>有效期开始:</label>
            <span>{{ item.begin_date }}</span>
          </div>
          <div class="card-item">
            <label>有效期结束:</label>
            <span>{{ item.end_date }}</span>
          </div>
          <div class="card-item">
            <label>创建时间:</label>
            <span>{{ item.create_time }}</span>
          </div>
        </div>
        <div class="card-actions">
          <el-button size="small" type="primary" @click="viewDetail(item)">详情</el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'

const router = useRouter()

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

const list = ref([])
const search = ref({ package_id: '', keyword: '', package_type: '' })

const validatePackageId = (value) => {
  // 只允许输入数字
  search.value.package_id = value.replace(/[^\d]/g, '')
}

const getList = async () => {
  try {
    const res = await axios.get('/api/package/list', { params: search.value })
    list.value = res.data.list || []
  } catch (error) {
    console.error('获取套餐列表失败:', error)
    ElMessage.error('获取套餐列表失败')
    list.value = []
  }
}

const reset = () => {
  search.value = { package_id: '', keyword: '', package_type: '' }
  getList()
}

const viewDetail = (packageInfo) => {
  router.push(`/package/detail/${packageInfo.package_id}`)
}

onMounted(getList)
</script>

<style scoped>
.mb-2 { margin-bottom: 16px; }

.package-container {
  width: 100%;
}

/* 搜索表单样式 */
.search-form {
  margin-bottom: 16px;
}

.search-row {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 12px;
}

.search-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.search-select {
  width: 140px;
}

.search-input {
  width: 200px;
}

/* 桌面端表格 */
.desktop-table {
  display: block;
}

/* 移动端列表 */
.mobile-list {
  display: none;
}

/* 移动端卡片样式 */
.mobile-card {
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  margin-bottom: 12px;
  padding: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #f0f0f0;
}

.card-id {
  font-weight: bold;
  color: #409eff;
  font-size: 14px;
}

.card-type {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
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

.card-content {
  margin-bottom: 12px;
}

.card-item {
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.card-item label {
  font-weight: 500;
  color: #666;
  font-size: 12px;
  margin-right: 8px;
  flex-shrink: 0;
  min-width: 80px;
  text-align: right;
}

.card-item span {
  color: #333;
  font-size: 14px;
  word-break: break-all;
  flex: 1;
  text-align: left;
}

.price-text {
  color: #f56c6c;
  font-weight: 500;
}

.free-text {
  color: #52c41a;
  font-weight: 500;
}

.card-actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
  padding-top: 8px;
  border-top: 1px solid #f0f0f0;
}

/* 移动端响应式样式 */
@media (max-width: 768px) {
  .search-row {
    flex-direction: column;
    gap: 8px;
  }
  
  .search-select, .search-input {
    width: 100%;
  }
  
  .search-actions {
    justify-content: center;
  }
  
  .desktop-table {
    display: none;
  }
  
  .mobile-list {
    display: block;
  }
  
  .mobile-card {
    margin-bottom: 8px;
    padding: 12px;
  }
  
  .card-header {
    margin-bottom: 8px;
  }
  
  .card-item {
    margin-bottom: 6px;
  }
}

@media (max-width: 480px) {
  .search-actions {
    flex-direction: column;
  }
  
  .search-actions .el-button {
    width: 100%;
  }
  
  .card-actions {
    flex-direction: column;
  }
  
  .card-actions .el-button {
    width: 100%;
  }
  
  .mobile-card {
    padding: 8px;
  }
  
  .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}
</style>
