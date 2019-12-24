class FastActivitySerializer
  include FastJsonapi::ObjectSerializer

  set_type :activity
  attributes :title, :description
end
