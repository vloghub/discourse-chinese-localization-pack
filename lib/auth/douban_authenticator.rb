class DoubanAuthenticator < ::Auth::Authenticator
  def name
    'douban'
  end

  def enabled?
    SiteSetting.zh_l10n_enable_douban_logins
  end

  # run once the user has completed authentication on the third party system. Should return an instance of Auth::Result.
  # If the user has requested to connect an existing account then `existing_account` will be set
  def after_authenticate(auth_options, existing_account: nil)
    result = Auth::Result.new

    data = auth_token[:info]
    raw_info = auth_token[:extra][:raw_info]
    name = data[:name]
    username = data[:nickname]
    douban_uid = auth_token[:uid]

    current_info = ::PluginStore.get('douban', "douban_uid_#{douban_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.username = username
    result.extra_data = { douban_uid: douban_uid }

    result
  end

  # can be used to hook in after the authentication process
  #  to ensure records exist for the provider in the db
  #  this MUST be implemented for authenticators that do not
  #  trust email
  def after_create_account(user, auth)
    douban_uid = auth[:extra_data][:douban_uid]
    ::PluginStore.set('douban', "douban_uid_#{douban_uid}", {user_id: user.id})
  end

  # return a string describing the connected account
  #  for a given user (typically email address). Used to list
  #  connected accounts under the user's preferences. Empty string
  #  indicates not connected
  def description_for_user(user)
    ::PluginStore.get('douban', "douban_uid_#{douban_uid}", {user_id: user.id})

    info = FacebookUserInfo.find_by(user_id: user.id)
    info&.email || info&.username || ""
  end

  # can authorisation for this provider be revoked?
  def can_revoke?
    false
  end

  # can exising discourse users connect this provider to their accounts
  def can_connect_existing_user?
    false
  end

  # optionally implement the ability for users to revoke
  #  their link with this authenticator.
  # should ideally contact the third party to fully revoke
  #  permissions. If this fails, return :remote_failed.
  # skip remote if skip_remote == true
  def revoke(user, skip_remote: false)
    raise NotImplementedError
  end

  def register_middleware(omniauth)
    omniauth.provider :douban, :setup => lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = SiteSetting.zh_l10n_douban_client_id
      strategy.options[:client_secret] = SiteSetting.zh_l10n_douban_client_secret
    }
  end
end
