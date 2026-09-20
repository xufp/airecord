<template>
  <div class="config-container">
    <!-- 搜索表单 -->
    <el-form :inline="true" :model="search" class="search-form mb-2">
      <div class="search-row">
        <el-form-item label="类型">
          <el-select v-model="search.config_type" placeholder="全部" class="search-select">
            <el-option label="全部" :value="''" />
            <el-option v-for="item in configTypes" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键字">
          <el-input v-model="search.keyword" placeholder="配置键/描述" class="search-input" />
        </el-form-item>
      </div>
      <div class="search-actions">
        <el-button type="primary" @click="getList">查询</el-button>
        <el-button @click="reset">重置</el-button>
        <el-button type="success" @click="showAdd = true">新增配置</el-button>
      </div>
    </el-form>
    
    <!-- 桌面端表格 -->
    <el-table :data="list" style="width: 100%" border class="desktop-table">
      <el-table-column prop="id" label="ID" width="60"/>
      <el-table-column prop="config_type" label="类型" width="120">
        <template #default="scope">{{ typeLabel(scope.row.config_type) }}</template>
      </el-table-column>
      <el-table-column prop="config_key" label="配置键" width="160"/>
      <el-table-column prop="config_value" label="配置值">
        <template #default="scope">
          <div class="config-value-cell">
            {{ scope.row.config_value }}
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="config_desc" label="描述" width="160">
        <template #default="scope">
          <div class="config-value-cell">
            {{ scope.row.config_desc }}
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="create_time" label="创建时间" width="180"/>
      <el-table-column prop="last_update_time" label="更新时间" width="180"/>
      <el-table-column label="操作" width="160">
        <template #default="scope">
          <el-button size="small" @click="edit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="del(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 移动端卡片列表 -->
    <div class="mobile-list">
      <div v-for="item in list" :key="item.id" class="mobile-card">
        <div class="card-header">
          <span class="card-id">#{{ item.id }}</span>
          <span class="card-type">{{ typeLabel(item.config_type) }}</span>
        </div>
        <div class="card-content">
          <div class="card-item">
            <label>配置键:</label>
            <span>{{ item.config_key }}</span>
          </div>
          <div class="card-item">
            <label>配置值:</label>
            <div class="config-value">{{ item.config_value }}</div>
          </div>
          <div class="card-item" v-if="item.config_desc">
            <label>描述:</label>
            <div class="config-desc">{{ item.config_desc }}</div>
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
        <div class="card-actions">
          <el-button size="small" @click="edit(item)">编辑</el-button>
          <el-button size="small" type="danger" @click="del(item)">删除</el-button>
        </div>
      </div>
    </div>
    <!-- 新增弹窗 -->
    <el-dialog v-model="showAdd" title="新增配置">
      <el-form :model="addForm" label-width="80px">
        <el-form-item label="类型">
          <el-select v-model="addForm.config_type" placeholder="请选择">
            <el-option v-for="item in configTypes" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="配置键"><el-input v-model="addForm.config_key"/></el-form-item>
        <el-form-item label="配置值"><el-input v-model="addForm.config_value" type="textarea" :rows="3"/></el-form-item>
        <el-form-item label="描述"><el-input v-model="addForm.config_desc" type="textarea" :rows="3"/></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" @click="add">确定</el-button>
      </template>
    </el-dialog>
    <!-- 编辑弹窗 -->
    <el-dialog v-model="showEdit" title="编辑配置">
      <el-form :model="editForm" label-width="80px">
        <el-form-item label="类型">
          <el-select v-model="editForm.config_type" placeholder="请选择" disabled>
            <el-option v-for="item in configTypes" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="配置键"><el-input v-model="editForm.config_key" disabled/></el-form-item>
        <el-form-item label="配置值"><el-input v-model="editForm.config_value" type="textarea" :rows="3"/></el-form-item>
        <el-form-item label="描述"><el-input v-model="editForm.config_desc" type="textarea" :rows="3"/></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showEdit = false">取消</el-button>
        <el-button type="primary" @click="update">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
const configTypes = [
  { value: 1, label: '应用协议' },
  { value: 2, label: '帮助手册' },
  { value: 3, label: 'IOS版本' },
  { value: 4, label: 'Android版本' },
  { value: 5, label: 'ASR引擎模型' },
  { value: 6, label: 'Prompt模板' },
  { value: 7, label: '蓝牙设备' },
  { value: 8, label: '套餐多语言配置' }
]
const typeLabel = (v) => configTypes.find(i=>i.value===v)?.label || v
const list = ref([])
const search = ref({ config_type: '', keyword: '' })
const showAdd = ref(false)
const showEdit = ref(false)
const addForm = ref({ config_type: '', config_key: '', config_value: '', config_desc: '', config_name: '' })
const editForm = ref({ id: '', config_type: '', config_key: '', config_value: '', config_desc: '', config_name: '' })
const getList = async () => {
  // 实际应带上筛选参数
  const res = await axios.get('/api/config/list', { params: search.value })
  list.value = res.data.list
}
const reset = () => {
  search.value = { config_type: '', keyword: '' }
  getList()
}
const add = async () => {
  await axios.post('/api/config/add', addForm.value)
  showAdd.value = false
  getList()
}
const edit = (row) => {
  editForm.value = { ...row }
  showEdit.value = true
}
const update = async () => {
  await axios.post('/api/config/update', editForm.value)
  showEdit.value = false
  getList()
}
const del = async (row) => {
  if (confirm('确定删除该配置项？')) {
    await axios.post('/api/config/delete', { id: row.id })
    getList()
  }
}
onMounted(getList)
</script>
<style scoped>
.mb-2 { margin-bottom: 16px; }

.config-container {
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

/* 表格单元格样式 */
.config-value-cell {
  max-height: 3em;
  line-height: 1.5em;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  word-break: break-all;
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
  background: #f0f9ff;
  color: #1890ff;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
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

.config-value, .config-desc {
  color: #333;
  font-size: 14px;
  word-break: break-all;
  line-height: 1.4;
  max-height: 4.2em;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
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
}
</style> 