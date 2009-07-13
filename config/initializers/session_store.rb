# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cuke_xml_session',
  :secret      => '4969e6e2ea0f8ca13c71af93c84d92bd8ab8233d1216ecb036388c64f96a757f2b2a30dbec93ad110d6d5edca2bff8549810029059bbf3b29ba293d577060e68'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
