module Api
  module V1
    class BankRequestsController < Api::V1::BaseController
      before_action :find_bank, only: %i[create]
      before_action :find_character, only: %i[create]
      before_action :find_game_item, only: %i[create]

      resource_description do
        short 'BankRequests resources'
        formats ['json']
      end

      api :POST, '/v1/bank_requests.json', 'Create bank request'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        authorize! @bank.guild, to: :bank?
        bank_request_form = BankRequestForm.new(bank_request_params.merge(bank: @bank, character: @character, game_item: @game_item))
        if bank_request_form.persist?
          render json: bank_request_form.bank_request, status: 201
        else
          render json: { errors: bank_request_form.errors.full_messages }, status: 409
        end
      end

      private

      def find_bank
        @bank = Bank.find_by(id: params[:bank_request][:bank_id])
        render_error(t('custom_errors.object_not_found'), 404) if @bank.nil?
      end

      def find_character
        @character = Current.user.characters.find_by(id: params[:bank_request][:character_id])
        render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
      end

      def find_game_item
        @game_item = GameItem.find_by(id: params[:bank_request][:game_item_id])
        render_error(t('custom_errors.object_not_found'), 404) if @game_item.nil?
      end

      def bank_request_params
        params.require(:bank_request).permit(:requested_amount)
      end
    end
  end
end
