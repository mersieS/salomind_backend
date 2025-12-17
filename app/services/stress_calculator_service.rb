class StressCalculatorService
  LEVEL_THRESHOLDS = {
    High: 25,
    Medium: 15
  }.freeze

  def initialize(inputs)
    @inputs = inputs.transform_keys(&:to_sym)
  end

  def call
    {
      stress_score: calculated_score,
      stress_level: stress_level
    }
  end

  private

  attr_reader :inputs

  def calculated_score
    @calculated_score ||= begin
      score = 0
      score += inputs[:mood].to_i * 2
      score += inputs[:stress_feeling].to_i * 2
      score += inputs[:physical_fatigue].to_i * 1.5
      score += (inputs[:heart_rate].to_i / 10.0)
      score += inputs[:caffeine_intake].to_i * 0.4
      score += inputs[:screen_time].to_f * 0.25
      score -= inputs[:sleep_quality].to_i * 1.5
      score -= inputs[:sleep_hours].to_f
      score = score.round
      score.negative? ? 0 : score
    end
  end

  def stress_level
    return "High" if calculated_score >= LEVEL_THRESHOLDS[:High]
    return "Medium" if calculated_score >= LEVEL_THRESHOLDS[:Medium]

    "Low"
  end
end
