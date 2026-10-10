module McpIntegration
  class UserContext
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def books
      user.writing_books
    end
  end
end
