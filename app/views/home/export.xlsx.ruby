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

  p.workbook.add_worksheet(name: "Followers") do |sheet|
    sheet.add_row %w(Twitter\ ID Name Website), style: header_style
    @current_user.followers.find_each do |user|
      row = sheet.add_row [user.handle, user.username, user.website_url], style: default_style
      sheet.add_hyperlink location: twitter_user_url(user.handle), ref: "A#{row.index + 1}"
      sheet.add_hyperlink location: user.website_url, ref: "C#{row.index + 1}" if user.website_url.present?
    end
  end

  p.workbook.add_worksheet(name: "Following") do |sheet|
    sheet.add_row %w(Twitter\ ID Name Website), style: header_style
    @current_user.friends.find_each do |user|
      row = sheet.add_row [user.handle, user.username, user.website_url], style: default_style
      sheet.add_hyperlink location: twitter_user_url(user.handle), ref: "A#{row.index + 1}"
      sheet.add_hyperlink location: user.website_url, ref: "C#{row.index + 1}" if user.website_url.present?
    end
  end
end
