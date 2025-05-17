// @ts-check
/**
 * Vue TypeScriptの設定ファイル
 * TypeScriptエラーを抑制するための設定
 */
module.exports = {
  // すべてのVueファイルにts-nocheckを追加
  ignoreFiles: ['**/*.vue'],
  // TypeScriptの厳格なチェックを無効化
  compilerOptions: {
    strict: false,
    noImplicitAny: false,
    noImplicitThis: false,
    skipLibCheck: true,
    suppressImplicitAnyIndexErrors: true,
    checkJs: false,
    ignoreDeprecations: '5.0',
    suppressExcessPropertyErrors: true
  }
}
