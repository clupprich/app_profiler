# frozen_string_literal: true

require "active_support"
require "logger"
require "app_profiler/version"
require "app_profiler/railtie" if defined?(Rails::Railtie)

module AppProfiler
  class ConfigurationError < StandardError
  end

  module Storage
    autoload :BaseStorage, "app_profiler/storage/base_storage"
    autoload :FileStorage, "app_profiler/storage/file_storage"
    autoload :GoogleCloudStorage, "app_profiler/storage/google_cloud_storage"
  end

  module Viewer
    autoload :BaseViewer, "app_profiler/viewer/base_viewer"
    autoload :SpeedscopeViewer, "app_profiler/viewer/speedscope_viewer"
  end

  autoload :Middleware, "app_profiler/middleware"
  autoload :RequestParameters, "app_profiler/request_parameters"
  autoload :Profiler, "app_profiler/profiler"
  autoload :Profile, "app_profiler/profile"

  # mattr_accessor :logger, default: ::Logger.new($stdout)
  def self.logger
    @@logger
  end

  def logger
    self.class.logger
  end

  def self.logger=(value)
    @@logger = value
  end

  def logger=(value)
    self.class.logger = value
  end

  self.logger = ::Logger.new($stdout)

  # mattr_accessor :root
  def self.root
    @@root
  end

  def root
    self.class.root
  end

  def self.root=(value)
    @@root = value
  end

  def root=(value)
    self.root = value
  end

  # mattr_accessor :profile_root
  def self.profile_root
    @@profile_root
  end

  def profile_root
    self.class.profile_root
  end

  def self.profile_root=(value)
    @@profile_root = value
  end

  def profile_root=(value)
    self.class.profile_root = value
  end

  # mattr_accessor :speedscope_host, default: "https://speedscope.app"
  def self.speedscope_host
    @@speedscope_host
  end

  def speedscope_host
    self.class.speedscope_host
  end

  def self.speedscope_host=(value)
    @@speedscope_host = value
  end

  def speedscope_host=(value)
    self.class.speedscope_host = value
  end

  self.speedscope_host = "https://speedscope.app"

  # mattr_accessor :autoredirect, default: false
  def self.autoredirect
    @@autoredirect
  end

  def autoredirect
    self.class.autoredirect
  end

  def self.autoredirect=(value)
    @@autoredirect = value
  end

  def autoredirect=(value)
    self.class.autoredirect = value
  end

  self.autoredirect = false

  # mattr_reader   :profile_header, default: "X-Profile"
  def self.profile_header
    @@profile_header
  end

  def profile_header
    self.class.profile_header
  end

  def profile_header=(value)
    self.class.profile_header = value
  end

  @@profile_header = "X-Profile"

  # mattr_accessor :context, default: nil
  def self.context
    @@context
  end

  def context
    self.class.context
  end

  def self.context=(value)
    @@context = value
  end

  def context=(value)
    self.class.context = value
  end

  self.context = nil

  # mattr_reader   :profile_url_formatter, default: nil
  def self.profile_url_formatter
    @@profile_url_formatter
  end

  def profile_url_formatter
    self.class.profile_url_formatter
  end

  def self.profile_url_formatter=(value)
    @@profile_url_formatter = value
  end

  self.profile_url_formatter = nil

  # mattr_accessor :storage, default: Storage::FileStorage
  def self.storage
    @storage
  end

  def storage
    self.class.storage
  end

  def self.storage=(value)
    @storage = value
  end

  def storage=(value)
    self.class.storage = value
  end

  self.storage = Storage::FileStorage

  # mattr_accessor :viewer, default: Viewer::SpeedscopeViewer
  def self.viewer
    @viewer
  end

  def viewer
    self.class.viewer
  end

  def self.viewer=(value)
    @viewer = value
  end

  def viewer=(value)
    self.class.viewer = value
  end

  self.viewer = Viewer::SpeedscopeViewer

  # mattr_accessor :middleware, default: Middleware
  def self.middleware
    @middleware
  end

  def middleware
    self.class.middleware
  end

  def self.middleware=(value)
    @middleware = value
  end

  def middleware=(value)
    self.class.middleware = value
  end

  self.middleware = Middleware

  class << self
    def run(*args, &block)
      Profiler.run(*args, &block)
    end

    def start(*args)
      Profiler.start(*args)
    end

    def stop
      Profiler.stop
      Profiler.results
    end

    def profile_header=(profile_header)
      @@profile_header = profile_header # rubocop:disable Style/ClassVars
      @@request_profile_header = nil    # rubocop:disable Style/ClassVars
      @@profile_data_header = nil       # rubocop:disable Style/ClassVars
    end

    def request_profile_header
      @@request_profile_header ||= begin # rubocop:disable Style/ClassVars
        profile_header.upcase.gsub("-", "_").prepend("HTTP_")
      end
    end

    def profile_data_header
      @@profile_data_header ||= profile_header.dup << "-Data" # rubocop:disable Style/ClassVars
    end

    # def profile_url_formatter=(block)
    #   @@profile_url_formatter = block # rubocop:disable Style/ClassVars
    # end
  end
end
