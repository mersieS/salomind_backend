module Api
  module V1
    class StressRecordsController < ApplicationController
      def create
        user = find_user
        if daily_entry_exists?(user)
          render json: { error: "Daily stress entry already exists" }, status: :conflict
          return
        end

        inputs = stress_input_params
        calculation = StressCalculatorService.new(inputs).call
        stress_record = user.stress_records.build(inputs.merge(
          stress_score: calculation[:stress_score],
          stress_level: calculation[:stress_level]
        ))

        if stress_record.save
          webhook_message = StressRecordAlertNotifier.call(user: user, inputs: inputs, calculation: calculation)
          render json: response_payload(calculation, webhook_message), status: :created
        else
          render json: { errors: stress_record.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      def weekly
        user = find_user
        records = user.stress_records
                      .where(created_at: weekly_window)
                      .order(created_at: :asc)

        data = WeeklyStressReportService.new(records).call
        render json: data, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      def availability
        user = find_user
        render json: { can_create_today: !daily_entry_exists?(user) }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      private

      def find_user
        user_id = params[:user_id] || params.dig(:stress_record, :user_id)
        User.find(user_id)
      end

      def daily_entry_exists?(user)
        user.stress_records.where(created_at: Time.zone.now.all_day).exists?
      end

      def stress_input_params
        payload = params[:stress_record] || params
        payload.permit(
          :mood,
          :stress_feeling,
          :heart_rate,
          :physical_fatigue,
          :sleep_hours,
          :sleep_quality,
          :caffeine_intake,
          :screen_time
        ).to_h
      end

      def response_payload(calculation, webhook_message)
        {
          stress_score: calculation[:stress_score],
          stress_level: calculation[:stress_level],
          recommendation: webhook_message.presence || StressRecordAlertNotifier.delivery_message(calculation[:stress_level])
        }
      end

      def weekly_window
        start_date = Time.zone.today - 6.days
        start_date.beginning_of_day..Time.zone.now.end_of_day
      end
    end
  end
end
