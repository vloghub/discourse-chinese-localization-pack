# name: Discourse 中文本地化服务集合
# about: 为 Discourse 增加了各种本地化的功能。
# version: 1.0.0
# authors: Erick Guan
# url: https://github.com/fantasticfears/discourse-chinese-localization-pack

enabled_site_setting :zh_l10n_enabled

# load oauth providers
Dir[File.expand_path('../lib/auth/*.rb', __FILE__)].each { |f| require f }
require 'active_support/inflector'
require "ostruct"

# name, frame_width, frame_height, background_color, glyph
PROVIDERS = [
  OpenStruct.new(pretty_name: 'Weibo', frame_width: 920, frame_heigh: 800, background_color: 'rgb(230, 22, 45)', glyph: '\f18a'),
  OpenStruct.new(pretty_name: 'QQ', frame_width: 760, frame_heigh: 500, background_color: '#51b7ec', glyph: '\f1d6'),
  OpenStruct.new(pretty_name: 'Douban', frame_width: 380, frame_heigh: 460, background_color: 'rgb(42, 172, 94)', glyph: '豆'),
  OpenStruct.new(pretty_name: 'Renren', frame_width: 950, frame_heigh: 500, background_color: 'rgb(0, 94, 172)', glyph: '\f18b')
].freeze
PLUGIN_PREFIX = 'zh_l10n_'.freeze
SITE_SETTING_NAME = 'zh_l10n_enabled'.freeze
ONEBOX_SETTING_NAME = 'zh_l10n_http_onebox_override'.freeze

def _prepare_auth_provide_args(struct)
  args = struct.to_h
  name = args[:pretty_name]
  args[:authenticator] = "#{name}Authenticator".constantize.new
  args
end

PROVIDERS.each { |provider| auth_provider _prepare_auth_provide_args(provider) }

Dir[File.expand_path('../lib/onebox_override/*.rb', __FILE__)].each { |f| require f }

after_initialize do
  next unless SiteSetting.zh_l10n_enabled

  Dir[File.expand_path('../lib/onebox/*.rb', __FILE__)].each { |f| require f }

  PROVIDERS.each do |provider|
    provider_name = provider.name.downcase
    enable_setting = "#{PLUGIN_PREFIX}enable_#{provider_name}_logins"
    check = "#{provider_name}_config_check".to_sym

    AdminDashboardData.class_eval do
      define_method(check) do
        if SiteSetting.public_send(enable_setting) && (
            SiteSetting.public_send("#{PLUGIN_PREFIX}#{provider_name}_client_id").blank? ||
            SiteSetting.public_send("#{PLUGIN_PREFIX}#{provider_name}_client_secret").blank?)
          I18n.t("dashboard.#{PLUGIN_PREFIX}#{provider_name}_config_warning")
        end
      end
    end
    AdminDashboardData.add_problem_check check
  end

  DiscourseEvent.on(:site_setting_saved) do |site_setting|
    if site_setting.name == SITE_SETTING_NAME && site_setting.value_changed? && site_setting.value == "f" # false
      PROVIDERS.each { |provider| SiteSetting.public_send("#{PLUGIN_PREFIX}enable_#{provider[0].downcase}_logins=", false) }
    end
  end

  module ::DisableUsernameSuggester
    def to_client_hash
      hash = defined?(super) ? super : nil
      return nil unless hash

      # only catch when a oauth login and a username is random
      if hash[:auth_provider]
        match = (hash[:username] || '').match(/^\d+$/i)

        if SiteSetting.zh_l10n_disable_random_username_sugeestion && match
          hash[:username] = nil

          if SiteSetting.enable_names? && SiteSetting.zh_l10n_disable_random_username_sugeestion && match
            hash[:name] = nil
          end
        end
      end

      hash
    end
  end

  Auth::Result.class_eval do
    prepend ::DisableUsernameSuggester
  end
end
