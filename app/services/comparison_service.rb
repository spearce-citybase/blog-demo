class ComparisonService
  RUN_EXAMPLES_THIS_MANY_TIMES = 3

  class << self


    def compare_each_and_find_each(batch_size: 100)
        Benchmark.memory do |x|
          x.report('find_each') do
            Post.uncached do
              Post.find_each(batch_size: batch_size) { |p| p.to_json }
            end
          end
          x.report('each') do
            Post.uncached do
              Post.all.each { |p| p.to_json }
            end
          end
          x.compare! memory: :allocated
          x.compare! memory: :retained
        end
    end

    def compare_create_and_insert_all
      Benchmark.memory do |x|
        x.report('insert_all') do
          RUN_EXAMPLES_THIS_MANY_TIMES.times do
            SeedService.seed_profiles
          end
        end
        x.report('create') do
          RUN_EXAMPLES_THIS_MANY_TIMES.times do
            SeedService.seed_profiles_slow
          end
        end
        x.compare! memory: :allocated
        x.compare! memory: :retained
      end
    end

    def compare_select_and_pluck
      Benchmark.memory do |x|
        x.report('select') do
          Post.uncached do
            Post.select(:title).map(&:title).to_json
          end
        end
        x.report('pluck') do
          Post.uncached do
            Post.pluck(:title).to_json
          end
        end
        x.compare!
      end
    end
  end
end
