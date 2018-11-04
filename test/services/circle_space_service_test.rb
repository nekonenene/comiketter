class CircleSpaceServiceTest < ActiveSupport::TestCase

  test "normalize_str" do
    assert_equal "ABCd123", CircleSpaceService.normalize_str("ＡＢＣd１２3")
    assert_equal "ハンカクカナですヨ", CircleSpaceService.normalize_str("ﾊﾝｶｸｶﾅですヨ")
    assert_equal "テスト@3日目(日)!!【東15a】", CircleSpaceService.normalize_str("テスト＠３日目（日）！！【東１５a】")
    assert_equal 'テスト@C93 土曜日東地区"ク"-13a', CircleSpaceService.normalize_str("テスト＠C93 土曜日東地区“ク”－13a")
    assert_equal "テスト@1日目(土)東エ02a", CircleSpaceService.normalize_str("テスト@1日目(土)東エ02a")
  end

  test "kanji_to_num" do
    assert_equal "1日目", CircleSpaceService.kanji_to_num("一日目")
    assert_equal "256", CircleSpaceService.kanji_to_num("二五六")
  end

  test "analyze_space_from_username" do
    assert_equal(
      {
        day: 1,
        hall_name: nil,
        space_prefix: "ク",
        space_number: "13",
        space_side: "a",
      },
      CircleSpaceService.analyze_space_from_username("テスト＠C93 土曜日東地区“ク”－13a")
    )

    assert_equal(
      {
        day: 2,
        hall_name: nil,
        space_prefix: "A",
        space_number: "17",
        space_side: nil,
      },
      CircleSpaceService.analyze_space_from_username("テスト@日 東A-17【クレスタ】")
    )

    assert_equal(
      {
        day: nil,
        hall_name: nil,
        space_prefix: "な",
        space_number: "07",
        space_side: "b",
      },
      CircleSpaceService.analyze_space_from_username("テスト[C93:な07b]‏")
    )

    assert_equal(
      {
        day: 1,
        hall_name: nil,
        space_prefix: "M",
        space_number: "07",
        space_side: "b",
      },
      CircleSpaceService.analyze_space_from_username("テスト@冬コミ土曜東Ｍ－07b‏‏")
    )

    assert_equal(
      {
        day: 2,
        hall_name: nil,
        space_prefix: "H",
        space_number: "44",
        space_side: "a",
      },
      CircleSpaceService.analyze_space_from_username("テスト＠二日目Ｈ－44a‏‏")
    )

    assert_equal(
      {
        day: 2,
        hall_name: "東7",
        space_prefix: "あ",
        space_number: "26",
        space_side: nil,
      },
      CircleSpaceService.analyze_space_from_username("テスト★2日目東7.あ26‏‏")
    )

    assert_equal(
      {
        day: 1,
        hall_name: nil,
        space_prefix: nil,
        space_number: nil,
        space_side: nil,
      },
      CircleSpaceService.analyze_space_from_username("テスト@コミケ（C93）一日目一般参加‏‏")
    )

    assert_equal(
      {
        day: 1,
        hall_name: nil,
        space_prefix: "コ",
        space_number: "50",
        space_side: "b",
      },
      CircleSpaceService.analyze_space_from_username("テスト 土-東コ50b‏‏")
    )

    assert_equal(
      {
        day: nil,
        hall_name: nil,
        space_prefix: "A",
        space_number: "14",
        space_side: "b",
      },
      CircleSpaceService.analyze_space_from_username("テスト＠ゆゆ式　C93土A-14b")
    )
  end

end
