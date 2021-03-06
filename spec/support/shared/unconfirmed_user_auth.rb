# frozen_string_literal: true

shared_examples_for 'Unconfirmed User Auth' do
  context 'for unconfirmed users' do
    sign_in_unconfirmed_user

    it 'render shared error' do
      do_request

      expect(response).to render_template 'shared/401'
    end
  end
end
