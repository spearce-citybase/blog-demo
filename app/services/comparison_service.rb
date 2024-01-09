class ComparisonService
  RUN_EXAMPLES_THIS_MANY_TIMES = 3

  class << self


    def compare_each_and_find_each(limit: 10_000)
      Rails.logger.silence do

        Benchmark.memory do |x|
          x.report('each') do
            Post.limit(limit).each { |p| p.inspect }
            GC.start
          end
          x.report('find_each') do
            Post.limit(limit).find_each { |p| p.inspect }
            GC.start
          end
          
          x.compare!
        end
      end
    end

    def compare_create_and_insert_all(num: 10_000)
      Rails.logger.silence do
        attributes = SeedService.post_attributes(num: num)

        Benchmark.memory do |x|
          x.report('insert_all') do
            Post.insert_all attributes
            GC.start
          end
          x.report('create') do
            Post.create attributes
            GC.start
          end

          x.compare!
        end
      end
    end
  end
end
