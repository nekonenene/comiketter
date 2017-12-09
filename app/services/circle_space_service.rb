class CircleSpaceService
  require "nkf"

  class << self

    # 半角カナ→全角カナ, 全角英数→半角英数
    # @param [String] str 入力文字列
    # @return [String]
    def normalize_str(str)
      NKF.nkf('-m0Z1 -w -W', str)
    end

  end
end
