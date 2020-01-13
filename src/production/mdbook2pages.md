# mdbook2pages

> [pyama2000/mdbook2pages][mdbook2pages]

Markdownから*book*を作成するツールに[rust-lang/mdBook][mdBook]を利用します。
このツールは[GitBook][GitBook]に似ていますが、**Rust**で書かれたものになっています。
mdBook向けに書かれたMarkdownファイル群をGitHubにプッシュすることでGitHub ActionsでCI/CDを行い、
本サイトのようにGitHub Pagesにデプロイします。

## 1. プロジェクトの構成図

```
mdbook2pages
├── .github
│  ├── actions
│  │  └── build
│  │     └── Dockerfile
│  └── workflows
│     └── main.yml
├── book
├── book.toml
├── docker-compose.yml
├── Dockerfile
├── README.md
├── src
│  ├── introduction.md
│  ├── production
│  │  ├── mdbook2pages.md
│  │  ├── moses.md
│  │  ├── musa.md
│  │  ├── spotify_api.md
│  │  ├── tex2pdf.md
│  │  └── tof.md
│  └── SUMMARY.md
└── theme
   ├── custom.css
   └── highlight.css
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
mdBookはデフォルトで3000番ポートを使用していますが、`-p`オプションでポート番号を変更できます。

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
   │  └── build
   │     └── Dockerfile
   └── workflows
      └── main.yml
```


### 4.1 GitHub Pages用のリポジトリを作成

GitHub Pagesは、GitHubのリポジトリからHTML、CSS、JavaScriptファイルを取得し、
ウェブサイトを公開できる静的なウェブサイトホスティングサービスです。

GitHub Pages用に`<USER_NAME>.github.io`というリポジトリを作成してください。  
**※ この例では`pyama2000.github.io`**

![Create GitHub Pages repository][create_github_pages_img]

リポジトリを作成することができたら、適当に**index.html**をプッシュし、
`https://<USER_NAME>.github.io`でユーザのウェブサイトにアクセスすることができます。

ユーザ用のサイトは1つしか作成できませんが、プロジェクトごとにもGitHub Pagesを作成することができます。
プロジェクトサイトを公開するには**gh-pages**ブランチにHTML、CSS、JavaScriptか、
**master**ブランチの/docsディレクトリを配置することで公開できます。
プロジェクトサイトのURLは`https://<USER_NAME>.github.io/<REPOSITORY_NAME>`となります。

詳細については[GitHub Pages について - GitHub ヘルプ](https://help.github.com/ja/github/working-with-github-pages/about-github-pages)を参照してください。

### 4.2 秘密鍵・公開鍵の作成

GitHub Pagesを公開するのに公開アクションである[GitHub Pages action · Actions · GitHub Marketplace](https://github.com/marketplace/actions/github-pages-action)を使用します。そのために秘密鍵・公開鍵を生成し、
それぞれのリポジトリに配置する必要があります。

以下のコマンドで秘密鍵と公開鍵のペアを作成します。

```shell
$ ssh-keygen -t rsa -b 4096 -C "$(git config user.email)" -f gh-pages -N ""
```

`-C`オプションでGitに登録しているメールアドレスをコメントとして渡し、
`-N`オプションでパスフレーズを空白として、`-f`オプションによってpg-pagesというファイル名で
キーペアを作成します。
作成したキーペアはコマンドを実行したディレクトリの直下に生成されます。

作成されたキーペアの公開鍵(**gh-pages**)の内容を4.1節で作成したGitHub Pages用のリポジトリ
(**<USER_NAME>.github.io**)の`Settings > Deploy keys`に任意の名前で登録します。
また、**Allow write access**にチェックを入れるのを忘れないでください。

![Add Deploy keys][add_deploy_keys_img]

秘密鍵は、mdBookでビルドするリポジトリ(ここでは**mdbook2pages**)の`Settings > Secrets`に
**ACTIONS_DEPLOY_KEY**という名前で登録します。

![Add Secrets][add_secrets_img]

### 4.3 アクションを作成

ワークフローでmdBookをビルドするアクションを定義します。  
**.github/actions/build/Dockerfile**を作成し、以下のように記述してください。

```dockerfile:.github/actions/build/Dockerfile
FROM rust:latest

RUN cargo install mdbook --no-default-features --features output --vers "^0.3.5"

CMD ["mdbook", "build"]
```

2.1節で作成したDockerfileと似ていますが、mdBookのインストールの際に`--no-default-features`オプションと
`--features`オプションで`output`を指定することで、出力するためだけの機能をもったmdBookを
インストールすることができます。  
CMD命令により、ビルドされたコンテナに入ると自動的に`mdbook build`コマンドが実行されます。

### 4.4 ワークフローを作成

以上によりmdBookのビルド、公開するアクションの準備が整ったのでいよいよワークフローを定義します。  
**.github/workflows/main.yml**が以下のコードとなっています。

```yaml:.github/workflows/main.yml
name: CI/CD
on:
  push:
    branches:
    - master
    paths:
    - "src/**.md"
    - "book.toml"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Build
      uses: ./.github/actions/build
    - name: Deploy
      uses: peaceiris/actions-gh-pages@v2
      env:
        ACTIONS_DEPLOY_KEY: ${{ secrets.ACTIONS_DEPLOY_KEY }}
        EXTERNAL_REPOSITORY: <USER_NAME>/<USER_NAME>.github.io
        PUBLISH_BRANCH: master
        PUBLISH_DIR: ./book
```

ワークフローの詳しい書き方は割愛しますが、このYAMLファイルにより、**master**ブランチに
**src/\*\*.md**または**book.toml**ファイルがプッシュされたら、**deploy**ジョブが実行されます。  
deployジョブではファイルを取得し、**Build**ステップでは4.3節で定義したアクションを実行、
`mdbook build`によってHTML一式を**book**ディレクトリ以下に生成します。  
その後、peaceiris/actions-gh-pages@v2アクションによってデプロイを行っています。
環境変数を与えることで外部リポジトリにプッシュしたりプッシュするブランチを指定できます。
`ACTIONS_DEPLOY_KEY`は4.2節で登録した**Secrets**を参照し、`EXTERNAL_REPOSITORY`で外部リポジトリを
定義しています。`EXTERNAL_REPOSITORY`の ***USER_NAME*** はご自身のユーザ名に置き換えてください。
`PUBLISH_BRANCH`でプッシュするブランチを指定します。最後に、`PUBLISH_DIR`で**Build**ステップで
生成された**book**ディレクトリをプッシュします。

その他の環境変数は[README.md][actions-gh-pages_README.md]に記載されているので、こちらを参照してください。

## 5. 完成したコードをプッシュ

4章までに作成したコードをリポジトリ(**ここではmdbook2pages**))にプッシュするとGitHub Actionsが
自動で実行され、エラーが発生しなかったら**USER_NAME.github.io**にHTML一式がプッシュされているはずです。

![Result of GitHub Actions][actions_result_img]

![GitHub Pages commit][github_pages_commit_img]

## おわりに

GitHub Actionsを利用することで、継続的にテストやビルド、デプロイ(CI/CD)ができるようになり、
プッシュするだけでウェブサイトが更新されるようになりました。以前では、手動でビルドし、
ビルドしたものをサーバにアップして...などの手順がめんどくさかったですが、GitHub Actionsによって
Markdownファイルを書き、プッシュするだけですべての手順を自動でやってくれるため、
書くことに集中することができるようになりました。
また、mdBookではCSSやJavaScriptを独自に定義することができるため、今後はこのCSSやJavaScriptを
リント、フォーマッティング、テストを行うアクションを定義したいと思います。

[mdBook]:https://github.com/rust-lang/mdBook
[GitBook]:https://www.gitbook.com/
[mdbook2pages]:https://github.com/pyama2000/mdbook2pages
[actions-gh-pages_README.md]:https://github.com/peaceiris/actions-gh-pages/blob/master/README.md


[summary_img]:https://user-images.githubusercontent.com/33086493/72126054-118cfd00-33ae-11ea-8369-b217005d36d0.png
[create_github_pages_img]:https://user-images.githubusercontent.com/33086493/72165777-7591de80-340b-11ea-95ad-65d0912e0361.png
[add_deploy_keys_img]:https://user-images.githubusercontent.com/33086493/72167663-e686c580-340e-11ea-9fa1-08354ccbb61c.png
[add_secrets_img]:https://user-images.githubusercontent.com/33086493/72167670-e8508900-340e-11ea-93f7-c55832450af1.png
[actions_result_img]:https://user-images.githubusercontent.com/33086493/72170077-a249f400-3413-11ea-88e1-45e5d2cf9c38.png
[github_pages_commit_img]:https://user-images.githubusercontent.com/33086493/72170676-a0346500-3414-11ea-9819-ed1683d1bf22.png
