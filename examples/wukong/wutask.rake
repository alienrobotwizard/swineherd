equire 'swineherd' ; include Swineherd

WukongTask.new_wukong_task(:wordcount, 'wordcount.rb') do |options|
  options[:inputs] = ['/tmp/raw_text']
  options[:output] = '/tmp/raw_text_wordcount'
end
