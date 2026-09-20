<template>
  <div class="login-root">
    <canvas ref="bgCanvas" class="login-bg-canvas"></canvas>
    <div class="login-main-area">
      <div class="login-main-content">
        <el-card class="login-card">
          <div class="login-logo-row">
            <img class="login-logo" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCI+PHBhdGggZmlsbD0iIzJjM2U1MCIgZD0iTTEyIDJDNi40OCAyIDIgNi40OCAyIDEyczQuNDggMTAgMTAgMTAgMTAtNC40OCAxMC0xMFMxNy41MiAyIDEyIDJ6bTAgMThjLTQuNDIgMC04LTMuNTgtOC04czMuNTgtOCA4LTggOCAzLjU4IDggOC0zLjU4IDgtOCA4eiIvPjxwYXRoIGZpbGw9IiMyYzNlNTAiIGQ9Ik0xMiA2Yy0zLjMxIDAtNiAyLjY5LTYgNiAwIDMuMzEgMi42OSA2IDYgNiAzLjMxIDAgNi0yLjY5IDYtNiAwLTMuMzEtMi42OS02LTYtNnpNMTIgMTBjLTEuMSAwLTItLjktMi0ycy45LTIgMi0yIDIgLjkgMiAyLS45IDItMiAyeiIvPjwvc3ZnPg==" />
            <span class="login-title">AiRecord 管理后台</span>
          </div>
          <el-form @submit.prevent="onLogin" :model="form" class="login-form">
            <el-form-item>
              <el-input v-model="form.email" placeholder="邮箱" size="large" />
            </el-form-item>
            <el-form-item>
              <el-input v-model="form.password" type="password" placeholder="密码" size="large" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" size="large" style="width:100%" @click="onLogin">登录</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </div>
      <div class="login-footer">© 2024 AiRecord. All rights reserved.</div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
const router = useRouter()
const form = ref({ email: '', password: '' })
const bgCanvas = ref(null)
let animationId

const drawBg = () => {
  const canvas = bgCanvas.value
  if (!canvas) return
  const ctx = canvas.getContext('2d')
  const dpr = window.devicePixelRatio || 1
  const w = canvas.width = window.innerWidth * dpr
  const h = canvas.height = window.innerHeight * dpr
  canvas.style.width = window.innerWidth + 'px'
  canvas.style.height = window.innerHeight + 'px'
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
  const particles = []
  const PARTICLE_NUM = 60
  for (let i = 0; i < PARTICLE_NUM; i++) {
    particles.push({
      x: Math.random() * window.innerWidth,
      y: Math.random() * window.innerHeight,
      vx: (Math.random() - 0.5) * 0.7,
      vy: (Math.random() - 0.5) * 0.7
    })
  }
  function animate() {
    ctx.clearRect(0, 0, window.innerWidth, window.innerHeight)
    // 画粒子
    for (let i = 0; i < PARTICLE_NUM; i++) {
      const p = particles[i]
      p.x += p.vx
      p.y += p.vy
      if (p.x < 0 || p.x > window.innerWidth) p.vx *= -1
      if (p.y < 0 || p.y > window.innerHeight) p.vy *= -1
      ctx.beginPath()
      ctx.arc(p.x, p.y, 2, 0, Math.PI * 2)
      ctx.fillStyle = '#409EFF'
      ctx.shadowColor = '#409EFF'
      ctx.shadowBlur = 8
      ctx.fill()
      ctx.shadowBlur = 0
    }
    // 画连线
    for (let i = 0; i < PARTICLE_NUM; i++) {
      for (let j = i + 1; j < PARTICLE_NUM; j++) {
        const p1 = particles[i], p2 = particles[j]
        const dist = Math.hypot(p1.x - p2.x, p1.y - p2.y)
        if (dist < 120) {
          ctx.beginPath()
          ctx.moveTo(p1.x, p1.y)
          ctx.lineTo(p2.x, p2.y)
          ctx.strokeStyle = 'rgba(64,158,255,' + (1 - dist / 120) + ')'
          ctx.lineWidth = 1
          ctx.stroke()
        }
      }
    }
    animationId = requestAnimationFrame(animate)
  }
  animate()
}

onMounted(() => {
  drawBg()
  window.addEventListener('resize', drawBg)
})
onBeforeUnmount(() => {
  cancelAnimationFrame(animationId)
  window.removeEventListener('resize', drawBg)
})

const onLogin = async () => {
  try {
    const res = await axios.post('/api/login', form.value)
    if (res.data.msg === '登录成功') {
      localStorage.setItem('access_token', res.data.access_token)
      router.push('/config')
    } else {
      ElMessage.error(res.data.msg)
    }
  } catch (error) {
    // 错误已经在axios拦截器中处理，这里不需要额外处理
  }
}
</script>
<style scoped>
.login-root {
  position: fixed;
  left: 0;
  top: 0;
  width: 100vw;
  height: 100vh;
  min-height: 100vh;
  background: linear-gradient(135deg, #e8edf3 0%, #f5f7fa 100%);
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}
.login-bg-canvas {
  position: fixed;
  left: 0;
  top: 0;
  width: 100vw;
  height: 100vh;
  z-index: 0;
  pointer-events: none;
}
.login-main-area, .login-main-content, .login-card {
  position: relative;
  z-index: 1;
}
.login-main-area {
  flex: 1 1 auto;
  width: 100vw;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  padding-top: 12vh;
}
.login-main-content {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.login-card {
  width: 100%;
  max-width: 420px;
  margin: 0 auto;
  padding: 32px 32px 24px 32px;
  border-radius: 12px;
  box-shadow: 0 4px 24px 0 rgba(44,62,80,0.08);
  background: #fff;
}
.login-logo-row {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32px;
}
.login-logo {
  width: 40px;
  height: 40px;
  margin-right: 12px;
}
.login-title {
  font-size: 22px;
  font-weight: bold;
  color: #2c3e50;
  letter-spacing: 1px;
}
.login-form {
  margin-top: 0;
}
.login-footer {
  width: 100vw;
  position: absolute;
  left: 0;
  bottom: 0;
  color: #888;
  font-size: 13px;
  text-align: center;
  padding: 16px 0 8px 0;
  background: transparent;
  z-index: 2;
}
@media (max-width: 768px) {
  .login-main-area {
    padding-top: 8vh;
  }
  
  .login-main-content {
    padding: 0 16px;
    max-width: 100%;
  }
  
  .login-card {
    padding: 24px 16px 20px 16px;
    max-width: 100%;
    border-radius: 8px;
  }
  
  .login-logo {
    width: 36px;
    height: 36px;
    margin-right: 10px;
  }
  
  .login-title {
    font-size: 20px;
  }
  
  .login-form .el-form-item {
    margin-bottom: 20px;
  }
}

@media (max-width: 480px) {
  .login-main-area {
    padding-top: 6vh;
  }
  
  .login-main-content {
    padding: 0 12px;
  }
  
  .login-card {
    padding: 20px 12px 16px 12px;
    border-radius: 6px;
  }
  
  .login-logo {
    width: 32px;
    height: 32px;
    margin-right: 8px;
  }
  
  .login-title {
    font-size: 18px;
  }
  
  .login-form .el-form-item {
    margin-bottom: 16px;
  }
  
  .login-footer {
    font-size: 12px;
    padding: 12px 0 6px 0;
  }
}
</style> 