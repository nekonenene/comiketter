Axlsx::Package.new do |p|
  header_style = p.workbook.styles.add_style({
    b: true,
    alignment: { horizontal: :center },
    border: { edges: [:bottom], style: :double, color: "000000" },
    bg_color: "8CE9FF",
  })

  default_style = p.workbook.styles.add_style({
    alignment: { horizontal: :left },
  })

  header_row = ["Twitter ID", "ユーザー名", "Website"]
  followers = @current_user.followers
  friends = @current_user.friends

  if @event_code.present?
    header_row = header_row.concat ["参加日付", "◯日目", "ホール", "参加スペース"]

    event = Event.find_by(code: @event_code)
    followers = @current_user.followers.select{|user| user.circle_spaces.find_by(event: event).present?}
    friends = @current_user.friends.select{|user| user.circle_spaces.find_by(event: event).present?}
  end

  p.workbook.add_worksheet(name: "Following") do |sheet|
    sheet.add_row header_row, style: header_style
    friends.each do |user|
      adding_row = [user.handle, user.username, user.website_url]
      if event.present?
        space = user.circle_spaces.find_by(event: event)
        join_date = event.start_date.days_since(space.day - 1) if space.day.present?
        adding_row = adding_row.concat [join_date.to_s, space.day.to_s, space.hall_name, space.space_prefix.to_s + space.space_number.to_s + space.space_side.to_s]
      end

      row = sheet.add_row adding_row, style: default_style
      sheet.add_hyperlink location: twitter_user_url(user.handle), ref: "A#{row.row_index + 1}"
      sheet.add_hyperlink location: user.website_url, ref: "C#{row.row_index + 1}" if user.website_url.present?
    end
  end

  p.workbook.add_worksheet(name: "Followers") do |sheet|
    sheet.add_row header_row, style: header_style
    followers.each do |user|
      adding_row = [user.handle, user.username, user.website_url]
      if event.present?
        space = user.circle_spaces.find_by(event: event)
        join_date = event.start_date.days_since(space.day - 1) if space.day.present?
        adding_row = adding_row.concat [join_date.to_s, space.day.to_s, space.hall_name, space.space_prefix.to_s + space.space_number.to_s + space.space_side.to_s]
      end

      row = sheet.add_row adding_row, style: default_style
      sheet.add_hyperlink location: twitter_user_url(user.handle), ref: "A#{row.row_index + 1}"
      sheet.add_hyperlink location: user.website_url, ref: "C#{row.row_index + 1}" if user.website_url.present?
    end
  end
end
