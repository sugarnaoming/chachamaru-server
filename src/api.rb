require 'rss'
require 'open-uri'
require 'rexml/document'
require 'json'

require_relative 'utils'
require_relative 'custom_rss'
require_relative 'qiita_db'

module API
  class HATEBU
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
      feed = Rss.new.get_rss(url: uri, fake_agent: true)
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

  class Qiita
    # DBからQiitaのデイリーランキングを取得します
    # @return [hash] HashMap形式で返します
    def self.daily_rank
      QiitaDB.new.get_rank(table_name: 'daily', rank_type: 'daily')
    end

    # DBからQiitaのウィークリーランキングを取得します
    # @return [hash] HashMap形式で返します
    def self.weekly_rank
      QiitaDB.new.get_rank(table_name: 'weekly', rank_type: 'weekly')
    end

    # rssとしてQiitaから人気の記事一覧を取得
    # @return [hash] HashMap形式で返します
    def self.popular
      feed = Rss.new.get_rss(url: 'https://qiita.com/popular-items/feed')
      articles = []
      feed.items.each do |item|
        title = REXML::Document.new(item.title.to_s).elements['title'].text
        link = REXML::Document.new(item.link.to_s).elements['link'].attributes['href']
        create_at = REXML::Document.new(item.published.to_s).elements['published'].text
        articles << [['title', title],
                     ['link', link],
                     ['create_at', Utils.to_readable_datetime(iso8601_format: create_at)]].to_h
      end
      articles
    end
  end
end