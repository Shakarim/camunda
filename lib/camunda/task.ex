defmodule Camunda.Task do
  @moduledoc ~S"""
  Module for working with tasks in Camunda
  """

  @list "/task"

  @doc ~S"""
  POST request for getting a task list

  ## Params

    username :: String.t()
    password :: String.t()
    body :: Map.t()
    options :: Keyword.t()

  ## Returns

    {:ok, List.t()} | {:error, String.t()} | {Atom.t(), Map.t()}

  ## Examples

    iex> Camunda.Task.list("demo", "demo", %{}, [])
    {:ok, []}

  """
  def list(username, password, body \\ %{}, options \\ [])

  def list(username, password, body, options) when (is_map(body) === true) do
    with {:ok, encoded_body} <- Jason.encode(body),
         request_headers <- ApiInstance.get_basic_header(username, password),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(@list, encoded_body, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, error} -> {status, error}
      result -> {:error, result}
    end
  end

  @doc ~S"""
  Creates "variable" key in task and load variable map into it

  ## Params

    task :: Map.t()
    username :: String.t()
    password :: String.t()
    options :: Keyword.t()

  ## Returns

    {:ok, Map.t()} | {:error, Map.t() | String.t()}

  """
  def load_variables(task, username, password, options \\ [])

  def load_variables(task, username, password, options) do
    with {:ok, variables} <- Camunda.Task.Variables.list(task, username, password, options) do
      {:ok, Map.put(task, "variables", variables)}
    else
      _ -> {:error, variables}
    end
  end

#  def claim(username, password, id, params) do
#    # Starts module
#    CamundaApi.start
#    response = CamundaApi.post!(
#      @claim
#      |> String.replace("{id}", id),
#      Jason.encode!(Map.merge(%{userId: username}, params)),
#      [
#        {"Authorization", "Basic #{Base.encode64("#{username}:#{password}")}"},
#        {"Content-type", "application/json"}
#      ],
#      []
#    )
#
#    CamundaApi.handle_request_result(
#      response,
#      fn (response) ->
#        with body <- Map.get(response, :body, nil),
#             body <- (if body != nil, do: body, else: %{}) do
#          {:ok, body}
#        end
#      end
#    )
#  end
end
