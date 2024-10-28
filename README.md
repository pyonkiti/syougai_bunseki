## 障害一覧の形態素解析を行うツール

#### 環境の作り方
1. d:\vagrant\syougai_bunsekiフォルダを作成
2. GitHubからPullする
3. VirturlBoxのUbuntuを起動
4. cd ./vagrant/syougai_bunseki

#### 動かし方
1. 楽楽販売の障害一覧より、「内容」「現象/原因」「処置」「備考」の４項目をCSV出力する。
2. CSVファイルをを1.txt、2.txt、3.txtと３つのファイルに分割する。
3.コードの中で、SyougaiBunseki.proc_mainの引数を指定する
  :all すべての処理を流す 1.txt、2.txt、3.txtからoutput.txtを作成するところも実行される
  :red アウトプットファイルの読み込みのみ実行 　output.txtがあることが前提で分析のみ行う
4. ruby syougai_bunseki.rbを実行する。すべての処理を流すと35分位かかります。
