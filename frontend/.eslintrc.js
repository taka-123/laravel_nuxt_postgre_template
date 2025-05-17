module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
  },
  parser: 'vue-eslint-parser',
  parserOptions: {
    parser: '@typescript-eslint/parser',
    ecmaVersion: 2020,
    sourceType: 'module',
    extraFileExtensions: ['.vue'],
    ecmaFeatures: {
      jsx: true
    }
  },
  extends: ['@nuxtjs/eslint-config-typescript', 'plugin:prettier/recommended'],
  plugins: [],
  rules: {
    'vue/multi-word-component-names': 'off',
    'vue/no-v-html': 'off',
    'vue/valid-v-slot': 'off',
    'vue/no-multiple-template-root': 'off',
    'vue/require-default-prop': 'off',
    '@typescript-eslint/no-unused-vars': 'off',
    'no-console': 'off',
    'prettier/prettier': 'warn',
    'vue/no-v-for-template-key': 'off',
    'vue/valid-template-root': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/ban-ts-comment': 'off',
    '@typescript-eslint/ban-types': 'off',
    '@typescript-eslint/no-var-requires': 'off',
    '@typescript-eslint/no-empty-function': 'off',
    '@typescript-eslint/no-non-null-assertion': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    'vue/no-template-shadow': 'off',
    'vue/valid-v-for': 'off',
    'vue/no-unused-vars': 'off',
    'vue/no-unused-components': 'off',
    'vue/no-parsing-error': 'off',
    'vue/require-v-for-key': 'off',
    'vue/return-in-computed-property': 'off',
    'no-undef': 'off',
    'no-unused-vars': 'off',
    'import/no-named-as-default': 'off',
    'import/no-named-as-default-member': 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'warn'
  },
  overrides: [
    {
      files: ['*.vue'],
      rules: {
        // Vueファイル内でのTypeScriptエラーを緩和する設定
        '@typescript-eslint/no-unused-vars': 'off',
        'no-undef': 'off',
      }
    }
  ]
} 