# **ブラウザベースのバーコード/ISBN 関連技術スタック選択肢（2025 年 4 月）**

## **1\. バーコードデコード（読み取り）ライブラリ**

### **主要候補比較**

| ライブラリ       | 開発状況           | 主な特徴                                                                                                      | 対応コード形式                                                            | ライセンス | 推奨度 |
| :--------------- | :----------------- | :------------------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------ | :--------- | :----- |
| **ZXing-JS**     | メンテナンスモード | • 最も成熟した実装 • 多様なコード形式対応 • 広範なブラウザ互換性 • 安定した性能と継続的なバグ修正             | QR コード、EAN、UPC、Code 128/39/93、Aztec、Data Matrix、PDF 417 など多数 | Apache 2.0 | ★★★★★  |
| **HTML5-QRCode** | メンテナンスモード | • 使いやすい API • ZXing-JS をベースとしている • 長期的メンテナンス性に懸念（新オーナー募集中）               | ZXing-JS と同様                                                           | Apache 2.0 | ★★★☆☆  |
| **Quagga2**      | アクティブ開発中   | • 1D バーコードに特化した高い性能 • 活発な開発継続 • 2D コード対応の制限 • 最新フレームワークとの優れた統合性 | 主に 1D バーコード（EAN、UPC、Code 128 など）                             | MIT        | ★★★★☆  |

### **詳細分析と推奨**

**ZXing-JS** は、バーコードスキャンライブラリの中で最も成熟したソリューションです。Google の ZXing (Java) をベースにした堅牢な実装で、多様なバーコード形式をサポートしています。メンテナンスモードとはいえ、安定性と広範な互換性を備えており、バグ修正は継続しています。

**HTML5-QRCode** は ZXing-JS の上に構築されたラッパーライブラリで、より簡単な API を提供します。しかし、作者が新しいメンテナーを探していることからも分かるように、長期的な安定性に懸念があります。内部的に ZXing-JS に依存しているため、直接 ZXing-JS を使用する方が中間層のリスクを避けられます。

**Quagga2** は、元の QuaggaJS の改良版として積極的に開発が続けられています。特に 1D バーコードに特化しており、最新のフレームワークとの統合サンプルが豊富です。2D コード対応は外部モジュールに依存するため、多様なコード形式が必要な場合は制約となります。

**推奨**: **ZXing-JS** を第一選択として推奨します。多様なコードに対応し、安定性と広範なブラウザ互換性を備えています。1D バーコードのみを扱う場合や、最新フレームワークとの最適な統合を重視する場合は **Quagga2** も有力な選択肢です。

## **2\. カメラアクセス API**

### **推奨（一択）: Web カメラ API (`getUserMedia`)**

Web カメラ API (`navigator.mediaDevices.getUserMedia`) が明確な一択である理由:

1. **標準規格**: W3C 標準として全主要ブラウザでサポートされており、特別な依存関係なく利用できます。  

2. **機能の充実**: カメラの選択、解像度設定、フレームレート調整など、バーコードスキャンに必要な全機能を提供します。  

3. **互換性の向上**: 以前問題だった iOS の Safari でも、iOS 15.1 以降で完全サポートされています（2025 年時点では大半のデバイスが対応）。  

4. **セキュリティ**: ユーザー許可を必須とする設計で、プライバシー保護が組み込まれています。  

5. **将来性**: ブラウザベンダーによる継続的な改善と、WebRTC など関連技術との統合が進んでいます。

この技術は標準 API であるため、サードパーティの代替手段は実質的に存在せず、全てのバーコードスキャンライブラリも内部的にこの API を使用しています。

## **3\. 書籍情報取得 API (ISBN 経由)**

### **主要候補比較**

| API                    | データ網羅性               | 提供情報                                            | 利用制限                    | API 認証       | 推奨度 |
| :--------------------- | :------------------------- | :-------------------------------------------------- | :-------------------------- | :------------- | :----- |
| **Google Books API**   | 非常に高い（国際書籍含む） | • 書誌情報 • 書影 • 目次 • 出版社情報 • プレビュー  | 1,000 リクエスト/日（無料） | 任意（推奨）   | ★★★★★  |
| **Open Library API**   | 中程度（英語圏中心）       | • 書誌情報 • 書影 • 著者情報 • 公開ドメイン全文     | 緩やか                      | 不要           | ★★★☆☆  |
| **国立国会図書館 API** | 非常に高い（日本語書籍）   | • 詳細書誌情報 • 書影（強化） • 分類情報 • 所蔵情報 | API 利用条件による          | 一部機能で必要 | ★★★★☆  |

### **詳細分析と推奨**

**Google Books API** は、国際的な書籍情報の網羅性、データの質、API の使いやすさにおいて最も優れています。無料枠（1,000 リクエスト/日）は多くのアプリケーションに十分であり、認証も簡便です。特に重要なのは、日本語書籍を含む幅広いデータベースと、書影や目次といった豊富なメタデータを提供している点です。

**Open Library API** は、オープンなデータポリシーが魅力ですが、日本語書籍の網羅性が低く、データの鮮度も Google Books API に劣ります。2025 年 1 月の API 改善はあったものの、主に英語圏の書籍に強みがあります。

**国立国会図書館 API** は、日本語書籍に関しては最も網羅的なデータを提供します。2024 年の書影 API 強化により使い勝手は向上しましたが、API の構造がやや複雑で、利用には一部申請が必要な場合があります。また、501 件以上の検索結果取得に制限があります。

**推奨**: **Google Books API** を主要 API として使用し、日本語書籍の詳細情報が必要な場合は **国立国会図書館 API** を補完的に利用する構成を推奨します。Google Books API は使いやすさと網羅性のバランスが最も優れており、多くのユースケースに対応できます。

### **補足: 楽天ブックス API について**

楽天ブックス API も選択肢として考えられますが、主に商品情報（価格、在庫等）に焦点を当てており、純粋な書誌情報 API としては上記 3 つに比べて目的が異なります。書籍の販売情報が必要な場合の補完的 API として位置づけられます。

## **結論: 推奨技術スタック**

最も安定した実装を実現するための推奨組み合わせは以下の通りです：

1. **バーコードデコード**: ZXing-JS

   - 多様なバーコード形式対応と安定性を重視する場合

2. **カメラアクセス**: Web カメラ API (getUserMedia)

   - 標準技術として一択

3. **書籍情報取得**: Google Books API（主）＋国立国会図書館 API（補助）
   - 国際書籍を含む幅広いデータが必要な場合は Google Books API
   - 日本語書籍の詳細情報が重要な場合は国立国会図書館 API も併用

この組み合わせにより、安定性と機能性を兼ね備えた ISBN/バーコードスキャンアプリケーションを実現できます。特に対応するバーコード形式が多様で、国際的な書籍情報も扱う必要がある場合に最適です。

## **リソース:**

- **ZXing-JS:**
  - GitHub: [https://github.com/zxing-js/library](https://github.com/zxing-js/library)
  - npm: [https://www.npmjs.com/package/@zxing/library](https://www.npmjs.com/package/@zxing/library)
- **Quagga2:**
  - GitHub: [https://github.com/ericblade/quagga2](https://github.com/ericblade/quagga2)
  - npm: [https://www.npmjs.com/package/@ericblade/quagga2](https://www.npmjs.com/package/@ericblade/quagga2)
- **HTML5-QRCode:**
  - GitHub: [https://github.com/mebjas/html5-qrcode](https://github.com/mebjas/html5-qrcode)
- **MDN Web Docs:** [https://developer.mozilla.org/ja/docs/Web/API/MediaDevices/getUserMedia](https://developer.mozilla.org/ja/docs/Web/API/MediaDevices/getUserMedia)
- **Google Books API:** [https://developers.google.com/books?hl=ja](https://www.google.com/search?q=https://developers.google.com/books%3Fhl%3Dja)
- **Open Library API:** [https://openlibrary.org/developers/api](https://openlibrary.org/developers/api)
- **国立国会図書館サーチ API:** [https://iss.ndl.go.jp/information/api/](https://iss.ndl.go.jp/information/api/) (仕様詳細、書影 API 含む)
- **楽天ブックス書籍検索 API:** [https://webservice.rakuten.co.jp/api/booksbooksearch/](https://www.google.com/search?q=https://webservice.rakuten.co.jp/api/booksbooksearch/)
