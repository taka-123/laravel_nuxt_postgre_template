# GitHub Issue 作成からのフロー

## 0. 初期設定（プロジェクト開始時に 1 回）

### リポジトリ基本設定

```bash
# GitHub リポジトリ設定
Settings → General

→ Default branch
  → ↔️ (Switch to another branch) → `develop`
  # デフォルトブランチをdevelopに変更（PRがデフォルトでdevelopに向く）

→ Pull Requests
  ☑️ Allow merge commits      # 通常のマージコミットを許可（ONのまま）
  ☑️ Allow squash merging      # スカッシュマージを許可（ONのまま）
  ☑️ Allow rebase merging      # リベースマージを許可→OFFにする（運用統一のため）
  ☑️ Always suggest updating pull request branches  # PR更新の提案を表示
  ☑️ Automatically delete head branches  # マージ後にブランチを自動削除
```

### Branch Protection Rules (Rulesets)

```bash
# developブランチ保護設定
Settings → Rules → Rulesets → New ruleset
→ Ruleset Name: protect-develop
→ Enforcement status: Active  # ルールを有効化
→ Target branches: Add target → Include by pattern → `develop`  # developブランチを指定
→ Rules:
  ☑️ Restrict deletions      # ブランチの削除を禁止
  ☑️ Block force pushes      # 強制プッシュを禁止（履歴の書き換え防止）
  ☑️ Require a pull request before merging  # 直接pushを禁止、PR必須
    → Required approvals: 0  # 承認必要数（個人開発なので0）
    → ☑️ Require conversation resolution before merging  # コメントの解決を必須化

# mainブランチ保護設定
Settings → Rules → Rulesets → New ruleset
→ Ruleset Name: protect-main
→ Enforcement status: Active  # ルールを有効化
→ Target branches: Add target → Include by pattern → `main`  # mainブランチを指定
→ Rules:
  ☑️ Restrict deletions      # ブランチの削除を禁止
  ☑️ Block force pushes      # 強制プッシュを禁止
  ☑️ Require a pull request before merging  # 直接pushを禁止、PR必須
    → Required approvals: 0  # 承認必要数（個人開発なので0）
    → ☑️ Require conversation resolution before merging  # コメントの解決を必須化
```

### PR テンプレート作成

```bash
# .github/pull_request_template.md
cat > .github/pull_request_template.md << 'EOF'
## 概要
<!-- 変更内容の簡潔な説明 -->

## 関連Issue
closes #

## 変更種別
- [ ] 🚀 feat: 新機能
- [ ] 🐛 fix: バグ修正
- [ ] 🔧 chore: その他の変更（ビルド、設定、ドキュメント等）

## チェックリスト
- [ ] ローカルで動作確認済み
- [ ] テストが通っている
- [ ] レビュー依頼の準備完了

## マージ方法確認
- [ ] feature → develop: **Squash and merge** を使用
- [ ] develop → main: **Create a merge commit** を使用
- [ ] hotfix → main: **Squash and merge** を使用
EOF

git add .github/pull_request_template.md
git commit -m "chore: PRテンプレートを追加"
git push origin develop
```

## 1. Issue 作成とブランチ作成

```bash
# GitHub上でIssue作成
└─ Issue #123「認証機能を追加」

# ローカルでの作業開始
git checkout develop  # developから作成
git pull origin develop  # 最新化
git checkout -b feat/123-add-auth
```

## 2. 開発作業

```bash
# 開発・テスト
└─ コーディング
└─ ローカルで動作確認（Docker等）

# コミット（細かく分けてOK）
git add .
git commit -m "feat: 認証機能の基本実装"
git commit -m "feat: バリデーション追加"
git commit -m "fix: エラーハンドリング修正"
# スカッシュマージするので細かいコミットでOK
```

## 3. PR 作成（develop 向け）

```bash
# push
git push origin feat/123-add-auth

# GitHub上でPR作成
└─ base: develop ← compare: feat/123-add-auth
└─ タイトル: "feat: 認証機能を実装 (#123)"
└─ 自動でIssue #123とリンク
└─ PRテンプレートに従って記載
```

## 4. コードレビュー

```bash
# レビュアーがGitHub上でコード確認
└─ 修正依頼がある場合
    git checkout feat/123-add-auth
    # 修正作業
    git add .
    git commit -m "fix: レビュー指摘事項を修正"
    git push origin feat/123-add-auth
    └─ 既存PRに自動反映
```

## 5. develop へマージ

```bash
# レビューOK → マージボタンクリック
└─ マージ方法: **Squash and merge**（スカッシュマージ）
    └─ 理由: 開発中の細かいコミットを1つにまとめる
└─ コミットメッセージ: "feat: 認証機能を実装 (#123)"
└─ 検証環境へ自動デプロイ（CI/CD設定済みの場合）
└─ feat/123-add-auth ブランチは自動削除される
```

## 6-A. ✅ 検証環境で OK の場合

````bash
# develop → main のPR作成
└─ GitHub上で新規PR
└─ base: main ← compare: develop
└─ タイトル: "Release: 認証機能 (#123)"
└─ 説明欄にリリース内容を記載
    ```
    ## リリース内容
    - feat: 認証機能を実装 (#123)
    - fix: ログインバグを修正 (#124)

    ## 検証完了項目
    - ✅ ユーザー登録機能
    - ✅ ログイン/ログアウト
    - ✅ パスワードリセット
    ```

# マージ
└─ マージ方法: **Create a merge commit**（通常マージ）
    └─ 理由: リリース単位を明確に履歴に残す
└─ 本番環境へ自動デプロイ
└─ 完了！🎉
````

## 6-B. ❌ 検証環境で NG の場合

```bash
# パターン1: 軽微な修正で対応
git checkout develop
git pull origin develop
git checkout -b fix/123-auth-issue  # 新規ブランチ作成
# 修正作業
git add .
git commit -m "fix: 検証環境の不具合を修正 (#123)"
git push origin fix/123-auth-issue
└─ 新規PRを作成（develop向け）
└─ レビュー → **Squash and merge** → 再検証

# パターン2: 根本的な問題（Revert）
# GitHub UIでRevert（推奨）
└─ マージ済みPRページ → "Revert" ボタン
└─ 自動でRevert PRが作成される
└─ **Squash and merge** でマージ
└─ Issue #123 を再オープンして対応継続

# またはCLIでRevert
gh pr list --state merged --limit 5
gh pr revert PR_NUMBER --title "Revert: 認証機能を一時的に取り消し (#123)"
```

## 7. 🚨 本番環境で問題発生時（緊急対応）

```bash
# A. main のRevert（develop → main のマージを取り消す）
└─ GitHub UI: マージ済みPRページ → "Revert" ボタン
└─ base: main のRevert PRが自動作成
└─ **Create a merge commit** でマージ（履歴保持）
└─ 本番環境が自動的に前の状態に戻る

# B. develop との同期
git checkout develop
git pull origin develop
git checkout -b sync/main-revert
git merge origin/main  # mainの状態をdevelopに反映
git push origin sync/main-revert
└─ PR作成（develop向け）
└─ タイトル: "sync: mainのrevertをdevelopに反映"
└─ **Create a merge commit** でマージ
```

## マージ戦略まとめ

### マージ方法の使い分け

```bash
# Squash and merge（履歴をまとめる）を使用
feat/* → develop      # 機能開発
fix/* → develop       # バグ修正
chore/* → develop     # その他の変更
revert-* → develop    # Revert PR
hotfix/* → main       # 緊急修正（単一コミット）

# Create a merge commit（履歴を保持）を使用
develop → main        # リリース
main → develop        # 同期
```

### なぜ使い分けるのか

```bash
# developブランチの履歴（スカッシュ効果）
* feat: 認証機能を実装 (#123)      # 10個のコミットが1つに
* fix: ログインバグを修正 (#124)    # 5個のコミットが1つに
* feat: 決済機能を実装 (#125)      # 20個のコミットが1つに

# mainブランチの履歴（通常マージ効果）
*   Merge: Release v1.1.0 - 認証機能
|\
| * feat: 認証機能を実装 (#123)
| * fix: ログインバグを修正 (#124)
|/
*   Merge: Release v1.0.0 - 初期リリース
```

## ブランチ命名規則

```bash
<type>/<issue番号>-<説明-ケバブケース>

feat/123-user-auth       # 新機能
fix/456-login-bug        # バグ修正
chore/567-update-deps    # その他（ドキュメント、設定、依存関係等）
hotfix/789-critical-fix  # 本番環境の緊急修正
sync/234-merge-main      # ブランチ同期用
revert-456-feature       # Revert用（GitHub自動生成）
```

## コミットメッセージ規則

```bash
<type>: <日本語説明> (#<issue番号>)

# 基本の3種類
feat: 認証機能を実装 (#123)    # 新機能追加
fix: ログインエラーを修正 (#456)  # バグ修正
chore: 依存関係を更新           # その他の変更

# 詳細な例
feat: ユーザー登録APIを追加 (#123)
feat: パスワードリセット機能を実装 (#124)
fix: ログイン時のセッションエラーを修正 (#456)
fix: バリデーションメッセージの誤字を修正 (#457)
chore: README.mdを更新
chore: ESLintの設定を追加
chore: Dockerfileを最適化

# Issue自動クローズ（オプション）
fix: 重大なバグを修正 (closes #456)
feat: 新機能を追加 (fixes #123)
```

## CI/CD 設定例

```yaml
# .github/workflows/deploy.yml
name: Auto Deploy

on:
  push:
    branches:
      - main # mainブランチへのpush時
      - develop # developブランチへのpush時

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Production
        if: github.ref == 'refs/heads/main' # mainブランチの場合
        run: |
          echo "本番環境へデプロイ"
          # fly deploy --app your-prod-app

      - name: Deploy to Staging
        if: github.ref == 'refs/heads/develop' # developブランチの場合
        run: |
          echo "検証環境へデプロイ"
          # fly deploy --app your-staging-app
```

## トラブルシューティング

### よくある問題と対処法

```bash
# コンフリクトが発生した場合
git checkout develop
git pull origin develop
git checkout feat/123-add-auth
git merge develop  # developの最新を取り込む
# コンフリクトを解決
git add .
git commit -m "chore: developとのコンフリクトを解決"
git push origin feat/123-add-auth

# 間違えてmainにPRを作成した場合
# PR画面で base branch を変更
# Edit → base: main を develop に変更

# スカッシュマージを忘れた場合
# 履歴は複雑になるが動作に影響なし
# 次回から気をつける（PRテンプレートで確認）
```
