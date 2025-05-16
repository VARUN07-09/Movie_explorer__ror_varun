FactoryBot.define do
  factory :movie do
    sequence(:title) { |n| "Movie #{n}" } # Unique titles: "Movie 1", "Movie 2", etc.
    genre { "Action" }
    release_year { 2023 }
    rating { 7.5 }
    director { "John Doe" }
    duration { 120 }
    streaming_platform { "Netflix" }
    main_lead { "Jane Doe" }
    description { "A sample movie description" }
    premium { false }
  end
end