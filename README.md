auto-tweet-delete-2
===================

1 時間おきに自分の発言を消していくツール (Heroku 対応)

## Usage

```shell
git clone git@github.com:shunirr/auto-tweet-delete-2.git
cd auto-tweet-delete-2
heroku create --stack cedar
heroku config:add consumer_key=xxxxx
heroku config:add consumer_secret=xxxxx
heroku config:add access_token=xxxxx
heroku config:add access_token_secret=xxxxx
git push heroku master
heroku scale bot=1
```
