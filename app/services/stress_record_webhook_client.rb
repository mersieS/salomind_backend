require "net/http"
require "json"

class StressRecordWebhookClient
  WEBHOOK_URI = URI.parse("http://localhost:5678/webhook/027b4f52-2223-4200-a6bc-98113a8c94f5").freeze

  def self.call(payload)
    request = Net::HTTP::Post.new(WEBHOOK_URI, "Content-Type" => "application/json")
    request.body = payload.to_json

    response = Net::HTTP.start(
      WEBHOOK_URI.host,
      WEBHOOK_URI.port,
      open_timeout: 20,
      read_timeout: 20
    ) do |http|
      http.request(request)
    end

    parse_response(response)
  rescue StandardError => e
    Rails.logger.error("Sync webhook call failed: #{e.message}")
    nil
  end

  def self.parse_response(response)
    return nil unless response.is_a?(Net::HTTPSuccess)
    body = response.body.to_s.strip
    return nil if body.blank?
    json = JSON.parse(body) rescue nil
    json.is_a?(Hash) ? json["message"] || body : body
  end
end
