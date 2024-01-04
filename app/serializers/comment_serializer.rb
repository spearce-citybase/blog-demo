class CommentSerializer < ActiveModel::Serializer
  attributes :id, :profile, :body
end
