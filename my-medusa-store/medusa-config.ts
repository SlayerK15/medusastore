import { defineConfig } from '@medusajs/framework/utils'

// Skip loadEnv entirely in Docker - just use environment variables directly
console.log('=== MEDUSA CONFIG DEBUG ===')
console.log('NODE_ENV:', process.env.NODE_ENV)
console.log('DATABASE_URL:', process.env.DATABASE_URL)
console.log('REDIS_URL:', process.env.REDIS_URL)
console.log('=== END DEBUG ===')

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    databaseDriverOptions: {
      ssl: false,
    },
    redisUrl: process.env.REDIS_URL,
    http: {
      storeCors: process.env.STORE_CORS!,
      adminCors: process.env.ADMIN_CORS!,
      authCors: process.env.AUTH_CORS!,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    }
  },
  admin: {
    backendUrl: process.env.MEDUSA_ADMIN_BACKEND_URL || "http://localhost:9000"
  }
})