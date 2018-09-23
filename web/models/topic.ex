defmodule Discuss.Topic do
  use Discuss.Web, :model

  schema "topics" do
    field :title, :string
    # relations. topic has one user
    belongs_to :user, Discuss.User
    # has many comments
    has_many :comments, Discuss.Comment
  end

  def changeset(struct, params \\ %{}) do
   struct
   |> cast(params, [:title])
   |> validate_required([:title])
  end
end

