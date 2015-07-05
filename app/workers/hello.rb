class Hello
  @queue = :resque_sample # Woeker起動時に指定するQUEUE名

  def self.perform()
    logger = Logger.new(File.join(Rails.root, 'log', 'resque.log'))
    logger.info "Hello"
  end
end