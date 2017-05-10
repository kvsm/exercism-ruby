require 'logger'

module Generator
  # Processes the command line arguments and sets everthing up and returns a
  # generator that can be called
  class CommandLine
    def initialize(paths)
      @paths = paths
    end

    def parse(args)
      parser = GeneratorOptparser.new(args, @paths)
      @options = parser.options
      return generators if parser.options_valid?
    end

    private

    def generators
      [generator_class.new(repository(@options[:exercise_name]))]
    end

    def generator_class
      @options[:freeze] ? GenerateTests : UpdateVersionAndGenerateTests
    end

    def repository(exercise_name)
      LoggingRepository.new(
        repository: Repository.new(paths: @paths, exercise_name: exercise_name),
        logger: logger
      )
    end

    def logger
      logger = Logger.new($stdout)
      logger.formatter = proc { |_severity, _datetime, _progname, msg| "#{msg}\n" }
      logger.level = @options[:verbose] ? Logger::DEBUG : Logger::INFO
      logger
    end
  end
end
