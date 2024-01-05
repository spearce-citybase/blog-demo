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

2 queries:
```
Post.limit(10).includes(:comments).map { |post| { title: post.title, comments: post.comments } }

Post Load (0.4ms)  SELECT "posts".* FROM "posts" LIMIT ?  [["LIMIT", 10]]
Comment Load (1.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN ....
```

n+1 queries:
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

2 queries:
```
Post.limit(10).includes(:comments).map { |post| { title: post.title, comments: post.comments.where(flag: true) } }
```

n+1 queries:
```
Post.limit(10).includes(:comments).map { |post| { title: post.title, comments: post.comments.where(flag: true) } }
```

