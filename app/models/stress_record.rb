class StressRecord < ApplicationRecord
  STRESS_LEVELS = %w[Low Medium High].freeze

  belongs_to :user

  validates :user, presence: true
  validates :mood, :stress_feeling, :physical_fatigue, :sleep_quality,
            inclusion: { in: 1..5 }
  validates :heart_rate, :caffeine_intake, :stress_score,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sleep_hours, :screen_time,
            numericality: { greater_than_or_equal_to: 0 }
  validates :stress_level, presence: true, inclusion: { in: STRESS_LEVELS }
end
