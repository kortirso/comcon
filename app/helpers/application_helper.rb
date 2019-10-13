# base helper
module ApplicationHelper
  def change_locale(locale)
    url_for(request.params.merge(locale: locale.to_s))
  end
end
