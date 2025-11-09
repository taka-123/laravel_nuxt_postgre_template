import { signIn as nuxtSignIn, signOut as nuxtSignOut } from '#auth'

export function useGoogleAuth() {
  return {
    // Google OAuth認証
    async loginWithGoogle(redirectPath?: string) {
      await nuxtSignIn('google', {
        callbackUrl: redirectPath || '/',
        redirect: true,
      })
    },

    // ログアウト
    async logout(redirectPath?: string) {
      await nuxtSignOut({
        callbackUrl: redirectPath || '/login',
        redirect: true,
      })
    },
  }
}
