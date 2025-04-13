<?php

namespace App\Services;

use Picqer\Barcode\BarcodeGeneratorPNG;
use Picqer\Barcode\BarcodeGeneratorSVG;
use App\Models\Book;
use Illuminate\Support\Str;

class BarcodeService
{
    /**
     * バーコードを生成する
     *
     * @param string $barcode バーコード番号
     * @param string $format 出力形式 (png|svg)
     * @param int $width バーコードの幅
     * @param int $height バーコードの高さ
     * @return string 生成されたバーコード画像データ
     */
    public function generate(string $barcode, string $format = 'png', int $width = 2, int $height = 50): string
    {
        if ($format === 'svg') {
            $generator = new BarcodeGeneratorSVG();
            return $generator->getBarcode($barcode, $generator::TYPE_CODE_128, $width, $height);
        } else {
            $generator = new BarcodeGeneratorPNG();
            return $generator->getBarcode($barcode, $generator::TYPE_CODE_128, $width, $height);
        }
    }

    /**
     * 新しい独自バーコードを生成する
     *
     * @return string 生成されたバーコード番号
     */
    public function generateUniqueBarcode(): string
    {
        $prefix = 'LIB'; // 図書館用のプレフィックス
        $randomPart = strtoupper(Str::random(8)); // ランダムな英数字8桁

        $barcode = $prefix . $randomPart;

        // バーコードが既に存在する場合は再生成
        while (Book::where('barcode', $barcode)->exists()) {
            $randomPart = strtoupper(Str::random(8));
            $barcode = $prefix . $randomPart;
        }

        return $barcode;
    }

    /**
     * バーコード画像をファイルとして保存する
     *
     * @param string $barcode バーコード番号
     * @param string $format 出力形式 (png|svg)
     * @param string $path 保存パス
     * @return string 保存されたファイルのパス
     */
    public function saveToFile(string $barcode, string $path, string $format = 'png'): string
    {
        $barcodeData = $this->generate($barcode, $format);
        $filename = $path . '/' . $barcode . '.' . $format;

        file_put_contents($filename, $barcodeData);

        return $filename;
    }
}
