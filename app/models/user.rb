class User < ApplicationRecord
  has_secure_password

  has_and_belongs_to_many :groups
  has_many :interview_reviews
  belongs_to :auth_config

  def name
    [first_name, last_name].compact.join(' ')
  end

  # Staff = anyone on the recruiting team (admin, manager, or HR). This is the
  # rule behind the check_staff gate in ApplicationController, lifted to the
  # model so views and other helpers can share the same predicate.
  def staff?
    !!(admin? || manager? || hr?)
  end

  def self.fetch_by_auth_name(auth_name)
    where(auth_name: auth_name).first
  end

  def self.all_active
    where(active: true).all
  end

  # ----- API key auth -----
  #
  # The plaintext key is never persisted. We store the HMAC-SHA256 digest of
  # the key (keyed by Rails.application.secret_key_base) in the
  # `api_key_digest` column. Lookup is O(1) via a unique index on the
  # digest. The plaintext is only available to the caller of
  # `regenerate_api_key!` for one method return — they're responsible for
  # showing it to the human ONCE.
  #
  # Why HMAC-SHA256 instead of bcrypt: we need a deterministic digest so we
  # can find the user by digest. bcrypt's salting would force an iterate-
  # every-user lookup. The HMAC secret turns this into a peppered hash —
  # a database leak alone is insufficient to forge tokens; an attacker
  # also needs the secret.

  # Generate a fresh URL-safe random key, persist its digest, and return
  # the plaintext exactly once. Subsequent reads of `api_key_digest`
  # cannot be reversed to the plaintext.
  def regenerate_api_key!
    plaintext = SecureRandom.urlsafe_base64(32)
    update!(api_key_digest: User.encode_api_key(plaintext))
    plaintext
  end

  # Compute the digest a presented key would have. Used by both the model
  # (when storing a fresh key) and the controller (when authenticating).
  def self.encode_api_key(plaintext)
    OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, plaintext.to_s)
  end

  # Look up the user a presented bearer key belongs to, or nil if no user
  # has that key's digest.
  def self.find_by_api_key(plaintext)
    return nil if plaintext.blank?
    find_by(api_key_digest: encode_api_key(plaintext))
  end
end
