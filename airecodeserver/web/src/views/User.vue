<template>
  <div class="user-container">
    <!-- 搜索表单 -->
    <el-form :inline="true" :model="search" class="search-form mb-2">
      <div class="search-row">
        <el-form-item label="状态">
          <el-select v-model="search.state" placeholder="全部" class="search-select">
            <el-option label="全部" :value="''" />
            <el-option label="待激活" :value="1" />
            <el-option label="正常" :value="2" />
            <el-option label="已注销" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="用户ID">
          <el-input 
            v-model="search.user_id" 
            placeholder="请输入用户ID" 
            class="search-input" 
            clearable
            @input="validateUserId"
          />
        </el-form-item>
        <el-form-item label="关键字">
          <el-input 
            v-model="search.keyword" 
            placeholder="用户名/邮箱/电话号码" 
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
      <el-table-column prop="user_id" label="用户ID" width="80"/>
      <el-table-column prop="nick_name" label="用户名称" width="180"/>
      <el-table-column prop="email" label="邮箱" min-width="180"/>
      <el-table-column prop="phone" label="电话号码" width="160"/>
      <el-table-column prop="state" label="用户状态" width="100">
        <template #default="scope">{{ stateLabel(scope.row.state) }}</template>
      </el-table-column>
      <el-table-column prop="create_time" label="注册时间" width="180"/>
      <el-table-column prop="last_login_time" label="最后登录时间" width="180"/>
      <el-table-column prop="membership_level" label="会员等级" width="90">
        <template #default="scope">{{ membershipLevelLabel(scope.row.membership_level) }}</template>
      </el-table-column>
      <el-table-column prop="membership_expire_time" label="会员过期时间" width="180">
        <template #default="scope">
          <span v-if="scope.row.membership_level > 0">{{ scope.row.membership_expire_time || '-' }}</span>
          <span v-else></span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button 
            size="small" 
            type="danger" 
            @click="cancelUser(scope.row)" 
            v-if="scope.row.state === 2"
          >
            注销
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 移动端卡片列表 -->
    <div class="mobile-list">
      <div v-for="item in list" :key="item.user_id" class="mobile-card">
        <div class="card-header">
          <span class="card-id">#{{ item.user_id }}</span>
          <span class="card-state" :class="getStateClass(item.state)">{{ stateLabel(item.state) }}</span>
        </div>
        <div class="card-content">
          <div class="card-item">
            <label>用户名称:</label>
            <span>{{ item.nick_name }}</span>
          </div>
          <div class="card-item">
            <label>邮箱:</label>
            <span>{{ item.email || '-' }}</span>
          </div>
          <div class="card-item">
            <label>电话号码:</label>
            <span>{{ item.phone || '-' }}</span>
          </div>
          <div class="card-item">
            <label>注册时间:</label>
            <span>{{ item.create_time }}</span>
          </div>
          <div class="card-item">
            <label>最后登录时间:</label>
            <span>{{ item.last_login_time || '-' }}</span>
          </div>
          <div class="card-item">
            <label>会员等级:</label>
            <span class="membership-level" :class="getMembershipClass(item.membership_level)">
              {{ membershipLevelLabel(item.membership_level) }}
            </span>
          </div>
          <div class="card-item" v-if="item.membership_level > 0">
            <label>会员过期时间:</label>
            <span>{{ item.membership_expire_time || '-' }}</span>
          </div>
        </div>
        <div class="card-actions" v-if="item.state === 2">
          <el-button size="small" type="danger" @click="cancelUser(item)">注销</el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'

// 状态标签
const stateLabel = (state) => {
  switch(state) {
    case 1: return '待激活'
    case 2: return '正常'
    case 3: return '已注销'
    default: return '未知'
  }
}

// 会员等级标签
const membershipLevelLabel = (level) => {
  switch(level) {
    case 0: return '-'
    case 1: return 'VIP1'
    case 2: return 'VIP2'
    case 99: return 'VIP99'
    default: return '-'
  }
}

// 状态样式类
const getStateClass = (state) => {
  switch(state) {
    case 1: return 'state-pending'
    case 2: return 'state-active'
    case 3: return 'state-cancelled'
    default: return ''
  }
}

// 会员等级样式类
const getMembershipClass = (level) => {
  switch(level) {
    case 0: return 'level-0'
    case 1: return 'level-1'
    case 2: return 'level-2'
    case 99: return 'level-99'
    default: return 'level-0'
  }
}

const list = ref([])
const search = ref({ user_id: '', keyword: '', state: '' })

const validateUserId = (value) => {
  // 只允许输入数字
  search.value.user_id = value.replace(/[^\d]/g, '')
}

const getList = async () => {
  try {
    const res = await axios.get('/api/user/list', { params: search.value })
    list.value = res.data.list || []
  } catch (error) {
    console.error('获取用户列表失败:', error)
    list.value = []
  }
}

const reset = () => {
  search.value = { user_id: '', keyword: '', state: '' }
  getList()
}

const cancelUser = async (user) => {
  try {
    if (confirm(`确定要注销用户 "${user.nick_name}" 吗？此操作不可撤销。`)) {
      await axios.post('/api/user/cancel', { user_id: user.user_id })
      ElMessage.success('用户注销成功')
      getList()
    }
  } catch (error) {
    console.error('注销用户失败:', error)
  }
}

onMounted(getList)
</script>

<style scoped>
.mb-2 { margin-bottom: 16px; }

.user-container {
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

.card-state {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
}

.state-pending {
  background: #fff7e6;
  color: #fa8c16;
}

.state-active {
  background: #f6ffed;
  color: #52c41a;
}

.state-cancelled {
  background: #fff2f0;
  color: #ff4d4f;
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

.membership-level {
  font-size: 12px;
  font-weight: 500;
  display: inline-block;
  color: #333;
}

.level-1 {
  color: #ff4d4f;
}

.level-2 {
  color: #faad14;
}

.level-99 {
  color: #722ed1;
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
  
  .mobile-card {
    padding: 8px;
  }
}
</style>
