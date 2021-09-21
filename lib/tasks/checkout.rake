# frozen_string_literal: true

#
#     $ rake checkout new_branch_name
#
# Via https://gist.github.com/jonlemmon/4076864
#
# 1. Roll back any migrations on your current branch which do not exist on the
#    other branch
# 2. Discard any changes to the db/schema.rb file
# 3. Check out the other branch
# 4. Run any new migrations existing in the other branch
# 5. Update your test database

desc "Switch git branches and apply migrations"
task checkout: [:environment] do
  raise "You cannot run this in production" if Rails.env.production?

  # We can't checkout if we're dirty
  unless `git diff --shortstat`.blank?
    warn "error: Your local changes would be overwritten by checkout."
    warn "Please, commit your changes or stash them before you can switch branches."
    abort "Aborting"
  end

  raise "You must supply a branch name and no other arguments" if ARGV.length != 2

  # Last argument trick
  # Via http://itshouldbeuseful.wordpress.com/2011/11/07/passing-parameters-to-a-rake-task/
  task(ARGV.last {}) # rubocop:disable Lint/EmptyBlock
  branch_name = ARGV.last

  # List migrations
  changes = `git diff #{branch_name} --name-status`.lines
  migrations = changes.map do |change|
    match = %r{^A.*migrate/([0-9]+)}.match(change)
    match ? match[1] : nil
  end.compact

  # Drop it like it's hot
  migrations.sort.reverse_each do |migration|
    # TODO: we're already in rake, we should call these tasks directly
    sh "bundle exec rake db:migrate:down VERSION=#{migration}"
  end

  # Switch
  sh "git checkout db/schema.rb"
  sh "git checkout #{branch_name}"
  sh "bundle exec rake db:migrate"
end
