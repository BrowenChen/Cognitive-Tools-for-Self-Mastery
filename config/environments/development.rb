Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  Paperclip.options[:command_path] = 'usr/local/bin/'
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  #
  #
  # Custom Falk's global variables
  config.deadline = DateTime.parse('June 19th 2016 11:59:59 PM')
  config.deadline = 3.hours.from_now
  config.time_step_in_min = 8
  config.total_time = 7*24*60/Rails.application.config.time_step_in_min
  config.bonus = 20
  #config.nr_activities = Activity.where(user_id: 1).count() + 1  
  #config.constant_point_value = 100 * Rails.application.config.bonus / Rails.application.config.nr_activities
  config.admin_id = 1    

end
