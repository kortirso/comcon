module Api
  module V1
    class BankRequestsController < Api::V1::BaseController
      before_action :find_guild, only: %i[index]
      before_action :find_bank, only: %i[create]
      before_action :find_character, only: %i[create]
      before_action :find_game_item, only: %i[create]
      before_action :find_bank_request, only: %i[decline approve destroy]

      resource_description do
        short 'BankRequests resources'
        formats ['json']
      end

      api :GET, '/v1/bank_requests.json', 'Get bank requests'
      error code: 401, desc: 'Unauthorized'
      def index
        authorize! @guild, to: :bank?
        render json: @guild.bank_requests.sent.order(id: :asc).includes(:character, :bank, :game_item), status: 200
      end

      api :POST, '/v1/bank_requests.json', 'Create bank request'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        authorize! @bank.guild, to: :bank?
        bank_request_form = BankRequestForm.new(bank_request_params.merge(bank: @bank, character: @character, game_item: @game_item))
        if bank_request_form.persist?
          CreateBankRequestJob.perform_later(bank_request_id: bank_request_form.bank_request.id)
          render json: bank_request_form.bank_request, status: 201
        else
          render json: { errors: bank_request_form.errors.full_messages }, status: 409
        end
      end

      api :POST, '/v1/bank_requests/:id/decline.json', 'Decline bank request'
      error code: 401, desc: 'Unauthorized'
      error code: 404, desc: 'Not found'
      def decline
        authorize! @bank_request.bank.guild, to: :bank?
        @bank_request.decline
        render json: { result: 'Bank request is declined' }, status: 200
      end

      api :POST, '/v1/bank_requests/:id/approve.json', 'Approve bank request'
      error code: 401, desc: 'Unauthorized'
      error code: 404, desc: 'Not found'
      def approve
        authorize! @bank_request.bank.guild, to: :bank?
        result = ApproveBankRequest.call(bank_request: @bank_request, provided_amount: params[:provided_amount])
        if result.success?
          result.bank_cell.destroy if result.bank_cell.amount.zero?
          render json: result.bank_cell, status: 200
        else
          render json: { result: result.message }, status: 409
        end
      end

      def destroy
        authorize! @bank_request, to: :destroy?
        @bank_request.destroy
        render json: { result: 'Bank request is destroyed' }, status: 200
      end

      private

      def find_guild
        @guild = Guild.find_by(id: params[:guild_id])
        render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
      end

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

      def find_bank_request
        @bank_request = BankRequest.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @bank_request.nil?
      end

      def bank_request_params
        params.require(:bank_request).permit(:requested_amount)
      end
    end
  end
end
