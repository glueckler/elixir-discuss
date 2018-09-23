defmodule Discuss.Comment do

  use Discuss.Web, :model

  # comments has a lot of bullshit that comes with it like created_at and other stuff
  # we only want the content at this point
  @derive {Poison.Encoder, only: [:content, :user]}

  schema "comments" do
    field :content, :string
    belongs_to :user, Discuss.User
    belongs_to :topic, Discuss.Topic # make sure to also add the has_many relation in Topic model

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content])
    |> validate_required([:content])
  end

end
