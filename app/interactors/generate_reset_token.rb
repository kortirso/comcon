# Process of generating reset password token
class GenerateResetToken
  include Interactor::Organizer

  organize CreateResetToken, SendResetToken
end
