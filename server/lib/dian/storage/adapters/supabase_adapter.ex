defmodule Dian.Storage.Adapters.SupabaseAdapter do
  @behaviour Dian.Storage.Adapter

  use Tesla

  plug Tesla.Middleware.BaseUrl, base_url()
  plug Tesla.Middleware.BearerAuth, token: api_key()
  plug Tesla.Middleware.JSON

  defp config, do: Application.fetch_env!(:dian, Dian.Storage)
  defp base_url, do: config() |> Keyword.fetch!(:base_url)
  defp api_key, do: config() |> Keyword.fetch!(:api_key)
  defp bucket_name, do: config() |> Keyword.fetch!(:bucket_name)

  @impl true
  def get_url(name) do
    "#{base_url()}/storage/v1/object/public/#{bucket_name()}/#{name}"
  end

  @impl true
  def exists?(name) do
    case get("/storage/v1/object/info/public/#{bucket_name()}/#{name}") do
      {:ok, %Tesla.Env{status: 200}} -> true
      _ -> false
    end
  end

  @impl true
  def upload(params) do
    %{"name" => name, "url" => url} = params

    with {:ok, %Tesla.Env{status: 200} = response} <- get(url),
         %Tesla.Env{headers: headers, body: body} = response,
         headers = Enum.find(headers, fn {key, _value} -> key == "content-type" end),
         payload =
           Tesla.Multipart.new() |> Tesla.Multipart.add_file_content(body, name, headers: headers),
         {:ok, %Tesla.Env{status: 200}} <-
           post("/storage/v1/object/#{bucket_name()}/#{name}", payload) do
      {:ok, get_url(name)}
    end
  end
end
