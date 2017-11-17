require 'sqlite3'
require 'sequel'
require_relative 'utils'

class QiitaDB
  def initialize
    options = {:encoding=>"utf8"}
    @db = Sequel.sqlite('db/qiita-rank', options)
  end

  # 特定のテーブルに接続する
  # @params [String] table_name: 接続したいテーブルの名称
  # @return [void] なし
  def connect_table(table_name:)
    @connected_table = @db[table_name.to_sym]
  end

  # 引数で指定された名称でQiita用のテーブルを作成する
  # 引数で指定された名称のテーブルがすでに存在する場合は何もしない
  # @params [String] table_name: 作成したいテーブルの名称
  # @return [void] なし
  def create_table?(table_name:)
    @db.create_table? table_name.to_sym do
      String :id, primary_key: true
      String :title
      String :create_date
      Integer :_create_date
      String :url
      Integer :good
    end
  end

  # QiitaのデータをDBに格納する
  # @params [String] id: QiitaAPIから取得できるID
  # @params [String] title: QiitaAPIから取得できるtitle
  # @params [String] create_date: QiitaAPIから取得できるcreate_at
  # @params [String] url: QiitaAPIから取得できるurl
  # @params [Int] good: QiitaAPIから取得できるlikes_count
  # @return [void] なし
  def insert(id:, title:, create_date:, url:, good:)
    date = Utils.to_readable_datetime(iso8601_format: create_date)
    calc_date = Utils.to_readable_datetime(iso8601_format: create_date, conversion_format: '%Y%m%d%H%M%S')
    @connected_table.insert_conflict(:replace).insert(:id => id, :title => title, :create_date => date, :_create_date => calc_date, :url => url, :good => good)
  end

  # 特定テーブルから指定した日付以前のデータを削除する
  # @params [String] table_name: 削除したいデータの存在するテーブル名
  # @params [Int] period: 現在日時を基準に、何日以前のデータを削除するか
  # @return [void] なし
  def delete_of_data_past_retention_period(table_name:, period:)
    t = Utils.days_ago_of(day: period, iso8601_conversion: true)
    period_time = Utils.to_readable_datetime(iso8601_format: t, conversion_format: '%Y%m%d%H%M%S')
    @db[table_name.to_sym].where(Sequel.expr(:_create_date) < period_time.to_i).delete
  end

  # DBに格納されているQiitaランキングを取得する
  # @params [String] table_name: 取得対象のテーブル名
  # @params [String] rank_type: 取得したいランキングのタイプ。dailyもしくはweeklyのどちらか
  # @params [Int] limit: 取得件数（いいね評価の上位から取得する数）
  # @return [hash] 対象のランキングをhash形式で返す
  def get_rank(table_name:, rank_type:, limit: 30)
    type = {:daily => 1, :weekly => 6}
    t = Utils.days_ago_of(day: type[rank_type.to_sym], iso8601_conversion: true)
    days_ago_of_1 = Utils.to_readable_datetime(iso8601_format: t, conversion_format: '%Y%m%d%H%M%S')
    table = @db[table_name.to_sym].where(Sequel.expr(:_create_date) >= days_ago_of_1.to_i)
    table = table.order(Sequel.desc(:good)).limit(limit)
    rank = []
    table.each do |row|
      rank << [['title', row[:title]],
               ['url', row[:url]],
               ['create_at', row[:create_date]],
               ['good', row[:good]]
              ].to_h
    end
    rank
  end
end