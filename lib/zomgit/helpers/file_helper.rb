module Zomgit
  module Helpers
    module FileHelper
      def relative_path(base, target)
        back = ""

        while target.sub(base, "") == target
          base = base.sub(/\/[^\/]*$/, "")
          back = "../#{back}"
        end

        "#{back}#{target.sub("#{base}/","")}"
      end
    end
  end
end

