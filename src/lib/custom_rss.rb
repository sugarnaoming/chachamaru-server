require 'open-uri'
require 'rss'

class CRss
  # 引数に渡されたurlに対してRSSの取得を試みます
  # @params [String] url: RSSを取得するURL
  # @params [Boolean] fake_agent: ユーザエージェントを偽装します
  # @return [RSS::Feed] rssのfeed形式で返します
  def get_rss(url:, fake_agent: false)
    opt = {}
    opt = {'User-Agent' => 'Opera/9.80 (Windows NT 5.1)'} if fake_agent
    open(url, opt){ |rss| RSS::Parser.parse(rss) }
  end
end