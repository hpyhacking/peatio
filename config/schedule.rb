every 1.hours do
  command '/usr/local/rbenv/shims/backup perform -t database_backup'
end

every :day, at: '4am' do
  rake 'solvency:clean solvency:liability_proof'
end
