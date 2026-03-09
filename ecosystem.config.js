module.exports = {
  apps: [
    {
      name: 'trading-mission-control',
      script: './server.js',
      cwd: '/shared/mission-control',
      env: {
        NODE_ENV: 'production',
        ALPHA_VANTAGE_KEY: process.env.ALPHA_VANTAGE_KEY || ''
      }
    },
    {
      name: 'mission-control',
      script: 'npm',
      args: ['run', 'start'],
      cwd: '/root/mission-control',
      env: {
        NODE_ENV: 'production'
      },
      kill_timeout: 8000,
      max_restarts: 10,
      min_uptime: '15s',
      treekill: true
    }
  ]
};
