module Health
  class DataGithubConfiguration < Writing::GithubConfiguration
    DEFAULT_REPOSITORY = "carlosmurilodn/peso-e-alimentacao".freeze

    def initialize(environment = ENV)
      super(
        "GITHUB_WRITING_TOKEN" => environment["GITHUB_HEALTH_DATA_TOKEN"].presence || environment["GITHUB_WRITING_TOKEN"],
        "GITHUB_WRITING_REPOSITORY" => environment["GITHUB_HEALTH_DATA_REPOSITORY"].presence || DEFAULT_REPOSITORY,
        "GITHUB_WRITING_BRANCH" => environment["GITHUB_HEALTH_DATA_BRANCH"].presence || "main"
      )
    end

    def error_message
      super&.gsub("GITHUB_WRITING_", "GITHUB_HEALTH_DATA_")
    end
  end
end
