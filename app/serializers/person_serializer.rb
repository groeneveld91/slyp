class PersonSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :display_name, :image, :friendship_id
end
