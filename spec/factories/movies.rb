FactoryBot.define do
  factory :movie do
    title { "Test Movie" }
    genre { "Action" }
    release_year { 2023 }
    rating { 7.5 }
    director { "Test Director" }
    duration { "2h" }
    streaming_platform { "Netflix" }
    main_lead { "Test Actor" }
    description { "A test movie description" }
    premium { false }
  end
end