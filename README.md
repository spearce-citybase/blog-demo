# Setup

```
asdf plugin-update ruby
asdf install
bundle
rails db:create
rails db:migrate
rake seed
rails server
```

OR via docker:

```
docker-compose up
docker-compose exec app rake seed
```

# Usage

## List posts

`curl "http://localhost:3000/posts"`

## List posts with preloads

`curl "http://localhost:3000/posts?preload=1"`

## List posts with fast serializer

`curl "http://localhost:3000/posts?fast_serializer=1"`

# ActiveRecord Performance Optimization

## create vs insert_all

`insert_all` will perform a single `INSERT`, whereas `create` will perform multiple `INSERT`s.

```
Post.insert_all(posts_attributes)

INSERT INTO "posts" ("profile_id","title","body","created_at","updated_at") VALUES ....
```

Note: `insert_all` does not run ActiveRecord callbacks.


```
Post.create(posts_attributes)

Profile Load (0.0ms)  SELECT "profiles".* FROM "profiles" WHERE "profiles"."id" = ? LIMIT ?  [["id", 252135], ["LIMIT", 1]]
Post Create (0.2ms)  INSERT INTO "posts" ("title", "body", "profile_id", "created_at", "updated_at") VALUES ...
  (0.3ms)  commit transaction
  (0.2ms)  begin transaction
Profile Load (0.0ms)  SELECT "profiles".* FROM "profiles" WHERE "profiles"."id" = ? LIMIT ?  [["id", 259212], ["LIMIT", 1]]
Post Create (0.1ms)  INSERT INTO "posts" ("title", "body", "profile_id", "created_at", "updated_at") VALUES ...
  (0.2ms)  commit transaction
  (0.0ms)  begin transaction
Profile Load (0.0ms)  SELECT "profiles".* FROM "profiles" WHERE "profiles"."id" = ? LIMIT ?  [["id", 251127], ["LIMIT", 1]]
Post Create (0.1ms)  INSERT INTO "posts" ("title", "body", "profile_id", "created_at", "updated_at") VALUES ...
   (0.2ms)  commit transaction
...
```

## each vs find_each

`find_each` will load `batch_size` records into memory, yield the block, and then garbage collect.

```
Post.find_each(batch_size: 1000) { |post| do_something_with_post }
```

Note: `find_each` cannot be ordered.

`each`, however, will load all records into memory, leaving a large amount of memory retained.

```
Post.all.each { |post| do_something_with_post }
```

## Preloading

Preload an association with `includes` to avoid n+1 queries.

```
Post.limit(10).includes(:comments).map { |post| { title: post.title, comments: post.comments } }

Post Load (0.4ms)  SELECT "posts".* FROM "posts" LIMIT ?  [["LIMIT", 10]]
Comment Load (1.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN ....
```

```
Post.limit(10).map { |post| { title: post.title, comments: post.comments } }

Post Load (0.1ms)  SELECT "posts".* FROM "posts" LIMIT ?  [["LIMIT", 10]]
Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" = ? LIMIT ? 
Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" = ? LIMIT ?
Comment Load (0.0ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" = ? LIMIT ?
...
```

### What preloading method to use?

* `preload` will load the association in a separate query.
```
irb(main):012> Post.limit(10).preload(:profile)
  Post Load (0.1ms)  SELECT "posts".* FROM "posts" /* loading for pp */ LIMIT ?  [["LIMIT", 10]]
  Profile Load (0.1ms)  SELECT "profiles".* FROM "profiles" WHERE "profiles"."id" IN (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)  [["id", 393511], ["id", 393174], ["id", 393515], ["id", 393248], ["id", 393988], ["id", 393164], ["id", 393688], ["id", 393695], ["id", 393910], ["id", 393239]]
```
* `eager_load` will load the association in the same query.
```
irb(main):011> Post.limit(10).eager_load(:profile)
  SQL (0.1ms)  SELECT "posts"."id" AS t0_r0, "posts"."title" AS t0_r1, "posts"."body" AS t0_r2, "posts"."profile_id" AS t0_r3, "posts"."created_at" AS t0_r4, "posts"."updated_at" AS t0_r5, "profiles"."id" AS t1_r0, "profiles"."name" AS t1_r1, "profiles"."created_at" AS t1_r2, "profiles"."updated_at" AS t1_r3, "profiles"."admin" AS t1_r4 FROM "posts" LEFT OUTER JOIN "profiles" ON "profiles"."id" = "posts"."profile_id" /* loading for pp */ LIMIT ?  [["LIMIT", 10]]
```
* `includes` will smartly decide on which of the above two approaches to use, based on the nature of the query.
```
irb(main):022> Post.limit(10).includes(:profile)
  Post Load (0.1ms)  SELECT "posts".* FROM "posts" /* loading for pp */ LIMIT ?  [["LIMIT", 10]]
  Profile Load (0.1ms)  SELECT "profiles".* FROM "profiles" WHERE "profiles"."id" IN (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)  [["id", 393511], ["id", 393174], ["id", 393515], ["id", 393248], ["id", 393988], ["id", 393164], ["id", 393688], ["id", 393695], ["id", 393910], ["id", 393239]]
```
```
irb(main):021> Post.limit(10).includes(:profile).where(profiles: { name: "Steve Pearce" })
  SQL (0.2ms)  SELECT "posts"."id" AS t0_r0, "posts"."title" AS t0_r1, "posts"."body" AS t0_r2, "posts"."profile_id" AS t0_r3, "posts"."created_at" AS t0_r4, "posts"."updated_at" AS t0_r5, "profiles"."id" AS t1_r0, "profiles"."name" AS t1_r1, "profiles"."created_at" AS t1_r2, "profiles"."updated_at" AS t1_r3, "profiles"."admin" AS t1_r4 FROM "posts" LEFT OUTER JOIN "profiles" ON "profiles"."id" = "posts"."profile_id" WHERE "profiles"."name" = ? /* loading for pp */ LIMIT ?  [["name", "Steve Pearce"], ["LIMIT", 10]]
```

So: prefer `includes` over `preload` or `eager_load`.

### Filtering preloaded relations

Chaining a scope on the preloaded relation will drop the preloaded data. So its best to do array manipulation.

```
Post.limit(10).includes(:comments).map { |post| { title: post.title, comments: post.comments.select(&:flag?) } }

Post Load (0.1ms)  SELECT "posts".* FROM "posts" LIMIT ?  [["LIMIT", 10]]
Comment Load (0.4ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN ....
```

```
Post.limit(10).includes(:comments).map { |post| { title: post.title, comments: post.comments.where(flag: true) } }

Post Load (0.5ms)  SELECT "posts".* FROM "posts" LIMIT ?  [["LIMIT", 10]]
Comment Load (1.6ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN ...
Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" = ? AND "comments"."flag" = ? LIMIT ? 
Comment Load (0.0ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" = ? AND "comments"."flag" = ? LIMIT ?
Comment Load (0.0ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" = ? AND "comments"."flag" = ? LIMIT ?
....
```

Alternatively, you can add a `has_many` that contains the condition and preload that:
```
has_many :flagged_comments, -> { where(flag: true) }, class_name: Comment.name

...

Post.limit(10).includes(:flagged_comments).map { |post| { title: post.title, comments: post.flagged_comments } }

Post Load (0.1ms)  SELECT "posts".* FROM "posts" LIMIT ?  [["LIMIT", 10]]
Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."flag" = ? AND "comments"."post_id" IN ...
```

If you don't know whether a relation is preloaded and need to filter it, you can check `loaded?`:
```
post.comments.loaded? ? post.comments.select(&:flag?) : post.comments.where(flag: true)
```

## select vs pluck

`select` initializes ActiveRecord objects, leading to a large memory allocation. `pluck` just returns an array of values.

```
Post.all.select(:title)

#<ActiveRecord::Relation [#<Post id: nil, title: "Qui autem nulla itaque libero earum.">, #<Post id: nil, title: "Odio enim doloribus qui magni.">,...
```

The benefit of `select` is that it returns a ActiveRecordRelation, so you can continue chaining scopes.

```
Post.all.pluck(:title)

["Qui autem nulla itaque libero earum.", "Odio enim doloribus qui magni.", ....
```

`pluck` returns an Array, not an ActiveRecordRelation.

## count vs size vs length

* `count` will make SQL COUNT query.
* `length` will convert the ActiveRecordRelation to an Array and call `Array#length`.
* `size` will check whether the ActiveRecordRelation is loaded. It will do `count` if it isn't, and `length` if it is.

If your ActiveRecordRelation hasn't been loaded, use `count`. If it has (e.g. if its a preloaded association), use `length`.
If you don't want to worry about this, use `size`, as it will always do the right thing.