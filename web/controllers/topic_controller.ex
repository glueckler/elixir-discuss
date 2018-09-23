defmodule Discuss.TopicController do
  # for access to a bunch, like Repo
  use Discuss.Web, :controller

  # for access to Topic
  alias Discuss.Topic

  # adding this will run plug before any function in module
  # plug Discuss.Plugs.RequireAuth
  # add guard clause to adjust for only necessary functions
  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  # use check topic owner to verify certain actions
  # this will prevent anyone from making requests outside of the browser
  # by passign an atom, controller will look at TopicContoller (itself)
  # and call the function before edit, update... etc
  plug :check_topic_owner when action in [:edit, :update, :delete]



  def index(conn, _params) do
    IO.inspect(conn.assigns) # keep in mind that this is conn.assign when writing
    topics = Repo.all(Topic)
    render conn, "index.html", topics: topics
  end

  def show(conn, %{"id" => topic_id}) do
    topic = Repo.get!(Topic, topic_id)
    render conn, "show.html", topic: topic
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
    # no longer relevant since we now have an association btween users and topics
    # changeset = Topic.changeset(%Topic{}, topic)

    # get current user struct so that we can build association with topic
    changeset = conn.assigns.user # starts as %{}User
      |> build_assoc(:topics) # becomes like %{}Topic
      |> Topic.changeset(topic)


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

  # note that params is coming from the conn object not params like when forms are submitted
  # this is how function plugs do
  def check_topic_owner(%{params: %{"id" => topic_id}} = conn, _params) do
    topic = Repo.get(Topic, topic_id)
    if topic && topic.user_id == conn.assigns.user.id do
      conn
    else
      conn
        |> put_flash(:error, "you can't do that, homie")
        |> redirect(to: topic_path(conn, :index))
        |> halt()
    end

  end
end
