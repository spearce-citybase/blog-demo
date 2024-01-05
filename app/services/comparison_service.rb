class ComparisonService
  class << self
    def compare_each_and_find_each(batch_size: 1000)
      Benchmark.memory do |x|
        x.report('find_each') do
          3.times do
            Post.find_each(batch_size: batch_size) { |p| p.title }
          end
        end
        x.report('each') do
          3.times do
            Post.all.each { |p| p.title }
          end
        end
        x.compare! memory: :retained
      end
    end

    def compare_create_and_insert_all
      Benchmark.memory do |x|
        x.report('insert_all') do
          3.times do
            SeedService.seed_profiles
          end
        end
        x.report('create') do
          3.times do
            SeedService.seed_profiles_slow
          end
        end
        x.compare! memory: :allocated
      end
    end
  end
end
