class QQAuthenticator < ::Auth::ManagedAuthenticator
  def name
    'qq'
  end

  def enabled?
    SiteSetting.zh_l10n_enable_qq_logins
  end

  def match_by_email
    false
  end

  def can_revoke?
    true
  end

  def can_connect_existing_user?
    true
  end

  def register_middleware(omniauth)
    omniauth.provider :qq_connect, :setup => lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = SiteSetting.zh_l10n_qq_client_id
      strategy.options[:client_secret] = SiteSetting.zh_l10n_qq_client_secret
    }
  end
end

