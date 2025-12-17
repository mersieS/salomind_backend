# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

SEED_USER_EMAIL = "test@salomind.com"
SEED_USER_PASSWORD = "password"

user = User.find_or_initialize_by(email: SEED_USER_EMAIL)
user.password = SEED_USER_PASSWORD
user.password_confirmation = SEED_USER_PASSWORD
user.save!

start_date = 2.weeks.ago.to_date
(0..13).each do |offset|
  target_date = start_date + offset
  next if user.stress_records.where(created_at: target_date.all_day).exists?

  inputs = {
    mood: rand(1..5),
    stress_feeling: rand(1..5),
    heart_rate: rand(55..100),
    physical_fatigue: rand(1..5),
    sleep_hours: (5..9).to_a.sample + rand.round(1),
    sleep_quality: rand(1..5),
    caffeine_intake: rand(0..4),
    screen_time: rand(1..7) + rand.round(1)
  }

  calculated = StressCalculatorService.new(inputs).call

  user.stress_records.create!(
    inputs.merge(
      stress_score: calculated[:stress_score],
      stress_level: calculated[:stress_level],
      created_at: target_date.beginning_of_day + 9.hours,
      updated_at: target_date.beginning_of_day + 9.hours
    )
  )
end
