# frozen_string_literal: true

# This is the main module code for the gem
module Konfigyu
  # Does the meat of the work
  class Config
    attr_accessor :config_file, :data, :options

    DEFAULT_FILENAME = 'konfigyu.yml'.freeze
    DEFAULT_EXAMPLE_FILENAME = 'konfigyu.yml.example'.freeze

    # Options Example:
    #
    # options = {
    #   required_fields: [
    #     'top_level', 'top_level.second_level_field',
    #     'log', 'log.level',
    #   ],
    #   required_values: {
    #     'log.level': %w{none fatal error warn info debug},
    #   }
    # }

    def initialize(config_file = nil, options = {})
      self.config_file = config_file.nil? ? File.expand_path("~/#{DEFAULT_FILENAME}") : File.expand_path(config_file)
      if !self.config_file || !File.exist?(self.config_file)
        raise Konfigyu::FileNotFoundException, "Missing configuration file: #{self.config_file}"
      end

      self.data = Sycl.load_file(self.config_file)
      @options = initialize_options(options)
      validate
    end

    def validate
      validate_usage
      validate_required_fields
      validate_required_values
    end

    def [](key)
      data.get(key)
    end

    private

    def validate_usage
      config_usage = "See #{DEFAULT_EXAMPLE_FILENAME} for more information on configuration."
      msg = "Missing configuration data for #{config_file}."
      msg += "\n#{config_usage}" if File.exist?(DEFAULT_EXAMPLE_FILENAME)
      raise Konfigyu::InvalidConfigException, msg unless data
    end

    def validate_required_fields
      errors = []
      (@options[:required_fields] || []).each do |required_field|
        errors.push(required_field) unless deep_key_exists?(required_field)
      end

      msg = "Missing required configuration elements: #{errors.join(', ')}"
      raise Konfigyu::InvalidConfigException, msg if errors.count > 0
    end

    def validate_required_values
      errors = []
      (@options[:required_values] || {}).each_pair do |key, required_value|
        value = data.get(key.to_s)
        next if !options[:required_fields].include?(key) && (value.nil? || value.empty?)

        errors.push(key) unless required_value.include?(value)
      end

      msg = "One or more keys missing required value: #{errors.join(', ')}"
      raise Konfigyu::InvalidConfigException, msg if errors.count > 0
    end

    def default_options
      {
        required_fields: [],
        required_values: {}
      }
    end

    def initialize_options(options = {})
      valid_keys = default_options.keys
      {}.merge(default_options).tap do |sanitized_option|
        unless options.keys.empty?
          options.keys.each do |key|
            sanitized_key = key.downcase.to_sym
            sanitized_option[sanitized_key] = options[key] if valid_keys.include?(sanitized_key)
          end
        end
      end
    end

    def deep_key_exists?(config_key)
      data.get(config_key)
    rescue NoMethodError
      false
    end
  end
end
