module Health
  class JournalGithubConfiguration < Writing::GithubConfiguration
    DEFAULT_REPOSITORY = "carlosmurilodn/acompanhamento-diario".freeze

    def initialize(environment = ENV)
      super(
        "GITHUB_WRITING_TOKEN" => environment["GITHUB_JOURNAL_TOKEN"].presence || environment["GITHUB_WRITING_TOKEN"],
        "GITHUB_WRITING_REPOSITORY" => environment["GITHUB_JOURNAL_REPOSITORY"].presence || DEFAULT_REPOSITORY,
        "GITHUB_WRITING_BRANCH" => environment["GITHUB_JOURNAL_BRANCH"].presence || "main"
      )
    end

    def error_message
      super&.gsub("GITHUB_WRITING_", "GITHUB_JOURNAL_")
    end
  end
end
