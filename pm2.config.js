module.exports = {
  apps: [
    {
      name: 'meengle-api',
      script: './backend/index.js',
      instances: process.env.NODE_ENV === 'production' ? 'max' : 1,
      exec_mode: process.env.NODE_ENV === 'production' ? 'cluster' : 'fork',
      env: {
        NODE_ENV: 'development',
        PORT: 3000,
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000,
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_file: './logs/combined.log',
      time: true,
      merge_logs: true,
      max_memory_restart: '500M',
      watch: process.env.NODE_ENV !== 'production',
      ignore_watch: ['node_modules', 'logs', 'uploads'],
      max_restarts: 10,
      min_uptime: '10s',
      autorestart: true,
    },
    {
      name: 'meengle-worker',
      script: './backend/workers/index.js',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'development',
      },
      env_production: {
        NODE_ENV: 'production',
      },
      error_file: './logs/worker-err.log',
      out_file: './logs/worker-out.log',
      max_memory_restart: '300M',
      autorestart: true,
    },
  ],
};
