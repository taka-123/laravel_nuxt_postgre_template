declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}

// Vueテンプレート内でのTypeScript型チェックを改善するための設定
declare module 'vue' {
  interface ComponentCustomProperties {
    $refs: {
      [key: string]: HTMLElement | any
    }
    // プロファイルページで使用される変数
    loading: boolean
    user: any
    userPosts: any[]
    userComments: any[]
    activeTab: string
    postsLoading: boolean
    commentsLoading: boolean
    truncateContent: (content: string, length: number) => string
    formatDate: (date: string) => string
    getStatusColor: (status: string) => string
    getStatusLabel: (status: string) => string
    
    // 投稿詳細ページで使用される変数
    post: any
    comments: any[]
    isLoggedIn: boolean
    isAdmin: boolean
    isAuthor: boolean
    newComment: string
    submittingComment: boolean
    submitComment: () => void
    confirmDelete: boolean
    deleting: boolean
    deletePost: () => void
    editComment: (comment: any) => void
    deleteComment: (comment: any) => void
    editCommentDialog: boolean
    editedCommentContent: string
    updateComment: () => void
    updatingComment: boolean
  }
}
