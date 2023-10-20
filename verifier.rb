# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'openssl'
require 'date'
require 'json'

begin
  ca_certificate_path = 'certificate.crt'
  server_url = URI.parse('https://localhost:4567/certificate_expiration')
  ssl_context = OpenSSL::SSL::SSLContext.new
  ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER
  ssl_context.cert_store = OpenSSL::X509::Store.new
  ssl_context.cert_store.add_file(ca_certificate_path)

  http = Net::HTTP.new(server_url.host, server_url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  http.cert_store = ssl_context.cert_store

  response = http.get(server_url.request_uri)

  if response.code.to_i == 200
    parsed_response = JSON.parse(response.body)
    expiration_date = DateTime.parse(parsed_response['expiration_date'])

    if expiration_date > DateTime.now
      puts "Server certificate is valid until: #{expiration_date}"
    else
      puts 'Server certificate has expired.'
    end
  else
    puts "Failed to connect to the server: #{response.code}"
  end
rescue StandardError => e
  puts "An error occurred: #{e.message}"
end

