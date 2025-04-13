module.exports = {
  "backend/**/*.php": ["cd backend && ./vendor/bin/phpcs"],
  "frontend/**/*.{js,ts,vue}": ["cd frontend && npm run lint"],
}; 