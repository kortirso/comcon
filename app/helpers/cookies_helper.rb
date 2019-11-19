# Helper for cookies authentification
module CookiesHelper
  # Remembers a person in a persistent session.
  def remember(person)
    person.remember
    cookies.permanent.signed[:guild_hall_user_id] = person.id
    cookies.permanent[:remember_token] = person.remember_token
  end

  # Forgets a person from a persistent session.
  def forget(person)
    person.forget
    cookies.delete(:guild_hall_user_id)
    cookies.delete(:remember_token)
  end

  # returns logged user, creates/returns guest, logges remembered person
  def current_person_in_cookies
    return current_user if user_signed_in?
    person = User.find_by(id: cookies.signed[:guild_hall_user_id])
    return nil if person.nil?
    return nil unless person.authenticated?(cookies[:remember_token])
    sign_in person
    @current_user = person
  end
end
