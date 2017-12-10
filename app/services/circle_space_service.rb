class CircleSpaceService
  require "nkf"

  class << self

    # 半角カナ→全角カナ, 全角英数→半角英数
    # @param [String] str 入力文字列
    # @return [String]
    def normalize_str(str)
      NKF.nkf('-m0Z1 -w -W', str)
    end

    # 漢数字を半角数字に変換
    def kanji_to_num(str)
      kan_num = {"一": 1, "二": 2, "三": 3, "四": 4, "五": 5, "六": 6, "七": 7, "八": 8, "九": 9}

      if str =~ /[#{kan_num.keys.join}]/
        kan_num.each{ |key, value|
          str.gsub!(/#{key}/, value.to_s)
        }
      end

      str
    end

    # ユーザーネームからサークルスペースを推測
    # @param [String] username ユーザーネーム
    # @return [Hash]
    def analyze_space_from_username(username)
      normalized = normalize_str(username)
      normalized = kanji_to_num(normalized)
      normalized.delete!("- \"")
      normalized.gsub!(/C9[3-9]/i, "") # C島は60までしか存在しない

      matched = normalized.scan(/([A-Zあ-んア-ン])([0-9]{2})([ab]{1,2})/)
      if matched.present?
        space_prefix = matched.last[0]
        space_number = matched.last[1]
        space_side = matched.last[2]
      end

      matched = normalized.match(/(東|西)[1-9]/)
      hall_name = matched[0] if matched.present?

      matched = normalized.scan(/([1-3])日/)
      day = matched.last[0] if matched.present?

      # FIXME: 金曜を1日目と決めつけてしまっている
      if day.nil?
        weekday_days = {"金": 1, "土": 2, "日": 3}

        weekday_days.each{ |key, value|
          if normalized =~ /(#{key}曜|@#{key}|\(#{key}\)|#{key}(東|西))/
            day = value
            break # 土曜日東館 が日曜と判断されないために break 必須
          end
        }
      end

      # ホール名・日付のいずれかがある場合は、abの記載がないスペース番号を許す
      if hall_name.present? || day.present?
        matched = normalized.scan(/([A-Zあ-んア-ン])([0-9]{2})/)
        if matched.present?
          space_prefix ||= matched.last[0]
          space_number ||= matched.last[1]
        end
      end

      return {
        day: day&.to_i,
        hall_name: hall_name,
        space_prefix: space_prefix,
        space_number: space_number,
        space_side: space_side,
      }
    end

  end
end
