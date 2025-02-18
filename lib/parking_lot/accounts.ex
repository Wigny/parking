defmodule ParkingLot.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias ParkingLot.Repo
  alias ParkingLot.Accounts.{Session, User}

  @session_validity_in_days 60

  def get_user(email: email, password: password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  def get_user(session: [token: token]) do
    User
    |> join(:left, [user], assoc(user, :sessions))
    |> where([user, session], session.token == ^token)
    |> where([user, token], token.inserted_at > ago(@session_validity_in_days, "day"))
    |> select([user, token], user)
    |> Repo.one()
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_session!(attrs) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert!()
  end

  def delete_sessions(token: token) do
    Session
    |> where(token: ^token)
    |> Repo.delete_all()

    :ok
  end
end
