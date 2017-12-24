class ErrorsController < ApplicationController
  layout "errors"
  rescue_from Exception, with: :server_error

  def show
    status = request.path[%r{(?<=\A/)\d{3}\z}]

    case status
    when "404"
      render "404", status: 404
    else
      render "500", status: status
    end
  end

  def server_error(exception)
    ExceptionNotifier.notify_exception(exception)
    render "500", status: 500
  end
end
