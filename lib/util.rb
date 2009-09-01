class Util

  class << self
    def log_info(message)
      DEFAULT_LOGGER.info(message)
    end

    def log_error(message)
      DEFAULT_LOGGER.info(message)
    end
  end

end