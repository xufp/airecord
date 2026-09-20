<template>
  <div class="card-container">
    <!-- 搜索表单 -->
    <el-form :inline="true" :model="search" class="search-form mb-2">
      <div class="search-row">
        <el-form-item label="状态">
          <el-select v-model="search.card_state" placeholder="全部" class="search-select">
            <el-option label="全部" :value="''" />
            <el-option label="未激活" :value="1" />
            <el-option label="已激活" :value="2" />
            <el-option label="已作废" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="激活码">
          <el-input v-model="search.card_code" placeholder="激活码" class="search-input" />
        </el-form-item>
      </div>
      <div class="search-actions">
        <el-button type="primary" @click="getList">查询</el-button>
        <el-button @click="reset">重置</el-button>
        <el-button type="success" @click="showAdd = true">新增激活码</el-button>
      </div>
    </el-form>
    
    <!-- 桌面端表格 -->
    <el-table :data="list" style="width: 100%" border class="desktop-table">
      <el-table-column prop="card_code" label="激活码" min-width="200"/>
      <el-table-column prop="card_state" label="状态" width="100">
        <template #default="scope">{{ stateLabel(scope.row.card_state) }}</template>
      </el-table-column>
      <el-table-column prop="card_expire_time" label="过期时间" min-width="180"/>
      <el-table-column prop="activation_user_id" label="激活用户ID" min-width="150"/>
      <el-table-column prop="activation_time" label="激活时间" min-width="180"/>
      <el-table-column prop="package_id" label="套餐ID" width="100"/>
      <el-table-column prop="create_time" label="创建时间" min-width="180"/>
      <el-table-column prop="last_update_time" label="更新时间" min-width="180"/>
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button size="small" type="danger" @click="voidCard(scope.row)" v-if="scope.row.card_state==1">作废</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 移动端卡片列表 -->
    <div class="mobile-list">
      <div v-for="item in list" :key="item.card_code" class="mobile-card">
        <div class="card-header">
          <span class="card-code">{{ item.card_code }}</span>
          <span class="card-state" :class="getStateClass(item.card_state)">{{ stateLabel(item.card_state) }}</span>
        </div>
        <div class="card-content">
          <div class="card-item">
            <label>套餐ID:</label>
            <span>{{ item.package_id }}</span>
          </div>
          <div class="card-item">
            <label>过期时间:</label>
            <span>{{ item.card_expire_time }}</span>
          </div>
          <div class="card-item" v-if="item.activation_user_id">
            <label>激活用户ID:</label>
            <span>{{ item.activation_user_id }}</span>
          </div>
          <div class="card-item" v-if="item.activation_time">
            <label>激活时间:</label>
            <span>{{ item.activation_time }}</span>
          </div>
          <div class="card-item">
            <label>创建时间:</label>
            <span>{{ item.create_time }}</span>
          </div>
          <div class="card-item">
            <label>更新时间:</label>
            <span>{{ item.last_update_time }}</span>
          </div>
        </div>
        <div class="card-actions" v-if="item.card_state == 1">
          <el-button size="small" type="danger" @click="voidCard(item)">作废</el-button>
        </div>
      </div>
    </div>
    <!-- 新增弹窗 -->
    <el-dialog v-model="showAdd" title="新增激活码">
      <el-form :model="addForm" label-width="80px">
        <el-form-item label="套餐ID"><el-input v-model="addForm.package_id" @input="validatePackageId" placeholder="请输入套餐ID"/></el-form-item>
        <el-form-item label="过期时间"><el-date-picker v-model="addForm.card_expire_time" type="datetime" placeholder="选择日期时间" style="width:100%"/></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" @click="add">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
const stateLabel = v => v===1?'未激活':v===2?'已激活':v===3?'已作废':v

const getStateClass = (state) => {
  switch(state) {
    case 1: return 'state-inactive'
    case 2: return 'state-active'
    case 3: return 'state-void'
    default: return ''
  }
}
const list = ref([])
const search = ref({ card_state: '', card_code: '' })
const showAdd = ref(false)
const addForm = ref({ package_id: '', card_expire_time: '' })

const validatePackageId = (value) => {
  // 只允许输入数字
  addForm.value.package_id = value.replace(/[^\d]/g, '')
}

const getList = async () => {
  const res = await axios.get('/api/card/list', { params: search.value })
  list.value = res.data.list
}
const reset = () => {
  search.value = { card_state: '', card_code: '' }
  getList()
}
const add = async () => {
  const submitData = {
    ...addForm.value,
    package_id: parseInt(addForm.value.package_id) || 0
  }
  await axios.post('/api/card/add', submitData)
  showAdd.value = false
  getList()
}
const voidCard = async (row) => {
  if (confirm('确定作废该激活码？')) {
    await axios.post('/api/card/void', { card_code: row.card_code })
    getList()
  }
}
onMounted(getList)
</script>
<style scoped>
.mb-2 { margin-bottom: 16px; }

.card-container {
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
  width: 120px;
}

.search-input {
  width: 180px;
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

.card-code {
  font-weight: bold;
  color: #333;
  font-size: 14px;
  font-family: monospace;
  word-break: break-all;
  flex: 1;
  margin-right: 8px;
}

.card-state {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
}

.state-inactive {
  background: #fff7e6;
  color: #fa8c16;
}

.state-active {
  background: #f6ffed;
  color: #52c41a;
}

.state-void {
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
  
  .card-code {
    font-size: 13px;
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
  
  .card-code {
    margin-right: 0;
    margin-bottom: 4px;
  }
}
</style> 