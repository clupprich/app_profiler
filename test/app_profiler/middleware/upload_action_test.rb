# frozen_string_literal: true

require "test_helper"

module AppProfiler
  class Middleware
    class UploadActionTest < AppProfiler::TestCase
      setup do
        @profile = Profile.new(stackprof_profile)
        @response = [200, {}, ["OK"]]
      end

      test ".cleanup" do
        Profiler.expects(:results).returns(@profile)
        assert_nothing_raised do
          UploadAction.cleanup
        end
      end

      test ".call uploads successfully when response is not provided" do
        assert_nothing_raised do
          UploadAction.call(@profile)
        end
      end

      test ".call uploads successfully when Profile#upload rescues an error" do
        assert_nothing_raised do
          AppProfiler.storage.stubs(:upload).raises(StandardError, "upload error")
          UploadAction.call(@profile, response: @response)
        end
      end

      test ".call uploads and appends headers with autoredirect" do
        UploadAction.call(@profile, response: @response, autoredirect: true)

        assert_predicate(@response[1][AppProfiler.profile_header], :present?)
        assert_predicate(@response[1][AppProfiler.profile_data_header], :present?)
        assert_predicate(@response[1]["Location"], :present?)
        assert_equal(@response[0], 303)
      end

      test ".call uploads and appends headers without autoredirect" do
        UploadAction.call(@profile, response: @response, autoredirect: false)

        assert_predicate(@response[1][AppProfiler.profile_header], :present?)
        assert_predicate(@response[1][AppProfiler.profile_data_header], :present?)
        assert_predicate(@response[1]["Location"], :blank?)
        assert_equal(@response[0], 200)
      end

      test ".call uploads and appends headers with global autoredirect" do
        with_autoredirect do
          UploadAction.call(@profile, response: @response)
        end

        assert_predicate(@response[1][AppProfiler.profile_header], :present?)
        assert_predicate(@response[1][AppProfiler.profile_data_header], :present?)
        assert_predicate(@response[1]["Location"], :present?)
        assert_equal(@response[0], 303)
      end

      private

      def with_autoredirect
        old_autoredirect = AppProfiler.autoredirect
        AppProfiler.autoredirect = true
        yield
      ensure
        AppProfiler.autoredirect = old_autoredirect
      end
    end
  end
end
