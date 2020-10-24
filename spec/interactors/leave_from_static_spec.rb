# frozen_string_literal: true

describe LeaveFromStatic do
  let!(:character) { create :character }
  let!(:static) { create :static, staticable: character }
  let!(:static_member) { create :static_member, character: character, static: static }
  let!(:subscribe) { create :subscribe, character: character, subscribeable: static }

  describe '.call' do
    context 'for unexisted character' do
      let(:interactor) { described_class.call(static: static, character: nil) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and does not delete static member' do
        expect { interactor }.not_to change(StaticMember, :count)
      end

      it 'and does not delete subscribe' do
        expect { interactor }.not_to change(Subscribe, :count)
      end
    end

    context 'for unexisted static' do
      let(:interactor) { described_class.call(static: nil, character: character) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and does not delete static member' do
        expect { interactor }.not_to change(StaticMember, :count)
      end

      it 'and does not delete subscribe' do
        expect { interactor }.not_to change(Subscribe, :count)
      end
    end

    context 'for unexisted static' do
      let(:interactor) { described_class.call(static: static, character: character) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and deletes static member' do
        expect { interactor }.to change(StaticMember, :count).by(-1)
      end

      it 'and deletes subscribe' do
        expect { interactor }.to change(Subscribe, :count).by(-1)
      end
    end
  end
end
