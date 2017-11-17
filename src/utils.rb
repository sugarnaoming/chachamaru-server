require 'time'

class Utils
  # iso8601形式で取得した日時を特定のフォーマットに変換する
  # デフォルトはYYYY/MM/DD hh:mm:ss
  # @params [Time] iso8601_format: 変換対象の時刻
  # @params [String] conversion_format: 変換後のフォーマット指定。デフォルトは'YYYY/MM/DD hh:mm:ss'
  # フォーマットの指定に使用できる形式は Time#strftime のリファレンスを参照してください
  # @return [String] 変換後の時刻
  def self.to_readable_datetime(iso8601_format:, conversion_format: '%Y/%m/%d %H:%M:%S')
   Time.iso8601(iso8601_format).strftime(conversion_format)
  end

  # 基準日から特定日数を引いた日付を算出する
  # @params [Int] day: 基準日から減算したい日数
  # @params [Time] base_day: 減算の基準日
  # @params [Boolean] iso8601_conversion: 算出結果をiso8601形式に変換するかどうか
  # @return [Time] 算出後の日時
  def self.days_ago_of(day:, base_day: Time.now.to_s, iso8601_conversion: false)
    return Time.parse(base_day) if day == 0
    t = Time.parse(base_day) - (24 * 60 * 60 * day)
    return t.iso8601 if iso8601_conversion
    t
  end
end