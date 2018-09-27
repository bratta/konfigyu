# frozen_string_literal: true

# Exception classes are defined here
module Konfigyu
  class FileNotFoundException < RuntimeError; end
  class InvalidConfigException < RuntimeError; end
end
