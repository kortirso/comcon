RSpec.shared_examples_for 'Admin Auth' do
  context 'for unlogged users' do
    it 'redirects to login page' do
      do_request

      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'for logged simple user' do
    sign_in_user

    it 'renders error page' do
      do_request

      expect(response).to render_template 'shared/error'
    end
  end
end
