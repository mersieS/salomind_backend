class WeeklyStressReportService
  def initialize(records)
    @records = records
  end

  def call
    records.map do |record|
      normalized = StressCalculatorService.normalized_value(record.stress_score)
      {
        date: record.created_at.to_date.iso8601,
        stress_score: normalized,
        normalized_stress_score: normalized,
        raw_stress_score: record.stress_score,
        stress_level: record.stress_level
      }
    end
  end

  private

  attr_reader :records
end
