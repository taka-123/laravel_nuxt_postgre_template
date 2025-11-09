import GoogleProvider from 'next-auth/providers/google'
import { NuxtAuthHandler } from '#auth'

export default NuxtAuthHandler({
  secret: useRuntimeConfig().authSecret,

  providers: [
    // @ts-expect-error
    GoogleProvider.default({
      clientId: useRuntimeConfig().googleClientId,
      clientSecret: useRuntimeConfig().googleClientSecret,
    }),
  ],

  callbacks: {
    async jwt({ token, account, profile }) {
      // 初回ログイン時（accountが存在する場合）
      if (account && profile) {
        // LaravelバックエンドにGoogle認証情報を送信
        const config = useRuntimeConfig()
        const apiBase = config.public.serverApiBase

        try {
          const response = await $fetch(`${apiBase}/auth/google/callback`, {
            method: 'POST',
            body: {
              google_id: profile.sub,
              email: profile.email,
              name: profile.name,
              avatar: profile.picture,
            },
          })

          // LaravelからのJWTトークンを保存
          token.accessToken = response.access_token
          token.user = response.user
        } catch (error) {
          // エラーはログインページで処理される
        }
      }

      return token
    },

    session({ session, token }) {
      // セッションにユーザー情報とトークンを含める
      session.accessToken = token.accessToken
      session.user = token.user
      return session
    },
  },

  pages: {
    signIn: '/login',
    error: '/login',
  },
})
