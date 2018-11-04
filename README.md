# Comiketter

Comiketterは、Twitterのフォロー・フォロワーを取得し、  
ユーザー名からサークルスペースを推測し、一覧で表示してくれるサービスです。

## 必要環境

* Ruby 2.5.3
* MySQL 5.7

Ruby のインストールには [rbenv](https://github.com/rbenv/rbenv) の使用をお勧めします。

## 開発を始めるには

このリポジトリを `git clone` したのち、

```bash
make init
```

`.env` ファイルがトップディレクトリに作られるので、  
DATABASE_USERNAME, DATABASE_PASSWORD などを環境に合わせて編集してください。

以下のコマンドでローカルサーバーが起動します。

```bash
make run
```

http://localhost:15300 にアクセスし、トップページが表示されていたら成功です。
