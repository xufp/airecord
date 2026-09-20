import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig({
  base: '/admin/', // 修正base路径，确保生产环境资源路径正确
  plugins: [
    vue(),
    vueDevTools(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  build: {
    // 配置代码分割和手动分块
    rollupOptions: {
      output: {
        manualChunks: {
          // 将 Vue 相关库分离到单独的 chunk
          'vue-vendor': ['vue', 'vue-router'],
          // 将 Element Plus 分离到单独的 chunk
          'element-plus': ['element-plus'],
          // 将 axios 分离到单独的 chunk
          'axios': ['axios'],
        },
        // 自定义 chunk 文件命名
        chunkFileNames: 'assets/[name]-[hash].js',
        entryFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash].[ext]'
      }
    },
    // 调整 chunk 大小警告限制
    chunkSizeWarningLimit: 1000,
    // 启用 CSS 代码分割
    cssCodeSplit: true,
    // 压缩选项
    minify: 'terser',
    terserOptions: {
      compress: {
        // 移除 console.log
        drop_console: true,
        // 移除 debugger
        drop_debugger: true,
      },
    },
  },
})
