# cloned_commit was added in 0.213.0; so we need to patch it in for 0.212.0 with an edit that
# removes the `SharedHelpers.with_git_configured(credentials: credentials) do` wrap

require 'dependabot/file_fetchers'

module Dependabot
  module FileFetchers
    class Base
      def cloned_commit
        return if repo_contents_path.nil? || !File.directory?(File.join(repo_contents_path, ".git"))
        Dir.chdir(repo_contents_path) do
          return SharedHelpers.run_shell_command("git rev-parse HEAD")&.strip
        end
      end
      def commit
        return cloned_commit if cloned_commit
        return source.commit if source.commit
        branch = target_branch || default_branch_for_repo
        @commit ||= client_for_provider.fetch_commit(repo, branch)
      rescue *CLIENT_NOT_FOUND_ERRORS
        raise Dependabot::BranchNotFound, branch
      rescue Octokit::Conflict => e
        raise unless e.message.include?("Repository is empty")
      end
    end
  end
end
