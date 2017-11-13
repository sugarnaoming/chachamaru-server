require 'rss'
require 'open-uri'
require 'rexml/document'

module API
  class HATEBU
    @opt = {'User-Agent' => 'Opera/9.80 (Windows NT 5.1)'}
    # はてなブックマークのrssを取得するapiです
    # 取得する画像が無い場合は空文字が入ります
    # 取得したrssからtitle, link, description, bookmark, favicon, img srcをhashにして返却します
    # @params [string] entry:
    # entryの値は"hotentry"もしくは"entrylist"を受け付けます
    # @params [string] category:
    # categoryの値は総合カテゴリ以外ははてなブックマークのrssと同じものが使えます
    # 総合カテゴリは"all"を入力すると取得できます
    # @return [hash]
    def self.rss(entry:, category:)
      entrys = ['hotentry', 'entrylist']
      categorys = ['all', 'social', 'economics', 'life', 'knowledge', 'it', 'entertainment', 'game', 'fun']
      unless entrys.include?(entry)
        raise ArgumentError
      end
      unless categorys.include?(category)
        raise ArgumentError
      end

      if category == 'all'
        uri = "http://b.hatena.ne.jp/#{entry}.rss"
      else
        uri = "http://b.hatena.ne.jp/#{entry}/#{category}.rss"
      end

      feed = open(uri, @opt){ |rss| RSS::Parser.parse(rss) }

      articles = []
      feed.items.each do |item|
        content_xml = item.content_encoded[/<blockquote(.*)<\/blockquote>/]
        doc = REXML::Document.new(content_xml)
        favicon_url = doc.elements['blockquote/cite/img'].attributes['src']
        img_url = doc.elements['blockquote/p/a/img'].attributes['src']
        img_url = '' unless img_url.start_with?('http://cdn-ak.b.st-hatena.com')
        img_url = '' if img_url.start_with?('https://cdn-ak-scissors.b.st-hatena.com/image/square')
        bookmark = open("http://api.b.st-hatena.com/entry.count?url=#{item.link}", @opt){ |res| res.read  }
        articles << [['title', item.title],
                     ['link', item.link],
                     ['desc', item.description],
                     ['bookmark', bookmark],
                     ['favicon', favicon_url],
                     ['imgurl', img_url]].to_h
      end
      articles
    end
  end
end