vim-unite-jenkins
------------------

# 概要

unite の source としてjenkinsを扱えるようにする

# なぜ作ったか

jenkins でビルドするたびにブラウザで結果を確認するのは非常に面倒。
どうせならエディタから結果を確認できたほうが幸せになれる。

# 依存

* vimproc

# 使い方

vimrc に以下の記述を追加する。(Mac と Linux で使うことを想定。)

    NeoBundle 'Shougo/vimproc', {
          \ 'build' : {
          \     'mac' : 'make -f make_mac.mak',
          \    },
          \ }
    NeoBundle 'rightoverture/vim-unite-jenkins'
    let g:unite_source_jenkins_server_host = 'jenkins.host.org'
    let g:unite_source_jenkins_server_port = '80'
    let g:unite_source_jenkins_relay_server_host = 'localhost'
    let g:unite_source_jenkins_relay_server_port = '10000'

g:unite_source_jenkins_server_host 等は必須ではないがデフォルトではどちらも localhost になっているため設定する必要がある。

# 各ジョブで落ちたテストファイルを表示する方法

Jenkins ではいろいろな言語のテストを走らせる事ができるためテスト結果をパースする方法も様々である。
そこで vim-unite-jenkins ではその部分を分離できるようにしている。

vimrc に

    let g:unite_source_jenkins_job_source = 'jenkins/job'

のように Job の結果を表示する unite-source を指定することができる。

このソースは第一引数にプロジェクトの名前、第二引数に Job 番号、第三引数にキャッシュすべきかどうかが渡され呼び出される。
このような機構になっているため個々人が必要な source を実装して使うことにより幸せになれる。

# どうやって動作しているの？

<pre>
Jenkins <---http---> relay server <---JSON API---> vim
</pre>

このように vim と jenkins の間に中継用のサーバーを設けることで実現している。
中継サーバーで Jenkins の API を呼び出し vim script として評価できる文字列として返す。
vim script では非同期で中継サーバーへリクエストを送り返ってきた文字列を eval することでデータ構造を復元している。

# 中継サーバーについて

ほぼすべてが Perl で書かれている。

## 中継サーバーで使っているモジュール

* Net::Jenkins
* Plack
* Starlet
* Carton
    * cpanm
* Data::VimScript(自作)

## 中継サーバーの立て方

中継サーバーのファイルが在るディレクトリで

    $ carton install
    $ carton exec -Ilib -- plackup -p server.psgi

# 既知の問題

* 中継サーバーが不正なバイト列を含む JSON をパースできないのでたまに死ぬ

これは不正なバイト列を含む JSON を返す Jenkins にも問題があればそのようなバイト列を含むコミットメッセージなどを書く人間も悪い

* Project 内の Job 一覧を取得する方法が非効率的

Job 数分 API を呼び出してしまう。他に効率がいい取得方法があれば置き換えたい。

# TODO

* Net::Jenkins からの脱却

Net::Jenkins は Moose に依存していて重い。
(常に起動しているサーバーなので起動時にインスタンスを作成しリクエストではそれを使いまわすようにすればそれほど気にならないかも。)

* 中継サーバーで API を呼び出すときはキャッシュしたい。

処理済みの Job などは API の結果が変わらないためキャッシュしておいたほうが効率的。
また Jenkins に対しても優しい仕様。これが実装されるまでは Jenkins に対してだいぶ厳しい使用。

# Author

Fumihiro Ito
