class SeedService
  class << self
    def seed_all(num_posts: 100_000)
      ActiveRecord::Base.logger.silence do
        seed_profiles(num: num_posts / 100)
        seed_posts(num: num_posts)
        seed_comments(num: num_posts * 3)
      end
      puts "All done!"
    end

    def seed_profiles(num: 1_000)
      puts "Seeding profiles..."
      Profile.delete_all
      Profile.insert_all profiles_attributes(num: num)
    end

    def profiles_attributes(num: 1_000)
      (1..num).each_with_object([]) do |_num, array|
        array << {
          name: FFaker::Name.name,
          created_at: now,
          updated_at: now
        }
      end
    end

    def seed_posts(num: 100_000)
      puts "Seeding posts..."
      Post.delete_all

      post_attributes(num: num).each_slice(10_000) do |attributes|
        Post.insert_all attributes
      end
    end

    def post_attributes(num: 100_000)
      (1..num).each_with_object([]) do |_num, array|
        array << {
          profile_id: profile_ids.sample,
          title: FFaker::Lorem.sentence,
          body: FFaker::Lorem.paragraph,
          created_at: now,
          updated_at: now
        }
      end
    end

    def seed_comments(num: 300_000)
      puts "Seeding comments..."
      Comment.delete_all

      comment_attributes(num: num).each_slice(10_000) do |attributes|
        Comment.insert_all attributes
      end
    end

    def comment_attributes(num: 300_000)
      (1..num).each_with_object([]) do |_num, array|
        array << {
          profile_id: profile_ids.sample,
          post_id: post_ids.sample,
          body: FFaker::Lorem.paragraph,
          flag: rand(10).zero?,
          created_at: now,
          updated_at: now
        }
      end
    end

    def profile_ids
      @profile_ids ||= Profile.pluck(:id)
    end

    def post_ids
      @post_ids ||= Post.pluck(:id)
    end

    def now
      DateTime.now
    end
  end
end
