module AuthConfig
  def config
    @@config ||= {}
  end

  def config=(hash)
    @@config = hash
  end
end