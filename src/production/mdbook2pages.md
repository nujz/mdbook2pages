# mdbook2pages

> [pyama2000/mdbook2pages][mdbook2pages]

Markdownから*book*を作成するツールに[rust-lang/mdBook][mdBook]を利用しています。
このツールは[GitBook][GitBook]に似ていますが、**Rust**で書かれたものになっています。
mdBook向けに書かれたMarkdownファイル群をGitHubにプッシュすることでGitHub ActionsでCI/CDを行い、
本サイトのようにGitHub Pagesにデプロイします。

## 1. プロジェクトの構成図

```
mdbook2pages
├── book
├── book.toml
├── docker-compose.yml
├── Dockerfile
├── README.md
└── src
   ├── introduction.md
   ├── production
   │  ├── mdbook2pages.md
   │  ├── moses.md
   │  ├── musa.md
   │  ├── spotif_api.md
   │  ├── tex2pdf.md
   │  └── tof.md
   └── SUMMARY.md
```

## 2. mdBook環境の構築

mdBookはRust製のツールなのでローカルまたはDockerで**Rust + mdBook**を
実行できる環境を構築する必要があります。ここではDockerを使って環境を構築したいと思います。  
Dockerfileは以下のようにシンプルなものになっています。  
**※ コンパイルが必要なため時間がかかります。**

### 2.1 Dockerfile

```dockerfile:Dockerfile
FROM rust:latest

RUN cargo install mdbook --vers "^0.3.5"

EXPOSE 3000

WORKDIR /mdbook
```

`cargo install`でmdbookをインストールしてますが、`--vers "^0.3.5"`とすることで
インストールするバージョンを**0.3.5**から**0.3.x**までに指定しています。

### 2.2 docker-compose.yml

```yaml:docker-compose.yml
version: "3"
services:
  mdbook:
    build: . 
    volumes:
      - ./:/mdbook
    ports:
      - 3000:3000
    container_name: mdbook2pages_mdbook
```

`docker-compose up --build`で2.1節のDockerfileをビルドします。
これでmdBookを編集、閲覧できる環境が整いました。

## 3. mdBookの使い方

### 3.1 プロジェクトの初期化

`mdbook init`で最小限の構成でmdBookを開始できます。  

```shell
$ mdbook init

mdbook2pages
├── book
└── src
   ├── chapter_1.md
   └── SUMMARY.md
```

**book**ディレクトリはmdBookでビルドしたファイルが格納されるディレクトリで、デプロイする際に利用します。  
**src**ディレクトリはMarkdownファイル群になっており、**SUMMARY.md**はサイドメニューです。

```markdown:SUMMARY.md
# Summary

- [Chapter 1](./chapter_1.md)
```

### 3.2 Markdownのビルド、閲覧

`mdbook build`で3.1節で作成されたMarkdownファイル群をビルドできます。ビルドされたファイルは
**book**ディレクトリに格納されているので、**book/index.html**をブラウザで開くと閲覧ができます。

`mdbook serve --hostname 0.0.0.0`は**src**ディレクトリ以下のファイルを監視し、変更があった場合自動で再ビルドします。
また、`http://localhost:3000`にアクセスすることで閲覧することができます。
mdBookはデフォルトで3000番ポートを使用していますが、`-p`オプションでポート番号を
変更できます。

![summary image][summary_img]


### 3.3 記事の追加

**src**ディレクトリ以下にMarkdownファイルを追加、または**SUMMARY.md**や他のMarkdownファイルで
他の記事をリンクするとビルド時に自動的にファイルが生成されます。  
また、**src/production**のようにディレクトリを作成して、そこにMarkdownファイルを追加することもできます。

```shell
$ cat SUMMARY.md
# Summary

- [自己紹介](./introduction.md)
- [制作物](./production/tof.md)
    - [mdbook2pages](./production/mdbook2pages.md)
    - [moses](./production/moses.md)
    - [musa](./production/musa.md)
    - [spotify_api](./production/spotify_api.md)
    - [TeX2PDF](./production/tex2pdf.md)
    - [New file](./production/new_file.md)  # 存在しないファイル

$ mdbook build

mdbook2pages
├── book
└── src
   ├── introduction.md
   ├── production
   │  ├── mdbook2pages.md
   │  ├── moses.md
   │  ├── musa.md
   │  ├── new_file.md  # 自動で生成される
   │  ├── spotif_api.md
   │  ├── tex2pdf.md
   │  └── tof.md
   └── SUMMARY.md
```

## 4. GitHub Actionsとの連携

mdBookで作成した*book*をGitHub ActionsでGitHub Pagesにデプロイします。

### ファイル構成

```
mdbook2pages
└── .github
   ├── actions
   │  └── deploy
   │     ├── Dockerfile
   │     └── entrypoint.sh
   └── workflows
      └── main.yml
```

### 4.1 アクションを作成

### 4.2 ワークフローを作成

[mdBook]:https://github.com/rust-lang/mdBook
[GitBook]:https://www.gitbook.com/
[mdbook2pages]:https://github.com/pyama2000/mdbook2pages

[summary_img]:https://user-images.githubusercontent.com/33086493/72126054-118cfd00-33ae-11ea-8369-b217005d36d0.png
