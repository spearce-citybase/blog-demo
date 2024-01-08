class SeedService
  NUM_PROFILES = 1_000
  NUM_POSTS = 30_000

  class << self
    def seed_all
      ActiveRecord::Base.logger.silence do
        seed_profiles
        seed_posts
        seed_comments
        seed_tags
      end
      puts "All done!"
    end

    def seed_profiles
      puts "Seeding profiles..."
      Profile.delete_all
      Profile.insert_all profiles_attributes
    end

    def seed_profiles_slow
      Profile.delete_all
      Profile.create profiles_attributes
    end

    def profiles_attributes
      (1..NUM_PROFILES).each_with_object([]) do |_num, array|
        array << {
          name: FFaker::Name.name,
          created_at: now,
          updated_at: now
        }
      end
    end

    def seed_posts
      puts "Seeding posts..."
      Post.delete_all

      attributes = (1..NUM_POSTS).each_with_object([]) do |_num, array|
        array << {
          profile_id: profile_ids.sample,
          title: FFaker::Lorem.sentence,
          body: FFaker::Lorem.paragraph,
          created_at: now,
          updated_at: now
        }
      end

      Post.insert_all attributes
    end

    def seed_comments
      puts "Seeding comments..."
      Comment.delete_all

      attributes = (1..NUM_POSTS * 10).each_with_object([]) do |_num, array|
        array << {
          profile_id: profile_ids.sample,
          post_id: post_ids.sample,
          body: FFaker::Lorem.paragraph,
          flag: rand(10).zero?,
          created_at: now,
          updated_at: now
        }
      end

      Comment.insert_all attributes
    end

    def seed_tags
      puts "Seeding tags..."
      Tag.delete_all

      attributes = (1..NUM_POSTS * 3).each_with_object([]) do |_num, array|
        array << {
          post_id: post_ids.sample,
          value: FFaker::Lorem.word,
          created_at: now,
          updated_at: now
        }
      end

      Tag.insert_all attributes
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
