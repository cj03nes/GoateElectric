module.exports = {
  apps: [
    {
      name: 'goate-electric-dapp',
      script: 'npm',
      args: 'start',
      cwd: '/home/user/webapp',
      env: {
        NODE_ENV: 'development',
        PORT: 3000,
        BROWSER: 'none', // Prevent automatic browser opening
        CI: 'true' // Prevent interactive prompts
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      log_file: './logs/combined.outerr.log',
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      time: true
    }
  ]
};