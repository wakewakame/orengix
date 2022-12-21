# orengix

オレオレ証明書を作って nginx で https サーバを起動する環境の雛形です。
秘密鍵の置き場所やパーミッションの設定などが雑なので実験以外での使用はやめた方がいいです。

# 使い方

## nginx の起動

Docker が必要です。

```bash
./run.sh <ホスト名>
```

実行例: `./run.sh localhost`

## nginx へのアクセス

nginx の起動が完了すると `orengix/nginx/cert/root_cert.crt` にオレオレ証明書が保存されるので、これをPCにインストールします。
その後、 `https://<ホスト名>` にアクセスすると nginx のデフォルトページが表示されます。

