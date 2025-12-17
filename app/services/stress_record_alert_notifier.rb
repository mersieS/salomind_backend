class StressRecordAlertNotifier
  def self.call(user:, inputs:, calculation:)
    payload = build_payload(user, inputs, calculation)
    StressRecordWebhookJob.perform_later(payload)
    StressRecordWebhookClient.call(payload)
  end

  def self.build_payload(user, inputs, calculation)
    {
      user_id: user.id,
      normalized_stress_score: calculation[:normalized_score],
      stress_level: calculation[:stress_level],
      mood: inputs[:mood],
      stress_feeling: inputs[:stress_feeling],
      heart_rate: inputs[:heart_rate],
      physical_fatigue: inputs[:physical_fatigue],
      sleep_hours: inputs[:sleep_hours],
      sleep_quality: inputs[:sleep_quality],
      caffeine_intake: inputs[:caffeine_intake],
      screen_time: inputs[:screen_time]
    }
  end

  def self.delivery_message(level)
    case level
    when "High"
      "Focus on breathing exercises and guided relaxation techniques."
    when "Medium"
      "Take a few short breaks and try light stretching."
    else
      "Great job—keep reinforcing the habits that keep you balanced."
    end
  end
end
