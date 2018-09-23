defmodule Discuss.CommentsChannel do

  use Discuss.Web, :channel

  # alias Discuss.Topic
  # alias Discuss.Comment
  # the pro way..
  alias Discuss.{Topic, Comment}

  # name is defined.. somewhere..
  # pattern matching strings
  def join("comments:" <> topic_id, _params, socket) do
    # postgres expects a number not a string
    topic_id = String.to_integer(topic_id)

    # use preload to retrieve records that are associated with another
    # this topic struct will have the comments embeded insed of it
    topic = Topic
      |> Repo.get(topic_id)
      # this says load all comments related to topic
      # then withen comments (nested) get all user associations
      |> Repo.preload(comments: [:user])

    # assign the topic to the socket object, so we can reference it in handle_in
    socket = assign(socket, :topic, topic)

    # comments has a lot of bullshit that comes with it like created_at and other stuff
    # we only want the content at this point
    # see the model for how we set up poison
    {:ok, %{comments: topic.comments}, socket}
  end

  def handle_in(name, %{"content" => content}, socket) do
    topic = socket.assigns.topic
    user_id = socket.assigns.user_id
    changeset =
      topic
      # build assoc can only be used to build one association
      # in this case we need to add a comments relation and a user relation
      |> build_assoc(:comments, user_id: user_id)
      |> Comment.changeset(%{content: content})


      case Repo.insert(changeset) do
        {:ok, comment} ->
          # use broadcast to update everyone on the channel
          # use the ! to handle errors
          broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", %{comment: comment})
          {:reply, :ok, socket}
        {:error, _reason} ->
          {:reply, {:error, %{errors: changeset}}, socket}
      end
  end

end
