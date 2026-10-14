namespace :journal do
  desc "Envia histórico do diário ao GitHub: journal:github_sync[user_id]"
  task :github_sync, [:user_id] => :environment do |_, args|
    abort "Informe usuário: journal:github_sync[user_id]" unless args[:user_id].to_s.match?(/\A[1-9]\d*\z/)

    user = User.find(args[:user_id])
    failures = 0
    user.health_journal_entries.find_each do |entry|
      result = Health::JournalGithubSync.new(entry).call
      puts "#{entry.entry_date.iso8601}: #{result.message}"
      failures += 1 unless result.success
      sleep 1
    end
    abort "#{failures} registro(s) com envio pendente. Execute novamente para retomar." if failures.positive?
  end
end
