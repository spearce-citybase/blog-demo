# ActiveRecord Performance Optimization

## create vs insert_all

Fast:

```
Post.insert_all(posts_attributes)
```

Slow:

```
posts_attributes do |post_attributes|
  Post.create(post_attributes)
end
```

Caveat: `insert_all` does not run ActiveRecord callbacks.

## each vs find_each

Low memory usage retained:
```
Post.find_each { |post| do_something_with_post }
```

High memory usage retained:
```
Post.all.each { |post| do_something_with_post }
```

Caveat: `find_each` cannot be ordered.

## Preloading

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



