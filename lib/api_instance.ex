defmodule ApiInstance do
  @moduledoc ~S"""
  Instance of HTTPoison for camunda
  """

  use HTTPoison.Base

  @doc ~S"""
  Returns basic hostname for request url
  """
  def process_request_url(url), do: get_hostname() <> url

  @doc ~S"""
  Handle when request body is nil
  """
  def process_response_body(nil), do: %{}

  def process_response_body(""), do: %{}

  def process_response_body(body) do
    with {:ok, body} <- Jason.decode(body) do
      body
    else
      _ -> %{}
    end
  end

  @doc ~S"""
  Returns basic header for camunda application
  """
  def get_basic_header(username, password, headers \\ []),
      do: [
            {"Authorization", "Basic #{Base.encode64("#{username}:#{password}")}"},
            {"Content-type", "application/json"}
          ] ++ headers

  @doc """
  Returns clean request result
  """
  def get_request_result(%HTTPoison.Response{status_code: status_code, body: body}), do:
    {Plug.Conn.Status.reason_atom(status_code), body}

  # Returns hostname of camunda api
  defp get_hostname, do: Keyword.get(Application.get_env(:camunda, :camunda), :hostname, nil)
end
