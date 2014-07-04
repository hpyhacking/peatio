environments = %w(
  PUSHER_APP
  PUSHER_KEY
  PUSHER_SECRET
)

environments.select! do |key|
  ENV[key] =~ /^YOUR/
end

unless environments.empty?
  puts "====================== WARNING ======================"
  puts "  please check below config in config/application.yml"
  puts ""
  environments.each do |key| puts "  #{key}" end
  puts "====================================================="
  raise "config missing"
end
