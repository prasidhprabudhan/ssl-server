# frozen_string_literal: true

require 'openssl'

common_name = 'localhost'
valid_days = 365

key = OpenSSL::PKey::RSA.new(2048)

cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 1
cert.subject = OpenSSL::X509::Name.parse("/DC=org/DC=ruby-lang/CN=#{common_name}")
cert.issuer = cert.subject
cert.public_key = key.public_key
cert.not_before = Time.now
cert.not_after = Time.now + valid_days * 24 * 60 * 60
ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate = cert
cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash'))
cert.add_extension(ef.create_extension('basicConstraints', 'CA:FALSE'))
cert.add_extension(ef.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature'))
ext_key_usage = ef.create_extension('extendedKeyUsage', 'serverAuth')
cert.add_extension(ext_key_usage)
cert.sign(key, OpenSSL::Digest::SHA256.new)

File.write('certificate.crt', cert.to_pem)
File.write('key.key', key.to_pem)
