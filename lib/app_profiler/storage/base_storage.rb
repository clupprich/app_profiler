# frozen_string_literal: true

module AppProfiler
  module Storage
    class BaseStorage
      # class_attribute :bucket_name, default: 'profiles'
      def self.bucket_name
        @bucket_name
      end

      def self.bucket_name=(value)
        @bucket_name = value
      end

      self.bucket_name = 'profiles'

      # class_attribute :credentials, default: {}
      def self.credentials
        @credentials
      end

      def self.credentials=(value)
        @credentials = value
      end

      self.credentials = {}

      def self.upload(_profile)
        raise NotImplementedError
      end
    end
  end
end
