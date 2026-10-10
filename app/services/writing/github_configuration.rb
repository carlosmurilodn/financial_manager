module Writing
  class GithubConfiguration
    def initialize(environment = ENV)
      @token = environment.fetch("GITHUB_WRITING_TOKEN", "").to_s.strip
      @repository = environment.fetch("GITHUB_WRITING_REPOSITORY", "").to_s.strip
      @branch = environment.fetch("GITHUB_WRITING_BRANCH", "").to_s.strip.presence || "main"
    end

    attr_reader :repository, :branch

    def configured?
      error_message.nil?
    end

    def error_message
      return "Configure GITHUB_WRITING_TOKEN e GITHUB_WRITING_REPOSITORY no ambiente do servidor." if @token.blank? || repository.blank?
      return "GITHUB_WRITING_TOKEN possui formato inválido." if @token.match?(/[[:space:]]/)
      unless repository.match?(%r{\A[A-Za-z0-9][A-Za-z0-9-]{0,38}/[A-Za-z0-9_.-]{1,100}\z}) && !repository.end_with?("/.", "/..")
        return "GITHUB_WRITING_REPOSITORY deve ter formato usuario/repositorio."
      end
      return "GITHUB_WRITING_BRANCH deve conter um nome de branch válido." unless valid_branch?

      nil
    end

    def authorization
      "Bearer #{@token}"
    end

    def inspect
      "#<#{self.class.name} configured=#{configured?} credentials=[FILTERED]>"
    end

    private

    def valid_branch?
      branch.length <= 255 && branch != "@" && !branch.match?(/[\x00-\x20\x7f~^:?*\[\\]/) &&
        !branch.include?("..") && !branch.include?("@{") && !branch.include?("//") &&
        !branch.start_with?("/") && !branch.end_with?("/", ".") &&
        branch.split("/").none? { |part| part.start_with?(".") || part.end_with?(".lock") }
    end
  end
end
