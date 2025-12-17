require "net/http"

class StressRecordWebhookJob < ApplicationJob
  queue_as :default

  WEBHOOK_URL = URI.parse("http://localhost:5678/webhook/027b4f52-2223-4200-a6bc-98113a8c94f5").freeze

  def perform(payload)
    request = Net::HTTP::Post.new(WEBHOOK_URL.request_uri, "Content-Type" => "application/json")
    request.body = payload.to_json

    Net::HTTP.start(WEBHOOK_URL.host, WEBHOOK_URL.port) do |http|
      http.request(request)
    end
  rescue StandardError => e
    Rails.logger.error("Webhook delivery failed: #{e.message}")
  end
end
