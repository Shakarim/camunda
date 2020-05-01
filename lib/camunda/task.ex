defmodule Camunda.Task do
  @moduledoc ~S"""
  Module for working with tasks in Camunda
  """

  @list "/task"
  @claim "/task/{id}/claim"

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
      result -> result
    end
  end

  @doc ~S"""
  Claims task by user `username`

  ## Params

    task :: Map.t()
    username :: String.t()
    password :: String.t()
    body :: Map.t()
    options :: Keyword.t()

  ## Returns

    {Atom.t(), Map.t() | List.t() | String.t()}

  """
  def claim(task, username, password, body \\ %{}, options \\ [])

  def claim(%{"id" => id} = _task, username, password, body, options) do
    with request_body <- Map.merge(%{userId: username}, body),
         {:ok, req_body} <- Jason.encode(request_body),
         req_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- String.replace(@claim, "{id}", id),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(request_url, req_body, req_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response) do
      {:ok, result}
    else
      {status, error} -> {status, error}
      result -> {:error, result}
    end
  end
end
