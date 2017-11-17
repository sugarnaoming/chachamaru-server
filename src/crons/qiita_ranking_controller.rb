require 'open-uri'
require 'json'
require_relative '../utils'
require_relative '../qiita_db'

class Qiita
  @@base_uri = 'https://qiita.com'
  # QiitaAPIを利用して現在日から1日前までに投稿された記事のid、タイトル、作成日、URL、いいね数を取得してDBに登録する
  # @return [void] なし
  def self.get_daily_rank
    db = QiitaDB.new
    db.create_table?(table_name: 'daily')
    db.connect_table(table_name: 'daily')
    t = Utils.days_ago_of(day: 1)
    1.step do |i|
      uri = "#{@@base_uri}/api/v2/items?page=#{i}&per_page=100&query=created%3A%3E#{t.year}-#{t.month}-#{t.day}"
      puts "URL #{uri}"
      daily_rank = open(uri) {|rank| JSON.parse(rank.read)}
      break if daily_rank.empty?
      daily_rank.each do |d|
        db.insert(id: d['id'], title: d['title'], create_date: d['created_at'], url: d['url'], good: d['likes_count'])
      end
    end
  end

  # QiitaDBに登録されているデイリーランキングから記事の作成日が2日前を超えたデータを削除する
  # @return [void]
  def self.delete_daily_rank
    QiitaDB.new.delete_of_data_past_retention_period(table_name: 'daily', period: 2)
  end

  # QiitaAPIを利用して現在日から1日前までに投稿された記事のid、タイトル、作成日、URL、いいね数を取得してDBに登録する
  # @return [void] なし
  def self.get_weekly_rank
    db = QiitaDB.new
    db.create_table?(table_name: 'weekly')
    db.connect_table(table_name: 'weekly')
    t = Utils.days_ago_of(day: 6)
    1.step do |i|
      uri = "#{@@base_uri}/api/v2/items?page=#{i}&per_page=100&query=created%3A%3E#{t.year}-#{t.month}-#{t.day}"
      puts "URL #{uri}"
      daily_rank = open(uri) {|rank| JSON.parse(rank.read)}
      break if daily_rank.empty?
      daily_rank.each do |d|
        db.insert(id: d['id'], title: d['title'], create_date: d['created_at'], url: d['url'], good: d['likes_count'])
      end
    end
  end

  # QiitaDBに登録されているウィークリーランキングから記事の作成日が7日前を超えたデータを削除する
  # @return [void]
  def self.delete_weekly_rank
    QiitaDB.new.delete_of_data_past_retention_period(table_name: 'weekly', period: 7)
  end
end