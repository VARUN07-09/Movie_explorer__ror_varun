FactoryBot.define do
  factory :movie do
    title { "Sample Movie" }
    genre { "Action" }
    release_year { 2022 }
    rating { 8.5 }
  end
end
