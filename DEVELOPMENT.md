# 開発環境ガイド

このドキュメントでは、本プロジェクトの開発環境や開発フローについて説明します。

## 目次

1. [開発環境のセットアップ](#開発環境のセットアップ)
2. [コーディング規約](#コーディング規約)
3. [品質管理ツール](#品質管理ツール)
4. [Git ワークフロー](#git-ワークフロー)
5. [テスト](#テスト)
6. [CI/CD](#cicd)

## 開発環境のセットアップ

基本的なセットアップ手順は [README.md](./README.md) を参照してください。ここでは追加の開発環境設定について説明します。

### エディタの設定

VSCode または VSCode 互換エディタ（Cursor, JetBrains Fleet など）の使用を推奨します。
プロジェクトには以下のエディタ設定が含まれています：

- `.editorconfig` - 基本的なエディタ設定（インデント、改行など）
- `.vscode/settings.json` - VSCode 向けの設定
- `.vscode/extensions.json` - 推奨拡張機能リスト

**推奨拡張機能:**

VSCode で開発する場合、プロジェクトを開くと推奨拡張機能のインストールが促されます。主な拡張機能は以下のとおりです：

- ESLint - JavaScript/TypeScript のコード品質チェック
- Prettier - コードフォーマッター
- Volar - Vue 3 のサポート
- Intelephense - PHP のサポート
- Laravel Extra Intellisense - Laravel のサポート
- EditorConfig - エディタ設定の共有

### 自動フォーマット設定

ファイル保存時に自動的にコードがフォーマットされるよう設定されています。
これはVSCodeの設定（`.vscode/settings.json`）によって有効になっています。

```json
"editor.formatOnSave": true,
"editor.codeActionsOnSave": {
  "source.fixAll.eslint": true
}
```

## コーディング規約

### フロントエンド (JavaScript/TypeScript/Vue)

- **フォーマットルール:** Prettier による自動フォーマット
  - セミコロンなし
  - シングルクォート
  - インデント: 2スペース
  - 最大行長: 120文字
  - 末尾カンマ: 可能な場所すべてに付ける
  
- **ESLint ルール:**
  - Vue 3 の推奨ルールセット
  - Nuxt の推奨ルールセット
  - TypeScript サポート

### バックエンド (PHP/Laravel)

- **PSR-12 準拠:** PHP_CodeSniffer によるチェック
  - インデント: 4スペース
  - クラス名: StudlyCaps
  - メソッド名: camelCase
  
- **PHPStan/Larastan（レベル5）:** 静的解析

## 品質管理ツール

### コマンドラインでの実行

**フロントエンド:**

```bash
# コード品質チェック
cd frontend && npm run lint

# コード品質チェックと自動修正
cd frontend && npm run lint:fix

# テスト実行
cd frontend && npm test

# テストカバレッジ確認
cd frontend && npm run test:coverage
```

**バックエンド:**

```bash
# コード品質チェック
cd backend && composer lint

# 静的解析
cd backend && composer analyze

# テスト実行
cd backend && composer test
```

### Git フック

コミットやプッシュの前に自動的に品質チェックが行われます：

- **pre-commit:** `lint-staged` によるコミット対象ファイルのチェック
- **pre-push:** フロントエンドとバックエンドのテスト実行

## Git ワークフロー

詳細な Git ワークフローについては [docs/git-workflow.md](./docs/git-workflow.md) を参照してください。

### ブランチ戦略

- `main`: 本番環境用のブランチ
- `develop`: 開発環境用のブランチ
- 機能開発: `feature/issue-番号-機能名`
- バグ修正: `fix/issue-番号-修正内容`

### コミットメッセージ規約

```
タイプ: 簡潔な説明

詳細な説明（オプション）

関連する問題やPR（オプション）
```

**タイプ例:** feat, fix, docs, style, refactor, test, chore

## テスト

### フロントエンド

- **テストフレームワーク:** Vitest
- **テストファイル配置:** `frontend/test/` ディレクトリ
- **コンポーネントテスト:** `@vue/test-utils` を使用

### バックエンド

- **テストフレームワーク:** PHPUnit
- **テストファイル配置:** `backend/tests/` ディレクトリ
- **データベーステスト:** SQLite メモリデータベースを使用

## CI/CD

GitHub Actions を使用して以下の CI/CD を実施しています：

- プッシュ・プルリクエスト時の自動テスト
- コードスタイルの自動チェック
- 依存パッケージの脆弱性チェック

詳細は [.github/workflows/ci.yml](./.github/workflows/ci.yml) を参照してください。 
