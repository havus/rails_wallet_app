# frozen_string_literal: true

module Api
  module V1
    class TeamsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def index
        teams = Team.all
        render json: teams, status: :ok
      end

      def show
        team = Team.find(params[:id])
        render json: team, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { errors: 'Team not found' }, status: :not_found
      end

      def create
        team = Team.new(team_params)
        if team.save
          render json: { message: 'Team created successfully', team: team }, status: :created
        else
          render json: { errors: team.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def wallet
        team = Team.find(params[:id])
        wallet = team.wallet

        if wallet
          get_balance = WalletServices::GetBalance.new
          get_balance.perform(wallet)

          render(
            json: {
              wallet: wallet,
              balance: get_balance.result,
            },
            status: :ok,
          )
        else
          render json: { errors: 'Wallet not found' }, status: :not_found
        end
      end

      private

      def team_params
        params.require(:team).permit(:name, :email, :password)
      end
    end
  end
end
