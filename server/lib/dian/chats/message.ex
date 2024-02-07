defmodule Dian.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dian.Chats.User

  schema "messages" do
    field :raw_text, :string
    field :content, {:array, :map}
    field :sent_at, :naive_datetime

    belongs_to :sender, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:raw_text, :content, :sent_at, :sender_id])
    |> validate_required([:raw_text, :content, :sent_at])
  end
end
