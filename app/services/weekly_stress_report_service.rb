class WeeklyStressReportService
  def initialize(records)
    @records = records
  end

  def call
    return [] if records.empty?

    normalized = normalize_scores
    records.each_with_index.map do |record, index|
      {
        date: record.created_at.to_date.iso8601,
        stress_score: normalized[index],
        stress_level: record.stress_level
      }
    end
  end

  private

  attr_reader :records

  def normalize_scores
    scores = records.map(&:stress_score)
    min_score = scores.min
    max_score = scores.max

    return Array.new(scores.size, default_normalized_value) if min_score == max_score

    scores.map do |score|
      normalized = 1 + ((score - min_score).to_f / (max_score - min_score) * 9)
      [[normalized.round, 1].max, 10].min
    end
  end

  def default_normalized_value
    5
  end
end
