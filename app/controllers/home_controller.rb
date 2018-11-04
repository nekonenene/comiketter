class HomeController < ApplicationController
  def index
    if @current_user.present?
      user_data_api = TwitterApi::UserData.new(@current_user)
      user_data_api.update_followers
      user_data_api.update_friends

      @latest_event = Event.last
      @followers_joining = @current_user.followers.select{ |user| user.circle_spaces.find_by(event: @latest_event).present? }
      @friends_joining = @current_user.friends.select{ |user| user.circle_spaces.find_by(event: @latest_event).present? }
    end
  end

  def export
    if @current_user.nil?
      flash[:alert] = I18n.t("auth.need_siginin")
      return redirect_to root_path
    end

    @event_code = params[:event_code]

    filename = @event_code + "_" if @event_code.present?
    filename = filename.to_s + "twitter_list_" + Time.zone.now.to_date.to_s
    send_data(
      render_to_string.to_stream.read,
      type: :xlsx,
      filename: filename + ".xlsx"
    )
  end
end
