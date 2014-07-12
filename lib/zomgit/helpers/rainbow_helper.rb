module Zomgit
  module Helpers
    module RainbowHelper
      # Black       0;30     Dark Gray     1;30
      # Blue        0;34     Light Blue    1;34
      # Green       0;32     Light Green   1;32
      # Cyan        0;36     Light Cyan    1;36
      # Red         0;31     Light Red     1;31
      # Purple      0;35     Light Purple  1;35
      # Brown       0;33     Yellow        1;33
      # Light Gray  0;37     White         1;37

      COLOR_CODES = {
        white:         "0",
        black:         "30",
        red:           "31",
        green:         "32",
        yellow:        "33",
        blue:          "34",
        purple:        "35",
        cyan:          "36",
        gray:          "37"
      }

      COLOR_CODE_PREFIX = "\033["
      COLOR_CODE_SUFFIX = "m"

      def paint(message, color = "white", options = {})
        options[:bold] ||= false

        raise ArgumentError, "Invalid color (#{color})" unless COLOR_CODES.has_key?(color.to_sym)
        raise ArgumentError, "Invalid color (white, bold)" if color == "white" && options[:bold]

        modifier = options[:bold] ? "1;" : "0;"

        "#{COLOR_CODE_PREFIX}#{modifier}#{COLOR_CODES[color.to_sym]}#{COLOR_CODE_SUFFIX}#{message}#{COLOR_CODE_PREFIX}#{COLOR_CODES[:white]}#{COLOR_CODE_SUFFIX}"
      end

      COLOR_CODES.keys.each do |color|
        define_method color do |message, options = {}|
          paint message, color, options
        end
      end
    end
  end
end
