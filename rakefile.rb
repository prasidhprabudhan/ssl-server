# frozen_string_literal: true

desc 'Test the code'
task :test do
  `ruby generator.rb`

  unless File.exist?('certificate.crt') && File.exist?('key.key')
    puts 'Error: Certificate files not generated.'
    exit(1)
  end

  server_pid = spawn('ruby web_server.rb')
  sleep 2

  response = `ruby verifier.rb`
  separator = '-' * 80
  puts separator
  puts response
  puts separator

  Process.kill('INT', server_pid)
end
