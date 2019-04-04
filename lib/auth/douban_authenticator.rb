class DoubanAuthenticator < ::Auth::ManagedAuthenticator
  def name
    'douban'
  end

  def enabled?
    SiteSetting.zh_l10n_enable_douban_logins
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
    omniauth.provider :douban, :setup => lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = SiteSetting.zh_l10n_douban_client_id
      strategy.options[:client_secret] = SiteSetting.zh_l10n_douban_client_secret
    }
  end
end
