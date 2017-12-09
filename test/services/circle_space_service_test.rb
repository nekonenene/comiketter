class CircleSpaceServiceTest < ActiveSupport::TestCase

  test "normalize" do
    assert_equal "ABCd123", CircleSpaceService.normalize_str("ＡＢＣd１２3")
    assert_equal "ハンカクカナですヨ", CircleSpaceService.normalize_str("ﾊﾝｶｸｶﾅですヨ")
  end

end
