require 'ngram'
require 'csv'
require 'nbayes'

class NameClassifier
  def initialize(csv)
    @nbayes_s = NBayes::Base.new
    @nbayes_c = NBayes::Base.new
    @ngram = NGram.new({:size=>3, :padchar=>' '})
    
    reader = CSV.open(csv, "r")
    reader.shift
    reader.each do |row|
      ng = @ngram.parse(row[0].downcase).flatten
      @nbayes_c.train(ng, row[2])

      /(^.*[A-Z]) ([A-Z][a-z].*)/ =~ row[0].gsub(/'/, '')
      if $1 != nil && $2 != nil
        firstname = $2
        ng = @ngram.parse(firstname.downcase).flatten
        @nbayes_s.train(ng, row[1])
      end
    end
    reader.close
  end

  def classify_country(fullname)
    c = @nbayes_c.classify(@ngram.parse(fullname).flatten)
    # sort array by probability then convert to hash
    c_hash = Hash[*c.sort{|a, b| b[1] <=> a[1]}[0..4].flatten]
    c_hash.each { |k, v| c_hash[k] = "%.7f" % v }
  end

  def classify_sex(firstname)
    s = @nbayes_s.classify(@ngram.parse(firstname).flatten)
    s.each { |k, v| s[k] = "%.3f" % v }
  end
end
