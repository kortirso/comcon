# base helper
module ApplicationHelper
  def change_locale(locale)
    url_for(request.params.merge(locale: locale.to_s))
  end

  def self.datetime_represent(value, type)
    return value[type] if Rails.env.test?
    DateTime.new(value["#{type}(1i)"].to_i, value["#{type}(2i)"].to_i, value["#{type}(3i)"].to_i, value["#{type}(4i)"].to_i, value["#{type}(5i)"].to_i)
  end
end
