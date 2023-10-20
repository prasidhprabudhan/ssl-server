# frozen_string_literal: true

require 'webrick'
require 'webrick/https'
require 'openssl'
require 'json'

ssl_key_path = 'key.key'
ssl_cert_path = 'certificate.crt'

ssl_options = {
  SSLEnable: true,
  SSLVerifyClient: OpenSSL::SSL::VERIFY_NONE,
  SSLPrivateKey: OpenSSL::PKey::RSA.new(File.read(ssl_key_path)),
  SSLCertificate: OpenSSL::X509::Certificate.new(File.read(ssl_cert_path)),
}

# Create a custom servlet for the REST API
class CertificateExpirationServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(_, response)
    response.status = 200
    response['Content-Type'] = 'application/json'

    ssl_cert_path = 'certificate.crt'
    # Load the server's SSL certificate and get its expiration date
    certificate = File.read(ssl_cert_path)
    cert = OpenSSL::X509::Certificate.new(certificate)
    expiration_date = cert.not_after

    # Respond with the certificate expiration date
    response.body = { expiration_date: expiration_date.to_s }.to_json
  end
end

# Create the server with SSL support
server = WEBrick::HTTPServer.new(
  Port: 4567,
  Logger: WEBrick::Log.new($stdout, WEBrick::Log::DEBUG),
  AccessLog: [],
  SSLEnable: true,
  SSLVerifyClient: OpenSSL::SSL::VERIFY_NONE,
  SSLPrivateKey: ssl_options[:SSLPrivateKey],
  SSLCertificate: ssl_options[:SSLCertificate],
  StartCallback: proc { $stdout.puts 'Server is running' }
)

# Mount the servlet for the REST API
server.mount('/certificate_expiration', CertificateExpirationServlet)

# Trap signals to gracefully shut down the server
trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }

# Start the server
server.start
