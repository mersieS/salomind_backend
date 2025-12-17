class StressCalculatorService
  LEVEL_THRESHOLDS = {
    low: 0..33,
    medium: 34..66,
    high: 67..100
  }.freeze

  def initialize(inputs)
    @inputs = inputs.transform_keys(&:to_sym)
  end

  def call
    total = total_stress_score.round
    {
      stress_score: total,
      stress_level: stress_level(total),
      normalized_score: self.class.normalized_value(total)
    }
  end

  def self.normalized_value(score)
    normalized = ((score.to_f / 100) * 9) + 1
    normalized = normalized.round
    [[normalized, 1].max, 10].min
  end

  private

  attr_reader :inputs

  def total_stress_score
    mental_average * 0.30 +
      physical_average * 0.25 +
      sleep_average * 0.30 +
      habits_average * 0.15
  end

  def stress_level(score)
    return "High" if LEVEL_THRESHOLDS[:high].include?(score.round)
    return "Medium" if LEVEL_THRESHOLDS[:medium].include?(score.round)

    "Low"
  end

  def mental_average
    average(mood_score, stress_feeling_score)
  end

  def physical_average
    average(heart_rate_score, physical_fatigue_score)
  end

  def sleep_average
    average(sleep_hours_score, sleep_quality_score)
  end

  def habits_average
    average(caffeine_score, screen_time_score)
  end

  def average(*values)
    return 0 if values.empty?

    values.sum.to_f / values.size
  end

  def mood_score
    case inputs[:mood].to_i
    when 5 then 0
    when 4 then 20
    when 3 then 40
    when 2 then 70
    else 100
    end
  end

  def stress_feeling_score
    case inputs[:stress_feeling].to_i
    when 1 then 0
    when 2 then 25
    when 3 then 50
    when 4 then 75
    else 100
    end
  end

  def heart_rate_score
    heart_rate = inputs[:heart_rate].to_i
    case heart_rate
    when 0..60 then 0
    when 61..70 then 20
    when 71..80 then 40
    when 81..90 then 70
    else 100
    end
  end

  def physical_fatigue_score
    case inputs[:physical_fatigue].to_i
    when 5 then 0
    when 4 then 20
    when 3 then 50
    when 2 then 75
    else 100
    end
  end

  def sleep_hours_score
    hours = inputs[:sleep_hours].to_f
    case hours
    when 8..Float::INFINITY then 0
    when 7...8 then 20
    when 6...7 then 50
    when 5...6 then 80
    else 100
    end
  end

  def sleep_quality_score
    case inputs[:sleep_quality].to_i
    when 5 then 0
    when 4 then 20
    when 3 then 50
    when 2 then 80
    else 100
    end
  end

  def caffeine_score
    caffeine = inputs[:caffeine_intake].to_i
    case caffeine
    when 0 then 0
    when 1 then 20
    when 2 then 40
    when 3 then 70
    else 100
    end
  end

  def screen_time_score
    screen_time = inputs[:screen_time].to_f
    case screen_time
    when 0..2 then 0
    when 2...4 then 30
    when 4...6 then 60
    else 100
    end
  end
end
