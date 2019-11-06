require 'bump'

def bot_username
  ENV.fetch('BOT_USERNAME', 'kite-bot')
end

def repository_slug
  ENV.fetch('REPOSITORY_SLUG', 'openware/peatio')
end

namespace 'release' do

  desc 'Bump the version of the application'
  task :travis do
    unless ENV['TRAVIS_BRANCH'] == 'master' || ENV['TRAVIS_BRANCH'].match?(/^[0-9]+-[0-9]+-stable$/)
      Kernel.abort 'Bumping version aborted: GitHub pull request detected.'
    end

    if ENV['TRAVIS_PULL_REQUEST'] != 'false'
      Kernel.abort 'Bumping version aborted: GitHub pull request detected.'
    end

    unless ENV['TRAVIS_TAG'].to_s.empty?
      Kernel.abort 'Bumping version aborted: the build has been triggered by Git tag.'
    end

    sh %(git config --global user.name 'OpenWare')
    sh %(git config --global user.email 'support@openware.com')
    sh %(git remote add authenticated-origin https://#{bot_username}:#{ENV.fetch('GITHUB_API_KEY')}@github.com/#{repository_slug})
    next_version = Bump::Bump.next_version('patch')
    sh %(V='#{next_version}' bin/gendocs)
    sh %(git add -A)
    Bump::Bump.run('patch', commit_message: '[skip ci]', tag: false)
    sh %(git tag #{Bump::Bump.current})
    sh %(git push --tags authenticated-origin HEAD:#{ENV.fetch('TRAVIS_BRANCH')})
  end
end
