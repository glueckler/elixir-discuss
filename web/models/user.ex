defmodule Discuss.User do
  use Discuss.Web, :model

  @derive {Poison.Encoder, only: [:email]}

  # look at the users table in our db
  schema "users" do
    field :email, :string
    field :provider, :string
    field :token, :string
    # relation.  user can have many topics
    has_many :topics, Discuss.Topic
    has_many :comments, Discuss.Comment

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :provider, :token])
    |> validate_required([:email, :provider, :token])
  end

end
