defmodule DianWeb.ChatsTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers

  alias Dian.Chats
  alias DianWeb.ChatsResolver

  object :chats_queries do
    connection field :threads, node_type: :thread do
      resolve &ChatsResolver.list_threads/2
    end
  end

  connection(node_type: :thread)

  node object(:thread) do
    field :owner, non_null(:user), resolve: dataloader(Chats)
    field :group, non_null(:group), resolve: dataloader(Chats)
    field :messages, non_null(list_of(:message)), resolve: dataloader(Chats)
    field :posted_at, non_null(:naive_datetime)
  end

  node object(:message) do
    field :sender, non_null(:user), resolve: dataloader(Chats)
    field :content, non_null(list_of(non_null(:message_content)))
    field :sent_at, non_null(:naive_datetime)
  end

  node object(:group) do
    field :gid, non_null(:string)
    field :name, non_null(:string)
  end

  union :message_content do
    types [:text_message_content, :at_message_content, :image_message_content]

    resolve_type fn
      %{"type" => "text"}, _ -> :text_message_content
      %{"type" => "at"}, _ -> :at_message_content
      %{"type" => "image"}, _ -> :image_message_content
      _, _ -> nil
    end
  end

  object :text_message_content do
    field :text, non_null(:string), resolve: ChatsResolver.message_content_data()
  end

  object :at_message_content do
    field :qid, non_null(:string), resolve: ChatsResolver.message_content_data("qid")
    field :name, non_null(:string), resolve: ChatsResolver.message_content_data("name")
  end

  object :image_message_content do
    field :url, non_null(:string), resolve: ChatsResolver.message_content_data("url")
  end
end
