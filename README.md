# git_diff_tool

## 概要
<p>Gitのブランチ間の差分を表示するアプリケーションです。</p>
<p>差分の取得にはホストのGitを利用します。</p>
<p>また３つのラジオボタンで差分の抽出結果を加工することができます。</p>

<p>普段業務で特定ブランチ間の差分を手動で抽出し、
差分ファイルを特定のサーバーに手動でアップロードするということを行っているのですが、</br>
人力作業によるミスを減らす為にこのアプリケーションを開発しました。</p>
``
入力項目の説明
``

<div>
<span style="font-weight: bold">Git Install Path:</span>
<span>ホスト側のgit.exeが格納されているフォルダを指定してください。</span>
<p>例：C:/Git/cmd</p>
</div>

<div>
<span style="font-weight: bold">Source Clone Path:</span>
<span>比較する対象のリポジトリのパスを指定してください。</span>
<p>例：D:\git\tsumami</p>
</div>

<div>
<span style="font-weight: bold">Staging Path:</span>
<span>アップロード先のパスを指定してください。</span>
<p>例：/var/www/html</p>
</div>

<div>
<span style="font-weight: bold">Branch-1:</span>
<span>比較するブランチ1</span>
<p>例：origin/master</p>
</div>

<div>
<span style="font-weight: bold">Branch-2:</span>
<span>比較するブランチ2</span>
<p>例：staging</p>
</div>


### Windowsでの配布
```
flutter build windows
```