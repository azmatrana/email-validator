require 'uri'

module EmailFinder
  class Email
    include ActiveModel::Model

    attr_accessor :first_name, :last_name, :url

    validates :first_name, :last_name, presence: true
    validates :url, presence: true, format: { with: /\A((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/ , message: "is not valid."}

    MAILBOXLAYER_ACCESS_KEY = "00a48c97265e70215b33e4d6e99cdb22"

    def make_patterns
      # Make patterns in below format
      # ben pratt
      # 1. ben.pratt@8returns.com
      # 2. ben@8returns.com
      # 3. benpratt@8returns.com
      # 4. pratt.ben@8returns.com
      # 5. b.pratt@8returns.com
      # 6. bp@8returns.com
      if self.valid?
        return [
          "#{first_name}.#{last_name}",
          "#{first_name}",
          "#{first_name}#{last_name}",
          "#{last_name}.#{first_name}",
          "#{first_name[0]}.#{last_name}",
          "#{first_name[0]}#{last_name[0]}"
        ]
      else
        return []
      end
    end

    def search
      # call fetch api for each of the pattern
      self.make_patterns.each do |mail|
        email = "#{mail}@#{url}"
        if found = fetch(email)
          return found
        end

        sleep 0.5 # added sleep because apilayer has limitation to call maximum 5 api in 1 seconds.
      end
      return nil
    end

    def fetch(email_address)
      # calling the mailboxlayer api to fetch the email results
      uri = URI.parse("https://apilayer.net/api/check?access_key=#{MAILBOXLAYER_ACCESS_KEY}&email=#{email_address}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Get.new(uri.request_uri)
      result = http.request(req)
      res = ::JSON.parse(result.body)
      return unless res

      if res["format_valid"] == true &&
        res["mx_found"] == true &&
        res["smtp_check"] == true
        return email_address
      else
        return nil
      end
    end
  end
end
