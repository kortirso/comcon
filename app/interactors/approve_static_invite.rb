# Approving static invite
class ApproveStaticInvite
  include Interactor::Organizer

  organize CreateStaticMember, UpdateStaticInvite
end
