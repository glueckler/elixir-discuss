defmodule Discuss.TopicController do
  # for access to a bunch, like Repo
  use Discuss.Web, :controller

  # for access to Topic
  alias Discuss.Topic

  def index(conn, _params) do
    IO.inspect(conn.assigns) # keep in mind that this is conn.assign when writing
    topics = Repo.all(Topic)
    render conn, "index.html", topics: topics
  end

  def new(conn, _params) do

    # we will creat a form to enter a new topic
    # we do this by creating an initial changeset
    # generate a default struct
    struct = %Topic{}
    # the params will be empty initially
    # to be honest, i suspect we can pass in nil..
    params = %{}
    changeset = Topic.changeset(struct, params)

    # render the new file inside templates/topic/new.html.eex
    render conn, "new.html", changeset: changeset

  end

  def create(conn, %{"topic" => topic}) do
    changeset = Topic.changeset(%Topic{}, topic)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        # create a flash message for success, this shows in the app.html be default in the container div
        |> put_flash(:info, "Topic Created")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  # id comes from the url
  def edit(conn, %{"id" => topic_id}) do
    # get the topic out of the db via topic id
    topic = Repo.get(Topic, topic_id)
    # create a new change set to be used with the template
    changeset = Topic.changeset(topic)

    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    # old_topic = Repo.get(Topic, topic_id)
    # this changeset will determine how to update the last topic to the next
    # changeset = Topic.changeset(old_topic, topic)
    # remember to refactor
    changeset = Repo.get(Topic, topic_id) |> Topic.changeset(topic)

    # get the topic incase there's an error and we must render the edit.html
    old_topic = Repo.get(Topic, topic_id)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: old_topic
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    # the ! does the same action but reports an error if things go south
    # delete! takes a struct_or_changeset, so first retrieve a struct
    Repo.get!(Topic, topic_id) |> Repo.delete!
    # somehow if there is an error the user will automatically be notified.. what?

    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: topic_path(conn, :index))
  end
end
