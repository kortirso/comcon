# frozen_string_literal: true

# Approving static invite
class ApproveStaticInvite
  include Interactor::Organizer

  organize CreateStaticMember, DeleteStaticInvite
end
