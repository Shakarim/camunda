defmodule Camunda.User do
  @moduledoc :false

  @profile "/user/{id}/profile"

  @doc ~S"""
  Returns user profile by user identity

  ## Examples

    iex> Camunda.User.get_user_profile_by_id("demo", "demo", "demo")

  """
  def get_user_profile_by_id(id, username, password, options \\ []) when (id !== nil) do
    with req_headers <- ApiInstance.get_basic_header(username, password),
         req_url <- String.replace(@profile, "{id}", id),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(req_url, req_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.User.get_user_by_id/4"}
    end
  end
  def get_user_profile_by_id(_, _, _, options \\ []), do: {:not_found, "User id can not be nil"}
end
