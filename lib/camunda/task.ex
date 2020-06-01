defmodule Camunda.Task do
  @moduledoc ~S"""
  Module for working with tasks in Camunda
  """

  @list "/task"
  @claim "/task/{id}/claim"
  @get "/task/{id}"
  @submit "/task/{id}/submit-form"

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
  def load_variables(task, username, password, options \\ [params: %{deserializeValues: false}])

  def load_variables(task, username, password, options) when (is_map(task)) do
    with {:ok, variables} <- Camunda.Task.Variables.list(task, username, password, options) do
      {:ok, Map.put(task, "variables", variables)}
    else
      result -> result
    end
  end

  def load_variables(tasks, username, password, options) when (is_list(tasks)) do
    Enum.map(
      tasks,
      fn x ->
        with {:ok, v} <- Camunda.Task.load_variables(x, username, password) do
          v
        else
          _ -> x
        end
      end
    )
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

  @doc ~S"""
  Returns task by id (this function returns task map only, it's not load variables
  or something else)

  ## Examples

    iex> Nbd.CamundaApi.Task.get(123, "demo", "demo")
    {:error, %{data: String.t()}}

  """
  def get_by_id(task_id, username, password, options \\ [])

  def get_by_id(task_id, username, password, options) do
    with req_headers <- ApiInstance.get_basic_header(username, password),
         req_url <- String.replace(@get, "{id}", task_id),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(req_url, req_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.Task.get_by_id/3"}
    end
  end

  @doc """
  Submit task by route by task id
  """
  def submit(task, username, password, body \\ %{}, options \\ [])

  def submit(%{"id" => task_id} = _task, username, password, body, options) do
    with req_headers <- ApiInstance.get_basic_header(username, password),
         req_url <- String.replace(@submit, "{id}", task_id),
         {:ok, req_body} <- Jason.encode(body),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(req_url, req_body, req_headers, options),
         {:no_content, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.Task.get_by_id/3"}
    end
  end
end
